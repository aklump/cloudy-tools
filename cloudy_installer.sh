#!/usr/bin/env bash

#
# @file
# Coudy installer script.
#

# Define the configuration file relative to this script.
CONFIG="cloudy.yml";

# Uncomment this line to enable file logging.
LOGFILE="install/cloudy/cache/cloudy_installer.log"

function on_boot() {

    # Run the test command before the bootstrap to avoid conflicts.
    [[ "$(get_command)" == "tests" ]] || return 0
    source "$CLOUDY_ROOT/inc/cloudy.testing.sh"
    do_tests_in "cloudy.tests.sh"
    exit_with_test_results
}

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/install/cloudy/cloudy.sh"
# End Cloudy Bootstrap

# Input validation
validate_input || exit_with_failure "Something didn't work..."

command=$(get_command)

# Handle help.
has_option "h" && exit_with_help $command
[[ "$command" == "help" ]] && exit_with_help $(get_command_arg 0)

# Handle other commands.
case $command in

"new")
    basename=$(get_command_arg 0 "cloudy_script.sh")
    script_filename=$(path_filename "$basename")
    config_file="$script_filename.yml"
    has_option "json" && config_file="$script_filename.json"

    example_script="script.example.sh"

    # Protect an existing script by that name.
    [ -e "$basename" ] && ! has_option "force" && fail_because "$basename already exists. Use --force, -f to proceed."

    if ! has_failed; then
        rsync -a $ROOT/install/ ./  --exclude=*.log --exclude=cache/ --exclude=*.example.* || fail_because "Could not copy Cloudy core to $WDIR."

        # The stub file script.sh
        mv script.sh $basename || fail_because "Could not rename script.sh to $basename."
        sed -i '' "s/__FILENAME/$script_filename/g" $basename || fail_because "Could not replace __FILENAME in $basename"
        sed -i '' "s/__CONFIG/${config_file}/g" $basename || fail_because "Could not update config filepath in $basename."

        # Copy over examples.
        if has_option "examples"; then
            cp "$ROOT/install/script.example.sh" . || fail_because "Could not copy script.example.sh"
            cp "$ROOT/install/script.example.config.yml" . || fail_because "Could not copy script.example.config.yml"

            has_option "json" && debug "json" && sed -i '' "s/config.yml/config.json/g" script.example.sh || fail_because "Could not update config filepath in script.example.config.yml."
        fi

        # Convert YAML config files to JSON, if necessary.
        if has_option "json"; then
            echo $(php $CLOUDY_ROOT/php/config_to_json.php "$ROOT" "script.yml") > ${config_file} || fail_because "Could not convert $(path_filename $config_file) to JSON"
            [ $? -eq 0 ] && rm script.yml

            echo $(php $CLOUDY_ROOT/php/config_to_json.php "$ROOT" "$WDIR/script.example.config.yml") > script.example.config.json || fail_because "Could not convert script.example.config.yml to JSON"
            [ $? -eq 0 ] && rm script.example.config.yml
        else
            mv script.yml $config_file || fail_because "Could not rename script.yml to $config_file."
        fi

        # Backout our files on failure.
        if has_failed; then
            [ -e $basename ] && rm $basename
            [ -e $config_file ] && rm $config_file
            [ -e cloudy ] && rm -r cloudy
        fi
    fi
    has_failed && exit_with_failure "Failed to install $basename"
    write_log_notice "Installed new script at $WDIR/$basename"
    exit_with_success_elapsed "New script $basename created."
    ;;

*)
    throw "Unhandled command \"$command\""
    ;;

esac

has_failed && exit_with_failure
