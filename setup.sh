#!/usr/bin/env bash

BOLD() { tput bold; }
RED() { tput setaf 1; }
GREEN() { tput setaf 2; }
NORMAL() { tput sgr0; }
printInfo() { BOLD; printf "%s\n" "$1"; NORMAL; }
printSuccess() { BOLD; GREEN; printf "%s\n" "$1"; NORMAL; }
printError() { BOLD; RED; printf "%s\n" "$1"; NORMAL; }

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
			printError "Unrecognized option: '$1'"
			usage 1
			;;
	esac
	shift
done

# Methods

check_install() {
	type "$1" &> /dev/null
}

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

# Start

tput clear

# Homebrew

if ask_install "brew"; then
	printInfo "Installing homebrew..."

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"

	check_install "brew" || {
		printError "Homebrew was not installed successfully. Please install homebrew: https://brew.sh/"
		exit 1
	}

	# shellcheck disable=SC2016
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$dotzprofile"

	tput clear

	printSuccess "Finished installing Homebrew"
fi

# ASDF

if ask_install "asdf"; then
	printInfo "Installing ASDF..."

	brew install coreutils curl git asdf

	check_install "asdf" || {
		printError "ASDF was not installed successfully. Please install asdf: https://asdf-vm.com/guide/getting-started.html"
		exit 1
	}

	# shellcheck disable=SC2016
	echo '. $(brew --prefix asdf)/libexec/asdf.sh' >> "$dotzprofile"

	# shellcheck disable=SC1091
	. "$(brew --prefix asdf)"/libexec/asdf.sh

	tput clear

	printSuccess "Finished installing ASDF"
fi
