#!/bin/bash

# Installation script for Claude Code Productivity Game

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_CONFIG="$HOME/.claude/settings.json"
GAME_SCRIPT="$SCRIPT_DIR/productivity-game.sh"

echo "Installing Claude Code Productivity Game..."

# Make the game script executable
chmod +x "$GAME_SCRIPT"

# Check if settings.json exists
if [ ! -f "$CLAUDE_CONFIG" ]; then
    echo "Warning: Claude Code settings not found at $CLAUDE_CONFIG"
    echo "Creating new settings file..."
    mkdir -p "$(dirname "$CLAUDE_CONFIG")"
    echo '{}' > "$CLAUDE_CONFIG"
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
    current_command = config.get('statusLine', {}).get('command', '')
    
    # Check if game is already installed
    if 'productivity-game.sh' in current_command:
        print("Productivity game is already installed.")
        sys.exit(0)
    
    # Create new command that appends game to existing statusline
    if current_command:
        # Append game to existing statusline with separator
        new_command = f'''existing_statusline=$({current_command})
game_display=$({game_script})
echo "$existing_statusline  |  $game_display"'''
    else:
        # No existing statusline: just show the game
        new_command = game_script
    
    # Update config
    if 'statusLine' not in config:
        config['statusLine'] = {}
    if isinstance(config['statusLine'], dict):
        config['statusLine']['command'] = new_command.strip()
    else:
        config['statusLine'] = {'type': 'command', 'command': new_command.strip()}
    
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
echo "Data is stored in ~/.claude/productivity.json"