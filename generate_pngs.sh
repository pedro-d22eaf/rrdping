#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
source ${SCRIPT_DIR}/config.sh

START="2d"

if [ ! -z "$1" ]; then
    START="$1"
fi

echo "Generating PNG files from RRD files..."

if [ ! -d "$DATA_DIR" ]; then
    echo "Error: Directory '$DATA_DIR' does not exist."
    exit 1
fi

VIA=${VIA:-null}

for rrdfile in "$DATA_DIR"/*.rrd; do
    [ -f "$rrdfile" ] || continue
    pngfile="${rrdfile%.rrd}.png"
    echo "Generating PNG for $rrdfile -> $pngfile"
    rrdtool graph "$pngfile" --start end-${START} --title "RTT and Packet Loss for $(basename "$rrdfile" .rrd) ${VIA}" \
        DEF:rtt="$rrdfile":rtt:MAX LINE1:rtt#0000FF:"RTT (ms)" \
        DEF:ploss="$rrdfile":loss:MAX LINE1:ploss#FF0000:"Packet Loss (%)" \
        --right-axis-label "Packet Loss (%)"
done

echo "PNG generation complete."
