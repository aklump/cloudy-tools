#!/usr/bin/env bash

function testYamlSetAndGetWorkAsExpected() {
  yaml_set $'echo: eggplant\nfoxtrot: fig'
  assert_same $'echo: eggplant\nfoxtrot: fig' "$(yaml_get)"
  assert_same "{\"echo\":\"eggplant\",\"foxtrot\":\"fig\"}" "$(yaml_get_json)"
}

function testYamlAddLineOnNoContentWorksCorrectly() {
  yaml_clear
  yaml_add_line "delta: daikon"
  assert_same $'delta: daikon' "$(yaml_get)"
  assert_same "{\"delta\":\"daikon\"}" "$(yaml_get_json)"
}

function testYamlAddLineAppendsToExistingContent() {
  yaml_set $'alpha: apple\nbravo: banana'
  yaml_add_line "charlie: carrot"
  assert_same $'alpha: apple\nbravo: banana\ncharlie: carrot' "$(yaml_get)"
  assert_same "{\"alpha\":\"apple\",\"bravo\":\"banana\",\"charlie\":\"carrot\"}" "$(yaml_get_json)"
}

function testYamlClearEmptiesTheYamlValues() {
  yaml_set $'alpha: apple\nbravo: banana'
  yaml_clear
  yaml_add_line "charlie: carrot"
  assert_same $'charlie: carrot' "$(yaml_get)"
  assert_same "{\"charlie\":\"carrot\"}" "$(yaml_get_json)"
}

