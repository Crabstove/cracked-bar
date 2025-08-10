#!/bin/bash

# Claude Code hook for tracking active minutes
# This hook is called by UserPromptSubmit and Stop events to track response time
# Also called by PreToolUse and PostToolUse to track tool execution time

PRODUCTIVITY_FILE="$HOME/.claude/productivity.json"
TIMING_FILE="$HOME/.claude/current_timing"

# Ensure directory exists
mkdir -p "$HOME/.claude"

# Parse the hook event type from input
EVENT_TYPE="$1"
TIMESTAMP=$(date +%s)

case "$EVENT_TYPE" in
    "start")
        # Mark start of activity (UserPromptSubmit or PreToolUse)
        echo "$TIMESTAMP" > "$TIMING_FILE"
        ;;
    
    "stop")
        # Calculate duration and add to active minutes (Stop or PostToolUse)
        if [ -f "$TIMING_FILE" ]; then
            START_TIME=$(cat "$TIMING_FILE")
            DURATION=$((TIMESTAMP - START_TIME))
            # Use Python instead of bc for better portability
            MINUTES=$(python3 -c "print(round($DURATION / 60, 2))")
            
            # Only update if productivity file exists
            if [ -f "$PRODUCTIVITY_FILE" ]; then
                # Add minutes to today's total
                python3 << EOF
import json
from datetime import datetime

with open('$PRODUCTIVITY_FILE', 'r') as f:
    data = json.load(f)

current_date = datetime.now().strftime('%Y-%m-%d')

# Check for day rollover
if data['today']['date'] != current_date:
    # Save yesterday to history
    if data['today']['activeMinutes'] > 0:
        data['history'].append({
            'date': data['today']['date'],
            'minutes': data['today']['activeMinutes']
        })
        # Update personal best if needed
        if data['today']['activeMinutes'] > data['personalBest']:
            data['personalBest'] = data['today']['activeMinutes']
    # Start new day
    data['today'] = {
        'date': current_date,
        'activeMinutes': $MINUTES
    }
else:
    # Add to today's total
    data['today']['activeMinutes'] += $MINUTES

with open('$PRODUCTIVITY_FILE', 'w') as f:
    json.dump(data, f, indent=2)
EOF
            fi
            
            # Always clean up timing file
            rm -f "$TIMING_FILE"
        fi
        ;;
    
    *)
        # Unknown event type - clean up any orphaned timing files
        rm -f "$TIMING_FILE"
        ;;
esac