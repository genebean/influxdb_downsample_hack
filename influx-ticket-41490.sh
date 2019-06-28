if [ "$#" -ne 3 ]; then
    echo "Usage: $0 db_name from_rp_name to_rp_name"
    exit 1
fi

[ "$DEBUG" == 'true' ] && set -x

# bring in the non-sharable things.
source local_vars

# To enable working with more than one db we get the db's name from stdin
export DB_NAME=$1
export FROM_RP_NAME=$2
export TO_RP_NAME=$3

### Step One --- cleaning out existing jobs
### First line, deletes all the existing kapacitor scripts that start with 'hack'
### Change as you see fit, I just wanted a way to differentiate the ones
### that are made with this script from others

kapacitor list tasks | grep "hack_${DB_NAME}_" | awk '{print $1}' > $WORKING_DIR/tmp/kapatmp.txt

for OLDKAP in $(cat $WORKING_DIR/tmp/kapatmp.txt);do
  kapacitor delete tasks $OLDKAP
done

### Step Two --- getting the measurements
### This will require credentials and whatnot to make the connection to your DB

influx -host $INFLUX_URL -port 8086 -username $INFLUX_USERNAME -password $INFLUX_PASSWORD -ssl --execute "show measurements on $DB_NAME" > $WORKING_DIR/tmp/dbtmp.txt

for MEASUREMENT in $(tail -n +4 $WORKING_DIR/tmp/dbtmp.txt );do
  ### Alters a stock .json file to create specific ones for the measurement in the loop
  cat $WORKING_DIR/hack_empty.yaml \
  | sed "s/replace_with_db/"$DB_NAME"/g" \
  | sed "s/replace_with_from_rp/"$FROM_RP_NAME"/g" \
  | sed "s/replace_with_to_rp/"$TO_RP_NAME"/g" \
  | sed "s/replace_with_measurement/"$MEASUREMENT"/g" \
  > "tmp/hack_${DB_NAME}_${MEASUREMENT}.yaml"

  ### Does the kapacitor mojo to create the task and enable it
  kapacitor define "hack_${DB_NAME}_${MEASUREMENT}" -file "${WORKING_DIR}/tmp/hack_${DB_NAME}_${MEASUREMENT}.yaml"
  kapacitor enable "hack_${DB_NAME}_${MEASUREMENT}"
done


### Lists all tasks when done
kapacitor list tasks
