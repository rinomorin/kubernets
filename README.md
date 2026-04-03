
# 🧪 PoC Wiki: Secure Cloud Architecture (Generic Draft)

## 1. High-Level Goal
Build a fully automated, production-ready "Dark Cloud" lab. The objective is to prove that Kubernetes services can be exposed securely via a **single, static entry point**, maintain a protocol break for outbound traffic via **Squid**, and demonstrate **Self-Healing** through **Immutable-ish Golden Images**.

## 2. The Prime Directive (Immutable Rules)
* **Rule 1: Set-and-Forget Ingress.** External LBs are configured once.
* **Rule 2: No Direct Provision Access.** All management via Masters/Helper.
* **Rule 3: One-Way Maintenance.** Outbound-only traffic via the Squid Service.
* **Rule 4: Provider Blindness.** Internal topology is never leaked.
* **Rule 5: No Naked Containers.** All public access via Service/Ingress.
* **Rule 6: CIS 2 Compliance.** Hardened Enterprise Linux 9 (EL9).
* **Rule 7: Immutable-ish Operations.** Nodes are cattle, not pets. Configuration is baked into the image; runtime changes are ephemeral and discarded on redeploy.

---

## 3. The Immutable-ish Strategy (`rocky_k8s_golden`)
We use a **"Bake, then Bootstrap"** approach. The `helper` node serves as the factory.

### **The Bake (Golden Image)**
* **Hardened Base:** EL9 with CIS 2 profiles applied (STIG-compliant partitioning).
* **Pre-Loaded Runtimes:** CRI-O, Podman, and Kubelet binaries are pre-installed to avoid "Post-Install" downloads.
* **Proxy-Aware:** `/etc/environment` and `dnf.conf` are pre-configured to point to the **Squid Service VIP** (`10.0.0.250`).
* **Security Context:** SELinux is set to `Enforcing` and the Internal CA trust store is pre-populated.

### **The Bootstrap (Cloud-Init / Ignition)**
* **Identity:** On first boot, the node uses a minimal script to join the **IDM/IPA** domain.
* **K8s Join:** The node uses a pre-staged token to join the cluster via the **Provision** network.
* **No Manual Edits:** Any configuration drift is corrected by the `helper` node's Ansible "Enforcement" playbooks, or the node is simply re-imaged.

---

## 4. Infrastructure Inventory & Status Tracker

| Component | Hostname(s) | Status | Technology |
| :--- | :--- | :--- | :--- |
| **Golden Image** | `el9-k8s-v1` | 🏗️ **WIP** | Ansible-baked EL9 (CIS 2 Hardened) |
| **Identity Core** | `idm01/02` | ✅ **Functional** | DNS, LDAP, Kerberos, CA. |
| **Admin Hub** | `helper` | ✅ **Functional** | Image Factory, Ansible, Tooling. |
| **Entry Point** | `lb01/02/03` | 🏗️ **WIP** | Keepalived (`192.168.1.30`), HAProxy. |
| **Control Plane** | `mast01/02/03` | 🏗️ **WIP** | CRI-O, **Squid Service**. |
| **Data Plane** | `wrk01/02` | 🏗️ **WIP** | CRI-O (Immutable-ish). |

---

## 5. Automation Roadmap (Playbook: `build_cloud`)

| Phase | Milestone | Goal | Status |
| :--- | :--- | :--- | :--- |
| **00** | **The Bake** | Build the CIS 2 Hardened Golden Image. | 🔄 Testing |
| **01** | **Ingress Core** | Deploy 3-node LB Cluster with failover. | 🏗️ **WIP** |
| **02** | **The Exit** | Deploy **Squid Service** (Self-healing). | 📝 Draft |
| **03** | **Enforcement** | Ansible playbooks to revert configuration drift. | 📝 Draft |

---

### **Success Criteria for Immutable-ish Nodes:**
1.  **Fast Recovery:** A failed worker node can be deleted and replaced by a fresh clone of the Golden Image in under 5 minutes.
2.  **Audit Integrity:** Periodic Ansible "Check-Mode" runs confirm 0 changes required on the nodes (proving no manual "hotfixes" occurred).

**Since we are focusing on the "Bake," would you like to see the Ansible variables for the `rocky_k8s_golden` role to ensure the CRI-O and Proxy settings are correctly "baked in"?**


### Summary: The `prep_helper` Readiness Mission
The goal of this playbook is to **prime the environment**. It creates the "Hooks" into your infrastructure so the next stages can actually "grab onto" something.

---

### 1. Preparing the Identity & Network "Hooks" (IPA/IDM)
Before you can deploy nodes, the Helper needs to be authorized to talk to your Identity Manager.
* **Zone Readiness:** It ensures the Forward and Reverse DNS zones exist. This is the "Phonebook" that the future cloud nodes will use to find each other.
* **Principal Setup:** It creates the Host and HTTP service principals. This is like creating "ID Cards" for the services that haven't even started yet.
* **Certificate Pipeline:** It requests and signs SSL certificates. This ensures that the first time you try to connect securely, the trust is already established.

