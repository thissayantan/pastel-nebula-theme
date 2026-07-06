#!/bin/sh
# Pastel Nebula theme installer for Oh My Posh.
#
#   curl -fsSL https://raw.githubusercontent.com/thissayantan/pastel-nebula-theme/main/install.sh | sh
#
# Downloads pastel-nebula.omp.json into ~/.config/oh-my-posh/themes/ and offers to
# add the `oh-my-posh init` line to your shell rc (default Yes; idempotent).
#
# Flags:
#   --dir <path>     where to install the theme (default: $XDG_CONFIG_HOME/oh-my-posh/themes)
#   --shell <name>   target shell for the init line (default: detected from $SHELL)
#   --no-shell       just install the file + print the init line; don't touch any rc
#
# Hardened: HTTPS-only, no sudo, body wrapped in a function called at the very end
# (guards against a truncated download executing half a script).

set -u

REPO="thissayantan/pastel-nebula-theme"
THEME="pastel-nebula.omp.json"
DEST_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/oh-my-posh/themes"
SHELL_NAME=""
WIRE_SHELL=1

main() {
	parse_args "$@"
	need curl || need wget || err "need curl or wget"

	config="${DEST_DIR}/${THEME}"
	mkdir -p "$DEST_DIR" || err "cannot create ${DEST_DIR}"

	say "Downloading ${THEME}…"
	fetch "https://raw.githubusercontent.com/${REPO}/main/${THEME}" "$config" || err "download failed"
	if need jq && ! jq empty "$config" >/dev/null 2>&1; then
		err "downloaded theme is not valid JSON (aborting)"
	fi
	say "Installed theme → ${config}"

	need oh-my-posh || say "note: oh-my-posh not found on PATH — install it first: https://ohmyposh.dev/docs/installation"

	[ -z "$SHELL_NAME" ] && SHELL_NAME="$(basename "${SHELL:-sh}")"
	wire_shell "$config" "$SHELL_NAME"
}

parse_args() {
	while [ $# -gt 0 ]; do
		case "$1" in
			--dir)      DEST_DIR="$2"; shift 2 ;;
			--shell)    SHELL_NAME="$2"; shift 2 ;;
			--no-shell) WIRE_SHELL=0; shift ;;
			*)          err "unknown flag: $1" ;;
		esac
	done
}

# wire_shell prints the init line for the target shell and (unless --no-shell)
# offers to append it to the rc file when it's not already there.
wire_shell() {
	config="$1"; sh_name="$2"
	case "$sh_name" in
		zsh)  rc="${ZDOTDIR:-$HOME}/.zshrc"; line="eval \"\$(oh-my-posh init zsh --config '${config}')\"" ;;
		bash) rc="${HOME}/.bashrc";          line="eval \"\$(oh-my-posh init bash --config '${config}')\"" ;;
		fish) rc="${HOME}/.config/fish/config.fish"; line="oh-my-posh init fish --config '${config}' | source" ;;
		pwsh|powershell)
			say "PowerShell: add this to your \$PROFILE, then restart:"
			say "  oh-my-posh init pwsh --config \"${config}\" | Invoke-Expression"
			return 0 ;;
		*)
			line="eval \"\$(oh-my-posh init ${sh_name} --config '${config}')\""
			say "Add this to your shell's startup file, then restart:"
			say "  ${line}"
			return 0 ;;
	esac

	if [ "$WIRE_SHELL" -eq 0 ]; then
		say "Add this to ${rc}, then restart your shell:"
		say "  ${line}"
		return 0
	fi
	if [ -f "$rc" ] && grep -q "$THEME" "$rc" 2>/dev/null; then
		say "Already wired in ${rc} — nothing to do."
		return 0
	fi

	answer=y
	if [ -r /dev/tty ]; then
		printf '  Add the theme to %s now? [Y/n] ' "$rc"
		read answer < /dev/tty 2>/dev/null || answer=y
	fi
	case "$answer" in
		[Nn]*)
			say "Skipped. Add this line to ${rc} yourself, then restart:"
			say "  ${line}" ;;
		*)
			mkdir -p "$(dirname "$rc")"
			printf '\n# Pastel Nebula theme for Oh My Posh\n%s\n' "$line" >> "$rc" \
				|| err "could not write ${rc}"
			say "Wired into ${rc} — restart your shell (or: source '${rc}') to see it." ;;
	esac
}

fetch() { # url dest
	if need curl; then curl --proto '=https' --tlsv1.2 -fsSL "$1" -o "$2"
	else wget -q "$1" -O "$2"; fi
}

need() { command -v "$1" >/dev/null 2>&1; }
say()  { printf '  %s\n' "$*"; }
err()  { printf 'error: %s\n' "$*" >&2; exit 1; }

main "$@"
