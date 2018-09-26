#!/usr/bin/env bash

#
# @file
# Coudy installer script.
#

# Define the configuration file relative to this script.
CONFIG="cloudy_tools.yml";

# Uncomment this line to enable file logging.
#LOGFILE="~/cloudy_tools.log"

function on_boot() {
    # Run the test command before the bootstrap to avoid conflicts.
    [[ "$(get_command)" == "tests" ]] || return 0
    source "$CLOUDY_ROOT/inc/cloudy.testing.sh"
    do_tests_in "tests/cloudy.tests.sh"
    exit_with_test_results
}

function rsync_framework() {
    [[ "$framework" ]] || return 1
    rsync -a $framework/cloudy/ ./cloudy  --exclude=*.log --exclude=cache/
}

function write_version_file() {
    echo "cloudy_update__last_update=$(timestamp)" > $WDIR/cloudy/version.sh

    echo "cloudy_update__version=\"$(get_version)\"" >> $WDIR/cloudy/version.sh
    echo "cloudy_update__source=\"https://github.com/aklump/cloudy\"" >> $WDIR/cloudy/version.sh
    [ $? -eq 0 ] || fail_because "An error occurred writing $WDIR/cloudy/version.sh"
    return $?
}

function validate_cloudy_instance_or_exit_with_failure() {
    [ -d "$WDIR/cloudy" ] || exit_with_failure "No Cloudy framework found in this directory."
}

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}";while [ -h "$s" ];do dir="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$dir/$s";done;r="$(cd -P "$(dirname "$s")" && pwd)";source "$r/framework/cloudy/cloudy.sh"
# End Cloudy Bootstrap

# Input validation
validate_input || exit_with_failure "Input validation failed."

implement_cloudy_basic

framework=$(realpath $CLOUDY_ROOT/..) || exit_with_failure "Missing Cloudy framework"
installation_info_filepath="$WDIR/cloudy/version.sh"

# Handle other commands.
command=$(get_command)
case $command in

    "flush")
        validate_cloudy_instance_or_exit_with_failure
        exit_with_cache_clear "$WDIR/cloudy"
        ;;

    "update")
        echo_title "Cloudy Framework Updater"

        available_version=$(get_version)

        # Check for cloudy folder.
        validate_cloudy_instance_or_exit_with_failure
        [ -f "$installation_info_filepath" ] || exit_with_failure "Cannot determine installed version; missing file $installation_info_filepath."
        source $installation_info_filepath

        # Check current version of instance.
        echo_key_value "Cloudy Directory" "$WDIR/cloudy"
        echo_key_value "Installed Version" "$cloudy_update__version"
        echo_key_value "Available System Version" "$available_version"

        # Check installed version.
        [[ "$cloudy_update__version" == "$available_version" ]] && exit_with_success "You're already up-to-date."

        echo
        echo_yellow "Your version $cloudy_update__version is out-of-date."
        echo

        has_option "dry_run" && exit_with_success "This was a dry run; nothing was changed."

        # Ask if they want to update.
        confirm "Do you want to update now?" || exit_with_failure "Update cancelled"

        rsync_framework || exit_with_failure "An error occurred while updating this Cloudy framework."
        write_version_file

        ! has_failed && exit_with_success "Framework has been updated"
    ;;

    "core")
        [ -e ./cloudy ] && exit_with_success "Cloudy is already installed.  Did you mean \"update\"?"
        rsync_framework || fail_because "Could not copy Cloudy core to $WDIR."
        if ! has_failed; then
            write_version_file
        fi
        has_failed && exit_with_failure "Failed to install core in current directory."
        write_log_notice "Installed Cloudy core in $WDIR"
        exit_with_success_elapsed "Core installed."
    ;;

    "new")
        basename=$(get_command_arg 0 "cloudy_script.sh")
        script_filename=$(path_filename "$basename")
        config_file="$script_filename.yml"
        has_option "json" && config_file="$script_filename.json"

        example_script="script.example.sh"

        # Protect an existing script by that name.
        [ -e "$basename" ] && ! has_option "force" && fail_because "$basename already exists. Use --force, -f to proceed."

        ! has_option 'y' && ! confirm "Create $script_filename in the current directory?" && exit_with_failure "Nothing accomplished."

        if ! has_failed; then
            rsync_framework || fail_because "Could not copy Cloudy core to $WDIR."
            cp $framework/script.sh ./
            cp $framework/script.yml ./

            # The stub file script.sh
            mv script.sh $basename || fail_because "Could not rename script.sh to $basename."
            sed -i '' "s/__FILENAME/$script_filename/g" $basename || fail_because "Could not replace __FILENAME in $basename"
            sed -i '' "s/__CONFIG/${config_file}/g" $basename || fail_because "Could not update config filepath in $basename."

            # Copy over examples.
            if has_option "examples"; then
                cp "$framework/script.example.sh" . || fail_because "Could not copy script.example.sh"
                cp "$framework/script.example.yml" . || fail_because "Could not copy script.example.yml"

                if has_option "json"; then
                    sed -i '' "s/script.example.yml/script.example.json/g" script.example.sh || fail_because "Could not update config filepath in script.example.sh."
                fi
            fi

            # Convert YAML config files to JSON, if necessary.
            if has_option "json"; then
                echo $(php $CLOUDY_ROOT/php/config_to_json.php "$ROOT" "script.yml") > ${config_file} || fail_because "Could not convert $(path_filename $config_file) to JSON"
                [ $? -eq 0 ] && rm script.yml

                echo $(php $CLOUDY_ROOT/php/config_to_json.php "$ROOT" "$WDIR/script.example.yml") > script.example.config.json || fail_because "Could not convert script.example.yml to JSON"
                [ $? -eq 0 ] && rm script.example.yml
            else
                mv script.yml $config_file || fail_because "Could not rename script.yml to $config_file."
            fi

            # Create a version stamp
            if ! has_failed; then
                write_version_file
            fi

            # Backout our files on failure.
            if has_failed; then
                [ -e "script.example.sh" ] && rm "script.example.sh"
                [ -e "script.example.yml" ] && rm "script.example.yml"
                [ -e "script.example.json" ] && rm "script.example.json"
                [ -e $basename ] && rm $basename
                [ -e $config_file ] && rm $config_file
                [ -e cloudy ] && rm -r cloudy
            fi
        fi
        has_failed && exit_with_failure "Failed to install $basename"
        write_log_notice "Installed new script at $WDIR/$basename"
        exit_with_success_elapsed "New script $basename created."
    ;;

esac

throw "Unhandled command \"$command\"".
