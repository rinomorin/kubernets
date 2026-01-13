#!/bin/bash

# Define the base directory
ROLE_DIR="roles/fcos_deploy"

# Create folder structure
mkdir -p $ROLE_DIR/{tasks,templates,defaults}

# 1. Create defaults/main.yml
cat << 'EOF' > $ROLE_DIR/defaults/main.yml
---
vm_host: "{{ lookup('env', 'VM_HOST') | default('kvmdc01.home.morinsoft.ca', true) }}"
cloud_helper_user: "{{ lookup('env', 'CLOUD_HELPER_USER') | default('cloud_helper', true) }}"

# OS Hardware/NIC names
nic_maint: "{{ lookup('env', 'nat_net_device') | default('enp1s0', true) }}"
nic_provision: "{{ lookup('env', 'cluster_net_device') | default('enp2s0', true) }}"
nic_provider: "{{ lookup('env', 'default_net_device') | default('enp3s0', true) }}"

# KVM Bridge Names
br_maint: "{{ lookup('env', 'KVM_NETWORK_NAT') | default('br-nat', true) }}"
br_provision: "{{ lookup('env', 'KVM_NETWORK_CLUSTER') | default('br-cluster', true) }}"
br_provider: "{{ lookup('env', 'KVM_NETWORK_PROVIDER') | default('br0', true) }}"

# Storage and Resources
image_path: "/var/lib/libvirt/images"
fcos_image_name: "fedora-coreos-qemu.x86_64.qcow2"
disk_size: "{{ lookup('env', 'VM_DISK_SIZE') | default('50', true) }}G"
vm_cpu: "{{ lookup('env', 'VM_CPU') | default(2, true) }}"
vm_mem: "{{ lookup('env', 'VM_MEM') | default(4096, true) }}"
EOF

# 2. Create tasks/main.yml
cat << 'EOF' > $ROLE_DIR/tasks/main.yml
---
- name: Pre-flight Environment Validation
  include_tasks: preflight.yml

- name: Build Phase - Orchestrate on Helper
  delegate_to: helper
  block:
    - name: Pull CoreOS Tools and Download Image
      include_tasks: prepare_helper.yml
    - name: Setup SSH Identity and Config
      include_tasks: generate_keys.yml
    - name: Render and Convert Ignition Files
      include_tasks: build_configs.yml

- name: Deploy Phase - Orchestrate on KVM Host
  delegate_to: "{{ vm_host }}"
  block:
    - name: Transfer and Secure Files
      include_tasks: deploy_to_kvm.yml
    - name: Launch Cluster VMs
      include_tasks: virt_install_tasks.yml
      loop: "{{ groups['cluster_nodes'] | reject('equalto', 'helper') | list }}"
      loop_control:
        loop_var: node_name

- name: Post-Deployment Cleanup
  include_tasks: cleanup.yml
EOF

# 3. Create tasks/preflight.yml
cat << 'EOF' > $ROLE_DIR/tasks/preflight.yml
---
- name: Verify Environment Variables
  fail:
    msg: "Env var {{ item }} is missing. Did you source env_build.sh?"
  when: lookup('env', item) == ''
  loop: [VM_HOST, HELPER_SSH_KEY_PATH, KVM_NETWORK_CLUSTER]

- name: Check KVM Network Availability
  delegate_to: "{{ vm_host }}"
  shell: "sudo /bin/sh -c 'virsh net-info {{ item }}'"
  loop: ["{{ br_maint }}", "{{ br_provision }}", "{{ br_provider }}"]
  changed_when: false
EOF

# 4. Create tasks/prepare_helper.yml
cat << 'EOF' > $ROLE_DIR/tasks/prepare_helper.yml
---
- name: Pull CoreOS Toolchain Images
  shell: "podman pull quay.io/coreos/{{ item }}:release"
  loop: [butane, coreos-installer, ignition-validate]

- name: Download FCOS Base Image
  shell: |
    podman run --rm -v /tmp:/pwd -w /pwd \
    quay.io/coreos/coreos-installer:release \
    download -p qemu -f qcow2.xz --decompress
  args:
    creates: "/tmp/{{ fcos_image_name }}"
EOF

# 5. Create tasks/generate_keys.yml
cat << 'EOF' > $ROLE_DIR/tasks/generate_keys.yml
---
- name: Ensure .ssh directory exists
  file: { path: "~/.ssh", state: directory, mode: '0700' }

- name: Generate SSH Key
  shell: "ssh-keygen -t rsa -b 4096 -f {{ lookup('env', 'HELPER_SSH_KEY_PATH') }} -N ''"
  args:
    creates: "{{ lookup('env', 'HELPER_SSH_KEY_PATH') }}"

- name: Configure SSH client behavior
  blockinfile:
    path: "~/.ssh/config"
    create: yes
    mode: '0600'
    block: |
      Host *
          StrictHostKeyChecking accept-new
          UserKnownHostsFile ~/.ssh/known_hosts
          IdentityFile {{ lookup('env', 'HELPER_SSH_KEY_PATH') }}

