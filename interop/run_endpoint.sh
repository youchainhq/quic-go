#!/bin/bash
set -e

# Set up the routing needed for the simulation.
/setup.sh

echo "Using commit:" `cat commit.txt`

echo "Starting tcpdump"
nohup tcpdump -i eth0 -w /logs/eth0.pcap &
echo "Started tcpdump"

if [ "$ROLE" == "client" ]; then
    # Wait for the simulator to start up.
    TIMEOUT=3000
    echo "Waiting $TIMEOUT seconds for the simulator"
    wait-for-it 193.167.0.2:57832 -s -t $TIMEOUT
    echo "Starting QUIC client..."
    echo "Client params: $CLIENT_PARAMS"
    echo "Test case: $TESTCASE"
    QUIC_GO_LOG_LEVEL=debug ./client $CLIENT_PARAMS $REQUESTS
else
    echo "Running QUIC server."
    QUIC_GO_LOG_LEVEL=debug ./server "$@"
fi
