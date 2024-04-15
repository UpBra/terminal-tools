#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"
ttys() { if [[ ! -t 1 ]]; then printf "\033[%sm" "$1"; else :; fi }
ttyr() { ttys 0; }
tty0() { ttys "0;$1"; }
tty1() { ttys "1;$1"; }
info() { printf "$(tty0 32)%s$(ttyr)\n" "$@"; }
warn() { printf "$(tty1 31)Warning$(ttyr): $(tty1 30)%s$(ttyr)\n" "$@"; }

usage() {
cat <<EOS
Dev Setup
Usage: setup.sh [options]
	-h, --help		Display this message.
	-f, --force		Force. Install without prompting for user input
EOS
exit "${1:-0}"
}

while [[ $# -gt 0 ]]
do
	case "$1" in
		-h | --help) usage ;;
		-f | --force) force=true ;;
		*)
			warn "Unrecognized option: '$1'"
			usage 1
			;;
	esac
	shift
done

# Ask Methods

ask() {
	# if force flag then don't ask. return yes
	[[ -n ${force} ]] && return 0

	echo "$1"
	select yn in "Yes" "No"; do
		case $yn in
			Yes ) return 0;;
			No ) return 1;;
		esac
	done
}

ask_install() {
	# if its already installed don't ask
	if type "$1" &> /dev/null; then
		return 1
	fi

	ask "Do you wish to install $1?"
}

# Dot Zprofile

dotzprofile="${ZDOTDIR:-$HOME}/.zprofile"
[ ! -f "$dotzprofile" ] && touch "$dotzprofile"

# Homebrew

if ask_install "brew"; then
	info "Installing homebrew..."

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# shellcheck disable=SC2016
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$dotzprofile"
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ASDF

if ask_install "asdf"; then
	info "Installing ASDF..."

	brew install coreutils curl git asdf

	# shellcheck disable=SC2016
	echo '. $(brew --prefix asdf)/libexec/asdf.sh' >> "$dotzprofile"

	# shellcheck disable=SC1091
	. "$(brew --prefix asdf)"/libexec/asdf.sh
fi
