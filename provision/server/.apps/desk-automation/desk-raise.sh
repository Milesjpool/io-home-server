#!/bin/bash
# Raise standing desk via HTTP API

DESK_URL="http://desk.aesop"
DESK_COMMAND="/api/raise"  # Adjust endpoint as needed

curl -s -X POST "${DESK_URL}${DESK_COMMAND}" || echo "Failed to raise desk at $(date)"


