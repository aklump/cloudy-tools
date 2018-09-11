#!/usr/bin/env bash

##
 # Override the variable name returned by get_config*
 #
function use_config_var() {
    local varname=$1
    CLOUDY_CONFIG_VARNAME="$varname" && return 0
}

##
 # Return to using the config varname as defined by the config file.
 #
function revert_config_var() {
    CLOUDY_CONFIG_VARNAME="" && return 0
}

#
# SECTION: Arguments, options, parameters
#

##
 # Validate the CLI input arguments and options.
 #
function validate_input() {
    local command

    command=$(get_command)

    # Assert only defined operations are valid.
    [[ "$command" ]] && _cloudy_validate_command $command

    # Assert only defined options for a given op.
    _cloudy_get_valid_operations_by_command $command

    for option in "${CLOUDY_OPTIONS[@]}"; do
       [[ "$option" =~ ^(.*)\=(.*) ]]
       name=${BASH_REMATCH[1]}
       value=${BASH_REMATCH[2]}
       stack_has_array=(${CLOUDY_STACK[@]})

       stack_has $name || fail_because "Invalid option: $name"

       # Assert the provided value matches schema.
       eval $(_cloudy_validate_against_scheme "commands.$command.options.$name" "$name" "$value")
       if [[ "$schema_errors" ]]; then
            for error in "${schema_errors[@]}"; do
               fail_because "$error"
            done
       fi
    done

    has_failed && return 1
    return 0
}

