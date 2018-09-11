#!/usr/bin/env bash

#
# @file
# Coudy installer script.
#

# Define the configuration file relative to this script.
CONFIG="cloudy_installer.yml";

# Uncomment this line to enable file logging.
LOGFILE="cloudy_installer.log"

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/install/cloudy/cloudy.sh"
# End Cloudy Bootstrap

# Input validation
validate_input || exit_with_failure "Something didn't work..."

command=$(get_command)

# Handle help.
has_option "h" && exit_with_help $command
[[ "$command" == "help" ]] && exit_with_help $(get_arg 0)

# Handle other commands.
case $command in

"new")
    basename=$(get_arg 0 "cloudy-script.sh")
    script_filename=$(path_filename $basename)
    default_config=$script_filename.yml
    example_script=$script_filename.example.sh
    config_file=$(get_option config $default_config)
    [ -e "$basename" ] && ! has_option "force" && fail_because "$basename already exists. Use --force, -f to proceed."
    if ! has_failed; then
        rsync -a $ROOT/install/ ./ || fail_because "Could not copy Cloudy core to ."
        mv script.sh $basename || fail_because "Could not rename script.sh to $basename"
        mv script.example.sh $example_script || fail_because "Could not rename script.example.sh to $example_script"
        sed -i '' "s/__CONFIG/$config_file/g" $basename || fail_because "Could not update config file in $basename"
        sed -i '' "s/__FILENAME/$script_filename/g" $basename || fail_because "Could not replace __FILENAME in $basename"

        if [[ "$config_file" != "config.yml" ]]; then
            mv ./config.yml $config_file || fail_because "Could not copy config.yml to $config_file"
        fi

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

"coretest")
    do_tests_in "cloudy_installer.tests.sh"
    exit_with_test_results
    ;;

*)
    throw "Unhandled operation \"$command\""
    ;;

esac

has_failed && exit_with_failure