### 2. Preparing the Hypervisor "Hooks" (KVM)
The Helper needs to be able to "reach out and touch" the KVM host to build VMs.
* **Credential Alignment:** It syncs the `cloud_helper` user across both machines. Without this, you'd hit "Permission Denied" the second you tried to create a virtual disk.
* **SSH Trust:** It wipes out the old "handshake" and forces a new, secure SSH key relationship. This gives the Helper a "Master Key" to the KVM host for automated VM creation.
* **Sudo Validation:** It places a validated `visudo` file on the host. This allows the Helper to run the `virt-install` commands it will need in the next stage.

### 3. Preparing the Local "Toolbox" (The Helper Node)
It loads the node with every binary and configuration required to "Deploy the Nodes and Build the Cloud."
* **Kubernetes Tooling:** It downloads and installs `kubectl`, `kubeadm`, and `crictl`. These are the "Command Centers" for the future cluster.
* **Isolated Workspace:** It creates a dedicated Python Virtual Environment (`venv`). This keeps your cloud-building Ansible scripts isolated from the system's default Python.
* **Container Capability:** It configures **Rootless Podman** with proper `subuid/subgid` mapping. This allows the `cloud_helper` user to run the building-block containers needed for the deployment stage without ever needing to "become root."

---

### Tasks to Finalize the "Prep" Documentation
To finish cleaning up the **DarkWeb/kubernetes** repo for this stage, we should document that `prep_helper` is the **Universal Prerequisite**.

| Environment | What was Prepared? |
| :--- | :--- |
| **Local Helper** | Venv, K8s Binaries, Rootless Podman |
| **KVM Host** | User Sync, SSH Keys, Sudoers Permissions |
| **IPA/DNS** | DNS Zones, Service Principals, SSL Certs |


This is the **Build Rock Cloud** grand finale. It’s a sophisticated orchestration that moves from a raw ISO to a fully functional, self-healing Kubernetes cluster in four distinct evolutionary stages.

Here is the summary of the **`build_rock_cloud.yml`** workflow:

---

### Phase 1: `rocky_k8s_golden` (The Immutable Foundation)
The goal here is consistency. Instead of configuring every node from scratch, you build one "perfect" template.
* **Base Image:** Creates a Rocky Linux 9 "Immutable-ish" image on the KVM host.
* **Hardening:** Pre-configures the OS-level essentials so that every clone starts with the same security and performance baseline.
* **Cloud-Ready:** Preps the image to be cloned rapidly, ensuring that unique identifiers (like Machine IDs) don't conflict later.

### Phase 2: `rocky_k8s_lbs` (The Traffic Gatekeepers)
This phase builds the "front door" of your cluster. It clones the Golden Image to create dedicated Load Balancer nodes.
* **High Availability:** Deploys **Keepalived** for a Virtual IP (VIP) and **HAProxy** for traffic distribution.
* **Dual-Network Setup:** Configures complex networking (Maintenance tunnels + Production IPs) to keep management traffic separate from cluster traffic.
* **IPA Integration:** Automatically registers DNS A and PTR records in your FreeIPA server so the LBs are reachable by name immediately.

### Phase 3: `rocky_k8s_nodes` (The Muscle)
This phase scales the environment by deploying the actual cluster members (Masters and Workers).
* **The "Silver" Image:** Takes the Golden Image, installs the heavy-hitters (**kubeadm, kubelet, kubectl, CRI-O, and etcd**), and then "syspreps" it.
* **Rapid Cloning:** Clones the Lead Master to create the remaining Masters and Workers.
* **Network Injection:** Uses a "Maintenance Tunnel" to inject static Production IPs into the nodes while they are still isolated behind a firewall (the "Blackhole" bridge).

### Phase 4: `rocky_k8s_init` (The Big Bang)
This finalizes the cluster, turning a group of nodes into a living "Cloud."
* **Control Plane Setup:** Initializes the first Master and has all other Masters and Workers join the fabric.
* **Network Fabric:** Deploys **Flannel** for Pod networking and configures **Firewalld** with specific rules for K8s intra-zone communication.
* **MetalLB & Ingress:** * Configures **MetalLB** to manage your 10.0.0.200-210 IP pool.
    * Deploys the **NGINX Ingress Controller** to route external web traffic.
* **The Smoke Test:** Deploys an Nginx test image and exposes it via a LoadBalancer service to prove the "North-South" traffic flow is working perfectly.

---

### Summary Checklist of the Result
By the time this playbook finishes, you have:
1.  **HA Endpoint:** A Keepalived VIP managed by HAProxy.
2.  **Verified Cluster:** A 5-node (or more) Kubernetes cluster in `Ready` status.
3.  **Dynamic Networking:** MetalLB ready to hand out IPs to new services.
4.  **Application Ready:** An Ingress controller waiting for your Stage 2 "OpenShift-style" apps.



### Note on the Playbook Warnings
Before you do your final "Stage 1" commit to the **DarkWeb** repo:
* **Duplicate Key:** You have a duplicate `ssh_key_path` in `rocky_k8s_init/defaults/main.yml` on line 42. It’s using the last defined value, but it's worth cleaning up to prevent confusion.
* **Inventory Path:** The `Unable to parse inventory.yaml` warning is still the biggest hurdle. Once you fix the path in your `ansible-playbook` command to point to the new location in the `DarkWeb/kubernetes` submodule, those `[kvm]` and `[cluster_nodes]` patterns will finally match!