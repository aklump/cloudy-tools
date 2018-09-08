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
validate_input || failed_exit "Uh, that's not quite right..."

# Handle the various operations.
op=$(get_op)
case $op in
"new")
    basename=$(get_arg 0 "cloudy-script.sh")
    default_config=$(path_filename $basename).yml
    example_script=$(path_filename $basename).example.sh
    config_file=$(get_option config $default_config)
    [ -e "$basename" ] && ! has_option "force" && fail_with "$basename already exists. Use --force, -f to proceed."
    if ! has_failed; then
        rsync -a $ROOT/install/ ./ || fail_with "Could not copy Cloudy core to ."
        mv script.sh $basename || fail_with "Could not rename script.sh to $basename"
        mv script.example.sh $example_script || fail_with "Could not rename script.example.sh to $example_script"
        sed -i '' "s/__CONFIG/$config_file/g" $basename || fail_with "Could not update config file in $basename"

        if [[ "$config_file" != "config.yml" ]]; then
            mv ./config.yml $config_file || fail_with "Could not copy config.yml to $config_file"
        fi

        if has_failed; then
            [ -e $basename ] && rm $basename
            [ -e $config_file ] && rm $config_file
            [ -e cloudy ] && rm -r cloudy
        fi
    fi
    has_failed && failed_exit "Failed to install $basename"
    success_elapsed_exit "New script $basename created."
    ;;

"help")
    echo_help && exit 0
    ;;

*)
    throw_exit "Unhandled operation \"$op\""
    ;;

esac

has_failed && failed_exit
