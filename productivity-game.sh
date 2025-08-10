#!/bin/bash

# Claude Code Productivity Game - Standalone module
# Outputs: "tokens burned: X.Xk | [10-char progress bar]"
# Designed to be appended to any existing statusline

PRODUCTIVITY_FILE="$HOME/.claude-code/productivity.json"

# Ensure directory exists
mkdir -p "$HOME/.claude-code"

# Initialize productivity file if it doesn't exist
if [ ! -f "$PRODUCTIVITY_FILE" ]; then
    cat > "$PRODUCTIVITY_FILE" << 'EOF'
{
  "personalBest": 0,
  "today": {
    "date": "1970-01-01",
    "activeMinutes": 0
  },
  "history": []
}
EOF
fi

# Function to handle day rollover
check_day_rollover() {
    local current_date=$(date +%Y-%m-%d)
    
    # Check for day rollover and update if needed
    python3 << EOF
import json

with open('$PRODUCTIVITY_FILE', 'r') as f:
    data = json.load(f)

current_date = '$current_date'
old_date = data['today']['date']

# Check for day rollover
if old_date != current_date:
    # Save to history if there was activity
    if data['today']['activeMinutes'] > 0:
        data['history'].append({
            'date': old_date,
            'minutes': data['today']['activeMinutes']
        })
        # Update personal best if needed
        if data['today']['activeMinutes'] > data['personalBest']:
            data['personalBest'] = data['today']['activeMinutes']
    # Reset for new day
    data['today'] = {
        'date': current_date,
        'activeMinutes': 0
    }
    
    with open('$PRODUCTIVITY_FILE', 'w') as f:
        json.dump(data, f, indent=2)
EOF
}

# Check for day rollover
check_day_rollover

# TODO: Add proper tracking of active minutes via Claude Code hooks
# This will be implemented when hooks are configured to track:
# - Response generation time (UserPromptSubmit -> Stop)
# - Tool execution time (PreToolUse -> PostToolUse)

# Generate productivity game display
game_display=$(python3 << 'EOF'
import json
import os

try:
    with open(os.path.expanduser('~/.claude-code/productivity.json'), 'r') as f:
        data = json.load(f)
    
    personal_best = data['personalBest']
    today_minutes = data['today']['activeMinutes']
    
    # Calculate progress
    if personal_best == 0:
        display = "░░░░░░░░░░"
    else:
        percent = (today_minutes / personal_best) * 100
        
        if percent >= 130:
            display = "TOUCH GRASS MAYBE?"
        elif percent >= 120:
            display = "CRACKED ENGINEER"
        elif percent >= 110:
            display = "god chosen dev"
        elif percent >= 100:
            display = "gmi"
        else:
            filled = int(percent / 10)
            empty = 10 - filled
            display = "█" * filled + "░" * empty
    
    print(display)
except:
    print("░░░░░░░░░░")
EOF
)

# Get token count from Claude Code environment
# TODO: Replace with actual token extraction from Claude Code
# For now, using placeholder that simulates token usage
if [ -f "$HOME/.claude-code/session_tokens" ]; then
    token_count=$(cat "$HOME/.claude-code/session_tokens")
else
    # Placeholder: accumulate based on activity
    token_count=$(python3 << 'EOF'
import json
import os

try:
    with open(os.path.expanduser('~/.claude-code/productivity.json'), 'r') as f:
        data = json.load(f)
    # Rough estimate: 100 tokens per active minute
    tokens = data['today']['activeMinutes'] * 0.1
    print(f"{tokens:.1f}")
except:
    print("0.0")
EOF
    )
fi

# Output the game display
echo "tokens burned: ${token_count}k | $game_display"