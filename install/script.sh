#!/usr/bin/env bash

#
# @file
# Lorem ipsum dolar sit amet consectador.
#

# Define the configuration file relative to this script.
CONFIG="__CONFIG";

# Uncomment this line to enable file logging.
#LOGFILE="__FILENAME.log"

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/cloudy/cloudy.sh"
# End Cloudy Bootstrap
