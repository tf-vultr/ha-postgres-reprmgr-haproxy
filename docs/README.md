# PostgreSQL High Availability Cluster

This documentation covers the deployment, operation, and maintenance of a highly available PostgreSQL cluster using **repmgr**, **HAProxy**, and **Keepalived**.

## Project Status & Limitations

> [!IMPORTANT]
> This project is currently in an active refinement phase. While the core architecture is functional, some features are experimental.

- **Status**: Beta / Active Development
- **Verified Platforms**: Ubuntu 24.04 LTS
- **Known Limitations**:
    - **Single VIP**: All traffic currently routes through a single floating IP, which can be a single point of failure if the underlying network infrastructure does not support high availability.
    - **Asynchronous Replication**: Default configuration is asynchronous; small data loss is possible during failover (typically < 1 second of transactions).
    - **No Fencing**: Split-brain prevention currently relies on network configuration and unique constraints. Fencing (isolating a failed node to prevent it from re-joining as a primary) is **TBC**.

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

*Note: IPs shown are examples. Replace with your actual cluster VIP.*

```bash
# Write operations (connects to PRIMARY)
psql -h <CLUSTER_VIP> -p 5000 -U <username> -d <database>

# Read operations (connects to STANDBY)
psql -h <CLUSTER_VIP> -p 5001 -U <username> -d <database>
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

*Example topology:*
```
                      VIP: <CLUSTER_VIP>
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
      │ (Primary)   │ │ (Standby)   │ │ (Standby)   │
      └─────────────┘ └─────────────┘ └─────────────┘
```

## Key Features

- **Automated Failover**: `repmgrd` monitors the cluster and promotes a standby if the primary fails.
- **Read Replica Load Balancing**: HAProxy distributes read queries across standby nodes.
- **VIP Management**: Keepalived ensures the virtual IP moves to a healthy node.
- **Minimal Downtime Operations**: Planned maintenance can be performed with reduced impact using controlled switchovers.

## Version Information

| Component | Version |
|-----------|---------|
| PostgreSQL | 17 |
| repmgr | 5.5 |
| HAProxy | 2.8 |
| Keepalived | 2.x |
| Ubuntu | 24.04 LTS |

## Support

For issues not covered in the [Troubleshooting Guide](04-troubleshooting-guide.md), please check existing issues or contact the project maintainers.
