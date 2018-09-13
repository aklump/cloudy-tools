#!/usr/bin/env bash

#
# @file
# Core functions used by the cloudy api.
#
function _cloudy_define_cloudy_vars() {
    # todo Can we move more things here, or would that break scope?
    LI="├──"
    LIL="└──"
}

function _cloudy_bootstrap_translations() {
    eval $(get_config_as "CLOUDY_LANGUAGE" "language" "en")

    # todo may not need to do these two?
    CLOUDY_SUCCESS=$(translate "exit_with_success" "Completed successfully.")
    CLOUDY_FAILED=$(translate "exit_with_failure" "Failed.")
}

function _cloudy_bootstrap() {
    SECONDS=0
    local aliases
    local value
    local options
    local command

    _cloudy_validate_config

    _cloudy_bootstrap_translations

    command=$(get_command)
    # Add in the alias options based on master options.
    for option in "${CLOUDY_OPTIONS[@]}"; do
        value="true"
        [[ "$option" =~ ^(.*)\=(.*) ]] && option=${BASH_REMATCH[1]} && value=${BASH_REMATCH[2]}
        eval $(get_config_keys_as 'aliases' "commands.${command}.options.${option}.aliases")
        for alias in ${aliases[@]}; do
           if ! has_option $alias; then
               CLOUDY_OPTIONS=("${CLOUDY_OPTIONS[@]}" "$alias")
               eval "CLOUDY_OPTION__$(string_upper $alias)=\"$value\""
           fi
        done
    done

    # Using aliases search for the master option.
    eval $(get_config_keys_as 'options' "commands.${command}.options")

    for master_option in "${options[@]}"; do
        eval $(get_config_as -a 'aliases' "commands.${command}.options.${master_option}.aliases")
        for alias in "${aliases[@]}"; do
            if has_option $alias && ! has_option $master_option; then
                value=$(get_option "$alias")
                CLOUDY_OPTIONS=("${CLOUDY_OPTIONS[@]}" "$master_option")
                eval "CLOUDY_OPTION__$(string_upper $master_option)=\"$value\""
            fi
        done
    done
}

##
 # Delete $CACHED_CONFIG_FILEPATH as necessary.
 #
function _cloudy_auto_purge_config() {
    local cache_mtime_filepath="${CACHED_CONFIG_FILEPATH/.sh/.modified.txt}"

    if [[ "$cloudy_development_do_not_cache_config" == true ]] || _cloudy_has_config_changed; then
        if [[ "$cloudy_development_do_not_cache_config" == true ]]; then
            write_log_dev_warning "Configuration purge detected due to \$cloudy_development_do_not_cache_config = true."
        else
            write_log_notice "Configuration changes detected."
        fi
        if ! rm -f "$CACHED_CONFIG_FILEPATH"; then
            fail_because "Could not rm $CACHED_CONFIG_FILEPATH during purge."
            write_log_critical "Cannot delete $CACHED_CONFIG_FILEPATH.  Cached configuration may be stale."
        fi
        ! has_failed && echo "$config_mtime" > "$cache_mtime_filepath"
    fi

    has_failed && exit_with_failure "Cannot auto purge config."
    return 0
}

##
 # Detect if cached config is stale against $CONFIG.
 #
function _cloudy_has_config_changed() {
    local cache_mtime_filepath="${CACHED_CONFIG_FILEPATH/.sh/.modified.txt}"
    [ -f "$cache_mtime_filepath" ] || touch "$cache_mtime_filepath" || fail

    local cache_mtime=$(cat "$cache_mtime_filepath")
    local config_mtime=$(php -r "echo filemtime('$CONFIG');")

    # Test if the yaml file was modified and automatically rebuild config.yml.sh
    [[ "$cache_mtime" -lt "$config_mtime" ]]
    return $?
}

##
 # Return config eval code for a given config path.
 #
 # @param string
 #   The config path, e.g. "commands.help.help"
 # @param string
 #   The default value if not found. This yields an exit status of 2.
 #
 # Options:
 # --as={custom_var_name}
 # --keys You want to return array keys.
 # --mutator={function name} Optional mutator function name.
 #
