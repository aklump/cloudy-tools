#!/usr/bin/env bash

function testGetConfigPathAsWorksAsItShould() {

    # This one handles the realpath portion as the subject involves traversal.
    eval $(get_config_path_as 'testpath' 'coretest.filepaths.cloudy')
    assert_same "$ROOT/install" $testpath

    eval $(get_config_path_as 'testpath' 'coretest.filepaths.absolute')
    assert_same "/dev/null" $testpath

    eval $(get_config_path_as 'testpath' 'coretest.filepaths.install')
    assert_same "$ROOT/install" $testpath

    eval $(get_config_path_as 'testpath' 'coretest.filepaths.cache')
    assert_same "$ROOT/install/cloudy/cache" $testpath
}

function testGetConfigPathWorksAsItShould() {

    # This one handles the realpath portion as the subject involves traversal.
    eval $(get_config_path 'coretest.filepaths.cloudy')
    assert_same "$ROOT/install" $coretest_filepaths_cloudy

    eval $(get_config_path 'coretest.filepaths.absolute')
    assert_same "/dev/null" $coretest_filepaths_absolute

    eval $(get_config_path 'coretest.filepaths.install')
    assert_same "$ROOT/install" $coretest_filepaths_install

    eval $(get_config_path 'coretest.filepaths.cache')
    assert_same "$ROOT/install/cloudy/cache" $coretest_filepaths_cache
}

function testArraySortLengthWorksAsExpected() {
    declare -a array_sort_by_item_length__array=("september" "five" "on")

    array_sort_by_item_length; assert_exit_status 0
    assert_same "on" ${array_sort_by_item_length__array[0]}
    assert_same "five" ${array_sort_by_item_length__array[1]}
    assert_same "september" ${array_sort_by_item_length__array[2]}
}

function testArraySplitWorksForMultipleChars() {
    array_split__string="do<br />re<br />mi"
    array_split '<br />'; assert_exit_status 0

    assert_count 3 'array_split__array'
    assert_same "do" ${array_split__array[0]}
    assert_same "re" ${array_split__array[1]}
    assert_same "mi" ${array_split__array[2]}
}

function testArraySplitWorksForCSV() {
    array_split__string="do,re,mi"
    array_split ','; assert_exit_status 0

    assert_count 3 'array_split__array'
    assert_same "do" ${array_split__array[0]}
    assert_same "re" ${array_split__array[1]}
    assert_same "mi" ${array_split__array[2]}
}

function testArraySortWorksAsExpected() {
    declare -a array_sort__array=("uno" "dos" "tres")

    array_sort; assert_exit_status 0
    assert_same "dos" ${array_sort__array[0]}
    assert_same "tres" ${array_sort__array[1]}
    assert_same "uno" ${array_sort__array[2]}
}

function testArrayJoinWorks() {
    declare -a array_join__array=("uno" "dos" "tres")
    assert_same "uno, dos, tres" "$(array_join ', ')"
}

function _testGetConfigWorksAsExpectedOnAssociativeArray() {
    local expected="cloudy_config_coretest_associative_array_do=\"alpha\";cloudy_config_coretest_associative_array_re=\"bravo\";cloudy_config_coretest_associative_array_mi=\"charlie\""

    eval $(get_config -a "coretest.associative_array")
    assert_same "alpha" "$cloudy_config_coretest_associative_array_do"
    assert_same "bravo" "$cloudy_config_coretest_associative_array_re"
    assert_same "charlie" "$cloudy_config_coretest_associative_array_mi"

#    assert_same "$expected" "$(get_config -a "coretest.associative_array")"
}

function testStringUpper() {
    assert_same 'JSON' $(string_upper 'json')
    assert_same 'JSON' $(string_upper 'JSON')
}

function testStringLower() {
    assert_same 'json' $(string_lower 'JSON')
    assert_same 'json' $(string_lower 'json')
}

function testPathExtension() {
    assert_same 'json' $(path_extension 'config.json')
}

