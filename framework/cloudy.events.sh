#!/usr/bin/env bash

##
 # @file
 # Examples of hooks to be used in Cloudy scripts.
 #

##
 # Fires when the caches are cleared.
 #
 # @return non-zero to block the cache clear.
 #
function on_clear_cache() {
    local cloudy_root=$1

    fail_because "The weather is cloudy." && return 1
}

##
 # Fires as soon as the minimum bootstrap has been executed.
 #
 # @return Ignored.
 #
function on_boot() {
    # Run the test command before the bootstrap to avoid conflicts.
    [[ "$(get_command)" == "tests" ]] || return 0
    source "$CLOUDY_ROOT/inc/cloudy.testing.sh"
    do_tests_in "tests/cloudy.tests.sh"
    exit_with_test_results
}
