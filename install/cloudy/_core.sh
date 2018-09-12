#!/usr/bin/env bash

#
# @file
# Core functions used by the cloudy api.
#

function _cloudy_bootstrap() {
    SECONDS=0
    local aliases
    local value
    local options
    local command

    _cloudy_validate_config

    eval $(get_config_as "CLOUDY_LANGUAGE" "language" "en")

    # todo may not need to do these two?
#    CLOUDY_SUCCESS=$(translate "exit_with_success" "Completed successfully.")
#    CLOUDY_FAILED=$(translate "exit_with_failure" "Failed.")

    # Create some "constants".
    LI="├──"
    LIL="└──"

    command=$(get_command)
    # Add in the alias options based on master options.
    for option in "${CLOUDY_OPTIONS[@]}"; do
        value="true"
        [[ "$option" =~ ^(.*)\=(.*) ]] && option=${BASH_REMATCH[1]} && value=${BASH_REMATCH[2]}
        eval $(get_config_keys_as 'aliases' "commands.${command}.options.${option}.aliases")
        for alias in ${aliases[@]}; do
           ! has_option $alias && CLOUDY_OPTIONS=("${CLOUDY_OPTIONS[@]}" "$alias=$value")
        done
    done

    # Using aliases search for the master option.
    eval $(get_config_keys_as 'options' "commands.${command}.options")

    for master_option in "${options[@]}"; do
        eval $(get_config_as -a 'aliases' "commands.${command}.options.${master_option}.aliases")
        for alias in "${aliases[@]}"; do
            if has_option $alias && ! has_option $master_option; then
                value=$(get_option "$alias")
                CLOUDY_OPTIONS=("${CLOUDY_OPTIONS[@]}" "$master_option=$value")
            fi
        done
    done
}


##
 # Parses arguments into options, args and option values.
 #
 # @code
 #   function my_func{) {
 #     _cloudy_parse_options_args @$
 #     ...
 # @endcode
 #
 # The following variables are generated for:
 # @code
 #   my_func -ab --tree=life do re
 # @endcode
 #
 # - _cloudy_parse_options_args__args = (do re)
 # - _cloudy_parse_options_args__options = (a b tree)
 # - _cloudy_parse_options_args__option__a = true
 # - _cloudy_parse_options_args__option__b = true
 # - _cloudy_parse_options_args__option__tree = life
 #
function _cloudy_parse_options_args() {
    local name
    local value

    # Purge any previous values.
    for name in "${_cloudy_parse_options_args__options[@]}"; do
        eval "unset _cloudy_parse_options_args__option__${name}"
    done
    _cloudy_parse_options_args__options=()
    _cloudy_parse_options_args__args=()

    # Set the new values.
    for arg in "$@"; do
      if [[ "$arg" =~ ^--(.*) ]]; then
        name="${BASH_REMATCH[1]}"
        value=true
        if [[ "$name" =~ ^(.*)=(.*)$ ]]; then
            name="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
        fi
        _cloudy_parse_options_args__options=("${_cloudy_parse_options_args__options[@]}" "$name")
        eval "_cloudy_parse_options_args__option__${name}=${value}"
      elif [[ "$arg" =~ ^-(.*) ]]; then
        options=($(echo "${BASH_REMATCH[1]}" | grep -o .))
        for name in "${options[@]}"; do
            _cloudy_parse_options_args__options=("${_cloudy_parse_options_args__options[@]}" "$name")
            eval "_cloudy_parse_options_args__option__${name}=true"
        done
      else
        _cloudy_parse_options_args__args=("${_cloudy_parse_options_args__args[@]}" "$arg")
      fi
    done
}

##
 # Detect if cached config is stale.
 #
function _cloudy_auto_purge_config() {
    local cache_mtime_filepath="${CACHED_CONFIG_FILEPATH/.sh/.modified.txt}"
    [ -f "$cache_mtime_filepath" ] || touch "$cache_mtime_filepath" || fail

    local cache_mtime=$(cat "$cache_mtime_filepath")
    local config_mtime=$(php -r "echo filemtime('$CONFIG');")

    # Test if the yaml file was modified and automatically rebuild config.yml.sh
    if [[ "$cache_mtime" -lt "$config_mtime" ]]; then
        rm -f "$CACHED_CONFIG_FILEPATH" || fail
        echo "$config_mtime" > "$cache_mtime_filepath"
        write_log_notice "Configuration changes detected; auto-purged $CACHED_CONFIG_FILEPATH"
    fi

    touch $CACHED_CONFIG_FILEPATH || fail_because  "Unable to write cache file: $CACHED_CONFIG_FILEPATH"

    has_failed && exit_with_failure "Cannot auto purge config."
    return 0
}

