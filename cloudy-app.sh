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

default_op=$(get_config operations._default)
op=$(get_arg 0 $default_op)

if [[ "$op" == "new" ]]; then
    basename=$(get_arg 1 "cloudy-script.sh")
    default_config=$(path_filename $basename).yml
    example_script=$(path_filename $basename).example.sh
    config_file=$(get_param config $default_config)
    [ -e "$basename" ] && ! has_flag f && fail_with "$basename already exists."
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
else
    fail_with "\"new\" is the only supported operation"
fi

has_failed && failed_exit "Failed to install $basename"
success_elapsed_exit "New script $basename created."
