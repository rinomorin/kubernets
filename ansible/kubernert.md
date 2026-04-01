
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