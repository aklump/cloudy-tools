#!/usr/bin/env bash

function testGetConfigWritesToCacheFile() {
    # Make sure admin hasn't disabled config cache.
    assert_false $cloudy_development_do_not_cache_config

    [ -f "$CACHED_CONFIG_FILEPATH" ] && rm "$CACHED_CONFIG_FILEPATH"
    assert_file_not_exists "$CACHED_CONFIG_FILEPATH"

    # This clears out memory to force a load from _get_config.php.
    CACHED_CONFIG=''

    # Getting config should create the cache file.
    local actual=$(get_config "coretest.string")
    assert_file_exists "$CACHED_CONFIG_FILEPATH" || return

    # See if the variable has been added to the cache file.
    assert_not_empty "$(grep "cloudy_config_coretest_string" "$CACHED_CONFIG_FILEPATH")"

    # See if the value has been added to the cache file.
    assert_not_empty "$(grep "$actual" "$CACHED_CONFIG_FILEPATH")"
}

function testGetConfigKeysAgainstAssociativeArray() {
    assert_same "declare -a coretest_associative_array='([0]=\"do\" [1]=\"re\" [2]=\"mi\")'" "$(get_config_keys "coretest.associative_array")"
}

function testGetConfigReturnsIndexedArray() {
    assert_same "declare -a coretest_indexed_array='([0]=\"alpha\" [1]=\"bravo\" [2]=\"charlie\")'" "$(get_config -a "coretest.indexed_array")"

    # Assert use_config_var works.
    use_config_var "september"
    assert_same "declare -a september='([0]=\"alpha\" [1]=\"bravo\" [2]=\"charlie\")'" "$(get_config -a "coretest.indexed_array")"
}

function testGetVersionIsNotEmpty() {
    assert_not_empty $(get_version)
}

function testGetConfigForScalarReturnsAsExpected() {
    assert_equals "Adam ate apples at Andrew's abode." "$(get_config "coretest.string")"
    assert_equals "Default value." "$(get_config "my.bogus.config.key" "Default value.")"
}

