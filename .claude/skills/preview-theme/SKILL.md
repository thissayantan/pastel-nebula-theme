---
name: preview-theme
description: Render the Pastel Nebula Oh My Posh theme so a color/segment change can be eyeballed without wiring it into a live shell. Use after editing pastel-nebula.omp.json.
---

# Preview the theme

Render the theme's primary prompt for the current directory so a color/segment change can be seen.

```bash
oh-my-posh print primary --config pastel-nebula.omp.json --shell zsh
```

`print primary` silently falls back to a default prompt on a broken config (it exits 0), so it does **not** validate the file. Check JSON syntax separately: `jq empty pastel-nebula.omp.json`.

Then show the user what changed:

1. Run the command above and report whether it rendered cleanly.
2. If the change was color-related, list the affected segments with their new `foreground`/`background` hex pairs so the user can sanity-check the dark-on-pastel pairing.
3. To exercise the git/status/version segments, `cd` into a directory that has the relevant context (a git repo with changes, a Node or Python project) and re-run, or note which segments won't appear here because their trigger conditions aren't met.

Notes:
- Requires `oh-my-posh` on PATH and a Nerd Font terminal for glyphs to display correctly.
- The second block is just the input arrow (`newline: true`); the informational segments are all in block 1.
