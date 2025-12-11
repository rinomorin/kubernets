#!/usr/bin/env python3

import xml.etree.ElementTree as ET
import os
import re
import yaml
import hashlib
from collections import defaultdict

# === CONFIG ===
RESULT_FILE = "/tmp/ipa01-result.xml"
OUTPUT_DIR = "roles/secops/tasks/remediations"
MAP_FILE = "roles/secops/tasks/remediations/remediation_map.yml"

# === Ensure output directory exists ===
os.makedirs(OUTPUT_DIR, exist_ok=True)

# === Hash task list for deduplication ===
def hash_tasks(task_list):
    serialized = yaml.dump(task_list, default_flow_style=False, sort_keys=True)
    return hashlib.sha256(serialized.encode()).hexdigest()

# === Extract and group Ansible fix blocks ===
def extract_ansible_fixes(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    task_groups = {}           # hash → parsed task list
    rule_to_file = {}          # rule_id → filename
    hash_to_ids = defaultdict(list)  # hash → list of rule_ids

    for fix in root.findall(".//{*}fix"):
        system = fix.attrib.get("system", "")
        if system != "urn:xccdf:fix:script:ansible":
            continue

        rule_id = fix.attrib.get("id", "").strip()
        complexity = fix.attrib.get("complexity", "unknown")
        disruption = fix.attrib.get("disruption", "unknown")
        strategy = fix.attrib.get("strategy", "unknown")

        content = fix.text.strip() if fix.text else ""
        if not rule_id or not content:
            continue

        try:
            parsed = yaml.safe_load(content)
            if not isinstance(parsed, list):
                parsed = [parsed]
        except Exception as e:
            print(f"⚠️ Failed to parse YAML for {rule_id}: {e}")
            continue

        # Build tags
        tags = [
            rule_id,
            f"{complexity}_complexity",
            f"{disruption}_disruption",
            "medium_severity",       # default unless parsed elsewhere
            "no_reboot_needed",      # override if reboot logic is added
            f"{strategy}_strategy"
        ]

        # Inject tags into each task
        for task in parsed:
            if isinstance(task, dict):
                task["tags"] = tags

        # Hash and group
        task_hash = hash_tasks(parsed)
        hash_to_ids[task_hash].append(rule_id)
        task_groups[task_hash] = parsed

    # Write unique task files
    for task_hash, rule_ids in hash_to_ids.items():
        filename = f"shared_{rule_ids[0]}.yml"
        path = os.path.join(OUTPUT_DIR, filename)
        with open(path, "w") as f:
            yaml.dump(task_groups[task_hash], f, default_flow_style=False, sort_keys=False)
        print(f"✅ Wrote {filename} for rules: {', '.join(rule_ids)}")

        for rule_id in rule_ids:
            rule_to_file[rule_id] = filename

    # Write dispatcher map
    with open(MAP_FILE, "w") as f:
        yaml.dump(rule_to_file, f, default_flow_style=False, sort_keys=True)
    print(f"📦 Wrote remediation map: {MAP_FILE}")

# === Main ===
def main():
    extract_ansible_fixes(RESULT_FILE)

if __name__ == "__main__":
    main()
