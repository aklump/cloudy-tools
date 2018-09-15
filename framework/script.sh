#!/usr/bin/env bash

#
# @file
# Lorem ipsum dolar sit amet consectador.
#

# Define the configuration file relative to this script.
CONFIG="__CONFIG";

# Uncomment this line to enable file logging.
#LOGFILE="__FILENAME.log"

#
# Event handlers and other functions.
#

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/cloudy/cloudy.sh"
# End Cloudy Bootstrap

# Input validation.
validate_input || exit_with_failure "Something didn't work..."
command=$(get_command)

# Handle help.
has_option "h" && exit_with_help $command
[[ "$command" == "help" ]] && exit_with_help $(get_command_arg 0)

# Handle other commands.
case $command in
    *)

    #
    # Begin building your code here.
    #

    ;;
esac

has_failed && exit_with_failure
throw "Unhandled command \"$command\"".
