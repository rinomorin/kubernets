import yaml
import os
import sys

SSG_BASE = "/usr/share/scap-security-guide/ansible"

def sanitize(tag):
    return tag.replace("xccdf_org.ssgproject.content_rule_", "").replace("/", "_")

def resolve_imports(playbook_path, output_dir):
    with open(playbook_path, "r") as f:
        playbook = yaml.safe_load(f)

    os.makedirs(output_dir, exist_ok=True)
    count = 0

    for entry in playbook:
        tasks = entry.get("tasks", [])
        for task in tasks:
            tags = task.get("tags", [])
            import_path = task.get("import_tasks")
            if not import_path or not tags:
                continue

            for tag in tags:
                if tag.startswith("xccdf_org.ssgproject.content_rule_"):
                    full_path = os.path.join(SSG_BASE, import_path)
                    if not os.path.exists(full_path):
                        print(f"⚠ Missing: {full_path}")
                        continue

                    with open(full_path, "r") as tf:
                        imported_tasks = yaml.safe_load(tf)

                    filename = sanitize(tag) + ".yml"
                    out_path = os.path.join(output_dir, filename)
                    with open(out_path, "w") as out:
                        yaml.dump(imported_tasks, out, default_flow_style=False)
                    print(f"✔ Extracted: {filename}")
                    count += 1

    print(f"\n✅ Generated {count} remediation files in {output_dir}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python resolve_ssg_imports.py <ssg_playbook.yml> <output_directory>")
        sys.exit(1)

    playbook_file = sys.argv[1]
    output_dir = sys.argv[2]

    if not os.path.exists(playbook_file):
        print(f"❌ File not found: {playbook_file}")
        sys.exit(1)

    resolve_imports(playbook_file, output_dir)
