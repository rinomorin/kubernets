import xml.etree.ElementTree as ET
import os

OSCAP_RESULT = "ipa01-result.xml"
OUTPUT_FILE = "roles/secops/tasks/dispatch_failed.yml"

def extract_failed_rules(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    ns = {'xccdf': 'http://checklists.nist.gov/xccdf/1.2'}

    failed = []
    for result in root.findall('.//xccdf:rule-result', ns):
        rule_id = result.attrib.get('idref')
        result_text = result.find('xccdf:result', ns)
        if result_text is not None and result_text.text == "fail":
            failed.append(rule_id)
    return failed

def generate_loop_dispatcher(failed_rules, output_path):
    with open(output_path, "w") as f:
        f.write("# Dynamically included failed remediations\n")
        f.write("- name: \"Remediate {{ full_id }}\"\n")
        f.write("  include_tasks: \"remediations/{{ full_id.split('rule_')[1] }}.yml\"\n")
        f.write("  when:\n")
        f.write("    - rule[full_id] == failed\n")
        f.write("    - rule_skip[full_id] == false\n")
        f.write("  loop:\n")
        for rule_id in failed_rules:
            f.write(f"    - {rule_id}\n")
        f.write("  loop_control:\n")
        f.write("    loop_var: full_id\n")
    print(f"\n✅ Loop-based dispatcher written to {output_path} with {len(failed_rules)} failed rules")

def main():
    failed_rules = extract_failed_rules(OSCAP_RESULT)
    generate_loop_dispatcher(failed_rules, OUTPUT_FILE)

if __name__ == "__main__":
    main()