function testPathFilename() {
    assert_same 'config' $(path_filename 'config.json')
    assert_same 'config' $(path_filename 'do/re/mi/config.json')
}

function testPathRelatiaveToRoot() {

    local path="some/tree.md"
    assert_same "$ROOT/$path" $(path_relative_to_root $path)

    path="/$path"
    assert_same "$path" $(path_relative_to_root $path)
}

function testHasCommandWorks() {
    declare -a CLOUDY_ARGS=();
    has_command; assert_exit_status 1

    declare -a CLOUDY_ARGS=("command");
    has_command; assert_exit_status 0

    declare -a CLOUDY_ARGS=("command" "target");
    has_command; assert_exit_status 0
}

function testHasCommandArgsWorks() {
    declare -a CLOUDY_ARGS=();
    has_command_args; assert_exit_status 1

    declare -a CLOUDY_ARGS=("command");
    has_command_args; assert_exit_status 1

    declare -a CLOUDY_ARGS=("command" "target");
    has_command_args; assert_exit_status 0
}

function testGetCommandArgWorksAsExpected() {
    declare -a CLOUDY_ARGS=();
    assert_empty $(get_command_arg 0)
    assert_same 'default_value' $(get_command_arg 0 'default_value')

    declare -a CLOUDY_ARGS=('COMMAND' 'name' 'force');
    assert_same 'name' $(get_command_arg 0)
    assert_same 'force' $(get_command_arg 1)
}

function testHasOptionGetOptionWorkAsExpected() {
    declare -a CLOUDY_OPTIONS=('name' 'force');
    CLOUDY_OPTION__NAME="alpha.md"
    CLOUDY_OPTION__FORCE=true

    assert_exit_status 0 $(has_option 'name')
    assert_exit_status 0 $(has_option 'force')
    assert_exit_status 1 $(has_option 'bogus')

    assert_same 'alpha.md' $(get_option 'name')
    assert_true $(get_option 'force')
    assert_empty $(get_option 'bogus')
}

function testHasOptionsWorksAsExpected() {
    CLOUDY_OPTIONS=("do" "re");
    assert_exit_status 0 $(has_options)
    CLOUDY_OPTIONS=();
    assert_exit_status 1 $(has_options)
}

function testGetCommandReturnsFirstArgument() {
    CLOUDY_ARGS=("order-take-out" "sushi")
    assert_same "order-take-out" $(get_command)

    # Now test that default passes through
    CLOUDY_ARGS=()
    eval $(get_config_as 'expected' 'default_command')
    assert_same $expected $(get_command)
}

function testGetTitleIsNotEmpty() {
    assert_not_empty 'Cloudy Installer' $(get_title)
}

function testGetVersionIsNotEmpty() {
    assert_not_empty $(get_version)
}

function testCloudyParseOptionsArgsWorksAsExpected() {
    parse_arguments init --file=index.php -y dev -abc

    assert_array_has_key 'file' 'parse_arguments__options'
    assert_array_has_key 'y' 'parse_arguments__options'
    assert_array_has_key 'a' 'parse_arguments__options'
    assert_array_has_key 'b' 'parse_arguments__options'
    assert_array_has_key 'c' 'parse_arguments__options'
    assert_array_not_has_key 'init' 'parse_arguments__options'

    assert_array_has_key 'init' 'parse_arguments__args'
    assert_array_has_key 'dev' 'parse_arguments__args'
    assert_array_not_has_key 'a' 'parse_arguments__args'

    assert_same 'index.php' $parse_arguments__option__file
    assert_same true $parse_arguments__option__y
    assert_same true $parse_arguments__option__a
    assert_same true $parse_arguments__option__b
    assert_same true $parse_arguments__option__c

    # Now call again and make sure the old values are cleared out
    parse_arguments help

    assert_array_not_has_key 'files' 'parse_arguments__options'
    assert_array_not_has_key 'y' 'parse_arguments__options'
    assert_array_not_has_key 'a' 'parse_arguments__options'
    assert_array_not_has_key 'b' 'parse_arguments__options'
    assert_array_not_has_key 'c' 'parse_arguments__options'

    assert_array_has_key 'help' 'parse_arguments__args'
    assert_array_not_has_key 'init' 'parse_arguments__args'
    assert_array_not_has_key 'dev' 'parse_arguments__args'
}

