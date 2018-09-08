#!/usr/bin/env bash

#
# @file
# Core functions used by the cloudy api.
#

function _cloudy_bootstrap() {
    SECONDS=0
    CLOUDY_EXIT_STATUS=0
    CLOUDY_CONFIG_JSON='{"language":"en"}'
    if [ -f "$CLOUDY_CONFIG" ]; then
        CLOUDY_CONFIG_JSON="$(php $CLOUDY_ROOT/_load_config.php "$ROOT" "$CLOUDY_CONFIG")"
    fi
    _cloudy_validate_config

    CLOUDY_LANGUAGE=$(get_config "language" "en")
    CLOUDY_SUCCESS=$(translate "success_exit" "Completed successfully.")
    CLOUDY_FAILED=$(translate "failed_exit" "Failed.")
    LI="├──"
    LIL="└──"

    # Parse script arguments into arrays.
    local arg
    local options
    local option

    for arg in "$@"; do
      if [[ "$arg" =~ ^--(.*) ]]; then
        option="${BASH_REMATCH[1]}"
        if [[ ! "$option" = *"="* ]]; then
            option="$option=true"
        fi
        CLOUDY_OPTIONS=("${CLOUDY_OPTIONS[@]}" "$option")
      elif [[ "$arg" =~ ^-(.*) ]]; then
        options=($(echo "${BASH_REMATCH[1]}" | grep -o .))
        for option in "${options[@]}"; do
            CLOUDY_OPTIONS=("${CLOUDY_OPTIONS[@]}" "$option=true")
        done
      else
        CLOUDY_ARGS=("${CLOUDY_ARGS[@]}" "$arg")
      fi
    done

    local op=$(get_op)

    # Add in the aliases for the options.
    local value
    for option in "${CLOUDY_OPTIONS[@]}"; do
        local value="true"
        [[ "$option" =~ ^(.*)\=(.*) ]] && option=${BASH_REMATCH[1]} && value=${BASH_REMATCH[2]}
        local varname=$(echo "operations_${op}_options_${option}_aliases" | tr [a-z] [A-Z])
        eval $(get_config "operations.${op}.options.${option}.aliases")

        for alias in ${OPERATIONS_NEW_OPTIONS_FORCE_ALIASES[@]}; do
           ! has_option $alias && CLOUDY_OPTIONS=("${CLOUDY_OPTIONS[@]}" "$alias=$value")
        done
    done
}

function _cloudy_read_config() {
    local config_key=$1
    local default_value=$2
    local array_keys=$3
    local return
    return=$(php "$CLOUDY_ROOT/_get_config.php" "$ROOT" "$CLOUDY_CONFIG_JSON" "$config_key" "$default_value" "$array_keys")
    if [ $? -eq 0 ]; then
      echo $return && return 0
    fi
    echo $default_value && return 2
}

##
 # Validate the configuration JSON or do a failed_exit.
 #
function _cloudy_validate_config() {
    local error
    error=$(php "$CLOUDY_ROOT/_get_config.php" "$ROOT" "$CLOUDY_CONFIG_JSON")
    if [ $? -eq 0 ]; then
      return 0
    fi
    failed_exit "$error in cloudy.json"
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
    for i in "${CLOUDY_LIST[@]}"; do
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

function _cloudy_success_exit() {
    local message=$1
    echo && echo_blue "👍 $message"

    ## Write out the failure messages if any.
    if [ ${#CLOUDY_SUCCESSES[@]} -gt 0 ]; then
        CLOUDY_LIST=("${CLOUDY_SUCCESSES[@]}")
        echo_green_list
    fi

    echo
    CLOUDY_EXIT_STATUS=0 && _cloudy_exit
}

##
 # Set $CLOUDY_STACK to all defined operations included aliases for a given op.
 #
function _cloudy_get_valid_operations_by_op() {
    local options
    declare -a options=();
    eval $(get_config_keys "operations.${op}.options")
    options=("${config_keys[@]}")

    for option in "${options[@]}"; do
        eval $(get_config "operations.${op}.options.${option}.aliases")
        options=("${options[@]}" "${config_values[@]}")
    done
    CLOUDY_STACK=(${options[@]})
}

function _cloudy_validate_against_scheme() {
    local config_path_to_schema=$1
    local name=$2
    local value=$3
    local errors
    echo $(php $CLOUDY_ROOT/_validate_against_schema.php "$CLOUDY_CONFIG_JSON" "$config_path_to_schema" "$name" "$value")
    return $?
}
