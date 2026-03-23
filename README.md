# Wazuh SOC Homelab - Proxmox Deployment

## Objective
Deployed Wazuh SIEM (manager, indexer, dashboard) to monitor homelab security events. Demonstrates container orchestration, troubleshooting, and security monitoring skills.


### Component Overview

| Component | Type | Purpose |
|-----------|------|---------|
| **Wazuh VM** | Virtual Machine | Central SIEM for security monitoring and log analysis |
| **Pi-Hole LXC** | Container | DNS-level ad and threat filtering |
| **TT-RSS LXC** | Container | RSS feed aggregation |
| **Pop_OS! Agent** | Physical Machine | Endpoint threat detection and monitoring |
| **Windows 11 Agent** | Physical Machine | Endpoint threat detection and monitoring |
     
     
## Deployment & Troubleshooting

### Challenge 1: LXC Static IP Networking

**Problem**
- Proxmox LXC container had IP `192.168.8.249` but no internet connectivity
- Missing default gateway in routing table (`ip route` output was incomplete)

**Solution**

Configure Netplan with the following YAML:

```yaml
network:
  version: 2
  ethernets:
    ens18:
      addresses:
        - "192.168.8.249/24"
      nameservers:
        addresses:
          - 192.168.8.10
          - 8.8.8.8
        search: []
      routes:
        - to: "default"
          via: "192.168.8.1"
```

Then apply and verify:

```bash
netplan apply
reboot
```

---

### Challenge 2: Wazuh Docker Deployment

**Problem**
- Initial LXC deployment attempt failed due to OCI rlimits and SSL certificate (`EISDIR`) errors
- Required a different deployment strategy

**Solution: Deploy on a Proxmox VM**

**VM Configuration**
- OS: Ubuntu 22.04
- RAM: 12GB
- Disk: 60GB (resized from 40GB)

**Deployment Steps**

1. Install Docker and clone the Wazuh repository:

```bash
git clone https://github.com/wazuh/wazuh-docker.git
cd wazuh-docker
git checkout v4.13.1
```

2. Launch containers:

```bash
docker-compose up -d
```

3. Verify containers are running:

```bash
docker-compose ps
```

**Status**: ✅ Manager/indexer healthy and operational

---

### Challenge 3: Resource Exhaustion

**Problem**
- Root partition `/` was 100% full
- `/var/lib/docker` consuming 16GB of space

**Solution**

1. Clean up Docker artifacts:

```bash
docker system prune -a
```

2. Clean journal logs:

```bash
journalctl --vacuum=50M
```

3. Resize LVM volumes:

```bash
growpart /dev/sda 3
pvresize /dev/sda3
lvextend -l +100%FREE /dev/pve/data
```

**Result**: ✅ 25GB free space recovered

---

### Challenge 4: Windows Agent Enrollment (Error 1208)

**Problem**: Agent installed but appearing in Agents dashboard

**Solution**

1. Edited `C:\Program Files (x86)\ossec-agent\ossec.conf`:
   ```xml
   <server>
     <address>192.168.8.249</address>  <!-- Fixed IP -->
     <port>1515</port>
   </server>
   ```

2. net stop wazuh && net start wazuh

**Result**: ✅ Agents table -> green staus
<img width="908" height="277" alt="{E8955B27-AF1D-44B0-8B96-C364F3F90E91}" src="https://github.com/user-attachments/assets/0321c4b9-d7f9-43fb-8179-986f15bd5059" />


## Current Status

✅ **Wazuh Dashboard**: Live at https://192.168.8.249

✅ **Manager/Indexer**: Healthy (verified with `docker-compose ps`)

✅ **Overall System**: All core components operational
