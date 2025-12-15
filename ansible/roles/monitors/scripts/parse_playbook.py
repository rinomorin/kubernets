#!/usr/bin/env python3
import os
import sys
import yaml

def resolve_path(base_file, inc_value, ansible_base):
    """Resolve include/import path relative to file or ansible base."""
    if os.path.isabs(inc_value):
        return inc_value
    # relative to current file
    rel_path = os.path.join(os.path.dirname(base_file), inc_value)
    if os.path.exists(rel_path):
        return rel_path
    # bare filename → assume in same dir as base_file
    fname = os.path.basename(inc_value)
    candidate = os.path.join(os.path.dirname(base_file), fname)
    if os.path.exists(candidate):
        return candidate
    # fallback: try under ansible base
    candidate2 = os.path.join(ansible_base, inc_value)
    if os.path.exists(candidate2):
        return candidate2
    return inc_value

def find_includes(obj):
    """Recursively walk a YAML structure and yield include/import values."""
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k in ("include_tasks", "import_tasks"):
                yield v
            else:
                yield from find_includes(v)
    elif isinstance(obj, list):
        for item in obj:
            yield from find_includes(item)

def parse_file(path, visited, ansible_base, order):
    if path in visited:
        return
    visited.add(path)

    if not os.path.exists(path):
        return

    order.append(path)

    with open(path, "r") as f:
        try:
            data = yaml.safe_load(f)
        except Exception:
            return

    for inc_value in find_includes(data):
        new_path = resolve_path(path, inc_value, ansible_base)
        parse_file(new_path, visited, ansible_base, order)

def main():
    if len(sys.argv) < 2:
        print("Usage: recursive_parser.py <playbook.yml>")
        sys.exit(1)

    playbook_path = sys.argv[1]
    playbook_dir = os.path.dirname(playbook_path)
    ansible_base = os.path.dirname(playbook_dir)

    with open(playbook_path, "r") as f:
        data = yaml.safe_load(f)

    visited = set()
    order = []

    if isinstance(data, list):
        for play in data:
            if not isinstance(play, dict):
                continue
            # roles
            for r in play.get("roles", []):
                role_name = r if isinstance(r, str) else r.get("role")
                role_main = os.path.join(ansible_base, "roles", role_name, "tasks", "main.yml")
                parse_file(role_main, visited, ansible_base, order)
            # includes in play tasks
            for inc_value in find_includes(play.get("tasks", [])):
                new_path = resolve_path(playbook_path, inc_value, ansible_base)
                parse_file(new_path, visited, ansible_base, order)

    for f in order:
        print(f)

if __name__ == "__main__":
    main()
