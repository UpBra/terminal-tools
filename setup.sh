#!/usr/bin/env bash

results=()
BOLD() { tput bold; }
RED() { tput setaf 1; }
GREEN() { tput setaf 2; }
NORMAL() { tput sgr0; }
printInfo() { BOLD; printf "%s\n" "$1"; NORMAL; }
printSuccess() { BOLD; GREEN; printf "%s\n" "$1"; NORMAL; }
printError() { BOLD; RED; printf "%s\n" "$1"; NORMAL; }
success() { printSuccess "$1"; results+=("$1"); }

usage() {
cat <<EOS
Dev Setup
Usage: setup.sh [options]
	-a, --ask		Ask for confirmation on each step.
	-h, --help		Display this message.
EOS
exit "${1:-0}"
}

while [[ $# -gt 0 ]]
do
	case "$1" in
		-a | --ask) ask=true ;;
		-h | --help) usage ;;
		*)
			printError "Unrecognized option: '$1'"
			usage 1
			;;
	esac
	shift
done

# ---------------------------------------------------------------------
# Checks if a command is installed
# ---------------------------------------------------------------------
check_install() {
	type "$1" &> /dev/null
}

# ---------------------------------------------------------------------
# Asks the user for confirmation (only if the ask flag is set)
# ---------------------------------------------------------------------
ask() {
	# if ask flag is not set return yes
	[[ -z ${ask} ]] && return 0

	echo "$1"
	select yn in "Yes" "No"; do
		case $yn in
			Yes ) return 0;;
			No ) return 1;;
		esac
	done
}

# ---------------------------------------------------------------------
# Helper method to determine if the command is already installed
# If this method returns success it should be installed
# If this method returns an error do not install
# ---------------------------------------------------------------------
require_install() {
	# if its already installed return no
	if check_install "$1"; then
		return 1
	fi

	ask "Do you wish to install $1?"
}

# ---------------------------------------------------------------------
# Create .zprofile if it doesn't already exist
# ---------------------------------------------------------------------

dotzprofile="${ZDOTDIR:-$HOME}/.zprofile"
[ ! -f "$dotzprofile" ] && touch "$dotzprofile"

# ---------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------

if require_install "brew"; then
	printInfo "Installing homebrew..."

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"

	check_install "brew" || {
		printError "Homebrew was not installed successfully. Please install homebrew: https://brew.sh/"
		exit 1
	}

	# shellcheck disable=SC2016
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$dotzprofile"

	success "Installed Homebrew!"
fi

# ---------------------------------------------------------------------
# ASDF
# ---------------------------------------------------------------------

if require_install "asdf"; then
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

	success "Installed ASDF!"
fi

if ask "Do you want to install the asdf plugins?"; then
	asdf plugin add awscli
	success "Installed asdf plugin awscli"

	brew install jq
	asdf plugin add flutter
	success "Installed asdf plugin flutter"

	asdf plugin add java
	success "Installed asdf plugin java"

	asdf plugin add nodejs
	success "Installed asdf plugin nodejs"

	asdf plugin add python
	success "Installed asdf plugin python"

	asdf plugin add ruby
	success "Installed asdf plugin ruby"

	asdf plugin add terraform
	success "Installed asdf plugin terraform"
fi

# ---------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------

tput clear

printInfo "Summary"
for value in "${results[@]}"
do
	printSuccess "$value"
done

printInfo ""
printError "Quit and re-open your terminal for the changes to take effect!"

exit 0
