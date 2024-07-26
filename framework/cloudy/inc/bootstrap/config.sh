#!/usr/bin/env bash

##
 # @file Bootstrap the configuration layer.
 ##

declare -rx CLOUDY_RUNTIME_ENV="$CLOUDY_CACHE_DIR/_runtime_vars.$CLOUDY_RUNTIME_UUID.sh";

compile_config__runtime_files=$(event_dispatch "compile_config")

config_cache_id=$(. "$PHP_FILE_RUNNER" "$CLOUDY_CORE_DIR/php/functions/invoke.php" "_cloudy_get_config_cache_id" "$ROOT\n$compile_config__runtime_files")

source "$CLOUDY_CORE_DIR/inc/config/normalize.sh" || exit_with_failure "Cannot normalize configuration."
source "$CLOUDY_CORE_DIR/inc/config/cache.sh" || exit_with_failure "Cannot cache configuration."

# Now load the normalized, cached config into memory.
source "$CACHED_CONFIG_FILEPATH" || exit_with_failure "Cannot load cached configuration."

eval $(get_config_as -a 'additional_bootstrap' 'additional_bootstrap')
if [[ "$additional_bootstrap" != null ]]; then
  for include in "${additional_bootstrap[@]}"; do
    source "$ROOT/$include"
  done
fi
