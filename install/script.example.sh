#!/usr/bin/env bash

#
# @file
# Demonstrate how one might write a Cloudy script.
#

# Define the configuration file relative to this script.
CONFIG="script.example.config.yml";

# Begin Cloudy Bootstrap
c="$CONFIG";s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";CONFIG="$(cd $(dirname "$r/$c") && pwd)/$(basename $c)";source "$r/cloudy/cloudy.sh";SCRIPT="$s";ROOT="$r";WDIR="$PWD"
# End Cloudy Bootstrap

# Input validation
validate_input || exit_with_failure "Uh, that's not quite right..."

# Handle the various operations.
command=$(get_command)
case $command in
"alpha")
    has_param "pass" || fail_because "Alpha does nothing yet"
    has_param "pass" && succeed_because "You passed the correct parameter \"pass\"."
    ;;

"help")
    echo_help
    ;;

*)
    throw "Unhandled operation \"$command\""
    ;;

esac

has_failed && exit_with_failure
exit_with_success_elapsed "Example completed."
