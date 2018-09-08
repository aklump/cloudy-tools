#!/usr/bin/env bash

#
# SECTION: Arguments, options, parameters
#

##
 # Validate the CLI input arguments and options.
 #
function validate_input() {
    local op

    op=$(get_op)

    # Assert only defined operations are valid.
    eval $(get_config_keys "operations")
    CLOUDY_STACK=(${config_keys[@]})
    stack_has $op || fail_with "Invalid operation \"$op\""

    # Assert only defined options for a given op.
    _cloudy_get_valid_operations_by_op $op
    for option in "${CLOUDY_OPTIONS[@]}"; do
       [[ "$option" =~ ^(.*)\=(.*) ]]
       name=${BASH_REMATCH[1]}
       value=${BASH_REMATCH[2]}
       stack_has $name || fail_with "Invalid option: $name"

       # Assert the provided value matches schema.
       eval $(_cloudy_validate_against_scheme "operations.$op.options.$name" "$name" "$value")
       if [[ "$schema_errors" ]]; then
            for error in "${schema_errors[@]}"; do
               fail_with "$error"
            done
       fi
    done

    has_failed && return 1
    return 0
}

function get_op() {
    [ ${#CLOUDY_ARGS[0]} -gt 0 ] && echo ${CLOUDY_ARGS[0]} && return 0
    echo $(get_config default_operation) && return 2
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
    for value in "${CLOUDY_STACK[@]}"; do
       [[ "$value" == "$needle" ]] && return 0
    done
    return 1
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
 #   get_op --> "action"
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

function get_config_keys() {
    local config_key=$1
    local default_value=$2
    _cloudy_read_config "$config_key" "$default_value" true
}
function get_config() {
    local config_key=$1
    local default_value=$2
    _cloudy_read_config "$config_key" "$default_value"
}

function translate() {
    local translation_key=$1
    local default_value=$2
    _cloudy_read_config "translate.$CLOUDY_LANGUAGE.$translation_key" "$default_value"
}

#
# SECTION: User feedback and output
#

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
    echo "⭐ ⭐ ⭐  $(_cloudy_message "$headline" "Headline")"
#    echo "$(tput setaf 15)$(tput setab 4)  $(tput smso) $(_cloudy_message "$headline" "Headline") $(tput sgr0)"
}


##
 # Echo an array as a bulletted list.
 #
 # You must provide your list array as $CLOUDY_STACK like so:
 # @code
 #   CLOUDY_STACK=("${some_array_to_echo[@]}")
 #   echo_red_list
 # @endcode
 #
function echo_list() {
    _cloudy_echo_list
}

function echo_red_list() {
    _cloudy_echo_list 1 1
}

function echo_green_list() {
    _cloudy_echo_list 2 2
}

function echo_yellow_list() {
    _cloudy_echo_list 3 3
}

function echo_blue_list() {
    _cloudy_echo_list 4 4
}

function echo_help() {
    echo_yellow "Help output @todo"
}

#
# SECTION: Ending the script.
#
# @link https://www.tldp.org/LDP/abs/html/exit-status.html
#

function success_exit() {
    local message=$1
    _cloudy_success_exit "$(_cloudy_message "$message" "$CLOUDY_SUCCESS")"
}

function success_elapsed_exit() {
    local message=$1
    _cloudy_success_exit "$(_cloudy_message "$message" "$CLOUDY_SUCCESS" " in $SECONDS seconds.")"
}

function succeed_with() {
    local message=$1
    [[ "$message" ]] || return 1
    message=$(_cloudy_message "$message")
    CLOUDY_EXIT_STATUS=0
    [[ "$message" ]] && CLOUDY_SUCCESSES=("${CLOUDY_SUCCESSES[@]}" "$message")
}

function failed_exit () {
    echo && echo_red "🔥🔥🔥 $(_cloudy_message "$1" "$CLOUDY_FAILED")"

    ## Write out the failure messages if any.
    if [ ${#CLOUDY_FAILURES[@]} -gt 0 ]; then
        CLOUDY_STACK=("${CLOUDY_FAILURES[@]}")
        echo_red_list
    fi

    echo

    if [ $CLOUDY_EXIT_STATUS -lt 2 ]; then
      CLOUDY_EXIT_STATUS=1
    fi
    _cloudy_exit
}

function fail_with() {
    local message=$1
    CLOUDY_EXIT_STATUS=1
    if [[ "$message" ]]; then
        message=$(_cloudy_message "$message")
        CLOUDY_FAILURES=("${CLOUDY_FAILURES[@]}" "$message")
    fi
}

function has_failed() {
    [ $CLOUDY_EXIT_STATUS -gt 0 ] && return 0
    return 1
}

##
 # Echo an exception message an perform failed_exit immediately.
 #
function throw_exit () {
    local args=$@
    echo "$(tput setaf 0)$(tput setab 1) Exception! $(tput smso) "${args[*]}" $(tput sgr0)"
    failed_exit
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
 # Use this for debugging.
 #
function breakpoint () {
    local args=$@
    echo "$(tput setaf 3)$(tput setab 15) breakpoint $(tput smso) "${args[*]}" $(tput sgr0)"
}

#
# End Public API
#
source="${BASH_SOURCE[0]}"
while [ -h "$source" ]; do # resolve $source until the file is no longer a symlink
  dir="$( cd -P "$( dirname "$source" )" && pwd )"
  source="$(readlink "$source")"
  [[ $source != /* ]] && source="$dir/$source" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
CLOUDY_ROOT="$( cd -P "$( dirname "$source" )" && pwd )"
# End Cloudy Bootstrap
declare -a CLOUDY_ARGS=()
declare -a CLOUDY_OPTIONS=()
declare -a CLOUDY_FAILURES=()
declare -a CLOUDY_SUCCESSES=()
declare -a CLOUDY_STACK=()
source "$CLOUDY_ROOT/_core.sh"
_cloudy_bootstrap $@

