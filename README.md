# cracked-bar

> a chaotic productivity tracker that makes you compete with yourself because external validation is temporary but personal bests are forever

## what is this

imagine if your terminal had a little friend that tracks how much you're coding and silently judges you when you're not beating your personal best. that's cracked-bar.

it's a statusline addon for claude code that:
- tracks your actual coding time (not just time with the editor open)
- shows you a progress bar comparing today vs your personal best
- displays fun chaos moods like "slightly feral" and "unhinged mode"
- reminds you that tests are optional and sanity is negotiable

## the vibe

```
✧･ﾟ slightly feral in ~/cracked-bar ･ﾟ✧ | main | (╯°□°）╯︵ ┻━┻          tokens burned: 4.2k | ████████░░
```

when you hit 130% of your personal best:
```
> literally just unhinged mode in ~/cracked-bar | main | don't ask          tokens burned: 6.9k | TOUCH GRASS MAYBE?
```

## how it works

tracks your productivity through claude code hooks:
- measures actual time spent getting responses and running tools
- saves daily stats to `~/.claude-code/productivity.json`
- compares today's grind to your personal best
- progress bar fills as you approach your record

## installation (wip)

1. clone this repo
2. run the install script (when it works):
   ```bash
   ./install.sh
   ```

3. or manually add to your claude code settings:
   - copy the statusline command from `statusline-working.sh`
   - add the hooks from `hooks/track-activity.sh`

## current status

very much work in progress. things that work:
- chaos moods and status messages ✓
- progress bar display ✓
- token counter (placeholder) ✓
- personal best tracking (when hooks are configured) ~

things that don't:
- automatic hook installation
- actual token counting from claude code
- proper activity tracking (needs hook integration)
- the install script (it's trying its best)

## philosophy

why track productivity? because:
- seeing numbers go up activates neurons
- competing with yesterday-you is healthier than comparing to others
- sometimes you need a progress bar to realize you've been coding for 8 hours straight
- "touch grass maybe?" is self-care

---

*built with chaos, maintained with vibes*