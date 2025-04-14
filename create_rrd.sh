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
    rrdtool create "$RRD_FILE" \
        --step $STEP \
        DS:rtt:GAUGE:120:0:10 \
        DS:loss:GAUGE:120:0:100 \
        RRA:AVERAGE:0.5:1:1440 \
        RRA:MIN:0.5:180:336 \
        RRA:MAX:0.5:180:336 

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