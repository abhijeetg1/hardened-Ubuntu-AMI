
# Ubuntu CIS Hardening Automation

## Overview

This project automates the creation of a hardened Ubuntu AMI by applying basic CIS (Center for Internet Security) controls.  
It uses **Ansible** to automate hardening tasks ensuring consistent, repeatable, and auditable security baseline.

---

## CIS Controls Implemented

- Create a separate `/var/log` partition  
- Disable IP forwarding  
- Configure local login warning banner  
- Disable secure ICMP redirects  
- Disable IPv6  
- Collect login and logout events  
- Collect file deletion events by users  
- Enforce password expiration to 90 days or less  
- Set SSH LogLevel to INFO  

---

## Prerequisites

- Ubuntu 20.04 or later instance  
- Ansible installed on the control machine  
- SSH access with sudo privileges  
- `community.general` Ansible collection installed  

```bash
ansible-galaxy collection install community.general
```

---

## Setup Instructions

### 1. Prepare Ansible Inventory (`hosts.ini`)

Add your target server IP or hostname:

```ini
[ubuntu]
YOUR_SERVER_IP
```

---

### 2. Configure SSH Private Key Access

Place your `.pem` key on the control machine and restrict permissions:

```bash
chmod 600 /path/to/rsa-ubuntu.pem
```

---

### 3. Test Ansible Connectivity

```bash
ansible -i hosts.ini ubuntu -m ping --become --private-key=/path/to/rsa-ubuntu.pem
```

Expected output:

```text
YOUR_SERVER_IP | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

### 4. Create and Mount Separate `/var/log` Partition

Make sure you have an unused disk device (e.g., `/dev/nvme1n1`).

Run the Ansible playbook:

```bash
ansible-playbook -i hosts.ini var_log_partition.yml --become --private-key=/path/to/rsa-ubuntu.pem
```

**What this playbook does:**

- Creates a primary partition on `/dev/nvme1n1`  
- Formats the partition as ext4  
- Stops logging services (`rsyslog` and `systemd-journald`)  
- Backs up existing `/var/log` to `/var/log_old`  
- Mounts the new partition on `/var/log`  
- Copies old logs back  
- Removes the backup  
- Updates `/etc/fstab` for persistence  
- Restarts logging services  

**Verify partition:**

```bash
df -h /var/log
```

---

### 5. Apply CIS Hardening Playbook

Run:

```bash
ansible-playbook -i hosts.ini cis_hardening.yml --become --private-key=/path/to/rsa-ubuntu.pem
```

**Main tasks include:**

- Disable IP forwarding:  
  ```bash
  sysctl -w net.ipv4.ip_forward=0
  ```
- Configure local login warning banner (`/etc/issue`)  
- Disable secure ICMP redirects:  
  ```bash
  sysctl -w net.ipv4.conf.all.secure_redirects=0
  sysctl -w net.ipv4.conf.default.secure_redirects=0
  ```
- Disable IPv6:  
  ```bash
  sysctl -w net.ipv6.conf.all.disable_ipv6=1
  ```
- Enable audit rules to log login/logout and file deletion events  
- Enforce password expiration to maximum 90 days:  
  ```bash
  chage --maxdays 90 <username>
  ```
- Set SSH LogLevel to INFO in `/etc/ssh/sshd_config` and restart SSH service  

---

### 6. (Optional) Manual Bash Script Execution

Alternatively, you can run a shell script that performs the above hardening steps:

```bash
bash cis_hardening.sh
```

---

## Verification Steps

After running the hardening playbooks/scripts, verify the changes:

- Check `/var/log` mount:

  ```bash
  df -h /var/log
  ```

- Confirm IP forwarding is disabled:

  ```bash
  sysctl net.ipv4.ip_forward
  # Expected output: net.ipv4.ip_forward = 0
  ```

- Confirm IPv6 is disabled:

  ```bash
  sysctl net.ipv6.conf.all.disable_ipv6
  # Expected output: net.ipv6.conf.all.disable_ipv6 = 1
  ```

- Check local login banner:

  ```bash
  cat /etc/issue
  ```

- List audit rules for login/logout and file deletion:

  ```bash
  sudo auditctl -l
  ```

- Verify password expiry for current user:

  ```bash
  chage -l $(whoami) | grep 'Maximum'
  # Expected output: Maximum number of days between password change : 90
  ```

- Confirm SSH LogLevel setting:

  ```bash
  grep LogLevel /etc/ssh/sshd_config
  # Expected output: LogLevel INFO
  ```

---

## Notes

- Always test on a staging environment first before production deployment.  
- Backup all critical data before modifying partitions.  
- Review audit logs regularly to ensure compliance.  
- Keep your Ansible playbooks updated with latest CIS recommendations.

---

## Contact

Prepared by: **ABHIJEET GORAI**  
Email: abhijeetgorai65@gmail.com  
Date: 29/05/2025  

---

## Repository Structure

```
.
├── cis_hardening.yml           # Main CIS hardening playbook
├── var_log_partition.yml       # Playbook for /var/log partitioning
├── hosts.ini                   # Ansible inventory file
├── cis_hardening.sh            # Optional Bash script for manual hardening
└── README.md                   # This documentation file
```
