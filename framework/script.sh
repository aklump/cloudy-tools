#!/usr/bin/env bash

#
# @file
# Lorem ipsum dolar sit amet consectador.
#

# Define the configuration file relative to this script.
CLOUDY_PACKAGE_CONFIG="__CONFIG";

# Uncomment this line to enable file logging.
#[[ ! "$CLOUDY_LOG" ]] && CLOUDY_LOG="__FILENAME.log"
# Or, set for a terminal session using `export CLOUDY_LOG="__FILENAME.log"`.

# TODO: Event handlers and other functions go here or register one or more includes in "additional_bootstrap".

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/cloudy/cloudy.sh";[[ "$ROOT" != "$r" ]] && echo "$(tput setaf 7)$(tput setab 1)Bootstrap failure, cannot load cloudy.sh$(tput sgr0)" && exit 1
# End Cloudy Bootstrap

# Input validation.
validate_input || exit_with_failure "Input validation failed."

implement_cloudy_basic

# Handle other commands.
command=$(get_command)
case $command in

    "command")

    # TODO: Write the code to handle this command here.

    has_failed && exit_with_failure
    exit_with_success
    ;;

esac

throw "Unhandled command \"$command\"."
