# Wazuh SOC Homelab - Proxmox Deployment

## Objective
Deployed Wazuh SIEM (manager, indexer, dashboard) to monitor homelab security events. Demonstrates container orchestration, troubleshooting, and security monitoring skills.

    ## Architecture Diagram
   text
Dell Optiplex 3050 (host)
├─ Proxmox VMs/LXCs:
│   ├── Wazuh VM (Ubuntu 22.04, Docker SIEM)
│   ├── Pi-Hole LXC (DNS filtering)
│   └── TT-RSS LXC (RSS reader)
|--Pop_OS! Desktop (Physical)
|    |
|    |---Wazuh Agent (endpoint monitoring)
|--Windows 11 Laptop (Physical)
     └── Wazuh Agent (endpoint monitoring)
     
     
## Deployment & Troubleshooting

### Challenge 1: LXC Static IP Networking
**Problem**: Proxmox LXC had IP (192.168.8.249) but no internet (`ip route` missing default gateway).

**Solution**: Netplan YAML:
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

netplan apply → reboot verified.

###Challenge 2: Wazuh Docker Deployment

LXC attempt: OCI rlimits, SSL cert EISDIR errors → pivoted to VM. 
VM deployment:

    ✅️ Proxmox VM: Ubuntu 22.04, 12GB RAM, 60GB disk (resized from 40GB).

    ✅️ Docker + git clone wazuh-docker → v4.13.1 → docker-compose up -d.

    ✅️ Disk pressure (100% full) → journal cleanup + LVM resize (growpart/pvresize/lvextend).

###Challenge 3: Resource Exhaustion

Root full: /var/lib/docker 16GB → cleanup + resize → 25GB free.
Current Status

    ✅ Wazuh dashboard live: https://192.168.8.249

    ✅ Manager/indexer healthy (docker-compose ps)

    ⏳ Agent deployment + incident report (next)

Next: Agent Deployment + Detections

    Windows 11 laptop agent.

    Generate alerts (failed logins).

    Incident report + screenshots.

