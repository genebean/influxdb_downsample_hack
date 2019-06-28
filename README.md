# InfluxDB Downsampling Hack

It seems that its rather easy to out run what CQ's are capable of downsampling. This repo contains a workaround for this issue that I have been working with InfluxData's support team on.

## Usage

You will need to create a file in the root of this repo called `local_vars` that contains the following information:

```sh
export INFLUX_USERNAME='<your user name>'
export INFLUX_PASSWORD='<your password>'
export INFLUX_URL='<the fqdn without port of your InfluxDB>'
export KAPACITOR_URL="https://$INFLUX_USERNAME:$INFLUX_PASSWORD@<your kapacitor host>:9092"

export WORKING_DIR='<the path to the folder containing this file (no trailing slash)>'
```

Once that file is in place, you can run the script like so:

_Running for one database_:

```sh
./influx-ticket-41490.sh source_db_name source_retention_policy_name destination_retention_policy
```

_Running for multiple databases_:

```sh
for db in telegraf_general telegraf_vsphere; do ./influx-ticket-41490.sh $db source_retention_policy_name destination_retention_policy; done
```

### Optional debugging output

setting `DEBUG=true` either as a prefix for the command being run or as an environment variable will enable printing everything that is happening to your terminal. For example:

```sh
DEBUG=true ./influx-ticket-41490.sh source_db_name source_retention_policy_name destination_retention_policy
```