- name: Get Public Key
  shell: "cat {{ lookup('env', 'HELPER_SSH_KEY_PATH') }}.pub"
  register: pub_key_out

- set_fact:
    helper_pub_key: "{{ pub_key_out.stdout }}"
EOF

# 6. Create tasks/build_configs.yml
cat << 'EOF' > $ROLE_DIR/tasks/build_configs.yml
---
- name: Render and Convert
  loop: "{{ groups['cluster_nodes'] | reject('equalto', 'helper') | list }}"
  loop_control: { loop_var: node_name }
  block:
    - template: { src: nodes.bu.j2, dest: "/tmp/{{ node_name }}.bu" }
    - shell: |
        podman run --rm -v /tmp:/pwd -w /pwd quay.io/coreos/butane:release --pretty --strict {{ node_name }}.bu > /tmp/{{ node_name }}.ign;
        podman run --rm -v /tmp:/pwd -w /pwd quay.io/coreos/ignition-validate:release {{ node_name }}.ign
EOF

# 7. Create tasks/deploy_to_kvm.yml
cat << 'EOF' > $ROLE_DIR/tasks/deploy_to_kvm.yml
---
- shell: "sudo /bin/sh -c 'mkdir -p {{ image_path }}/ignition && chmod 755 {{ image_path }}/ignition'"
- copy:
    src: "/tmp/{{ item }}"
    dest: "/tmp/{{ item }}"
  loop: "{{ groups['cluster_nodes'] | reject('equalto', 'helper') | list | map('append', '.ign') | list + [fcos_image_name] }}"
- shell: |
    sudo /bin/sh -c '
    mv /tmp/{{ fcos_image_name }} {{ image_path }}/ ;
    mv /tmp/*.ign {{ image_path }}/ignition/ ;
    chown qemu:qemu {{ image_path }}/ignition/*.ign ;
    restorecon -Rv {{ image_path }}/'
EOF

# 8. Create tasks/virt_install_tasks.yml
cat << 'EOF' > $ROLE_DIR/tasks/virt_install_tasks.yml
---
- shell: "sudo /bin/sh -c 'qemu-img create -f qcow2 -F qcow2 -b {{ image_path }}/{{ fcos_image_name }} {{ image_path }}/{{ node_name }}.qcow2 {{ disk_size }}'"
- shell: |
    sudo /bin/sh -c 'virt-install --name {{ node_name }} \
      --vcpus {{ vm_cpu }} --memory {{ vm_mem }} \
      --os-variant fedora-coreos-stable \
      --disk path={{ image_path }}/{{ node_name }}.qcow2 \
      --import --noautoconsole \
      --network network={{ br_maint }},model=virtio \
      --network network={{ br_provision }},model=virtio \
      --network network={{ br_provider }},model=virtio \
      --qemu-commandline=\"-fw_cfg name=opt/com.coreos/config,file={{ image_path }}/ignition/{{ node_name }}.ign\"'
  register: virt_res
  failed_when: "virt_res.rc != 0 and 'already exists' not in virt_res.stderr"
EOF

# 9. Create tasks/cleanup.yml
cat << 'EOF' > $ROLE_DIR/tasks/cleanup.yml
---
- delegate_to: helper
  file: { path: "/tmp/{{ item }}", state: absent }
  loop: ["{{ fcos_image_name }}", "{{ node_name }}.bu", "{{ node_name }}.ign"]
- delegate_to: "{{ vm_host }}"
  shell: "sudo /bin/sh -c 'rm -f /tmp/*.ign /tmp/{{ fcos_image_name }}'"
EOF

# 10. Create templates/nodes.bu.j2
cat << 'EOF' > $ROLE_DIR/templates/nodes.bu.j2
variant: fcos
version: 1.6.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - {{ helper_pub_key }}
storage:
  files:
    - { path: /etc/hostname, mode: 0644, contents: { inline: "{{ hostvars[node_name].hostname }}" } }
    - path: /etc/NetworkManager/system-connections/{{ nic_maint }}.nmconnection
      mode: 0600
      contents:
        inline: |
          [connection]
          id={{ nic_maint }}
          type=ethernet
          interface-name={{ nic_maint }}
          [ipv4]
          method=auto
    - path: /etc/NetworkManager/system-connections/{{ nic_provision }}.nmconnection
      mode: 0600
      contents:
        inline: |
          [connection]
          id={{ nic_provision }}
          type=ethernet
          interface-name={{ nic_provision }}
          [ipv4]
          address1={{ hostvars[node_name].provision_ip }}/24
          method=manual
{% if hostvars[node_name].provider_ip is defined %}
    - path: /etc/NetworkManager/system-connections/{{ nic_provider }}.nmconnection
      mode: 0600
      contents:
        inline: |
          [connection]
          id={{ nic_provider }}
          type=ethernet
          interface-name={{ nic_provider }}
          [ipv4]
          address1={{ hostvars[node_name].provider_ip }}/24
          method=manual
{% endif %}
EOF

echo "Ansible Role 'fcos_deploy' generated successfully in $(pwd)/$ROLE_DIR"
