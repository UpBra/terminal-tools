#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"

if [[ -t 1 ]]; then TTY=0; fi
tty_escape() { if [ "$TTY" -eq 0 ]; then printf "\033[%sm" "$1"; else :; fi }
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

usage() {
cat <<EOS
Dev Setup
Usage: setup.sh [options]
	-h, --help		Display this message.
	-f, --force		Force. Install without prompting for user input
EOS
exit "${1:-0}"
}

shell_join() {
	local arg
	printf "%s" "$1"
	shift
	for arg in "$@"
	do
		printf " "
		printf "%s" "${arg// /\ }"
	done
}

chomp() {
	printf "%s" "${1/"$'\n'"/}"
}

ohai() {
	printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
	printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
}

while [[ $# -gt 0 ]]
do
	case "$1" in
		-h | --help) usage ;;
		-f | --force) force=0 ;;
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
	if [ "$force" -eq 0 ]; then exit 0; fi

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

# Homebrew

if ask_install "brew"; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