function _cloudy_get_config() {
    local config_path="$1"
    local default_value="$2"

    local default_type
    local var_name
    local var_value
    local array_keys
    local mutator
    local eval_code
    local dev_null
    local code
    local cached_var_name
    local cached_var_name_keys

    parse_arguments $@
    config_path=${parse_arguments__args[0]}
    cached_var_name="cloudy_config___${config_path//./___}"

    # This is the name of the variable containing the keys for $cached_var_name
    cached_var_name_keys=${cached_var_name/cloudy_config___/cloudy_config_keys___}

    get_array_keys=${parse_arguments__option__keys}
    [[ "$get_array_keys" ]] && cached_var_name="cloudy_config_keys___${config_path//./___}"
    default_value=${parse_arguments__args[1]}

    # Use the synonym if --as is passed
    var_name=${parse_arguments__option__as:-${config_path//./_}}

    [[ "${parse_arguments__option__a}" == true ]] && default_type='array'
    mutator=${parse_arguments__option__mutator}

    #todo apply mutator

    var_value=$(eval "echo "\$$cached_var_name"")

    # Determine the default value
    # @todo How to handle array defaults, syntax?
    # @link https://trello.com/c/6JXskrQn/9-c-619-allow-arrays-to-have-default-values-in-getconfig
    if ! [[ "$var_value" ]]; then
        if [[ "$default_type" == 'array' ]]; then
            eval "local $cached_var_name=("$default_value")"
        else
            eval "local $cached_var_name="$default_value""
        fi
    fi

    local var_type="$default_type"
    # todo discern the type.

    if [[ "$var_type" == "array" ]]; then
        eval "local get_array_keys=("\${$cached_var_name_keys[@]}")"
        [[ "${get_array_keys[0]}" == 0 ]] && var_type="indexed_array" || var_type="associative_array"
    fi
debug "$var_type;\$var_type"
    # It's an array and the keys are being asked for.
    if [[ "$get_array_keys" ]] && [[ "$var_type" =~ _array$ ]]; then
        code=$(declare -p $cached_var_name_keys)
        code="${code//$cached_var_name=/$var_name=}"

    elif [[ "$var_type" == "associative_array" ]]; then
        code=''
        for key in "${get_array_keys[@]}"; do
            eval "var_value=\"\$${cached_var_name}___${key}\""
            code="${code}${var_name}_${key}=\"$var_value\";"
        done
    else
        code=$(declare -p $cached_var_name)
        code="${code//$cached_var_name=/$var_name=}"
    fi

    echo $code && return 0
}


function _old_cloudy_get_config() {
    local config_path="$1"
    local default_value="$2"

    local default_type
    local var_name
    local array_keys
    local mutator
    local eval_code
    local dev_null

    parse_arguments $@
    config_path=${parse_arguments__args[0]}
    default_value=${parse_arguments__args[2]}
    var_name=${config_path//./_}
    [[ "${parse_arguments__option__a}" == true ]] && default_type='array'
    array_keys=${parse_arguments__option__keys}
    mutator=${parse_arguments__option__mutator}

    debug "$config_path;\$config_path"
    debug "$default_value;\$default_value"
    debug "$default_type;\$default_type"
    debug "$array_keys;\$array_keys"
    debug "$mutator;\$mutator"

    # Load from memory
    config_data=("$(echo "$CACHED_CONFIG" | grep "$config_path|")")
    if ! [[ "$config_data" ]]; then

        # Load using PHP
        config_data=$(php "$CLOUDY_ROOT/_get_config.php" "$ROOT" "$CLOUDY_CONFIG_JSON" "$config_path" "$default_value" "$var_name" "$default_type" "$array_keys" "$mutator")
    fi

    local IFS="|";
    if [ $? -eq 0 ]; then
       read dev_null eval_code <<< "$config_data"
    else
       read file message <<< "$config_data"
       write_log_error "$message In file $file"
       return 1
    fi

    if [[ "${parse_arguments__option__as}" ]]; then
        eval_code="${eval_code/$var_name=/$parse_arguments__option__as=}"
    fi

    echo $eval_code && return 0
}

##
 # Validate the configuration JSON or do a exit_with_failure.
 #
function _cloudy_validate_config() {
    local error
    error=$(php "$CLOUDY_ROOT/_get_config.php" "$ROOT" "$CLOUDY_CONFIG_JSON")
    if [ $? -eq 0 ]; then
      return 0
    fi
    exit_with_failure "Configuration syntax error in $(basename $CLOUDY_CONFIG_JSON)."
}

function _cloudy_exit() {
    exit $CLOUDY_EXIT
}

##
 # Prepare a message with optional suffix and fallback.
 #
 # * default is used if no override is given.
 # * Ensures ends with period.
 #
function _cloudy_message() {
    local override=$1
    local default=$2
    local suffix=$3

    if [[ "$override" ]]; then
      echo ${override%.}${suffix%.}. && return 0
    fi
    echo ${default%.}${suffix%.}. && return 2
}

function _cloudy_echo_color() {
    local color=$1
    local message=$2
    local bg=$3

    if [[ "$bg" ]]; then
        echo "$(tput setaf $color)$(tput setab $bg)$message$(tput sgr0)"
    else
        echo "$(tput setaf $color)$message$(tput sgr0)"
    fi
}

##
 # Echo a list of items with bullets in color
 #
function _cloudy_echo_list() {
    local line_item
    local color_items=$1
    local color_bullets=$2
    local bullet
    local item
    for i in "${echo_list_array[@]}"; do
        bullet="$LI"
        if [[ "$color_bullets" ]]; then
            bullet=$(_cloudy_echo_color $color_bullets "$LI")
        fi
        item="$line_item"
        if [[ "$color_items" ]]; then
            item=$(_cloudy_echo_color $color_items "$line_item")
        fi
        [[ "$line_item" ]] && echo "$bullet $item"
        line_item="$i"
    done

    bullet="$LIL"
    if [[ "$color_bullets" ]]; then
        bullet=$(_cloudy_echo_color $color_bullets "$LIL")
    fi
    item="$line_item"
    if [[ "$color_items" ]]; then
        item=$(_cloudy_echo_color $color_items "$line_item")
    fi
    [[ "$line_item" ]] && echo "$bullet $item"
}

function _cloudy_exit_with_success() {
    local message=$1
    echo && echo_blue "👍  $message"

    ## Write out the failure messages if any.
    if [ ${#CLOUDY_SUCCESSES[@]} -gt 0 ]; then
        echo_list_array=("${CLOUDY_SUCCESSES[@]}")
        echo_blue_list
    fi

    echo
    CLOUDY_EXIT_STATUS=0 && _cloudy_exit
}

##
 # Set $_cloudy_get_valid_operations_by_command__array to all defined operations included aliases for a given op.
 #
function _cloudy_get_valid_operations_by_command() {
    local command=$1

    local option
    local options
    local aliases

    eval $(get_config_keys_as 'options' -a "commands.${command}.options")

    for option in "${options[@]}"; do
        eval $(get_config_as 'aliases' -a "commands.${command}.options.${option}.aliases")

        options=("${options[@]}" "${aliases[@]}")
    done

    _cloudy_get_valid_operations_by_command__array=("${options[@]}")
}

function _cloudy_validate_against_scheme() {
    local config_path_to_schema=$1
    local name=$2
    local value=$3
    local errors
    echo $(php $CLOUDY_ROOT/_validate_against_schema.php "$CLOUDY_CONFIG_JSON" "$config_path_to_schema" "$name" "$value")
    return $?
}

function _cloudy_help_commands() {
    local commands
    local help_command
    local help

    echo_headline "$(get_title) VER $(get_version)"

    echo_yellow "Available commands:"
    eval $(get_config_keys "commands")
    for help_command in "${commands[@]}"; do
        eval $(get_config_as 'help' "commands.$help_command.help")
        echo_list_array=("${echo_list_array[@]}" "$(echo_green "${help_command}") $help")
    done
    echo_list
}

function _cloudy_help_for_single_command() {
    local command_help_topic="$1"

    local arguments
    local options
    local usage
    local option
    local option_value
    local option_type
    local help_option
    local help_options
    local help_alias
    local help_argument

    eval $(get_config_as 'arguments' -a "commands.${command_help_topic}.arguments")
    eval $(get_config_as -a 'options' "commands.${command_help_topic}.options")

    usage="$(basename $SCRIPT) $command_help_topic"

    [ ${#options} -gt 0 ] && usage="$usage <options>"
    [ ${#arguments} -gt 0 ] && usage="$usage <arguments>"

    echo_headline "Help Topic: $command_help_topic"

    eval $(get_config_as 'help' "commands.${command_help_topic}.help")
    echo_green "$help"
    echo

    echo_yellow "Usage:"
    echo $LIL $(echo_green "$usage") && echo

    # The arguments.
    if [ ${#arguments} -gt 0 ]; then
        echo_yellow "Arguments:"
        echo_list_array=()

        for help_argument in "${arguments[@]}"; do
            eval $(get_config_as 'help' "commands.${command_help_topic}.arguments.${help_argument}.help")
            echo_list_array=("${echo_list_array[@]}" "$(echo_green "$help_argument") $help")
        done
        echo_list
        echo
    fi

    # The options.
    if [ ${#options} -gt 0 ]; then
        echo_yellow "Available options:"
        echo_list_array=()

        for option in "${options[@]}"; do

            option_value=''
            eval $(get_config_as 'option_type' "commands.${command_help_topic}.options.${option}.type" "boolean")
            [[ "$option_type" != "boolean" ]] && option_value="=<$option_type>"

            help_options=("$option")

            # Add in the aliases
            eval $(get_config_as -a 'options' "commands.${command_help_topic}.options.${option}.aliases")
            for help_alias in "${aliases[@]}"; do
               help_options=("${help_options[@]}" "$help_alias")
            done

            array_sort_by_item_length_array=(${help_options[@]})
            array_sort_by_item_length

            # Add in hyphens and values
            help_options=()
            for help_option in "${array_sort_by_item_length_array[@]}"; do
               if [ ${#help_option} -eq 1 ]; then
                    help_options=("${help_options[@]}" "-${help_option}${option_value}")
               else
                    help_options=("${help_options[@]}" "--${help_option}${option_value}")
               fi
            done

            array_join_array=(${help_options[@]})
            options=$(array_join ", ")

            eval $(get_config_as 'help' "commands.${command_help_topic}.options.${option}.help")

            echo_list_array=("${echo_list_array[@]}" "$(echo_green "$options") $help")
        done
        echo_list
    fi
}

function _cloudy_validate_command() {
    local command=$1

    local commands

    eval $(get_config_keys "commands")
    array_has_value__array=(${commands[@]})
    array_has_value "$command" && return 0
    fail_because "Command \"$command\", does not exist."
    return 1
}

function _cloudy_debug_helper() {
    local sidebar=''
    local IFS=";"; read default fg bg message basename funcname lineno  <<< "$@"
    [[ "$basename" ]] && sidebar="$sidebar${basename##./}"
    [[ "$funcname" ]] && sidebar="$funcname in $sidebar"
    [[ "$lineno" ]] && sidebar="$sidebar on line $lineno"
    [[ "$sidebar" ]] || sidebar="$default"
    echo && echo "$(tput setaf $fg)$(tput setab $bg) $sidebar $(tput smso) "$message" $(tput sgr0)" && echo
}

function _cloudy_assert_failed() {
    local actual=$1
    local reason="$(echo "$2")"

    [ ${#actual} -eq 0 ] && actual='""'
    actual="$(echo_yellow "$actual")"
    [[ $# -gt 2 ]] && expected="$(echo_green "$3")"

    let CLOUDY_FAILED_ASSERTION_COUNT=(CLOUDY_FAILED_ASSERTION_COUNT + 1)
    [[ "$CLOUDY_ACTIVE_TEST" ]] && fail_because "Failed test: $CLOUDY_ACTIVE_TEST in $(basename $CLOUDY_ACTIVE_TESTFILE)" && CLOUDY_ACTIVE_TEST=''

    local because="$actual $reason"
    [[ $# -gt 2 ]] && because="$because expected $expected"
    fail_because "$because"

    return 1
}

function _cloudy_write_log() {
    [[ "$LOGFILE" ]] || return
    local level="$1"
    shift
    local directory=$(dirname $LOGFILE)
    test -d "$directory" || mkdir -p "$directory"
    touch "$LOGFILE"
    echo "[$(date)] [$level] $@" >> "$LOGFILE"
#    echo "[$(date)] [$level] [$(whoami)] $@" >> "$LOGFILE"
}

#
# Begin Core Controller Section.
#

# Set this to true and config will be read from YAML every time.
cloudy_development_do_not_cache_config=true

cloudy_development_skip_config_validation=true

# Expand some vars from our controlling script.
CONFIG="$(cd $(dirname "$r/$CONFIG") && pwd)/$(basename $CONFIG)"
[[ "$LOGFILE" ]] && LOGFILE="$(cd $(dirname "$r/$LOGFILE") && pwd)/$(basename $LOGFILE)"

_cloudy_define_cloudy_vars

# Store the script options for later use.
parse_arguments $@

declare -a CLOUDY_ARGS=("${parse_arguments__args[@]}")
declare -a CLOUDY_OPTIONS=("${parse_arguments__options[@]}")
for option in "${CLOUDY_OPTIONS[@]}"; do
    eval "CLOUDY_OPTION__$(string_upper $option)=\"\$parse_arguments__option__${option}\""
done

# Define shared variables
declare -a CLOUDY_FAILURES=()
declare -a CLOUDY_SUCCESSES=()
declare -a CLOUDY_STACK=()
CLOUDY_EXIT_STATUS=0

#
# Setup caching
#

# For scope reasons we have to source these here and not inside _cloudy_bootstrap.
CACHE_DIR="$CLOUDY_ROOT/cache"
CACHED_CONFIG_FILEPATH="$CACHE_DIR/_cached.$(path_filename $SCRIPT).config.sh"
CACHED_CONFIG_INDEX_FILEPATH="${CACHED_CONFIG_FILEPATH/.sh/.index.txt}"
CACHED_CONFIG=''

# Ensure the configuration cache environment is present and writeable.
if [ -d "$CACHE_DIR" ]; then
    mkdir -p "$CACHE_DIR" || exit_with_failure "Unable to create cache folder: $CACHE_DIR"
fi

# Detect changes in YAML and purge config cache if necessary.
_cloudy_auto_purge_config

# Generate the cached configuration file.
if [ ! -f "$CACHED_CONFIG_FILEPATH" ]; then
    touch $CACHED_CONFIG_FILEPATH || exit_with_failure  "Unable to write cache file: $CACHED_CONFIG_FILEPATH"

    # Normalize the config file to JSON.
    CLOUDY_CONFIG_JSON="$(php $CLOUDY_ROOT/_config_to_json.php "$ROOT" "$CONFIG" "$cloudy_development_skip_config_validation")"

    [[ "$cloudy_development_skip_config_validation" == true ]] && write_log_dev_warning "Configuration validation is disabled due to \$cloudy_development_skip_config_validation == true."

    # Convert the JSON to bash config.
    php "$CLOUDY_ROOT/_generate_bash_config.php" "$ROOT" "$CLOUDY_CONFIG_JSON" > "$CACHED_CONFIG_FILEPATH" || exit_with_failure "Cannot create cached config filepath"
    if [ $? -ne 0 ]; then
        compiled=$(cat  "$CACHED_CONFIG_FILEPATH")
        fail_because "$(IFS="|"; read file reason <<< "$compiled"; echo "$reason")"
        exit_with_failure "Cannot create cached config filepath."
    else
        write_log_debug "$(basename $CONFIG) configuration compiled to $CACHED_CONFIG_FILEPATH."
    fi
fi

# Import the cached config variables at this top scope into memory.
source "$CACHED_CONFIG_FILEPATH" || exit_with_failure "Cannot load cached configuration."

#
# End caching setup
#


##_cloudy_get_config "title"
##_cloudy_get_config "fifo" "gigo"
##_cloudy_get_config "prod.db" --keys
##_cloudy_get_config "prod.db" --keys --as=db_keys
##_cloudy_get_config "prod.db" -a --as=database
##_cloudy_get_config "prod.db" -a
##_cloudy_get_config "prod.db"
##_cloudy_get_config -a "user.images.tags"
##_cloudy_get_config -a "user.images.tags" --keys
##_cloudy_get_config "user.images.tags.0"
##_cloudy_get_config "user.images.tags.1"
##_cloudy_get_config "user.images.tags.2"
##_cloudy_get_config "user.images.tags.3"
#assert_same "declare -a user_images_types_vector='([0]=\"svg\")'" "${_cloudy_get_config "user.images.types.vector" -a}"
#_cloudy_get_config "user.images.types.vectorize" -a
#_cloudy_get_config "user.images.types.bitmap.1"
#throw ";$0;$FUNCNAME;$LINENO"
#
##eval $(_cloudy_get_config -a "db")
##debug "$db_user;\$db_user"
##debug "$db_name;\$db_name"
##debug "$db_pass;\$db_pass"
##echo
##echo

#eval $(_cloudy_get_config -a "coretest.user.images.types.bitmap" --as=cmds)
#
#echo $0 at line $LINENO
#echo Function: $FUNCNAME
#echo '  "'$cmds'"'
#echo '    [#] => '${#cmds[@]}
#echo '    [@] => '${cmds[@]}
#echo '    [*] => '${cmds[*]}
#echo 'Array'
#echo '('
#echo '    [0] => '${cmds[0]}
#echo '    [1] => '${cmds[1]}
#echo '    [2] => '${cmds[2]}
#echo '    [3] => '${cmds[3]}
#echo '    [4] => '${cmds[4]}
#echo '    [5] => '${cmds[5]}
#echo '    [6] => '${cmds[6]}
#echo '    [7] => '${cmds[7]}
#echo '    [8] => '${cmds[8]}
#echo '    [9] => '${cmds[9]}
#echo ')'
#exit
#
#
##_cloudy_get_config -a 'commands' --keys
#get_config_keys 'commands'
#throw ";$0;$FUNCNAME;$LINENO"

if [[ $(type -t on_boot) == "function" ]]; then
    on_boot
fi

_cloudy_bootstrap $@