function _cloudy_get_config() {
    local config_key=$1
    local default_value=$2
    local default_type=$3
    local array_keys=$4
    local mutator=$5

    local return
    local var_type
    local var_name=${config_key//./_}
    local var_cached_name="cloudy_config_${var_name}"
    [[ "$default_type" ]] && var_cached_name="${var_cached_name}__${default_type}"
    [[ "$array_keys" ]] && var_cached_name="${var_cached_name}__keys"
write_log "cache_name" $var_cached_name
    local var_eval

    # Check if the variable is in memory because it was previously written to
    # $CACHED_CONFIG_FILEPATH, if not pull it in with the slower PHP process.
    if [[ "$CACHED_CONFIG" != *"$var_cached_name="* ]]; then
        write_log "config_read" "$var_cached_name"
        return=$(php "$CLOUDY_ROOT/_get_config.php" "$ROOT" "$CLOUDY_CONFIG_JSON" "$config_key" "$default_value" "$default_type" "$array_keys" "$mutator" "$var_cached_name")

        if [ $? -eq 0 ]; then
            local IFS="|"; read var_type var_cached_name var_eval <<< "$return"
            if [[ "$cloudy_development_do_not_cache_config" != true ]]; then
                echo "$var_eval" >> "$CACHED_CONFIG_FILEPATH" || fail_because "Could not write to $(basename $CACHED_CONFIG_FILEPATH)"
                echo "unset $var_cached_name" >> "${CACHED_CONFIG_FILEPATH/.sh/.purge.sh}" || fail_because "Could not write to $(basename $CACHED_CONFIG_FILEPATH)"
                write_log_debug "$var_eval was written to $(basename $CACHED_CONFIG_FILEPATH)"
                write_log "config_write" "$var_eval"
            else
                write_log_warning "$var_eval not written since \$cloudy_development_do_not_cache_config is TRUE."
            fi
        else
           local IFS="|"; read file message <<< "$return"
           write_log_error "$message In file $file"
           return 1
        fi


        # Beware this only has the scope of this function if a new
        # variable.  It won't be until the next run of the script that
        # the scope will be at the top level, because that's when the
        # cache file is sourced by cloudy.sh.  We need to evaluate it
        # here though, because it's used below.
        if [[ "$var_eval" ]]; then
            eval "$var_eval"
        else
            write_log_critical "\$var_eval was empty"
            return 1
        fi
    fi

    [ "$CLOUDY_CONFIG_VARNAME" ] && var_name="$CLOUDY_CONFIG_VARNAME"

    # Either way the variable is in memory at this point as $var_cached_name.
    # We now need to figure out what to echo back to the caller.
    local code=$(declare -p $var_cached_name)

    echo "${code/$var_cached_name/$var_name}" && return 0
    return 1

    # We have an array, so we have to echo an eval statement.
    if [[ "$code" =~ "declare -a" ]]; then

        # Try to use $var_name instead of $var_cached_name.
        echo "${code/$var_cached_name/$var_name}" && return 0
    fi

    # We have a scalar and we just want a value.
    eval value=\"\$$var_cached_name\"
    echo $value && return 0
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
    exit_with_failure "$error in cloudy.json"
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

    local options
    local option
    local aliases

    eval $(get_config_as 'options' -a "commands.${command}.options")

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
cloudy_development_do_not_cache_config=false


# Expand some vars from our controlling script.
CONFIG="$(cd $(dirname "$r/$CONFIG") && pwd)/$(basename $CONFIG)"
[[ "$LOGFILE" ]] && LOGFILE="$(cd $(dirname "$r/$LOGFILE") && pwd)/$(basename $LOGFILE)"

# Store the script options for later use.
_cloudy_parse_options_args $@

declare -a CLOUDY_ARGS=("${_cloudy_parse_options_args__args[@]}")
declare -a CLOUDY_OPTIONS=("${_cloudy_parse_options_args__options[@]}")
for option in "${CLOUDY_OPTIONS[@]}"; do
    eval "CLOUDY_OPTION__$(string_upper $option)=\"\$_cloudy_parse_options_args__option__${option}\""
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
CACHED_CONFIG=''

# Ensure the configuration cache environment is present and writeable.
if [ -d "$CACHE_DIR" ]; then
    mkdir -p "$CACHE_DIR" || exit_with_failure "Unable to create cache folder: $CACHE_DIR"
fi
touch $CACHED_CONFIG_FILEPATH || exit_with_failure  "Unable to write cache file: $CACHED_CONFIG_FILEPATH"

# Detect changes in YAML and purge config cache if necessary.
_cloudy_auto_purge_config

# Import the cached config variables at this top scope.
source "$CACHED_CONFIG_FILEPATH" || exit_with_failure "Cannot load cached configuration."
CACHED_CONFIG=$(cat "$CACHED_CONFIG_FILEPATH")

# Load the configuration JSON into memory which is used by get_config*.
if [ -f "$CACHE_DIR/_cached.$(path_filename $SCRIPT).config.json" ]; then
    CLOUDY_CONFIG_JSON=$(cat "$CACHE_DIR/_cached.$(path_filename $SCRIPT).config.json")
else
    CLOUDY_CONFIG_JSON="$(php $CLOUDY_ROOT/_config_to_json.php "$ROOT" "$CONFIG")"
    if [[ "$cloudy_development_do_not_cache_config" != true ]]; then
        echo $CLOUDY_CONFIG_JSON > "$CACHE_DIR/_cached.$(path_filename $SCRIPT).config.json"
    fi
fi

#
# End caching setup
#

_cloudy_bootstrap $@
