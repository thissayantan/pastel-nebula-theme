# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single [Oh My Posh](https://ohmyposh.dev/) prompt theme. The entire theme lives in `pastel-nebula.omp.json` (config schema `"version": 3`); everything else is docs (`README.md`, `pastel-nebula.png` preview, `LICENSE`). There is no build, test, lint, or release tooling — distribution is "download the one JSON file."

## Previewing a change

After editing the theme, render it to eyeball the change before committing:

```bash
oh-my-posh print primary --config pastel-nebula.omp.json --shell zsh
```

Requires a [Nerd Font](https://www.nerdfonts.com/) terminal to see the glyphs correctly.

Note: `oh-my-posh print` silently falls back to a default prompt on a broken config (it exits 0), and there is no `config validate` subcommand in this version — so it does **not** catch malformed JSON. Validate JSON syntax separately with `jq empty pastel-nebula.omp.json` (a PostToolUse hook in `.claude/settings.json` does this automatically after edits).

## Editing conventions

- **Color palette**: each segment pairs a dark `foreground` with a pale pastel `background` of the same hue family (e.g. path = `#00474E` on `#D8E2CF`). Preserve that dark-on-pastel pairing when changing colors. Colors are explicit hex values.
- **Nerd Font glyphs** are raw escaped code points (e.g. ``) inside `template` strings — keep them valid or icons break. The execution-time template ends with a braille blank `⠀` (an intentional invisible spacer); don't delete it.
- The Python virtualenv is rendered by a dedicated `text` segment (the `python` segment has `fetch_virtual_env: false`) — edit venv display there, not on the `python` segment.
- Keep the install snippets and the filename referenced in `README.md` in sync with any rename of the `.omp.json`.

## Commits

Format: `<emoji> <type>: <lowercase description>`, following Conventional Commits with a leading gitmoji — e.g. `✨ feat:`, `📝 docs:`, `🐛 fix:`, `🚀 chore:`.
