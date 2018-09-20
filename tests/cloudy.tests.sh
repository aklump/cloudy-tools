#!/usr/bin/env bash

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

function testGetConfigPathOnIndexedArrayMakesAllElementsRealPaths() {
    eval $(get_config_path_as "fish" -a 'tests.paths_indexed')
    assert_same "tests/stubs/bogus.md" ${fish[3]}
    assert_same "$(realpath $ROOT/tests/stubs/alpha.txt)" ${fish[0]}
    assert_same "$(realpath $ROOT/tests/stubs/bravo.txt)" ${fish[1]}
    assert_same "$(realpath $ROOT/tests/stubs/charlie.md)" ${fish[2]}
    assert_same 4 ${#fish[@]}
}

function testGetConfigPathOnIndexedArrayMakesAllElementsRealPaths() {
    eval $(get_config_path -a 'tests.paths_indexed')
    assert_same "tests/stubs/bogus.md" ${tests_paths_indexed[3]}
    assert_same "$(realpath $ROOT/tests/stubs/alpha.txt)" ${tests_paths_indexed[0]}
    assert_same "$(realpath $ROOT/tests/stubs/bravo.txt)" ${tests_paths_indexed[1]}
    assert_same "$(realpath $ROOT/tests/stubs/charlie.md)" ${tests_paths_indexed[2]}
    assert_same 4 ${#tests_paths_indexed[@]}
}

function _testGetConfigPathAsUsingGlobWorksAsExpected() {
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

function testGetTitleIsNotEmpty() {
    assert_not_empty 'Cloudy Installer' $(get_title)
}

function testGetVersionIsNotEmpty() {
    assert_not_empty $(get_version)
}

function testCloudyParseOptionsArgsWorksAsExpected() {
    parse_args init --file=index.php -y dev -abc -t=free --yellow

    assert_array_has_key 't' 'parse_args__options'
    assert_array_has_key 'yellow' 'parse_args__options'

    assert_array_has_key 'file' 'parse_args__options'
    assert_array_has_key 'y' 'parse_args__options'
    assert_array_has_key 'a' 'parse_args__options'
    assert_array_has_key 'b' 'parse_args__options'
    assert_array_has_key 'c' 'parse_args__options'
    assert_array_not_has_key 'init' 'parse_args__options'

    assert_array_has_key 'init' 'parse_args__args'
    assert_array_has_key 'dev' 'parse_args__args'
    assert_array_not_has_key 'a' 'parse_args__args'

    assert_same 'index.php' $parse_args__option__file
    assert_same 'free' $parse_args__option__t
    assert_same true $parse_args__option__y
    assert_same true $parse_args__option__a
    assert_same true $parse_args__option__b
    assert_same true $parse_args__option__c
    assert_same true $parse_args__option__yellow

    # Now call again and make sure the old values are cleared out
    parse_args help

    assert_array_not_has_key 'files' 'parse_args__options'
    assert_array_not_has_key 'y' 'parse_args__options'
    assert_array_not_has_key 'a' 'parse_args__options'
    assert_array_not_has_key 'b' 'parse_args__options'
    assert_array_not_has_key 'c' 'parse_args__options'

    assert_array_has_key 'help' 'parse_args__args'
    assert_array_not_has_key 'init' 'parse_args__args'
    assert_array_not_has_key 'dev' 'parse_args__args'
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

function testGetConfigForScalarReturnsAsExpected() {
    assert_equals "declare -- tests_associative_array_do=\"alpha\"" "$(get_config "tests.associative_array.do")"
    assert_equals "declare -- tests_string=\"Adam ate apples at Andrew's abode.\"" "$(get_config "tests.string")"

    # Assert default is returned for non-existent.
    assert_equals "declare -- my_bogus_config_key=\"Default\"" "$(get_config "my.bogus.config.key" "Default value.")"

    # With an indexed array key as last
    assert_equals "declare -- tests_user_images_tags_0=\"literature\"" "$(get_config "tests.user.images.tags.0")"
    assert_equals "declare -- tests_user_images_tags_1=\"nature\"" "$(get_config "tests.user.images.tags.1")"
    assert_equals "declare -- tests_user_images_tags_2=\"space\"" "$(get_config "tests.user.images.tags.2")"
    assert_equals "declare -- tests_user_images_tags_3=\"religion\"" "$(get_config "tests.user.images.tags.3")"
}

function testGetConfigAsForScalarReturnsAsExpected() {
    assert_equals "declare -- hero=\"alpha\"" "$(get_config_as 'hero' "tests.associative_array.do")"

    # Assert default is returned for non-existent.
    assert_equals "declare -- hero=\"Batman\"" "$(get_config_as 'hero' "my.bogus.superhero" "Batman")"
}
