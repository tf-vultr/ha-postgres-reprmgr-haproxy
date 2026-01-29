# PostgreSQL High Availability Documentation

This documentation covers the deployment, operation, and maintenance of a highly available PostgreSQL cluster using repmgr, HAProxy, and Keepalived.

## Documentation Index

| Document | Description |
|----------|-------------|
| [01 - Architecture Overview](01-architecture-overview.md) | System architecture, components, and data flow |
| [02 - Setup Guide](02-setup-guide.md) | Step-by-step installation and configuration |
| [03 - Operations Guide](03-operations-guide.md) | Day-to-day operations, maintenance, and upgrades |
| [04 - Troubleshooting Guide](04-troubleshooting-guide.md) | Common issues and solutions |
| [05 - Quick Reference](05-quick-reference.md) | Command cheat sheet for daily use |

## Quick Start

### Connect to the Database

```bash
# Write operations (connects to PRIMARY)
psql -h 192.168.87.100 -p 5000 -U <username> -d <database>

# Read operations (connects to STANDBY)
psql -h 192.168.87.100 -p 5001 -U <username> -d <database>
```

### Check Cluster Health

```bash
sudo -u postgres repmgr -f /etc/repmgr.conf cluster show
```

### Perform Planned Switchover

```bash
# From the standby you want to promote
sudo -u postgres repmgr standby switchover -f /etc/repmgr.conf --siblings-follow
```

## Architecture Summary

```
                      VIP: 192.168.87.100
                             │
             ┌───────────────┼───────────────┐
             │               │               │
      ┌──────┴──────┐ ┌──────┴──────┐ ┌──────┴──────┐
      │     pg1     │ │     pg2     │ │     pg3     │
      │  HAProxy    │ │  HAProxy    │ │  HAProxy    │
      │  Keepalived │ │  Keepalived │ │  Keepalived │
      │  repmgrd    │ │  repmgrd    │ │  repmgrd    │
      ├─────────────┤ ├─────────────┤ ├─────────────┤
      │ PostgreSQL  │ │ PostgreSQL  │ │ PostgreSQL  │
      │192.168.87.54│ │192.168.87.57│ │192.168.87.66│
      └─────────────┘ └─────────────┘ └─────────────┘
```

## Key Features

- **Automatic Failover**: repmgrd monitors the cluster and promotes a standby if the primary fails
- **Read Scaling**: HAProxy distributes read queries across standby nodes
- **VIP Failover**: Keepalived ensures the virtual IP moves to a healthy node
- **Zero-Downtime Switchover**: Planned maintenance can be performed without application impact

## Support

For issues not covered in the [Troubleshooting Guide](04-troubleshooting-guide.md), contact:

- DBA Team: _______________
- Infrastructure Team: _______________

## Version Information

| Component | Version |
|-----------|---------|
| PostgreSQL | 17 |
| repmgr | 5.5 |
| HAProxy | 2.8 |
| Keepalived | 2.x |
| Ubuntu | 24.04 LTS |

---

*Documentation generated: January 2026*
