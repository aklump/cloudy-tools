#!/usr/bin/env bash
source="${BASH_SOURCE[0]}"
while [ -h "$source" ]; do # resolve $source until the file is no longer a symlink
  dir="$( cd -P "$( dirname "$source" )" && pwd )"
  source="$(readlink "$source")"
  [[ $source != /* ]] && source="$dir/$source" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
ROOT="$( cd -P "$( dirname "$source" )" && pwd )"
CLOUDY_CONFIG=$ROOT/cloudy-app.yml
source "$ROOT/install/cloudy/cloudy.sh"
# End Cloudy Bootstrap

# Input validation
validate_input || exit_with_failure "Something didn't work..."

# Handle the various operations.
command=$(get_command)
case $command in
"new")
    basename=$(get_arg 0 "cloudy-script.sh")
    default_config=$(path_filename $basename).yml
    example_script=$(path_filename $basename).example.sh
    config_file=$(get_option config $default_config)
    [ -e "$basename" ] && ! has_option "force" && fail_because "$basename already exists. Use --force, -f to proceed."
    if ! has_failed; then
        rsync -a $ROOT/install/ ./ || fail_because "Could not copy Cloudy core to ."
        mv script.sh $basename || fail_because "Could not rename script.sh to $basename"
        mv script.example.sh $example_script || fail_because "Could not rename script.example.sh to $example_script"
        sed -i '' "s/__CONFIG/$config_file/g" $basename || fail_because "Could not update config file in $basename"

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
    exit_with_success_elapsed "New script $basename created."
    ;;

"help")
    echo_help $(get_arg 0) && exit 0
    ;;

*)
    throw "Unhandled operation \"$command\""
    ;;

esac

has_failed && exit_with_failure