function testGetConfigKeysAsWorksAsExpected() {
    assert_same "declare -a list='([0]=\"do\" [1]=\"re\" [2]=\"mi\")'" "$(get_config_keys_as "list" "coretest.associative_array")"
}

function testGetConfigKeysWorksAsExpected() {
    assert_same "declare -a coretest_associative_array='([0]=\"do\" [1]=\"re\" [2]=\"mi\")'" "$(get_config_keys "coretest.associative_array")"
}

function testGetConfigReturnsIndexedArray() {
    assert_same "declare -a coretest_indexed_array='([0]=\"alpha\" [1]=\"bravo\" [2]=\"charlie\")'" "$(get_config -a "coretest.indexed_array")"
}

function testGetConfigAsReturnsIndexedArray() {
    assert_same "declare -a september='([0]=\"alpha\" [1]=\"bravo\" [2]=\"charlie\")'" "$(get_config_as -a 'september' "coretest.indexed_array")"
}

function testGetConfigForScalarReturnsAsExpected() {
    assert_equals "declare -- coretest_associative_array_do=\"alpha\"" "$(get_config "coretest.associative_array.do")"
    assert_equals "declare -- coretest_string=\"Adam ate apples at Andrew's abode.\"" "$(get_config "coretest.string")"
    assert_equals "declare -- my_bogus_config_key=\"Default\"" "$(get_config "my.bogus.config.key" "Default value.")"
}

function testGetConfigAsScalarReturnsAsExpected() {
    assert_equals "declare -- hero=\"alpha\"" "$(get_config_as 'hero' "coretest.associative_array.do")"
    assert_equals "declare -- hero=\"Batman\"" "$(get_config_as 'hero' "my.bogus.superhero" "Batman")"
}

function testGetConfigWithAOptionWorksAsExpected() {
    assert_same "declare -- bogus_path_to_null=\"\"" "$(get_config "bogus.path.to.null")"
    assert_same "declare -a bogus_path_to_null='()'" "$(get_config -a "bogus.path.to.null")"
    assert_same "declare -a bogus_path_to_null='()'" "$(get_config "bogus.path.to.null" -a)"
}

function testGetConfigAsWithAOptionWorksAsExpected() {
    assert_same "declare -a var_name='()'" "$(get_config_as -a "var_name" "bogus.path.to.null")"
    assert_same "declare -a var_name='()'" "$(get_config_as "var_name" -a "bogus.path.to.null")"
    assert_same "declare -a var_name='()'" "$(get_config_as "var_name" "bogus.path.to.null" -a)"
}

function testGetConfigWritesIndexedArrayToCacheFile() {

    [[ "$cloudy_development_do_not_cache_config" == true ]] && mark_test_skipped && return

    [ -f "$CACHED_CONFIG_FILEPATH" ] && mv "$CACHED_CONFIG_FILEPATH" "$CACHED_CONFIG_FILEPATH.bak"
    assert_file_not_exists "$CACHED_CONFIG_FILEPATH"

    # This clears out memory to force a load from _get_config.php.
    CACHED_CONFIG=''

    # Getting config should create the cache file.

    local actual
    eval $(get_config_as 'actual' "coretest.indexed_array")
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
    local actual
    eval $(get_config_as 'actual' "coretest.string")
    assert_file_exists "$CACHED_CONFIG_FILEPATH" || return

    # See if the variable has been added to the cache file.
    assert_not_empty "$(grep "cloudy_config_coretest_string=\"$actual\"" "$CACHED_CONFIG_FILEPATH")" "cloudy_config_coretest_string=$actual" "not found in $CACHED_CONFIG_FILEPATH"

    rm "$CACHED_CONFIG_FILEPATH" && mv "$CACHED_CONFIG_FILEPATH.bak" "$CACHED_CONFIG_FILEPATH"
}
