#!/usr/bin/env bash

function _testGetConfigWorksAsExpectedOnAssociativeArray() {
    get_config "coretest.associative_array"
mark_test_skipped && return
    assert_same "declare -a coretest_associative_array='([0]=\"do\" [1]=\"re\" [2]=\"mi\")'" "$(get_config "coretest.associative_array")"
}

function testGetConfigKeysWorksAsExpected() {
    assert_same "declare -a coretest_associative_array='([0]=\"do\" [1]=\"re\" [2]=\"mi\")'" "$(get_config_keys "coretest.associative_array")"
}

function testGetConfigReturnsIndexedArray() {
    assert_same "declare -a coretest_indexed_array='([0]=\"alpha\" [1]=\"bravo\" [2]=\"charlie\")'" "$(get_config -a "coretest.indexed_array")"

    # Assert use_config_var works.
    use_config_var "september"
    assert_same "declare -a september='([0]=\"alpha\" [1]=\"bravo\" [2]=\"charlie\")'" "$(get_config -a "coretest.indexed_array")"
    revert_config_var
}

function testGetVersionIsNotEmpty() {
    assert_not_empty $(get_version)
}

function testGetConfigForScalarReturnsAsExpected() {
    assert_equals "alpha" "$(get_config "coretest.associative_array.do")"
    assert_equals "Adam ate apples at Andrew's abode." "$(get_config "coretest.string")"
    assert_equals "Default value." "$(get_config "my.bogus.config.key" "Default value.")"
}

function testGetConfigAOptionsWorksAsExpected() {
    assert_empty "$(get_config "bogus.path.to.null")"
    assert_same "declare -a bogus_path_to_null='()'" "$(get_config -a "bogus.path.to.null")"
}

function testGetConfigWritesIndexedArrayToCacheFile() {

    [[ "$cloudy_development_do_not_cache_config" == true ]] && mark_test_skipped && return

    [ -f "$CACHED_CONFIG_FILEPATH" ] && mv "$CACHED_CONFIG_FILEPATH" "$CACHED_CONFIG_FILEPATH.bak"
    assert_file_not_exists "$CACHED_CONFIG_FILEPATH"

    # This clears out memory to force a load from _get_config.php.
    CACHED_CONFIG=''

    # Getting config should create the cache file.
    local actual=$(get_config "coretest.indexed_array")
    assert_file_exists "$CACHED_CONFIG_FILEPATH" || return

    # See if the variable has been added to the cache file.
    local actual='declare -a cloudy_config_coretest_indexed_array=("alpha" "bravo" "charlie")'
    assert_not_empty "$(grep "$actual" "$CACHED_CONFIG_FILEPATH")" "$actual" "not found in $CACHED_CONFIG_FILEPATH"

    rm "$CACHED_CONFIG_FILEPATH" && mv "$CACHED_CONFIG_FILEPATH.bak" "$CACHED_CONFIG_FILEPATH"
}

function testGetConfigWritesScalarToCacheFile() {

    [[ "$cloudy_development_do_not_cache_config" == true ]] && mark_test_skipped && return

    [ -f "$CACHED_CONFIG_FILEPATH" ] && mv "$CACHED_CONFIG_FILEPATH" "$CACHED_CONFIG_FILEPATH.bak"
    assert_file_not_exists "$CACHED_CONFIG_FILEPATH"

    # This clears out memory to force a load from _get_config.php.
    CACHED_CONFIG=''

    # Getting config should create the cache file.
    local actual=$(get_config "coretest.string")
    assert_file_exists "$CACHED_CONFIG_FILEPATH" || return

    # See if the variable has been added to the cache file.
    assert_not_empty "$(grep "cloudy_config_coretest_string=\"$actual\"" "$CACHED_CONFIG_FILEPATH")" "cloudy_config_coretest_string=$actual" "not found in $CACHED_CONFIG_FILEPATH"

    rm "$CACHED_CONFIG_FILEPATH" && mv "$CACHED_CONFIG_FILEPATH.bak" "$CACHED_CONFIG_FILEPATH"
}