function get_command() {
    [ ${#CLOUDY_ARGS[0]} -gt 0 ] && echo ${CLOUDY_ARGS[0]} && return 0
    echo $(get_config default_command) && return 2
}

##
 # Determine if the script was called with a given option.
 #
function has_option() {
    local option=$1
    local value
    value=$(get_option "$option")
    return $?
}

##
 # Determine if any options were used when calling the script.
 #
function has_options() {
    [ ${#CLOUDY_OPTIONS[@]} -gt 0 ] && return 0
    return 1
}

##
 # Get the value of a given script parameter, if it exists.
 #
function get_option() {
    local param=$1
    local default=$2
    local var
    for var in "${CLOUDY_OPTIONS[@]}"; do
        if [[ "$var" =~ ^(.*)\=(.*) ]] && [ ${BASH_REMATCH[1]} == $param ]; then
            echo ${BASH_REMATCH[2]} && return 0
        fi
    done
    echo $default && return 2
}

##
 # Search $CLOUDY_STACK for a value.
 #
 # You must provide your array as $CLOUDY_STACK like so:
 # @code
 #   CLOUDY_STACK=("${some_array_to_search[@]}")
 #   stack_has "tree" && echo "found tree"
 # @endcode
 #
function stack_has() {
    local needle=$1
    local value
    for value in "${stack_has_array[@]}"; do
       [[ "$value" == "$needle" ]] && return 0
    done
    return 1
}

##
 # Join a stack into an array with delimiter.
 #
function stack_join() {
    local glue=$1
    local string
    string=$(printf "%s$glue" "${stack_join_array[@]}") && string=${string%$glue} || return 1
    echo $string
    return 0
}

##
 # Alphabetically sort a stack.
 #
function stack_sort() {
    local IFS=$'\n'
    stack_sort_array=($(sort <<<"${stack_sort_array[*]}"))
}

##
 # Sort a stack based on length of values.
 #
function stack_sort_length() {
    eval $(php "$CLOUDY_ROOT/_helpers.php" "stack_sort_length" "${stack_sort_length_array[@]}")
    return $?
}

##
 # Determine if there are any arguments for the script "operation".
 #
function has_args() {
    [ ${#CLOUDY_ARGS[@]} -gt 1 ] && return 0
    return 1
}

##
 # Return a operation argument by zero-based index key.
 #
 # As an example see the following code:
 # @code
 #   ./script.sh action blue apple
 #   get_command --> "action"
 #   get_arg 0 --> "blue"
 #   get_arg 1 --> "apple"
 # @endcode
 #
function get_arg() {
    local index=$1
    local default=$2
    let index=(index + 1)
    [ ${#CLOUDY_ARGS[@]} -gt $index ] && echo  ${CLOUDY_ARGS[$index]} && return 0
    echo $default && return 2
}

##
 # Get a config value.
 #
 # When requesting an array you must pass -a as the first argument if there's
 # any chance that the return value will be empty.
 #
function get_config() {
    if [[ "$1" == '-a' ]]; then
        default_type='array'
        shift
    fi
    local config_key=$1
    local default_value=$2
    _cloudy_get_config "$config_key" "$default_value" "$default_type"
}

##
 # Return configuration value or values as full path(s) relative to $ROOT.
 #
function get_config_path() {
    local config_key=$1
    local default_value=$2
    local default_type=$3
    _cloudy_get_config "$config_key" "$default_value" "$default_type" false "_cloudy_realpath"
}

function translate() {
    local translation_key=$1
    local default_value=$2
    _cloudy_get_config "translate.$CLOUDY_LANGUAGE.$translation_key" "$default_value" "string"
}

##
 # Determine if $stack_is_array_array is an array or not.
 #
function stack_is_array() {
    [[ "$(declare -p stack_is_array_array)" =~ "declare -a" ]]
}

#
# SECTION: User feedback and output
#

##
 # Accept a y/n confirmation message or end
 #
 # @param string $1
 #   A question to ask ending with a '?' mark.  Leave blank for default.
 #
 # @return bool
 #   Sets the value of confirm_result
 #
function confirm() {
 while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; return 0 ;;
      [nN]) echo ; return 1 ;;
      *) printf " \033[31m %s \n\033[0m" "invalid input"
    esac
  done
}

##
 # Echo a string in red.
 #
function echo_red() {
    _cloudy_echo_color 1 "$1";
}

##
 # Echo a string in green.
 #
function echo_green() {
    _cloudy_echo_color 2 "$1";
}

##
 # Echo a string in yellow.
 #
function echo_yellow() {
    _cloudy_echo_color 3 "$1";
}

##
 # Echo a string in blue.
 #
function echo_blue() {
    _cloudy_echo_color 4 "$1";
}

##
 # Print out a headline for a section of user output.
 #
function echo_headline() {
    local headline=$1
    [[ ! "$headline" ]] && return 1
    echo && echo "⭐  $(string_uppercase "${headline//.}")" && echo
}

##
 # Echo an array as a bulletted list.
 #
 # @param $echo_list_array
 #
 # You must provide your list array as $echo_list_array like so:
 # @code
 #   echo_list_array=("${some_array_to_echo[@]}")
 #   echo_list
 # @endcode
 #
function echo_list() {
    _cloudy_echo_list
}

##
 # @param $echo_list_array
 #
function echo_red_list() {
    _cloudy_echo_list 1 1
}

##
 # @param $echo_list_array
 #
function echo_green_list() {
    _cloudy_echo_list 2 2
}

##
 # @param $echo_list_array
 #
function echo_yellow_list() {
    _cloudy_echo_list 3 3
}

##
 # @param $echo_list_array
 #
function echo_blue_list() {
    _cloudy_echo_list 4 4
}

##
 # Return the elapsed time in seconds since the beginning of the script.
 #
function echo_elapsed() {
    echo $SECONDS
}

function echo_help() {

    # Focused topic, show info about command.
    if has_args; then

        _cloudy_validate_command $(get_arg 0) || exit_with_failure "No help for that!"

        # Todo: write this to a text file in cache.
        _cloudy_help_for_single_command

        exit_with_success "Use just \"help\" for more commands"
    fi

    # Top-level just show all commands.
    # Todo: write this to a text file in cache.
    _cloudy_help_commands
    exit_with_success "Use \"help [command]\" for specific info"

}

#
# SECTION: Ending the script.
#
# @link https://www.tldp.org/LDP/abs/html/exit-status.html
#

function exit_with_success() {
    local message=$1
    _cloudy_exit_with_success "$(_cloudy_message "$message" "$CLOUDY_SUCCESS")"
}

function exit_with_success_elapsed() {
    local message=$1
    _cloudy_exit_with_success "$(_cloudy_message "$message" "$CLOUDY_SUCCESS" " in $SECONDS seconds.")"
}

function succeed_because() {
    local message=$1
    [[ "$message" ]] || return 1
    message=$(_cloudy_message "$message")
    CLOUDY_EXIT_STATUS=0
    [[ "$message" ]] && CLOUDY_SUCCESSES=("${CLOUDY_SUCCESSES[@]}" "$message")
}

function exit_with_failure() {
    echo && echo_red "🔥  $(_cloudy_message "$1" "$CLOUDY_FAILED")"

    ## Write out the failure messages if any.
    if [ ${#CLOUDY_FAILURES[@]} -gt 0 ]; then
        echo_list_array=("${CLOUDY_FAILURES[@]}")
        echo_red_list
    fi

    echo

    if [ $CLOUDY_EXIT_STATUS -lt 2 ]; then
      CLOUDY_EXIT_STATUS=1
    fi
    _cloudy_exit
}

function fail() {
    CLOUDY_EXIT_STATUS=1 && return 0
}

function fail_because() {
    local message=$1
    fail
    if [[ "$message" ]]; then
        message=$(_cloudy_message "$message")
        CLOUDY_FAILURES=("${CLOUDY_FAILURES[@]}" "$message")
    fi
}

function has_failed() {
    [ $CLOUDY_EXIT_STATUS -gt 0 ] && return 0
    return 1
}

#
# Filepaths
#

function path_filename() {
    local path=$1
    filename=$(basename "$path")
    echo "${filename%.*}"
}

function path_extension() {
    local path=$1
    filename=$(basename "$path")
    echo "${filename##*.}"
}

function string_uppercase() {
    local string=$1
    echo $string | tr [a-z] [A-Z]
}

#
# Development
#

##
 # Echo the arguments sent to this is an eye-catching manner.
 #
 # Call as in the example below for better tracing.
 # @code
 #   debug "Some message to show|$0|$FUNCNAME|$LINENO"
 # @endcode
 #
function debug() {
    _cloudy_debug_helper "debug;3;0;$@"
}

function echo_key_value() {
    local key=$1
    local value=$2
    echo "$(tput setaf 0)$(tput setab 7) $key $(tput smso) "$value" $(tput sgr0)"
}

##
 # Echo an exception message and exit.
 #
function throw() {
    _cloudy_debug_helper "exception;1;7;$@"
    exit 3
}

##
 # Write to the log file, if logging is enabled.
 #
 # @param ... any number of args
 #
function write_log() {
    if [[ "$LOGFILE" ]]; then
        local directory=$(dirname $LOGFILE)
        test -d "$directory" || mkdir -p "$directory"
        touch "$LOGFILE"
        echo "[$(date)] [$(whoami)] $@" >> "$LOGFILE"
    fi
}

#
# End Public API
#

# Begin Cloudy Core Bootstrap
SCRIPT="$s";ROOT="$r";WDIR="$PWD";s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;CLOUDY_ROOT="$(cd -P "$(dirname "$s")" && pwd)";source "$CLOUDY_ROOT/_core.sh"|| exit_with_failure "Missing cloudy/_core.sh"
