[ "$DEBUG" == 'true' ] && set -x

# bring in the non-sharable things.
source local_vars

### Step One --- cleaning out existing jobs
### First line, deletes all the existing kapacitor scripts that start with 'hack'
### Change as you see fit, I just wanted a way to differentiate the ones
### that are made with this script from others

kapacitor list tasks | grep -e '^hack_' | awk '{print $1}' > $WORKING_DIR/tmp/kapatmp.txt

for OLDKAP in $(cat $WORKING_DIR/tmp/kapatmp.txt);do

kapacitor delete tasks $OLDKAP

done

### Step Two --- getting the measurements
### This will require credentials and whatnot to make the connection to your DB

influx -host $INFLUX_URL -port 8086 -username $INFLUX_USERNAME -password $INFLUX_PASSWORD -ssl --execute "show measurements on $DB_NAME" > $WORKING_DIR/tmp/dbtmp.txt

for MEASUREMENT in $(tail -n +4 $WORKING_DIR/tmp/dbtmp.txt );do

### Alters a stock .json file to create specific ones for the measurement in the loop
cat $WORKING_DIR/hack_empty.json | sed "s/empty/"$MEASUREMENT"/g" > tmp/hack_$MEASUREMENT.json

### Does the kapacitor mojo to create the task and enable it
kapacitor define hack_$MEASUREMENT -file $WORKING_DIR/tmp/hack_$MEASUREMENT.json
kapacitor enable hack_$MEASUREMENT

done


### Lists all tasks when done
kapacitor list tasks

