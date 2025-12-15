#!/usr/bin/env python3
import sys, os, subprocess, json, re

def parse_tasks(output_lines, playbook_path):
    plays = []
    current_play = None
    for line in output_lines:
        if line.startswith("  play #"):
            if current_play:
                plays.append(current_play)
            parts = re.match(r'  play #(\d+) \((.*?)\): (.*?)', line)
            if parts:
                current_play = {
                    "id": int(parts.group(1)),
                    "hosts": parts.group(2),
                    "name": parts.group(3),
                    "tags": [],
                    "tasks": []
                }
        elif "tasks:" in line:
            continue
        elif ":" in line and "TAGS" in line:
            role_task = line.strip().split("TAGS")[0].strip()
            if " : " in role_task:
                role, name = role_task.split(" : ", 1)
                if role.strip():  # only append if role is non-empty
                    current_play["tasks"].append({
                        "role": role.strip(),
                        "name": name.strip(),
                        "tags": []
                    })
            else:
                # no role present → skip this task entirely
                continue
    if current_play:
        plays.append(current_play)
    return {"playbook": playbook_path, "plays": plays}

def main():
    if "-p" not in sys.argv or "-d" not in sys.argv:
        print("Usage: build_json_list.py -p <playbook.yml> -d /path/to/ansible [-i inventory.yml] [-r roles_path]")
        sys.exit(1)

    playbook_index = sys.argv.index("-p") + 1
    workdir_index = sys.argv.index("-d") + 1
    playbook_path = sys.argv[playbook_index]
    workdir = sys.argv[workdir_index]

    # Optional inventory
    inventory_file = None
    if "-i" in sys.argv:
        inventory_index = sys.argv.index("-i") + 1
        inventory_file = sys.argv[inventory_index]

    # Optional roles_path
    roles_path = None
    if "-r" in sys.argv:
        roles_index = sys.argv.index("-r") + 1
        roles_path = sys.argv[roles_index]

    cmd = ["ansible-playbook", playbook_path, "--list-tasks"]
    if inventory_file:
        cmd.extend(["-i", inventory_file])
    if roles_path:
        cmd.extend(["-e", f"ansible_roles_path={roles_path}"])

    result = subprocess.run(
        cmd,
        cwd=workdir,
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        print("Error running ansible-playbook:", result.stderr or result.stdout)
        sys.exit(1)

    tasks_output = result.stdout.splitlines()
    json_data = parse_tasks(tasks_output, playbook_path)

    buildmon_dir = os.path.join(workdir, "buildMon")
    os.makedirs(buildmon_dir, exist_ok=True)

    output_file = os.path.join(buildmon_dir, "tasks.json")
    with open(output_file, "w") as f:
        json.dump(json_data, f, indent=2)

    print(f"JSON saved to {output_file}")

if __name__ == "__main__":
    main()
