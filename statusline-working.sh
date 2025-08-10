#\!/bin/bash

# Simplified statusline with game
cwd_display="/$(basename "$PWD")"
git_branch=$(git branch --show-current 2>/dev/null || echo 'no-git')
chaos_vibes=("vibing" "coding" "existing" "debugging" "slightly feral" "in the zone" "totally fine" "unhinged mode")
chaos_mood=${chaos_vibes[$RANDOM % ${#chaos_vibes[@]}]}
status_chaos=("commits: maybe" "bugs: probably" "tests: what tests" "docs: someday" "sanity: optional" "(╯°□°）╯︵ ┻━┻" "don't ask")
status_msg=${status_chaos[$RANDOM % ${#status_chaos[@]}]}

# Random border style
border_style=$((RANDOM % 5))
case $border_style in
    0) statusline="✧･ﾟ ${chaos_mood} in ~${cwd_display} ･ﾟ✧ | ${git_branch} | ${status_msg}" ;;
    1) statusline="◌ ${chaos_mood} in ~${cwd_display} ◌ | ${git_branch} | ${status_msg}" ;;
    2) statusline="> literally just ${chaos_mood} in ~${cwd_display} | ${git_branch} | ${status_msg}" ;;
    3) statusline="[ ${chaos_mood} ] in ~${cwd_display} | ${git_branch} | ${status_msg}" ;;
    4) statusline="*${chaos_mood}* in ~${cwd_display} | ${git_branch} | ${status_msg}" ;;
esac

# Get game display
game_display=$(bash /Users/crabstove/dev/productivity-game-claude-code/productivity-game.sh)

# Output with game
echo "${statusline}          ${game_display}"
