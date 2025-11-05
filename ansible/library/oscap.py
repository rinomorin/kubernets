#!/usr/bin/env python

from ansible.module_utils.basic import AnsibleModule
import json
import os

class ScanCommandBuilder:
    def __init__(self, hostname: str, profile: str, scan_path: str, skip_rules: list[str], remediate: bool = False):
        self.hostname = hostname
        self.profile = profile
        self.scan_path = scan_path
        self.skip_rules = skip_rules
        self.remediate = remediate

    def build(self) -> str:
        skip_args = ""
        if self.skip_rules:
            skip_args = "".join(f"  --skip-rule {rule} \\\n" for rule in self.skip_rules)

        remediate_line = "  --remediate \\\n" if self.remediate else ""

        return (
            f"oscap xccdf eval \\\n"
            f"  --profile {self.profile} \\\n"
            f"{skip_args}"
            f"  --results /tmp/{self.hostname}-result.xml \\\n"
            f"  --report /tmp/{self.hostname}-report-initial.html \\\n"
            f"{remediate_line}"
            f"  {self.scan_path} > /tmp/{self.hostname}-rout.txt && \\\n"
            f"  chmod 644 /tmp/{self.hostname}-r*"
        )

# === RuleSkip: returns rule_id → skip boolean for a given host ===
class RuleSkip:
    def __init__(self, json_path):
        self.json_path = json_path
        self.data = self._load()

    def _load(self):
        if not os.path.exists(self.json_path):
            raise FileNotFoundError(f"Missing rule skip file: {self.json_path}")
        with open(self.json_path, "r") as f:
            return json.load(f)

    def get_skip_map(self, host):
        skip_map = {}
        for rule in self.data.get("rules", []):
            if host in rule.get("hosts", []):
                skip_map[rule["rule_id"]] = rule.get("rule_skip", False)
        return skip_map

# === RuleStatus: returns lists of pass/fail rule_ids for a given host ===
class RuleStatus:
    def __init__(self, json_path):
        self.json_path = json_path
        self.data = self._load()

    def _load(self):
        if not os.path.exists(self.json_path):
            raise FileNotFoundError(f"Missing rule status file: {self.json_path}")
        with open(self.json_path, "r") as f:
            return json.load(f)

    def get_status_map(self, host):
        status_map = {"pass": [], "fail": []}
        for rule in self.data.get("rules", []):
            if host in rule.get("hosts", []):
                state = rule.get("state", "unknown")
                if state in status_map:
                    status_map[state].append(rule["rule_id"])
        return status_map

# === Main entrypoint ===
def main():
    module_args = dict(
        hostname=dict(type='str', required=True),
        json_path=dict(type='str', required=False, default='rule_skip_db.json'),
        mode=dict(type='str', required=False, choices=['skip', 'status', 'prep-scan', 'prep-fix-scan'], default='skip'),
        profile=dict(type='str', required=False),
        scan_path=dict(type='str', required=False),
        skips=dict(type='dict', required=False, default={})
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    hostname = module.params['hostname']
    json_path = module.params['json_path']
    mode = module.params['mode']

    try:
        if mode == 'skip':
            skip_api = RuleSkip(json_path)
            rule_skip = skip_api.get_skip_map(hostname)
            module.exit_json(changed=False, rule_skip=rule_skip)
        elif mode == 'status':
            status_api = RuleStatus(json_path)
            rule_status = status_api.get_status_map(hostname)
            module.exit_json(changed=False, rule_status=rule_status)
        elif mode == 'prep-scan':
            skip_dict = module.params["skips"].get("rule_skip", {})
            skip_rules = [rule for rule, skip in skip_dict.items() if skip]
            builder = ScanCommandBuilder(
                hostname=hostname,
                profile=module.params["profile"],
                scan_path=module.params["scan_path"],
                skip_rules=skip_rules
            )
            scan_command = builder.build()
            module.exit_json(changed=False, scan_command=scan_command)
        elif mode == 'prep-fix-scan':
            skip_dict = module.params["skips"].get("rule_skip", {})
            skip_rules = [rule for rule, skip in skip_dict.items() if skip]
            builder = ScanCommandBuilder(
                hostname=hostname,
                profile=module.params["profile"],
                scan_path=module.params["scan_path"],
                skip_rules=skip_rules,
                remediate=True
            )
            scan_command = builder.build()
            module.exit_json(changed=False, scan_command=scan_command)

    except Exception as e:
        module.fail_json(msg=str(e))

if __name__ == '__main__':
    main()