function testGetConfigPathAsOnIndexedArrayMakesAllElementsRealPaths() {
    eval $(get_config_path_as "fish" -a 'tests.paths_indexed')
    assert_same "/an/absolute/bogus/path" ${fish[4]}
    assert_same "$ROOT/tests/stubs/bogus.md" ${fish[3]}
    assert_same "$(realpath $ROOT/tests/stubs/alpha.txt)" ${fish[0]}
    assert_same "$(realpath $ROOT/tests/stubs/bravo.txt)" ${fish[1]}
    assert_same "$(realpath $ROOT/tests/stubs/charlie.md)" ${fish[2]}
    assert_same "$(realpath $HOME/.trash)" ${fish[5]}
    assert_same 6 ${#fish[@]}
}

function testHashReturnsExpectedValues() {
  assert_same 'acbd18db4cc2f85cedef654fccc4a4d8' $(md5_string foo)
  assert_same '5594685ef95d3606cdbbc232a18acaee' $(md5_string 'some thing that is hashed')
}

function testGetConfigPathOnIndexedArrayMakesAllElementsRealPaths() {
    eval $(get_config_path -a 'tests.paths_indexed')
    assert_same "/an/absolute/bogus/path" ${tests_paths_indexed[4]}
    assert_same "$ROOT/tests/stubs/bogus.md" ${tests_paths_indexed[3]}
    assert_same "$(realpath $ROOT/tests/stubs/alpha.txt)" ${tests_paths_indexed[0]}
    assert_same "$(realpath $ROOT/tests/stubs/bravo.txt)" ${tests_paths_indexed[1]}
    assert_same "$(realpath $ROOT/tests/stubs/charlie.md)" ${tests_paths_indexed[2]}
    assert_same "$(realpath $HOME/.trash)" ${tests_paths_indexed[5]}
    assert_same 6 ${#tests_paths_indexed[@]}
}

function testFailBecauseWithOneArgumentAndStatusDoesntPrintStatus() {
    fail_because "bla" --status=3
    assert_same 3 "$CLOUDY_EXIT_STATUS"
    assert_same "bla" "${CLOUDY_FAILURES[0]}"
    assert_empty "${CLOUDY_FAILURES[1]}"
}

function testWarnBecauseReturns0() {
    warn_because "bla"; assert_exit_status 0
}

function testFailBecauseReturns0() {
    fail_because "bla"; assert_exit_status 0
}

function testSucceedBecauseReturns0() {
    succeed_because "bla"; assert_exit_status 0
}

function testWarnBecauseWithoutArgumentsExitsWith1() {
    warn_because; assert_exit_status 1
}

function _testSucceedBecauseCausesExitToBeZero() {
    (fail_because "bla" && succeed_because "blu" && _cloudy_exit >/dev/null 2>&1)
    assert_exit_status 0
}

function testSucceedBecauseWithoutArgumentsExitsWith1() {
    succeed_because; assert_exit_status 1
}

function testWarnBecauseWithTwoArgumentsUsesThemBoth() {
    local result=$(warn_because charlie delta && echo ${CLOUDY_SUCCESSES[@]})
    assert_reg_exp "charlie" "$result"
    assert_reg_exp "delta" "$result"
}

function testSucceedBecauseWithoutArgumentsSetsExitStatus() {
    $(CLOUDY_EXIT_STATUS=1; succeed_because; _cloudy_exit >/dev/null 2>&1)
    assert_exit_status 0
}

function testSucceedBecauseWithTwoArgumentsUsesThemBoth() {
    local result=$(succeed_because alpha bravo && echo ${CLOUDY_SUCCESSES[@]})
    assert_same "alpha bravo" "$result"
}

function testFailBecauseCausesExitToBeNonZero() {
    CLOUDY_EXIT_STATUS=3
    (succeed_because "blu" && fail_because "bla" && _cloudy_exit >/dev/null 2>&1)
    assert_exit_status 1
}

function testFailBecauseWithoutArgumentsExitsWith1() {
    fail_because; assert_exit_status 1
}

function testFailBecauseWithoutArgumentsSetsExitStatus() {
    $(CLOUDY_EXIT_STATUS=0; fail_because; _cloudy_exit >/dev/null 2>&1)
    assert_exit_status 1
}

function testFailBecauseWithTwoArgumentsUsesThemBoth() {
    local result=$(fail_because foo bar && echo ${CLOUDY_FAILURES[@]})
    assert_same "foo bar" "$result"
}

function testCloudyExitExitsBasedOnCloudyExitStatusVar() {
    (_cloudy_exit)
    assert_exit_status 0

    CLOUDY_EXIT_STATUS=1
    (_cloudy_exit)
    assert_exit_status 1

    CLOUDY_EXIT_STATUS=0
    (_cloudy_exit)
    assert_exit_status 0

    CLOUDY_EXIT_STATUS=2
    (_cloudy_exit)
    assert_exit_status 2
}

function testArrayMapExitsWith!WhenArrayNotDefined() {
    function array_map__callback() {
        echo "<h1>$1</h1>"
    }
    unset examples
    array_map examples; assert_exit_status 1
}

function testArrayMapEchosNothingWhenNoCallbackDefined() {
    declare -a local examples=("do re me" "fa so");
    unset array_map__callback
    assert_empty "$(array_map examples)"
}

function testArrayMapExitsWith1WhenNoCallbackDefined() {
    declare -a local examples=("do re me" "fa so");
    unset array_map__callback
    array_map examples; assert_exit_status 1
}

function testArrayMapWorksForTwoItems() {
    function array_map__callback() {
        echo "<h1>$1</h1>"
    }
    declare -a local titles=("The Hobbit" "Charlottes Web");
    eval $(array_map titles)
    assert_exit_status 0
    assert_same "<h1>The Hobbit</h1>" "${titles[0]}"
    assert_same "<h1>Charlottes Web</h1>" "${titles[1]}"
    assert_count 2 titles
}

function testFunctionExists() {
    function_exists bogus; assert_exit_status 1

    function not_so_bogus() {
        return 0
    }
    function_exists not_so_bogus; assert_exit_status 0

    unset not_so_bogus
    function_exists not_so_bogus; assert_exit_status 1
}

function testGetConfigForScalarReturnsAsExpected() {

    # Assert default is returned for non-existent.
    assert_equals "declare -- my_bogus_config_key=\"Default\"" "$(get_config "my.bogus.config.key" "Default value.")"

    assert_equals "declare -- tests_associative_array_do=\"alpha\"" "$(get_config "tests.associative_array.do")"
    assert_equals "declare -- tests_string=\"Adam ate apples at Andrew's abode.\"" "$(get_config "tests.string")"

    # With an indexed array key as last
    assert_equals "declare -- tests_user_images_tags_0=\"literature\"" "$(get_config "tests.user.images.tags.0")"
    assert_equals "declare -- tests_user_images_tags_1=\"nature\"" "$(get_config "tests.user.images.tags.1")"
    assert_equals "declare -- tests_user_images_tags_2=\"space\"" "$(get_config "tests.user.images.tags.2")"
    assert_equals "declare -- tests_user_images_tags_3=\"religion\"" "$(get_config "tests.user.images.tags.3")"
}

function testPathMtimeWorks() {
    local file="$ROOT/tests/stubs/alpha.txt"
    local mtime
    mtime=$(path_mtime $file)
    assert_exit_status 0
    assert_not_empty $mtime
    assert_less_than $(timestamp) $mtime

    local file="$ROOT/tests/stubs/totally-bogux.txt"
    local mtime
    mtime=$(path_mtime $file)
    assert_exit_status 1
    assert_empty "$mtime"
}

function testPathIsAbsolute() {
    path_is_absolute "/do/re"; assert_exit_status 0
    path_is_absolute "do/re"; assert_exit_status 1
}

function testPathResolveEchosRealpath() {
    assert_same "$ROOT/tests" $(path_resolve "$ROOT" "tests/stubs/../../tests")
    assert_same "$ROOT/bogus/stubs/../../tests" $(path_resolve "$ROOT" "bogus/stubs/../../tests")
}

function testPathResolve() {
    local dir="/some/great/path/"
    local path="tree.md"
    assert_same "/some/great/path/tree.md" $(path_resolve $dir $path)

    path="/$path"
    assert_same "$path" $(path_resolve $dir $path)
}

function testPathRelatiaveToConfigBase() {

    local path="some/tree.md"
    assert_same "$ROOT/$path" $(path_relative_to_config_base $path)

    path="/$path"
    assert_same "$path" $(path_relative_to_config_base $path)
}

function testPathRelativeToRoot() {
    local path="some/tree.md"
    assert_same "$ROOT/$path" $(path_relative_to_root $path)

    path="/$path"
    assert_same "$path" $(path_relative_to_root $path)
}

function testExitWithFailureCodeWithStatusOnlyEchosNothingReturnsStatus() {
    $(exit_with_failure_code_only --status=2)
    assert_same 2 $?
}

function testExitWithFailureCodeOnlyEchosNothingReturns1() {
    $(exit_with_failure_code_only)
    assert_same 1 $?
    assert_empty $(exit_with_failure_code_only)
}

function testCloudyExitWithFailureExitsWithNonZero() {
    (exit_with_failure >/dev/null 2>&1)
    assert_same 1 $?
    (exit_with_failure --status=4 >/dev/null 2>&1)
    assert_same 4 $?
    local message=$(exit_with_failure --status=2 "stop drop roll")
    assert_reg_exp "stop drop roll" "$message"
}

function testGetVersionIsNotEmpty() {
    assert_not_empty $(get_version)
}

function testGetTitleIsNotEmpty() {
    assert_not_empty $(get_title)
}

function testTempdirUsesExistingDirectoryPerArgument() {
    local dir=$(tempdir "com.apple.aklump.cloudy"); assert_exit_status 0
    assert_not_empty $dir
    assert_file_exists $dir
    assert_same "com.apple.aklump.cloudy" "$(basename $dir)"

    # Call again and see what happens.
    local dir2=$(tempdir "com.apple.aklump.cloudy"); assert_exit_status 0
    assert_not_empty $dir2
    assert_file_exists $dir2
    assert_same "com.apple.aklump.cloudy" "$(basename $dir2)"

    assert_same "$dir" "$dir2"
}

function testTempdirCreatesExistingDirectory() {
    local dir=$(tempdir); assert_exit_status 0
    assert_not_empty $dir
    assert_file_exists $dir
}

function testConfigurationMerge() {
    eval $(get_config "tests.config.fruit")
    assert_same "banana" $tests_config_fruit
    eval $(get_config "tests.config.vegetable")
    assert_same "artichoke" $tests_config_vegetable
    eval $(get_config "tests.config.meat")
    assert_same "bear" $tests_config_meat
    eval $(get_config -a "tests.config.merge_test")
    assert_count 7 "tests_config_merge_test"
    assert_same "uno" ${tests_config_merge_test[0]}
    assert_same "dos" ${tests_config_merge_test[1]}
    assert_same "tres" ${tests_config_merge_test[2]}
    assert_same "quatro" ${tests_config_merge_test[3]}
    assert_same "cinco" ${tests_config_merge_test[4]}
    assert_same "seis" ${tests_config_merge_test[5]}
    assert_same "siete" ${tests_config_merge_test[6]}

    eval $(get_config_as "assoc_test" -a "tests.config.associative_merge_test")
    assert_same "zebra" "$assoc_test_z"
    assert_same "yak" "$assoc_test_y"
    assert_same "xylitol" "$assoc_test_x"
    assert_same "whisky" "$assoc_test_w"

    eval $(get_config_as "child_only" -a "tests.config.child_only_key")
    assert_internal_type "array" "child_only"
    assert_count 2 "child_only"
    assert_same "mike" "${child_only[0]}"
    assert_same "joe" "${child_only[1]}"
}

##
 # @see testEventListenAndDispatch
 #
function on_test_bravo__custom() {
    [[ "$1" == "do re" ]] && [[ "$2" == "mi" ]] && on_test_bravo__custom=true
}

##
 # @see testEventListenAndDispatch
 #
function on_test_bravo() {
    [[ "$1" == "do re" ]] && [[ "$2" == "mi" ]] && on_test_bravo__value=true
}

function testEventListenAndDispatchWithOnEventExplicitFunctionName() {
    event_listen test_bravo on_test_bravo__custom
    on_test_bravo__value=false
    event_dispatch "test_bravo" "do re" "mi"; assert_exit_status 0
    assert_same true $on_test_bravo__custom
}

function testEventListenAndDispatchWithOnEventFunctionName() {
    on_test_bravo__value=false
    event_dispatch "test_bravo" "do re" "mi"; assert_exit_status 0
    assert_same true $on_test_bravo__value
}

##
 # @see testEventListenAndDispatch
 #
function was_called_with_do_re() {
    [[ "$1" == "do re" ]] && [[ "$2" == "mi" ]] && was_called_with_do_re__value=true
}

function testEventListenAndDispatchWithCustomFunctionName() {
    event_listen test_alpha was_called_with_do_re
    was_called_with_do_re__value=false
    event_dispatch "test_alpha" "do re" "mi"; assert_exit_status 0
    was_called_with_do_re__value=true
    assert_same true $was_called_with_do_re__value
}

function testUrlAddCacheBuster() {
    local url
    url=$(url_add_cache_buster "site.com")
    assert_reg_exp "site\.com\?[0-9]+$" "$url"

    url=$(url_add_cache_buster "site.com?t=1234")
    assert_reg_exp "site\.com\?t=1234&[0-9]+$" "$url"
}

function testExitWithSuccessCodeOnlyEchosNothing() {
    assert_empty $(exit_with_success_code_only)
    assert_same 0 $?
}

function testCloudyExitWithSuccessExitsWithZero() {
    (exit_with_success >/dev/null 2>&1)
    assert_same 0 $?
    (exit_with_success_elapsed >/dev/null 2>&1)
    assert_same 0 $?
}

function testGetConfigPathUsingAssociateArrayReturnsRealPaths() {
    eval $(get_config_path -a "tests.paths_associative")

    assert_not_internal_type "array" "tests_paths_associative_alpha"
    assert_same "$(realpath $ROOT/tests/stubs/alpha.txt)" ${tests_paths_associative_alpha}

    assert_not_internal_type "array" "tests_paths_associative_trash"
    assert_same "$(realpath $HOME/.trash)" ${tests_paths_associative_trash}

    assert_internal_type "array" "tests_paths_associative_all"
    assert_same "$(realpath $ROOT/tests/stubs/alpha.txt)" ${tests_paths_associative_all[0]}
    assert_same "$(realpath $ROOT/tests/stubs/bravo.txt)" ${tests_paths_associative_all[1]}
}

function testGetConfigPathOnNullReturnsArray() {

    # Does exist but is null.
    eval $(get_config_path -a "tests.empty_array")
    assert_count 0 "tests_empty_array"

    # Does not exist.
    eval $(get_config_path -a "tests_empty_array")
    assert_count 0 "tests_empty_array"
}

function testTableAddRowTableHasRowsTableClearWorKAsExpected() {
    table_add_row "alpha"
    table_add_row "bravo"
    assert_count 2 "_cloudy_table_rows"
    table_has_rows; assert_exit_status 0

    table_clear
    assert_count 0 "_cloudy_table_rows"
    table_has_rows; assert_exit_status 1
}

function testListAddItemAndListClearWorkAsExpected() {
    list_add_item "alpha"
    list_add_item "bravo"
    assert_count 2 "echo_list__array"
    list_has_items; assert_exit_status 0

    list_clear
    assert_count 0 "echo_list__array"
    list_has_items; assert_exit_status 1
}

function testUrlHostWorks() {
    assert_same "www.abc.com" $(url_host "https://www.abc.com/do/re/me")
}

function testArraySplitWorksWithSpaces() {
    string_split__string="my my;this is good"
    string_split ';'; assert_exit_status 0

    assert_count 2 'string_split__array'
    assert_same "my my" "${string_split__array[0]}"
    assert_same "this is good" "${string_split__array[1]}"

    string_split__string="my my|this is good"
    string_split '|'; assert_exit_status 0

    assert_count 2 'string_split__array'
    assert_same "my my" "${string_split__array[0]}"
    assert_same "this is good" "${string_split__array[1]}"
}

function testGetConfigPathAsUsingGlobWorksAsExpected() {
    eval $(get_config_path_as "wed" -a 'tests.globtest')
    assert_same "$(realpath $ROOT/tests/stubs/alpha.txt)" ${wed[0]}
    assert_same "$(realpath $ROOT/tests/stubs/bravo.txt)" ${wed[1]}
    assert_same 2 ${#wed[@]}
}

function testGetConfigPathUsingGlobWorksAsExpected() {
    eval $(get_config_path -a 'tests.globtest')
    assert_same "$(realpath $ROOT/tests/stubs/alpha.txt)" ${tests_globtest[0]}
    assert_same "$(realpath $ROOT/tests/stubs/bravo.txt)" ${tests_globtest[1]}
    assert_same 2 ${#tests_globtest[@]}
}

function testGetConfigPathWorksAsItShould() {

    # This one handles the realpath portion as the subject involves traversal.
    eval $(get_config_path 'tests.filepaths.cloudy')
    assert_same "$(realpath $CLOUDY_ROOT/..)" $tests_filepaths_cloudy

    eval $(get_config_path 'tests.filepaths.absolute')
    assert_same "/dev/null" $tests_filepaths_absolute

    eval $(get_config_path 'tests.filepaths.install')
    assert_same "$(realpath $CLOUDY_ROOT/..)" $tests_filepaths_install

    eval $(get_config_path 'tests.filepaths.cache')
    assert_same "$CLOUDY_ROOT/cache" $tests_filepaths_cache
}

function testGetConfigPathAsWorksAsItShould() {
    # This one handles the realpath portion as the subject involves traversal.
    eval $(get_config_path_as 'testpath' 'tests.filepaths.cloudy')
    assert_same "$(realpath $CLOUDY_ROOT/..)" $testpath

    eval $(get_config_path_as 'testpath' 'tests.filepaths.absolute')
    assert_same "/dev/null" $testpath

    eval $(get_config_path_as 'testpath' 'tests.filepaths.install')
    assert_same "$(realpath $CLOUDY_ROOT/..)" $testpath

    eval $(get_config_path_as 'testpath' 'tests.filepaths.cache')
    assert_same "$CLOUDY_ROOT/cache" $testpath
}

function testArrayHasValue() {
    array_has_value__array=('value1' 'value2');
    array_has_value 'value2'; assert_exit_status 0
    assert_same 1 $array_has_value__index

    array_has_value 'value1'; assert_exit_status 0
    assert_same 0 $array_has_value__index

    array_has_value 'no_value'; assert_exit_status 1
}

function testCloudyGetMasterCommand() {
    assert_same "new" "$(_cloudy_get_master_command "new")"
    assert_same "clear-cache" "$(_cloudy_get_master_command "clear-cache")"
    assert_same "clear-cache" "$(_cloudy_get_master_command "clearcache")"
    assert_same "clear-cache" "$(_cloudy_get_master_command "cc")"
}

function testValidateCommandWorksForMasterCommandsAndAliases() {
    _cloudy_validate_command "clear-cache" ;assert_exit_status 0
    _cloudy_validate_command "clearcache" ;assert_exit_status 0
    _cloudy_validate_command "cc" ;assert_exit_status 0
}

function testTimeLocal() {
    assert_same "$(date +%H:%M)" "$(time_local)"
    assert_same "$(date +%H:%M:%S)" "$(time_local -s)"
}

function testTimestamp() {
    assert_same "$(date +%s)" "$(timestamp)"
}

function testGetConfigWorksAsExpectedOnAssociativeArray() {
    local result="$(get_config -a "tests.associative_array")"
    assert_same "declare -- tests_associative_array_do=\"alpha\";declare -- tests_associative_array_re=\"bravo\";declare -- tests_associative_array_mi=\"charlie\"" "$result"

    eval "$result"
    assert_same "alpha" "$tests_associative_array_do"
    assert_same "bravo" "$tests_associative_array_re"
    assert_same "charlie" "$tests_associative_array_mi"
}

function testGetConfigWorksAsExpectedOnAssociativeArrayWithArrayValues() {
    local result="$(get_config -a "tests.user.images.types")"
    assert_same "declare -a tests_user_images_types_bitmap='([0]=\"jpg\" [1]=\"png\" [2]=\"gif\")'" "$result"

    eval "$result"
    assert_same "jpg" "${tests_user_images_types_bitmap[0]}"
    assert_same "png" "${tests_user_images_types_bitmap[1]}"
    assert_same "gif" "${tests_user_images_types_bitmap[2]}"
}

function testArraySortLengthWorksAsExpected() {
    array_sort_by_item_length__array=("september" "five" "three" "on")
    array_sort_by_item_length; assert_exit_status 0
    assert_same "on" ${array_sort_by_item_length__array[0]}
    assert_same "five" ${array_sort_by_item_length__array[1]}
    assert_same "three" ${array_sort_by_item_length__array[2]}
    assert_same "september" ${array_sort_by_item_length__array[3]}
}

function testGetConfigAndTheAOptionWorksAsExpected() {
    assert_same "declare -a bogus_path_to_null='()'" "$(get_config -a "bogus.path.to.null")"
    assert_same "declare -a bogus_path_to_null='()'" "$(get_config "bogus.path.to.null" -a)"
}

function testGetConfigWithBogusPathForScaler() {
    assert_same "declare -- bogus_path_to_null=\"\"" "$(get_config "bogus.path.to.null")"
}

function testGetConfigAsWithBogusPathForScaler() {
    assert_same "declare -a var_name='()'" "$(get_config_as -a "var_name" "bogus.path.to.null")"
}

function testGetConfigAsWithAOptionWorksAsExpected() {
    assert_same "declare -a var_name='()'" "$(get_config_as "var_name" -a "bogus.path.to.null")"
    assert_same "declare -a var_name='()'" "$(get_config_as "var_name" "bogus.path.to.null" -a)"
}


function testGetConfigKeysAsWorksAsExpected() {
    assert_same "declare -a list='([0]=\"do\" [1]=\"re\" [2]=\"mi\")'" "$(get_config_keys_as "list" "tests.associative_array")"

    # Three levels deep.
    assert_same "declare -a db_keys='([0]=\"name\" [1]=\"pass\")'" "$(get_config_keys_as "db_keys" "tests.prod.db")"
}

function testGetCommandReturnsFirstArgument() {
    CLOUDY_ARGS=("order-take-out" "sushi")
    assert_same "order-take-out" $(get_command)

    # Now test that default_command from config is returned when no arguments
    # provided to the script.
    CLOUDY_ARGS=()
    eval $(get_config_as 'config_default' 'default_command')
    assert_same "$config_default" "$(get_command)"
}

function testGetConfigReturnsIndexedArray() {
    assert_same "declare -a tests_user_images_tags='([0]=\"literature\" [1]=\"nature\" [2]=\"space\" [3]=\"religion\")'" "$(get_config -a "tests.user.images.tags")"

    assert_same "declare -a tests_indexed_array='([0]=\"alpha\" [1]=\"bravo\" [2]=\"charlie\")'" "$(get_config -a "tests.indexed_array")"
}

function testArraySplitWorksForMultipleChars() {
    string_split__string="do<br />re<br />mi"
    string_split '<br />'; assert_exit_status 0

    assert_count 3 'string_split__array'
    assert_same "do" ${string_split__array[0]}
    assert_same "re" ${string_split__array[1]}
    assert_same "mi" ${string_split__array[2]}
}

function testArraySplitWorksForCSV() {
    string_split__string="do,re,mi"
    string_split ','; assert_exit_status 0

    assert_count 3 'string_split__array'
    assert_same "do" ${string_split__array[0]}
    assert_same "re" ${string_split__array[1]}
    assert_same "mi" ${string_split__array[2]}
}

function testArraySortWorksAsExpected() {
    declare -a array_sort__array=("uno" "dos" "tres")

    array_sort; assert_exit_status 0
    assert_same "dos" ${array_sort__array[0]}
    assert_same "tres" ${array_sort__array[1]}
    assert_same "uno" ${array_sort__array[2]}
}

function testArrayJoinWorks() {
    declare -a array_join__array=("my my" "this is good")
    assert_same "my my, this is good" "$(array_join ', ')"

    declare -a array_join__array=("uno" "dos" "tres")
    assert_same "uno, dos, tres" "$(array_join ', ')"

    declare -a array_join__array=("-h" "--help" "--name=aaron")
    assert_same "-h, --help, --name=aaron" "$(array_join ', ')"
}

function testStringUpper() {
    assert_same 'JSON' $(string_upper 'json')
    assert_same 'JSON' $(string_upper 'JSON')
}

function testStringLower() {
    assert_same 'json' $(string_lower 'JSON')
    assert_same 'json' $(string_lower 'json')
}

function testPathExtensionOnDirectory() {
    assert_same '' $(path_extension 'config')
    assert_same '' $(path_extension '/foo/bar/config')
}

function testPathExtension() {
    assert_same 'json' $(path_extension 'config.json')
    assert_same 'json' $(path_extension '/foo/bar/config.json')
    assert_same 'twig' $(path_extension 'config.html.twig')
}

function testPathFilename() {
    assert_same 'config' $(path_filename 'config.json')
    assert_same 'config' $(path_filename 'do/re/mi/config.json')
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

function testCloudyParseOptionsArgsWorksAsExpected() {
    parse_args init --file=index.php -y dev -abc -t=free --yellow

    assert_contains 't' 'parse_args__options'
    assert_contains 'yellow' 'parse_args__options'

    assert_contains 'file' 'parse_args__options'
    assert_contains 'y' 'parse_args__options'
    assert_contains 'a' 'parse_args__options'
    assert_contains 'b' 'parse_args__options'
    assert_contains 'c' 'parse_args__options'
    assert_not_contains 'init' 'parse_args__options'

    assert_contains 'init' 'parse_args__args'
    assert_contains 'dev' 'parse_args__args'
    assert_not_contains 'a' 'parse_args__args'

    assert_same 'index.php' $parse_args__options__file
    assert_same 'free' $parse_args__options__t
    assert_same true $parse_args__options__y
    assert_same true $parse_args__options__a
    assert_same true $parse_args__options__b
    assert_same true $parse_args__options__c
    assert_same true $parse_args__options__yellow

    # Now call again and make sure the old values are cleared out
    parse_args help

    assert_not_contains 'files' 'parse_args__options'
    assert_not_contains 'y' 'parse_args__options'
    assert_not_contains 'a' 'parse_args__options'
    assert_not_contains 'b' 'parse_args__options'
    assert_not_contains 'c' 'parse_args__options'

    assert_contains 'help' 'parse_args__args'
    assert_not_contains 'init' 'parse_args__args'
    assert_not_contains 'dev' 'parse_args__args'
}

function testGetConfigKeysWorksAsExpected() {
    # Two levels deep
    assert_same "declare -a tests_associative_array='([0]=\"do\" [1]=\"re\" [2]=\"mi\")'" "$(get_config_keys "tests.associative_array")"

    # Three levels deep.
    assert_same "declare -a tests_prod_db='([0]=\"name\" [1]=\"pass\")'" "$(get_config_keys "tests.prod.db")"
}

function testGetConfigAsReturnsIndexedArray() {
    assert_same "declare -a tags='([0]=\"literature\" [1]=\"nature\" [2]=\"space\" [3]=\"religion\")'" "$(get_config_as -a "tags" "tests.user.images.tags")"

    assert_same "declare -a september='([0]=\"alpha\" [1]=\"bravo\" [2]=\"charlie\")'" "$(get_config_as -a 'september' "tests.indexed_array")"
}

function testGetConfigAsForScalarReturnsAsExpected() {
    assert_equals "declare -- hero=\"alpha\"" "$(get_config_as 'hero' "tests.associative_array.do")"

    # Assert default is returned for non-existent.
    assert_equals "declare -- hero=\"Batman\"" "$(get_config_as 'hero' "my.bogus.superhero" "Batman")"
}
