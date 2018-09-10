#!/usr/bin/env bash

#
# @file
# Lorem ipsum dolar sit amet consectador.
#

# Define the configuration file relative to this script.
CONFIG="__CONFIG";

# Begin Cloudy Bootstrap
c="$CONFIG";s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";CONFIG="$(cd $(dirname "$r/$c") && pwd)/$(basename $c)";source "$r/cloudy/cloudy.sh";SCRIPT="$s";ROOT="$r"
# End Cloudy Bootstrap
