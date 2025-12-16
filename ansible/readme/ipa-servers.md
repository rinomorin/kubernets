---

# Manual Installation Guide for RHEL 9 / Rocky Linux 9.6

This document describes how to manually install the operating system without using a Kickstart file. It follows the same configuration and partitioning logic defined in the provided Kickstart template.

---

## 1. Installation Media
- Boot from the RHEL 9 / Rocky Linux 9.6 ISO.
- At the installer prompt, choose **Install RHEL 9** (or Rocky Linux 9.6).
- When asked for installation source:
  - Use the mirrorlist for **BaseOS**:  
    `https://mirrors.rockylinux.org/mirrorlist?arch=x86_64&repo=BaseOS-9.6`
  - Add repository for **AppStream**:  
    `https://mirrors.rockylinux.org/mirrorlist?arch=x86_64&repo=AppStream-9.6`

---

## 2. Localization
- **Language**: `en_CA.UTF-8`
- **Keyboard layout**: `us`
- **Timezone**: `UTC`

---

## 3. Network Configuration
- Configure static networking:
  - IP address: `<your ip_addr>`
  - Netmask: `<your ip_mask>`
  - Gateway: `<your ip_gate>`
  - DNS: `<your ip_dns>`
- Set hostname: `<hostname>`
- Configure NTP: `pool.ntp.org`

---

## 4. Security Settings
- Enable **SELinux** in enforcing mode.
- Enable firewall with SSH service allowed.

---

## 5. Disk Partitioning
- Use disk: `sda`
- Clear all partitions and create new layout:
  - `/boot` → xfs, 1024 MB
  - `/boot/efi` → efi, 300 MB, options: `umask=0077,shortname=winnt`
  - Create LVM PV (`pv.dns`) of 48 GB
  - Create VG `dnsvg` on `pv.dns`
  - Logical volumes:
    - `/tmp` → xfs, 1024 MB, options: `nodev,nosuid,noexec`
    - `/var` → xfs, 2048 MB
    - `/var/log` → xfs, 2048 MB
    - `/var/log/audit` → xfs, 2048 MB
    - `/var/tmp` → xfs, 1024 MB, options: `nodev,nosuid,noexec`
    - `/dev/shm` → xfs, 1024 MB, options: `nodev,nosuid,noexec`
    - `/home` → xfs, 1024 MB
    - `/` → xfs, 6144 MB
    - `swap` → swap, 2048 MB

---

## 6. Bootloader
- Install bootloader in MBR on `sda`.

---

## 7. User Accounts
- Set root password (hashed).
- Create users:
  - `sysadmin` (wheel group)
  - `secops` (wheel group)

---

## 8. Package Selection
Install the following groups and packages:
- Groups:
  - `@^minimal-environment`
  - `@standard`
  - `@headless-management`
- Packages:
  - `openscap-scanner`
  - `scap-security-guide`
  - `aide`
  - `audit`
  - `libpwquality`
  - `policycoreutils`
  - `policycoreutils-python-utils`
  - `gnupg2`
  - `lvm2`
  - `iscsi-initiator-utils`
  - `chrony`
  - `openssl`
  - `sssd`
  - `rsyslog`
  - `logrotate`
  - `gnutls-utils`

---

## 9. Post-Install Configuration
- Set crypto policies to FIPS:  
  `update-crypto-policies --set FIPS`
- Create group `sshusers`.
- Add `sysadmin` and `secops` to `sshusers`.
- Configure sudoers for passwordless sudo:
  ```
  sysadmin ALL=(ALL) NOPASSWD:ALL
  secops ALL=(ALL) NOPASSWD:ALL
  ```
- Configure Chrony (`/etc/chrony.conf`) with Canadian pool servers and local subnet allowance.
- Enable and start `chronyd`.
- Update `/etc/hosts` with system IP and hostname.
- Enable and restart `named-pkcs11`.
- Reset passwords for admin accounts.
- Add SSH authorized key for `secops`.

---

## 10. Finalization
- Verify services:
  - `chronyd`
  - `named-pkcs11`
- Confirm SELinux enforcing and firewall enabled.
- Power off or reboot system.

---



---

# RHEL 9 / Rocky Linux 9.6 Manual Install Checklist

