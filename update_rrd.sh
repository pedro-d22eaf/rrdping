#!/usr/bin/bash

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/config.sh

# Check if the target list file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <target_list_file>"
    exit 1
fi

# Define the target list file
TARGET_LIST_FILE="$1"

# Check if the target list file exists
if [ ! -f "$TARGET_LIST_FILE" ]; then
    echo "Error: Target list file '$TARGET_LIST_FILE' not found."
    exit 1
fi

# Ensure the data directory exists
if [ ! -d "$DATA_DIR" ]; then
    echo "Error: Data directory '$DATA_DIR' not found."
    exit 1
fi

function collect_update() {
    local step=$1
    echo "Processing step: $step"

    # Loop through each target in the target list file
    while IFS= read -r target || [ -n "$target" ]; do
        # Skip empty lines or comments
        if [[ -z "$target" || "$target" =~ ^# ]]; then
            continue
        fi

        # Define the RRD file name for the target
        RRD_FILE="${target}.rrd"

        # Ping the target using fping and extract RTT values and packet loss
        # Expected fping output:
        # 192.168.1.1  : 5.68 1.71 3.27 1.83 3.49
        # 109.51.0.1   : 5.83 3.59 3.26 3.50 4.46
        # 1.1.1.1      : 5.96 3.91 3.90 3.89 4.73
        # 8.8.8.8      : 13.7 12.6 12.7 12.5 13.2
        # 192.168.1.54 : - - - - -
        OUTPUT=$($FPING_CMD $FPING_OPTIONS "$target" 2>&1 | awk -F': ' '{print $2}')
        RTT_VALUES=($(echo "$OUTPUT" | awk '{for (i=1; i<=NF; i++) print $i}'))
        PACKET_LOSS=$(echo "${RTT_VALUES[@]}" | grep -o '-' | wc -l)
        PACKET_LOSS=$((PACKET_LOSS * 100 / ${#RTT_VALUES[@]}))

        # Calculate the average RTT, ignoring packet loss
        VALID_RTT=($(echo "${RTT_VALUES[@]}" | grep -v '-'))
        if [ ${#VALID_RTT[@]} -eq 0 ]; then
            AVG_RTT="U"
        else
            AVG_RTT=$(echo "${VALID_RTT[@]}" | awk '{sum=0; for (i=1; i<=NF; i++) sum+=$i; print sum/NF}')
        fi

        echo "Target: $target, RTTs: ${RTT_VALUES[*]}, Packet Loss: $PACKET_LOSS, Avg RTT: $AVG_RTT"

        # Update the RRD file with the average RTT
        if [ -f "${DATA_DIR}/$RRD_FILE" ]; then
            rrdtool update "${DATA_DIR}/$RRD_FILE" N:"$AVG_RTT":"$PACKET_LOSS"
            if [ $? -eq 0 ]; then
                echo "Updated RRD file '$RRD_FILE' with Avg RTT: $AVG_RTT - $PACKET_LOSS"
            else
                echo "Failed to update RRD file '$RRD_FILE'."
            fi
        else
            echo "RRD file '$RRD_FILE' not found. Skipping target '$target'."
        fi
    done < "$TARGET_LIST_FILE"
}

while(true); do
    # Get the current timestamp
    CURRENT_TIME=$(date +%s)

    # Calculate the next step time
    NEXT_STEP=$((CURRENT_TIME + STEP))

    # Collect and update RRD files
    collect_update "$NEXT_STEP"

    # Sleep until the next step time
    sleep $((NEXT_STEP - CURRENT_TIME))
done
