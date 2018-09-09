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
        [ $? -ne 0 ] && exit_with_failure "$CLOUDY_CONFIG_JSON"
    fi
    _cloudy_validate_config

    CLOUDY_LANGUAGE=$(get_config "language" "en")

    # todo may not need to do these two?
    CLOUDY_SUCCESS=$(translate "exit_with_success" "Completed successfully.")
    CLOUDY_FAILED=$(translate "exit_with_failure" "Failed.")

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

    local command=$(get_command)

    # Add in the alias action based on master options.
    local value
    for option in "${CLOUDY_OPTIONS[@]}"; do
        local value="true"
        [[ "$option" =~ ^(.*)\=(.*) ]] && option=${BASH_REMATCH[1]} && value=${BASH_REMATCH[2]}
        eval $(get_config "commands.${command}.options.${option}.aliases")

        for alias in ${OPERATIONS_NEW_OPTIONS_FORCE_ALIASES[@]}; do
           ! has_option $alias && CLOUDY_OPTIONS=("${CLOUDY_OPTIONS[@]}" "$alias=$value")
        done
    done

    # Using aliases search for the master option.
    eval $(get_config_keys "commands.${command}.options")
    for master_option in "${config_keys[@]}"; do
        eval $(get_config "commands.${command}.options.${master_option}.aliases")
        for alias in "${config_values[@]}"; do
            if has_option $alias && ! has_option $master_option; then
                value=$(get_option "$alias")
                CLOUDY_OPTIONS=("${CLOUDY_OPTIONS[@]}" "$master_option=$value")
            fi
        done
    done
}

function _cloudy_read_config() {
    local config_key=$1
    local default_value=$2
    local default_type=$3
    local array_keys=$4
    local mutator=$5
    local return
    return=$(php "$CLOUDY_ROOT/_get_config.php" "$ROOT" "$CLOUDY_CONFIG_JSON" "$config_key" "$default_value" "$default_type" "$array_keys" "$mutator")
    if [ $? -eq 0 ]; then
      echo $return && return 0
    fi
    echo $default_value && return 2
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
        echo_green_list
    fi

    echo
    CLOUDY_EXIT_STATUS=0 && _cloudy_exit
}

##
 # Set $CLOUDY_STACK to all defined operations included aliases for a given op.
 #
function _cloudy_get_valid_operations_by_command() {
    local command=$1
    local options
    declare -a options=();
    eval $(get_config_keys "commands.${command}.options")
    options=("${config_keys[@]}")

    for option in "${options[@]}"; do
        eval $(get_config "commands.${command}.options.${option}.aliases")
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

function _cloudy_help_commands() {
    echo_yellow "Available commands:"
    eval $(get_config_keys "commands")
    for help_command in "${config_keys[@]}"; do
        help=$(get_config "commands.$help_command.help")
        echo_list_array=("${echo_list_array[@]}" "$(echo_green "${help_command}") $help")
    done
}

function _cloudy_help_command_options() {
    local command=$1

    local option
    local option_value
    local option_type
    local help_option
    local help_options
    local help_alias
    local help_argument

    # The arguments.
    echo_yellow "Arguments:"
    echo_list_array=()
    eval $(get_config_keys "commands.${command}.arguments")
    for help_argument in "${config_keys[@]}"; do
        help=$(get_config "commands.${command}.arguments.${help_argument}.help")
        echo_list_array=("${echo_list_array[@]}" "$(echo_green "$help_argument") $help")
    done
    echo_list

    echo

    # The options.
    echo_yellow "Available options:"
    echo_list_array=()
    eval $(get_config_keys "commands.${command}.options")

    for option in "${config_keys[@]}"; do

        option_value=''
        option_type=$(get_config "commands.${command}.options.${option}.type" "boolean")
        [[ "$option_type" != "boolean" ]] && option_value="={$option_type}"

        help_options=("$option")

        # Add in the aliases
        eval $(get_config "commands.${command}.options.${option}.aliases" "" "array")
        for help_alias in "${config_values[@]}"; do
           help_options=("${help_options[@]}" "$help_alias")
        done

        stack_sort_length_array=(${help_options[@]})
        stack_sort_length

        # Add in hyphens and values
        help_options=()
        for help_option in "${stack_sort_length_array[@]}"; do
           if [ ${#help_option} -eq 1 ]; then
                help_options=("${help_options[@]}" "-${help_option}${option_value}")
           else
                help_options=("${help_options[@]}" "--${help_option}${option_value}")
           fi
        done

        stack_join_array=(${help_options[@]})
        options=$(stack_join ", ")

        help=$(get_config "commands.${command}.options.${option}.help")

        echo_list_array=("${echo_list_array[@]}" "$(echo_green "$options") $help")
    done
    echo_list
}

function _cloudy_validate_command() {
    local command=$1
    eval $(get_config_keys "commands")
    stack_has_array=(${config_keys[@]})
    stack_has $command && return 0
    fail_because "Command \"$command\", does not exist."
    return 1
}