## Pre-Install
- **[Boot from ISO media](guide://action?prefill=Tell%20me%20more%20about%3A%20Boot%20from%20ISO%20media)**  
- **[Select installation source](guide://action?prefill=Tell%20me%20more%20about%3A%20Select%20installation%20source)**: BaseOS + AppStream mirrorlists  
- **[Verify hardware target disk](guide://action?prefill=Tell%20me%20more%20about%3A%20Verify%20hardware%20target%20disk)**: `sda`

---

## Localization
- **[Set language](guide://action?prefill=Tell%20me%20more%20about%3A%20Set%20language)**: `en_CA.UTF-8`  
- **[Set keyboard layout](guide://action?prefill=Tell%20me%20more%20about%3A%20Set%20keyboard%20layout)**: `us`  
- **[Set timezone](guide://action?prefill=Tell%20me%20more%20about%3A%20Set%20timezone)**: `UTC`

---

## Networking
- **[Configure static IP](guide://action?prefill=Tell%20me%20more%20about%3A%20Configure%20static%20IP)**: address, netmask, gateway, DNS  
- **[Set hostname](guide://action?prefill=Tell%20me%20more%20about%3A%20Set%20hostname)**  
- **[Configure NTP](guide://action?prefill=Tell%20me%20more%20about%3A%20Configure%20NTP)**: `pool.ntp.org`

---

## Security
- **[Enable SELinux enforcing](guide://action?prefill=Tell%20me%20more%20about%3A%20Enable%20SELinux%20enforcing)**  
- **[Enable firewall](guide://action?prefill=Tell%20me%20more%20about%3A%20Enable%20firewall)** with SSH allowed

---

## Disk Partitioning
- **[Clear existing partitions](guide://action?prefill=Tell%20me%20more%20about%3A%20Clear%20existing%20partitions)**  
- **[Create /boot](guide://action?prefill=Tell%20me%20more%20about%3A%20Create%20%2Fboot)**: xfs, 1024 MB  
- **[Create /boot/efi](guide://action?prefill=Tell%20me%20more%20about%3A%20Create%20%2Fboot%2Fefi)**: efi, 300 MB, secure options  
- **[Create LVM PV](guide://action?prefill=Tell%20me%20more%20about%3A%20Create%20LVM%20PV)**: 48 GB, VG `dnsvg`  
- **[Create logical volumes](guide://action?prefill=Tell%20me%20more%20about%3A%20Create%20logical%20volumes)**:  
  - `/tmp` 1024 MB (nodev,nosuid,noexec)  
  - `/var` 2048 MB  
  - `/var/log` 2048 MB  
  - `/var/log/audit` 2048 MB  
  - `/var/tmp` 1024 MB (nodev,nosuid,noexec)  
  - `/dev/shm` 1024 MB (nodev,nosuid,noexec)  
  - `/home` 1024 MB  
  - `/` 6144 MB  
  - `swap` 2048 MB

---

## Bootloader
- **[Install bootloader](guide://action?prefill=Tell%20me%20more%20about%3A%20Install%20bootloader)** in MBR on `sda`

---

## Accounts
- **[Set root password](guide://action?prefill=Tell%20me%20more%20about%3A%20Set%20root%20password)**  
- **[Create sysadmin user](guide://action?prefill=Tell%20me%20more%20about%3A%20Create%20sysadmin%20user)** (wheel group)  
- **[Create secops user](guide://action?prefill=Tell%20me%20more%20about%3A%20Create%20secops%20user)** (wheel group)

---

## Packages
- **[Install group minimal environment](guide://action?prefill=Tell%20me%20more%20about%3A%20Install%20group%20minimal%20environment)**  
- **[Install group standard](guide://action?prefill=Tell%20me%20more%20about%3A%20Install%20group%20standard)**  
- **[Install group headless management](guide://action?prefill=Tell%20me%20more%20about%3A%20Install%20group%20headless%20management)**  
- **[Install security packages](guide://action?prefill=Tell%20me%20more%20about%3A%20Install%20security%20packages)**: openscap, scap-security-guide, aide, audit, libpwquality, policycoreutils, chrony, etc.

---

## Post-Install
- **[Set crypto policy to FIPS](guide://action?prefill=Tell%20me%20more%20about%3A%20Set%20crypto%20policy%20to%20FIPS)**  
- **[Create sshusers group](guide://action?prefill=Tell%20me%20more%20about%3A%20Create%20sshusers%20group)**  
- **[Add sysadmin/secops to sshusers](guide://action?prefill=Tell%20me%20more%20about%3A%20Add%20sysadmin%2Fsecops%20to%20sshusers)**  
- **[Configure sudoers](guide://action?prefill=Tell%20me%20more%20about%3A%20Configure%20sudoers)** for passwordless sudo  
- **[Configure chrony.conf](guide://action?prefill=Tell%20me%20more%20about%3A%20Configure%20chrony.conf)** with Canadian pool servers  
- **[Enable chronyd](guide://action?prefill=Tell%20me%20more%20about%3A%20Enable%20chronyd)**  
- **[Update /etc/hosts](guide://action?prefill=Tell%20me%20more%20about%3A%20Update%20%2Fetc%2Fhosts)**  
- **[Enable named-pkcs11](guide://action?prefill=Tell%20me%20more%20about%3A%20Enable%20named-pkcs11)**  
- **[Reset user passwords](guide://action?prefill=Tell%20me%20more%20about%3A%20Reset%20user%20passwords)**  
- **[Add secops SSH key](guide://action?prefill=Tell%20me%20more%20about%3A%20Add%20secops%20SSH%20key)**

---

## Finalization
- **[Verify services](guide://action?prefill=Tell%20me%20more%20about%3A%20Verify%20services)**: chronyd, named-pkcs11  
- **[Confirm SELinux enforcing](guide://action?prefill=Tell%20me%20more%20about%3A%20Confirm%20SELinux%20enforcing)**  
- **[Confirm firewall enabled](guide://action?prefill=Tell%20me%20more%20about%3A%20Confirm%20firewall%20enabled)**  
- **[Shutdown or reboot](guide://action?prefill=Tell%20me%20more%20about%3A%20Shutdown%20or%20reboot)**

---

# RHEL 9 / Rocky Linux 9.6 Operator Install Sheet

## System Info
- **Hostname**: __________________________  
- **IP Address**: __________________________  
- **Netmask**: __________________________  
- **Gateway**: __________________________  
- **DNS**: __________________________  
- **Timezone**: __________________________  

---

## Disk & Partitioning
- Target Disk: `sda`  
- **/boot**: 1024 MB (xfs)  
- **/boot/efi**: 300 MB (efi, secure options)  
- **VG dnsvg** (48 GB LVM PV)  
  - `/tmp`: 1024 MB (nodev,nosuid,noexec)  
  - `/var`: 2048 MB  
  - `/var/log`: 2048 MB  
  - `/var/log/audit`: 2048 MB  
  - `/var/tmp`: 1024 MB (nodev,nosuid,noexec)  
  - `/dev/shm`: 1024 MB (nodev,nosuid,noexec)  
  - `/home`: 1024 MB  
  - `/`: 6144 MB  
  - `swap`: 2048 MB  

---

## Accounts
- **Root password**: __________________________  
- **Sysadmin user**: __________________________  
- **Sysadmin password**: __________________________  
- **Secops user**: __________________________  
- **Secops password**: __________________________  
- **Secops SSH key**: __________________________  

---

## Packages
- Groups: `@^minimal-environment`, `@standard`, `@headless-management`  
- Packages: openscap-scanner, scap-security-guide, aide, audit, libpwquality, policycoreutils, chrony, rsyslog, logrotate, etc.

---

## Post-Install Tasks
- Set crypto policy: `update-crypto-policies --set FIPS`  
- Create group `sshusers`  
- Add sysadmin/secops to `sshusers`  
- Configure sudoers (NOPASSWD)  
- Configure `/etc/chrony.conf` with pool servers  
- Enable/start `chronyd`  
- Update `/etc/hosts`  
- Enable/start `named-pkcs11`  
- Reset user passwords  
- Add secops SSH key  

---

## Verification
- SELinux enforcing: ☐  
- Firewall enabled: ☐  
- chronyd running: ☐  
- named-pkcs11 running: ☐  
- Crypto policy set to FIPS: ☐  

---

# Post‑Install Compliance Validation Checklist

## Security & Policies
- ☐ **SELinux enforcing**  
  ```
  getenforce
  ```
  Expected: `Enforcing`

- ☐ **Firewall enabled with SSH allowed**  
  ```
  firewall-cmd --state
  firewall-cmd --list-services
  ```
  Expected: `running`, includes `ssh`

- ☐ **Crypto policy set to FIPS**  
  ```
  update-crypto-policies --show
  ```
  Expected: `FIPS`

---

## Services
- ☐ **Chronyd active and synced**  
  ```
  systemctl status chronyd
  chronyc sources -v
  ```
  Expected: `active (running)`, servers reachable

- ☐ **named-pkcs11 active**  
  ```
  systemctl status named-pkcs11
  ```
  Expected: `active (running)`

---

## Accounts & Access
- ☐ **Sysadmin and Secops users exist**  
  ```
  id sysadmin
  id secops
  ```
  Expected: both in `wheel` and `sshusers`

- ☐ **Passwordless sudo configured**  
  ```
  sudo -l -U sysadmin
  sudo -l -U secops
  ```
  Expected: `NOPASSWD: ALL`

- ☐ **Secops SSH key present**  
  ```
  cat /home/secops/.ssh/authorized_keys
  ```
  Expected: key matches deployment record

---

## Disk & Partitioning
- ☐ **Verify mount points and options**  
  ```
  mount | egrep "tmp|var|shm|home|boot|efi"
  ```
  Expected: all listed with correct options (`nodev,nosuid,noexec` where required)

- ☐ **Swap active**  
  ```
  swapon --show
  ```
  Expected: 2048 MB swap

---

## Logging & Audit
- ☐ **Auditd running**  
  ```
  systemctl status auditd
  ```
  Expected: `active (running)`

- ☐ **AIDE installed**  
  ```
  rpm -q aide
  ```
  Expected: package present

---

# RHEL 9 / Rocky Linux 9.6 Compliance Report (Onboarding Edition)

## System Information
- Hostname: __________________________  
- IP Address: __________________________  
- Gateway: __________________________  
- DNS: __________________________  
- Timezone: __________________________  
- Install Date: __________________________  
- Operator: __________________________  

---

## Security & Policies
| Check | Command | Expected | Why It Matters | Result (Pass/Fail) | Notes |
|-------|---------|----------|----------------|--------------------|-------|
| SELinux enforcing | `getenforce` | Enforcing | Mandatory access control prevents unauthorized actions even if root is compromised. | ______ | ______ |
| Firewall enabled | `firewall-cmd --state` | running | Ensures network exposure is controlled; only approved services are reachable. | ______ | ______ |
| SSH allowed | `firewall-cmd --list-services` | includes ssh | Confirms remote administration is possible while keeping other ports closed. | ______ | ______ |
| Crypto policy | `update-crypto-policies --show` | FIPS | Enforces strong cryptography standards required for compliance (CIS, NIST). | ______ | ______ |

---

## Services
| Check | Command | Expected | Why It Matters | Result (Pass/Fail) | Notes |
|-------|---------|----------|----------------|--------------------|-------|
| Chronyd active | `systemctl status chronyd` | active (running) | Accurate time is critical for logs, Kerberos, and security audits. | ______ | ______ |
| Chrony sync | `chronyc sources -v` | servers reachable | Confirms system clock is synced with trusted NTP sources. | ______ | ______ |
| named-pkcs11 active | `systemctl status named-pkcs11` | active (running) | Provides secure DNS service with PKCS#11 crypto integration. | ______ | ______ |

---

## Accounts & Access
| Check | Command | Expected | Why It Matters | Result (Pass/Fail) | Notes |
|-------|---------|----------|----------------|--------------------|-------|
| Sysadmin exists | `id sysadmin` | wheel, sshusers | Ensures primary admin account is provisioned with correct privileges. | ______ | ______ |
| Secops exists | `id secops` | wheel, sshusers | Provides dedicated security operations account for automation and audits. | ______ | ______ |
| Passwordless sudo | `sudo -l -U sysadmin` | NOPASSWD: ALL | Reduces friction for automation while maintaining audit visibility. | ______ | ______ |
| SSH key present | `cat /home/secops/.ssh/authorized_keys` | matches record | Confirms secure, key‑based login for SecOps automation. | ______ | ______ |

---

## Disk & Partitioning
| Check | Command | Expected | Why It Matters | Result (Pass/Fail) | Notes |
|-------|---------|----------|----------------|--------------------|-------|
| Mount points | `mount | egrep "tmp|var|shm|home|boot|efi"` | correct options | Enforces isolation (`nodev,nosuid,noexec`) to reduce attack surface. | ______ | ______ |
| Swap active | `swapon --show` | 2048 MB | Ensures memory management and crash resilience. | ______ | ______ |

---

## Logging & Audit
| Check | Command | Expected | Why It Matters | Result (Pass/Fail) | Notes |
|-------|---------|----------|----------------|--------------------|-------|
| Auditd running | `systemctl status auditd` | active (running) | Provides mandatory audit trail for security events. | ______ | ______ |
| AIDE installed | `rpm -q aide` | package present | Detects unauthorized file changes for integrity monitoring. | ______ | ______ |

---

## Operator Sign-Off
- Operator Name: __________________________  
- Date: __________________________  
- Signature: __________________________  

---
