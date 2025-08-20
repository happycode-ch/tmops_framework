#!/bin/bash

# TESTER Instance Polling Script
# Polls for 001-discovery-trigger.md with exponential backoff

POLL_INTERVAL=2
MAX_INTERVAL=60
TRIGGER_FILE=""

echo "[TESTER] Starting to poll for 001-discovery-trigger.md..."

while true; do
    # Look for trigger file in any feature subdirectory
    TRIGGER_FILE=$(find .tmops -name "001-discovery-trigger.md" -type f 2>/dev/null | head -1)
    
    if [ -n "$TRIGGER_FILE" ]; then
        echo "[TESTER] Found trigger: $TRIGGER_FILE"
        echo "$TRIGGER_FILE"
        exit 0
    fi
    
    echo "[TESTER] No trigger found. Waiting ${POLL_INTERVAL}s..."
    sleep $POLL_INTERVAL
    
    # Exponential backoff
    if [ $POLL_INTERVAL -lt $MAX_INTERVAL ]; then
        POLL_INTERVAL=$((POLL_INTERVAL * 2))
        if [ $POLL_INTERVAL -gt $MAX_INTERVAL ]; then
            POLL_INTERVAL=$MAX_INTERVAL
        fi
    fi
done