#!/bin/bash
# Kill all running lake processes

if pgrep -x lake > /dev/null; then
    echo "Killing lake processes..."
    pkill -x lake
    echo "Done."
else
    echo "No lake processes running."
fi
