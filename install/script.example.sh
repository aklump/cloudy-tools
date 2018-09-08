#!/usr/bin/env bash
source="${BASH_SOURCE[0]}"
while [ -h "$source" ]; do # resolve $source until the file is no longer a symlink
  dir="$( cd -P "$( dirname "$source" )" && pwd )"
  source="$(readlink "$source")"
  [[ $source != /* ]] && source="$dir/$source" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
ROOT="$( cd -P "$( dirname "$source" )" && pwd )"
CLOUDY_CONFIG=$ROOT/script.example.config.yml
source "$ROOT/cloudy/cloudy.sh"
# End Cloudy Bootstrap

op=$(get_op)

validate_input || failed_exit "Failed input validation"

case $op in
"alpha")
    has_param "pass" || fail_with "Alpha does nothing yet"
    has_param "pass" && succeed_with "You passed the correct parameter \"pass\"."
    ;;
"help")
    echo_help
    ;;
*)
    throw_exit "Unhandled operation \"$op\""
    ;;
esac

has_failed && failed_exit
success_elapsed_exit "Example completed."
