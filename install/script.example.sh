#!/usr/bin/env bash

#
# @file
# Demonstrate how one might write a Cloudy script.
#

# Define the configuration file relative to this script.
CONFIG="script.example.config.yml";

# Uncomment this line to enable file logging.
LOGFILE="script.example.log"

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/cloudy/cloudy.sh"
# End Cloudy Bootstrap

# Input validation
validate_input || exit_with_failure "Uh, that's not quite right..."

hi=$(succeed_because "bla")

# Handle the various operations.
command=$(get_command)
case $command in
"alpha")
    has_param "pass" || fail_because "Alpha does nothing yet"
    has_param "pass" && succeed_because "You passed the correct parameter \"pass\"."
    ;;

"examples")

    echo_headline "associative array values"
    echo_key_value 'Usage' 'eval $(get_config -a "user.images.types");Usage' && echo
    echo $LIL $(echo_green " $(get_config -a 'user.images.types')")
    echo; echo
    ;;

"help")
    exit_with_help
    ;;

*)
    throw "Unhandled operation \"$command\""
    ;;

esac

has_failed && exit_with_failure
exit_with_success_elapsed "Example completed."
