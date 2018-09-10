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
