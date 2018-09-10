#!/usr/bin/env bash
CLOUDY_SCRIPT="${BASH_SOURCE[0]}"
while [ -h "$CLOUDY_SCRIPT" ]; do # resolve $CLOUDY_SCRIPT until the file is no longer a symlink
  dir="$( cd -P "$( dirname "$CLOUDY_SCRIPT" )" && pwd )"
  CLOUDY_SCRIPT="$(readlink "$CLOUDY_SCRIPT")"
  [[ $CLOUDY_SCRIPT != /* ]] && CLOUDY_SCRIPT="$dir/$CLOUDY_SCRIPT" # if $CLOUDY_SCRIPT was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
ROOT="$( cd -P "$( dirname "$CLOUDY_SCRIPT" )" && pwd )"
CLOUDY_CONFIG=$ROOT/script.example.config.yml
source "$ROOT/cloudy/cloudy.sh"
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
