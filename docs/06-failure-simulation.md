# Failure Simulation & Verification Guide

This guide provides step-by-step instructions to simulate a node outage (Primary failure) and verify that the High Availability (HA) mechanisms correctly promote a Standby to Primary.

---

## Prerequisites

Before starting, ensure the cluster is healthy and `repmgrd` is running on all nodes.

### 1. Check Cluster Status
Run this on any node:
```bash
sudo -u postgres repmgr -f /etc/repmgr.conf cluster show
```

**Expected Output:**
- One node is `* running` as **primary**.
- Other nodes are `running` as **standby** and attached to the primary.

### 2. Check repmgrd Status
Failover will **not** happen if `repmgrd` is not running.
```bash
pgrep repmgrd
# OR
sudo systemctl status repmgrd
```
*Ensure it is active/running on all Standby nodes.*

---

## Scenario: Primary Node Failure

In this scenario, we will effectively "pull the plug" on the current Primary node by stopping the PostgreSQL service. This simulates a crash or service failure.

### Step 1: Identify the Primary
Run `cluster show` to confirm which node is currently Primary.
```bash
sudo -u postgres repmgr -f /etc/repmgr.conf cluster show
```
*Let's assume `pg1` is Primary for this example.*

### Step 2: Start Monitoring on a Standby
Open a new terminal window to a **Standby** node (e.g., `pg2` or `pg3`) and follow the `repmgrd` logs. This will let you watch the election process in real-time.

```bash
# On a Standby node:
sudo journalctl -u repmgrd -f
```

### Step 3: Simulate the Outage
On the **Primary** node (`pg1`), stop the PostgreSQL service.

```bash
# On Primary (pg1):
sudo systemctl stop postgresql
```

### Step 4: Watch the Failover
Watch the logs in your Standby terminal. You should see the following sequence events:

1.  **Detection**: `unable to connect to upstream node` (Retried ~6 times).
2.  **Election**: `standby node "pgX" ... is the winner`.
3.  **Promotion**: `promoting standby to primary`.
4.  **Notification**: `notifying node "pgY" to follow node X`.

The whole process usually takes roughly 60 seconds (depending on `reconnect_attempts` and `reconnect_interval` settings).

### Step 5: Verify New Cluster State
Once the logs show successful promotion, check the cluster status on the **new Primary**.

```bash
sudo -u postgres repmgr -f /etc/repmgr.conf cluster show
```

**Expected Result:**
- The old Primary (`pg1`) is marked as `failed` / `unreachable`.
- The new Primary (`pg2` or `pg3`) is marked as `* running`.
- The remaining Standby is following the *new* Primary.

---

## Recovery: Rejoining the Old Primary

After the test, the old Primary is down and out of the cluster. To bring it back, you must rejoin it as a Standby.

### 1. Ensure the Old Primary is Up
Start the actual VM/Server if it was powered off, but **do not** start PostgreSQL yet (or stop it if it auto-started).

```bash
# On the Old Primary (pg1):
sudo systemctl stop postgresql
sudo systemctl stop repmgrd
```

### 2. Execute Node Rejoin
Use the `rejoin` command with `--force-rewind`. This will sync it with the new Primary (discarding any divergent changes).

```bash
# Run on the Old Primary (pg1):
# Replace <NEW_PRIMARY_IP> with the IP of the current Primary
sudo -u postgres repmgr -h <NEW_PRIMARY_IP> -U repmgr -d repmgr \
    -f /etc/repmgr.conf node rejoin \
    -d 'host=<NEW_PRIMARY_IP> dbname=repmgr user=repmgr' \
    --force-rewind --verbose
```

*If `pg_rewind` fails due to missing WAL files, use `standby clone` instead:*
```bash
# Alternative: Full Clone (if rejoin fails)
sudo -u postgres repmgr -h <NEW_PRIMARY_IP> -U repmgr -d repmgr \
    -f /etc/repmgr.conf standby clone --force
```

### 3. Start Services
Once the rejoin/clone is complete:

```bash
sudo systemctl start postgresql
sudo systemctl start repmgrd
```

### 4. Verify Full Recovery
Check the cluster status again. All 3 nodes should now be running, with the old Primary now serving as a healthy Standby.

```bash
sudo -u postgres repmgr -f /etc/repmgr.conf cluster show
```
