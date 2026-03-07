[wazuh_project.txt](https://github.com/user-attachments/files/25809016/wazuh_project.txt)
## Project Overview
Built Wazuh SIEM in Proxmox LXC to monitor homelab (Pi-Hole, TT-RSS, Windows). Demonstrates log collection, alerting, incident reporting.

## Architecture Diagram
[Paste ASCII or screenshot: PVE → Wazuh LXC → Agents]

## Challenges Overcome
- **Static IP, no internet**: LXC had IP but no default gateway post-reboot.
  - Diagnosed: `ip route` empty → manual `ip route add` (temp).
  - Fixed: Netplan YAML with explicit `routes: - to: default via 192.168.8.1`.
  - [Before `ip route` screenshot] [After screenshot] [Netplan YAML code block]
- ** wazuh-certs-generator Docker image used to generate certficates for each node failed
  -Diagnosed: docker compose -f generate-indexer-certs.yml run --rm generator -> unknown shorthand flag: 'f' in -f wazuh
  - Fixed: installed docker-compose 'sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose' - assigned permissions chmod +x /usr/local/bin/docker-compose

## Setup Steps
1. Proxmox LXC: Ubuntu 22.04, 8GB RAM/1GB swap, static IP 192.168.8.249.
2. Netplan config → `netplan apply`.
3. Docker → `docker run wazuh/wazuh-manager`.
4. Agent on Windows VM → alerts generated.

## Outputs
- [Dashboard screenshot]
- [Sample alert]
- [Incident report PDF/MD]

