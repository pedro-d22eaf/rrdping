#!/bin/bash

. config.sh

# filepath: create_rrd.sh


function createrrd() {
    # Define the RRD file name from the argument
    RRD_FILE="${DATA_DIR}/$1"

    # Check if the RRD file already exists
    if [ -f "$RRD_FILE" ]; then
        echo "RRD file '$RRD_FILE' already exists. Exiting."
        return
    fi

    # Create the RRD file
    # 24h with 1 minute intervals AVERAGE
    #
    rrdtool create "$RRD_FILE" \
        --step $STEP \
        DS:rtt:GAUGE:5m:0:200 \
        DS:loss:GAUGE:5m:0:100 \
        RRA:AVERAGE:0.5:1m:2d \
        RRA:MIN:0.5:15m:2d \
        RRA:MAX:0.5:15m:2d \
        RRA:MIN:0.5:1h:30d \
        RRA:MAX:0.5:1h:30d \
        RRA:AVERAGE:0.5:1h:30d \
        RRA:MIN:0.5:1d:1y \
        RRA:MAX:0.5:1d:1y \
        RRA:AVERAGE:0.5:1d:1y

    # Check if the RRD file was created successfully
    if [ $? -eq 0 ]; then
        echo "RRD file '$RRD_FILE' created successfully."
    else
        echo "Failed to create RRD file."
    fi
}


# Check if the target RRD file name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <config file>"
    exit 1
fi
FILE=$1

for i in $(cat $FILE); do
    # Create RRD file for each target in the target list file
    createrrd "$i.rrd"
done