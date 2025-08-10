# Claude Code Productivity Game

A motivational productivity tracker for Claude Code that gamifies your coding sessions. Track your daily active usage and compete against your personal best!

## What it does

Adds a productivity game to your Claude Code statusline that displays:
- **Token burn counter** - Shows how many tokens you've used today
- **Progress bar** - Visual representation of today's productivity vs your personal best
- **Achievement messages** - Special messages when you hit milestones

## Display Examples

```
Your existing statusline                    tokens burned: 12.3k | ████░░░░░░
Your existing statusline                    tokens burned: 15.2k | CRACKED ENGINEER
Your existing statusline                    tokens burned: 8.1k | ██████░░░░
```

## Progress Indicators

- `░░░░░░░░░░` - Just starting (0% of personal best)
- `████░░░░░░` - 40% of personal best  
- `████████░░` - 80% of personal best
- `gmi` - 100% of personal best (you're gonna make it!)
- `god chosen dev` - 110% of personal best
- `CRACKED ENGINEER` - 120% of personal best
- `TOUCH GRASS MAYBE?` - 130% of personal best

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/productivity-game-claude-code.git
cd productivity-game-claude-code
```

2. Run the installation script:
```bash
chmod +x install.sh
./install.sh
```

The installer will:
- Backup your existing Claude Code settings
- Append the productivity game to your current statusline
- Configure hooks to track your actual Claude Code usage
- Create tracking files in `~/.claude-code/`

## How it Works

### Active Time Tracking
The game automatically tracks "active minutes" - total time Claude Code spends:
- Generating responses
- Executing tools
- Running code

Tracking starts immediately after installation!

### Daily Rollover
- At midnight (or first use of a new day), yesterday's score is saved
- Personal best updates if you beat your record
- New day starts fresh at 0

### Data Storage
Your productivity data is stored in `~/.claude-code/productivity.json`:
```json
{
  "personalBest": 145,
  "today": {
    "date": "2025-08-09", 
    "activeMinutes": 72
  },
  "history": [
    {"date": "2025-08-08", "minutes": 145},
    {"date": "2025-08-07", "minutes": 89}
  ]
}
```

## Uninstallation

To remove the productivity game:
1. Restore your backup: `cp ~/.claude-code/settings.json.backup.* ~/.claude-code/settings.json`
2. Remove tracking files: `rm ~/.claude-code/productivity.json`

## Future Enhancements

- [ ] Hook into Claude Code events for accurate tracking:
  - Response generation time (UserPromptSubmit → Stop)  
  - Tool execution time (PreToolUse → PostToolUse)
- [ ] Add weekly/monthly statistics
- [ ] Export productivity reports
- [ ] Customizable achievement thresholds
- [ ] Different game modes (efficiency vs volume)

## Contributing

PRs welcome! Some ideas:
- Better token tracking integration
- Additional game modes
- Statistics visualization
- Custom achievement messages

## License

MIT

## Credits

Created with subtle chaos energy and the motivation to track productivity without being too serious about it.