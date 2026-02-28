# SNMP Exporter for Synology NAS

This service runs the Prometheus SNMP exporter to collect metrics from a Synology NAS.

## Installation

1. **Enable SNMPv3 on Synology NAS:**
   - Go to `Control Panel` → `Terminal & SNMP` → `SNMP`
   - Enable SNMP
   - Configure SNMPv3 with the following credentials:
     - **Username** - Create a username for SNMP access
     - **Authentication protocol:** SHA
     - **Authentication password** - Create a password for authentication
     - **Privacy protocol:** AES
     - **Privacy password** - Create a password for encryption (can be the same as auth password, but different is more secure)
   - **Important:** Use SNMPv3 only (v1 and v2 are insecure)
   - **Note:** These credentials will be need for the next step


1. **Generate snmp.yml:**

    Follow the instructions here to generate your SNMP config: [Monitoring Synology NAS Guide](https://colby.gg/posts/2023-10-17-monitoring-synology/).

    The `snmp.yml` configuration file must be generated using the snmp_exporter generator tool. The default configuration will not work.


1. **Copy the generated snmp.yml:**

   Assuming you're already in the _snmp-exporter_ directory:
   ```bash
   cp snmp.yml .
   ```


1. **Install the SNMP exporter:**

    ```bash
    cd provision/server/.apps/snmp-exporter
    ./install.sh
    ```

1. **(Optional) Test the exporter manually:**

    ```bash
    # Test if_mib module
    curl 'http://localhost:9116/snmp?target=mimas.aesop&auth=synology&module=if_mib'

    # Test synology module
    curl 'http://localhost:9116/snmp?target=mimas.aesop&auth=synology&module=synology'
    ```

    Both commands should return a long list of metrics.

    After starting the service, verify Prometheus is scraping:
    - Check Prometheus UI: `Status → Targets → snmp` (should show `mimas.aesop` as instance)
    - Verify metrics are being collected in Grafana
