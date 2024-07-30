#!/usr/bin/env bash

#
# @file
# Helper for generating Cloudy's Knowledge Documentation.
#

CLOUDY_PACKAGE_CONFIG="cloudy_runtime.yml";
CLOUDY_COMPOSER_VENDOR="../../framework/cloudy/vendor"

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/../../framework/cloudy/cloudy.sh";[[ "$ROOT" != "$r" ]] && echo "$(tput setaf 7)$(tput setab 1)Bootstrap failure, cannot load cloudy.sh$(tput sgr0)" && exit 1
# End Cloudy Bootstrap

command=$(get_command)
case "$command" in
variables)
    . $PHP_FILE_RUNNER "$ROOT/commands/php_variables.php"
   ;;
functions)
    . $PHP_FILE_RUNNER "$ROOT/commands/php_functions.php"
   ;;
esac
