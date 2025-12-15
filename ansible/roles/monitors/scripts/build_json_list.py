def main():
    if "-p" not in sys.argv or "-d" not in sys.argv:
        print("Usage: build_json_list.py -p <playbook.yml> -d /path/to/ansible [-i inventory.yml]")
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

    cmd = ["ansible-playbook", playbook_path, "--list-tasks"]
    if inventory_file:
        cmd.extend(["-i", inventory_file])

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
