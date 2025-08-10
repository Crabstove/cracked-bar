#!/bin/bash

# Installation script for Claude Code Productivity Game

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_CONFIG="$HOME/.claude-code/settings.json"
GAME_SCRIPT="$SCRIPT_DIR/productivity-game.sh"

echo "Installing Claude Code Productivity Game..."

# Make the game script executable
chmod +x "$GAME_SCRIPT"

# Check if settings.json exists
if [ ! -f "$CLAUDE_CONFIG" ]; then
    echo "Error: Claude Code settings not found at $CLAUDE_CONFIG"
    echo "Please ensure Claude Code is installed and configured first."
    exit 1
fi

# Backup existing settings
cp "$CLAUDE_CONFIG" "$CLAUDE_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
echo "Backed up existing settings to $CLAUDE_CONFIG.backup.*"

# Make hook script executable
chmod +x "$SCRIPT_DIR/hooks/track-activity.sh"

# Update the statusline command and hooks using Python to modify JSON
python3 << EOF
import json
import sys
import os

config_file = '$CLAUDE_CONFIG'
game_script = '$GAME_SCRIPT'
hook_script = '$SCRIPT_DIR/hooks/track-activity.sh'

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    # Get current statusline command
    current_command = config.get('statusLine', '')
    
    # Check if game is already installed
    if 'productivity-game.sh' in current_command:
        print("Productivity game is already installed.")
        sys.exit(0)
    
    # Create new command that appends game to existing statusline
    if current_command:
        # Existing statusline: append game with right-alignment
        new_command = f'''
# Get existing statusline
existing_statusline=\$({current_command})

# Get productivity game display
game_display=\$({game_script})

# Get terminal width
term_width=\$(tput cols 2>/dev/null || echo 80)

# Calculate padding
existing_length=\${#existing_statusline}
game_length=\${#game_display}
total_length=\$((existing_length + game_length + 2))

if [ \$total_length -lt \$term_width ]; then
    # Add padding to push game to the right
    padding_length=\$((term_width - total_length))
    padding=\$(printf '%*s' \$padding_length '')
    echo "\$existing_statusline\$padding  \$game_display"
else
    # No room for padding
    echo "\$existing_statusline  \$game_display"
fi
'''
    else:
        # No existing statusline: just show the game
        new_command = game_script
    
    # Update config
    config['statusLine'] = new_command.strip()
    
    # Add hooks for activity tracking
    if 'hooks' not in config:
        config['hooks'] = {}
    
    # Define our hook commands
    start_cmd = f"{hook_script} start"
    stop_cmd = f"{hook_script} stop"
    
    # Helper function to add hook
    def add_hook(event_name, command):
        if event_name not in config['hooks']:
            config['hooks'][event_name] = []
        
        # Check if hook already exists
        for hook_group in config['hooks'][event_name]:
            if 'hooks' in hook_group:
                for hook in hook_group['hooks']:
                    if hook.get('command') == command:
                        return  # Hook already exists
        
        # Add the hook
        config['hooks'][event_name].append({
            'hooks': [{
                'type': 'command',
                'command': command
            }]
        })
    
    # Add all necessary hooks
    add_hook('UserPromptSubmit', start_cmd)
    add_hook('Stop', stop_cmd)
    add_hook('PreToolUse', start_cmd)
    add_hook('PostToolUse', stop_cmd)
    
    # Write updated config
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print("Successfully installed productivity game to statusline!")
    
except Exception as e:
    print(f"Error updating settings: {e}")
    sys.exit(1)
EOF

echo ""
echo "Installation complete!"
echo ""
echo "The productivity game will now appear on the right side of your statusline."
echo "It tracks your active Claude Code usage and shows:"
echo "  - Daily token burn count"
echo "  - Progress bar comparing today's activity to your personal best"
echo ""
echo "Progress indicators:"
echo "  ░░░░░░░░░░ = Starting out"
echo "  ████░░░░░░ = 40% of personal best"
echo "  gmi = 100% of personal best"
echo "  CRACKED ENGINEER = 120% of personal best"
echo "  TOUCH GRASS MAYBE? = 130% of personal best"
echo ""
echo "Data is stored in ~/.claude-code/productivity.json"