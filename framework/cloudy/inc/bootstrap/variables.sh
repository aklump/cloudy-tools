#!/usr/bin/env bash

source "$CLOUDY_CORE_DIR/inc/cloudy.define_variables.sh"

##
 # @file Processes variables during the bootstrapping.
 #
 # @export string $CLOUDY_PACKAGE_CONFIG
 # @export string $CLOUDY_RUNTIME_UUID
 # @global string $CLOUDY_BASEPATH
 # @global string $CLOUDY_INSTALLED_AS
 # @global string $CLOUDY_LOG
 ##

# Expand some vars from our controlling script.
if [[ "$CLOUDY_PACKAGE_CONFIG" ]] && ! path_is_absolute "$CLOUDY_PACKAGE_CONFIG"; then
  CLOUDY_PACKAGE_CONFIG="$(cd $(dirname "$r/$CLOUDY_PACKAGE_CONFIG") && pwd)/$(basename $CLOUDY_PACKAGE_CONFIG)"
fi
export CLOUDY_PACKAGE_CONFIG="$(realpath "$CLOUDY_PACKAGE_CONFIG")"

if [[ "$CLOUDY_LOG" ]]; then
  CLOUDY_LOG="$(path_resolve "$r" "$CLOUDY_LOG")"
  log_dir="$(dirname "$CLOUDY_LOG")"
  if ! mkdir -p "$log_dir"; then
    fail_because "Please manually create \"$log_dir\" and ensure it is writeable."
    return 2
  fi
  export CLOUDY_LOG="$(cd $log_dir && pwd)/$(basename $CLOUDY_LOG)"
fi

# Detect installation type
CLOUDY_INSTALLED_AS=$(_cloudy_detect_installation_type)
if [ $? -ne 0 ]; then
  write_log_error "Failed to determine \$CLOUDY_INSTALLED_AS"
else
  write_log_debug "\$CLOUDY_INSTALLED_AS set to \"$CLOUDY_INSTALLED_AS\""
fi

CLOUDY_PACKAGE_CONTROLLER="$(realpath "$CLOUDY_PACKAGE_CONTROLLER")"

export CLOUDY_RUNTIME_UUID=$(create_uuid)
