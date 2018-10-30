#!/usr/bin/env bash

##
 # @file
 # Provide the Package Manager functions.
 #

function _cloudypm_install_package() {
    local package="$1"

    ! [[ "$package" ]] && fail_because "Missing package name, e.g. \"aklump/perms\"." && return 1

    _cloudypm_load_and_validate_package $package|| return 1
    echo_heading "Package located, installing..."

    local lockfile="$WDIR/cloudypm.lock"
    local cloudy_destination_dir="$WDIR/opt/cloudy/cloudy"
    local package_destination_dir="$WDIR/opt/$package"
    local package_basename=$(basename $package_destination_dir)
    local bin="$WDIR/bin"

    if [ ! -d "$cloudy_destination_dir" ]; then
        (mkdir -p "$(dirname $cloudy_destination_dir)" && cd "$(dirname $cloudy_destination_dir)" && cloudy core > /dev/null)
        echo_green "$LI Installed Cloudy."
    fi

    [ -d "$package_destination_dir" ] && fail_because "Package already installed." && return 1


    # Install the package
    [ ! -d "$(dirname $package_destination_dir)" ] && mkdir -p $(dirname $package_destination_dir)
    (cd $(dirname $package_destination_dir) && git clone "$cloudypm___clone_from" "$package_basename" >/dev/null 2>&1 && rm -rf $package_destination_dir/.git) && echo_green "$LI Downloaded package version $cloudypm___version."

    # Manage the bin/symlink.
    ! [ -d "$bin" ] && mkdir "$bin" && echo_green "$LI Created directory \"$(basename bin)\"."

    [[ "$cloudypm___symlink" ]] || cloudypm___symlink="$(path_filename $cloudypm___entry_script)"
    local symlink="$WDIR/bin/$cloudypm___symlink"
    if [ ! -s "$symlink" ]; then
        local target="../opt/$package/$cloudypm___entry_script"
        if [ -f "$bin/$target" ]; then
            (cd "$bin" && ln -s "$target" "$symlink") && echo_green "$LI Symlink \"$symlink\" created."
        else
            fail_because "Could not create symlink to missing target: $bin/$target" && return 1
        fi
    fi

    if [[ "$cloudypm___on_install" ]]; then
        cd $WDIR && "./bin/$cloudypm___symlink" "$cloudypm___on_install" || fail_because "The command $cloudypm___on_install failed."
    fi

    _cloudypm_update_lock_file $package

    return 0
}

function _cloudypm_load_package_info() {
    local package="$1"

    local cached_info="$CACHE_DIR/cpm/$package.sh"
    local found=$(grep "$package " "$ROOT/cloudy_package_registry.txt")
    local json
    read name url <<< "$found"
    [[ "$url" ]] || return 1

    # Download YAML and convert to cached BASH.
    if [ ! -f "$cached_info" ]; then
        local cache_info_yml=${cached_info/.sh/.yml}
        url=$(url_add_cache_buster "$url")
        curl -o $cache_info_yml --create-dirs "$url" >/dev/null 2>&1 || fail_because "Cannot download $url"
        json=$(php $CLOUDY_ROOT/php/config_to_json.php "$ROOT" "$CLOUDY_ROOT/cloudypm_info.schema.json" "$cache_info_yml")
        json_result=$?
        rm $cache_info_yml
        [ $json_result -gt 0 ] && fail_because "Cannot convert package info to JSON." && return 1
        php "$CLOUDY_ROOT/php/json_to_bash.php" "$ROOT" "cloudypm" "$json" > "$cached_info"
        source $cached_info || return 1

        # Use the git clone to determine the version based on the latest tag.
        local stash=$(tempdir)
        (cd $stash && git clone "$cloudypm___clone_from" repo >/dev/null 2>&1)
        cloudypm___version=$(cd "$stash/repo" && echo $(git describe --abbrev=0 --tags 2>/dev/null))
        if [[ ! "$cloudypm___version" ]]; then
            cloudypm___version="dev-$(cd "$stash/repo" && echo $(git rev-parse --abbrev-ref HEAD))"
        fi
        rm -rf $stash && echo >> $cached_info && echo "cloudypm___version=\"$cloudypm___version\"" >> $cached_info || return 1
        return 0
    fi

    source $cached_info
}


function _cloudypm_load_and_validate_package() {
    local package="$1"

    _cloudypm_load_package_info "$package"
    [ $? -gt 0 ] && fail_because "Package \"$1\" is not found in the registry." && return 1
    return 0
}

function _cloudypm_update_package() {
    local package="$1"

    ! [[ "$package" ]] && fail_because "Missing package name, e.g. \"aklump/perms\"." && return 1

    local package_destination_dir="$WDIR/opt/$package"
    ! [ -d "$package_destination_dir" ] && fail_because "Package is not installed; try pm-install $package" && return 1

    ## First, update Cloudy.
    (cd "$WDIR/opt/cloudy/" && cloudy update -fy > /dev/null) && succeed_because "cloudy/cloudy was also updated."

    ## Now update package.
    _cloudypm_update_package__new_version=''
    _cloudypm_load_and_validate_package $package|| return 1
    echo_heading "Package located, updating..."
    local package_destination_dir="$WDIR/opt/$package"
    local package_basename=$(basename $package_destination_dir)
    local stash=$(tempdir)

    (cd $stash && git clone "$cloudypm___clone_from" repo >/dev/null 2>&1)
    [ -d "$stash/repo" ] || return 1
    rsync -a --delete --exclude=.git* "$stash/repo/" "$package_destination_dir/" || return 1
    rm -rf $stash

    if [[ "$cloudypm___on_update" ]]; then
        [[ "$cloudypm___symlink" ]] || cloudypm___symlink="$(path_filename $cloudypm___entry_script)"
        local symlink="$WDIR/bin/$cloudypm___symlink"
        cd $WDIR && "./bin/$cloudypm___symlink" "$cloudypm___on_update" || fail_because "The command $cloudypm___on_update failed."
    fi
    _cloudypm_update_lock_file $package
    _cloudypm_update_package__new_version=$cloudypm___version

    has_failed ? return 1 : return 0
}

function _cloudypm_update_lock_file() {
    local package=$1

    local lockfile="$WDIR/cloudypm.lock"
    touch $lockfile
    local find=($(grep $package $lockfile))
    [ ${#find[@]} -gt 1 ] && write_log_error "Data corruption detected in $lockfile; duplicate entries for \"$package\" found."
    local replace="$package:$cloudypm___version"
    if [[ "$find" ]]; then
        sed -i '' -E "s#${find}#${replace}#g" $lockfile || return 1
    else
        echo "$replace" >> $lockfile
    fi
}
