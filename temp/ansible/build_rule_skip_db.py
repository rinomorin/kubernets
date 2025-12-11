#!/usr/bin/env python

import xml.etree.ElementTree as ET
import json
import sys
import os
from collections import defaultdict

# === CONFIG ===
RESULT_FILES = ["/tmp/ipa01-result.xml", "/tmp/ipa02-result.xml"]
OUTPUT_JSON = "rule_skip_db.json"

# === SKIP RULES ===
GLOBAL_SKIPS = {
    "xccdf_org.ssgproject.content_rule_grub2_password",
    "xccdf_org.ssgproject.content_rule_package_bind_removed",
    "xccdf_org.ssgproject.content_rule_package_openldap-clients_removed",
    "xccdf_org.ssgproject.content_rule_package_httpd_removed",
    "xccdf_org.ssgproject.content_rule_service_rpcbind_disabled",
    "xccdf_org.ssgproject.content_rule_service_nfs_disabled"
}

HOST_FILE_SCOPED = {
    "xccdf_org.ssgproject.content_rule_sudo_require_authentication": {
        "hosts": ["ipa01", "ipa02"],
        "files": [
            "/etc/sudoers.d/124_AWX_MORINSOFT_DFLT",
            "/etc/sudoers.d/123_AE_MORINSOFT_DFLT"
        ]
    }
}

# === PARSE XML RESULTS ===
def extract_rule_states(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    ns = {"xccdf": "http://checklists.nist.gov/xccdf/1.2"}

    rule_states = {}
    for result in root.findall(".//xccdf:rule-result", ns):
        rule_id = result.attrib.get("idref")
        severity = result.attrib.get("severity", "unknown")
        result_text = result.find("xccdf:result", ns)
        state = result_text.text if result_text is not None else "unknown"
        rule_states[rule_id] = {
            "state": state,
            "severity": severity
        }
    return rule_states

# === BUILD RULE DB ===
def build_rule_db(result_files):
    rule_map = defaultdict(lambda: {
        "rule_id": "",
        "rule_skip": False,
        "description": "",
        "platform": ["rocky", "redhat"],
        "severity": "unknown",
        "state": "unknown",
        "hosts": [],
        "files": []
    })

    for file in result_files:
        hostname = os.path.basename(file).split("-")[0]
        rule_states = extract_rule_states(file)

        for rule_id, info in rule_states.items():
            entry = rule_map[rule_id]
            entry["rule_id"] = rule_id
            entry["severity"] = info["severity"]
            entry["state"] = info["state"]

            if hostname not in entry["hosts"]:
                entry["hosts"].append(hostname)

            # Apply skip logic only if rule failed
            if info["state"] == "fail":
                if rule_id in GLOBAL_SKIPS:
                    entry["rule_skip"] = True
                    entry["description"] = "Global skip"

                elif rule_id in HOST_FILE_SCOPED and hostname in HOST_FILE_SCOPED[rule_id]["hosts"]:
                    entry["rule_skip"] = True
                    entry["description"] = "Host-specific sudo exemption"
                    entry["files"] = HOST_FILE_SCOPED[rule_id]["files"]

    return {"rules": list(rule_map.values())}

# === MAIN ===
def main():
    rule_db = build_rule_db(RESULT_FILES)
    with open(OUTPUT_JSON, "w") as f:
        json.dump(rule_db, f, indent=2)
    print(f"✅ Wrote {OUTPUT_JSON} with {len(rule_db['rules'])} rules")

if __name__ == "__main__":
    main()
