import json
import re

tasks_output = open("tasks.txt").read().splitlines()
plays = []
current_play = None

for line in tasks_output:
    if line.startswith("  play #"):
        if current_play:
            plays.append(current_play)
        parts = re.match(r'  play #(\d+) \((.*?)\): (.*?)', line)
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
        else:
            role, name = None, role_task
        current_play["tasks"].append({"role": role, "name": name, "tags": []})

if current_play:
    plays.append(current_play)

print(json.dumps({"playbook": "playbooks/home_cloud.yml", "plays": plays}, indent=2))
