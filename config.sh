# Configuration
PACKET_COUNT=5
DATA_DIR="./data"                # Directory where RRD files are stored
FPING_CMD="/usr/bin/fping"       # Path to the fping command
FPING_OPTIONS="-C ${PACKET_COUNT} -q"
STEP=60                          # Step interval for RRD (in seconds)

SCRIPT_DIR=$(dirname "$0")
DATA_DIR="${SCRIPT_DIR}/${DATA_DIR}"
