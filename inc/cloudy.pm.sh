#!/usr/bin/env bash

##
 # @file
 # Provide the Package Manager functions.
 #

function _cloudypm_install_package() {
    local package="$1"

    ! [[ "$package" ]] && fail_because "Missing package name, e.g. \"aklump/perms\"." && return 1

    # Make sure cloudy/cloudy is up-to-date.
    ! _cloudypm_update_cloudy && fail_because "Failed to update cloudy/cloudy." && return 1

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
    if [[ ! -f "$cached_info" ]]; then
        local path_to_package_yml=${cached_info/.sh/.yml}
        url=$(url_add_cache_buster "$url")
        curl -o "$path_to_package_yml" --create-dirs "$url" >/dev/null 2>&1 || fail_because "Cannot download $url"
        json=$(php "$CLOUDY_ROOT/php/config_to_json.php" "$CLOUDY_ROOT/cloudypm_info.schema.json" "$path_to_package_yml")
        json_result=$?
        write_log_debug "$json"
        rm $path_to_package_yml
        [[ $json_result -gt 0 ]] && fail_because "Cannot convert package info to JSON." && return 1
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

# Update cloudy as installed by cloudypm.
#
# Returns 0 if successful. 1 if not.
function _cloudypm_update_cloudy() {
  local path_to_dir="$WDIR/opt/cloudy/"
  ! [[ -d  "$path_to_dir" ]] && fail_because "Missing Cloudy package, which is expected to be installed in $path_to_dir." && return 1
  result=$(cd $path_to_dir && cloudy update -fy)
  [[ $? -ne 0 ]] && write_log_error "$result" && return 1
  succeed_because "cloudy/cloudy is at version $(cd $path_to_dir && cloudy --version)."

  return 0
}

# Update one or more packages.
#
# $1 - string
#   Optional. The package name, e.g. aklump/perms.  If omitted the option to
#   update all packages.
#
# Returns 0 if successful.
function _cloudypm_update_package() {
    local package="$1"

    # If package is not given, then they might want to update all
    ! [[ "$package" ]] && ! has_option yes && ! confirm --caution "Update all installed packages?" && fail_because "For single package update include the package name, e.g. \"aklump/perms\"." && return 1

    # Updating cloudy/cloudy or cloudy is a different process.
    if [[ "$package" == "cloudy" ]] || [[ "$package" == "cloudy/cloudy" ]]; then
      ! _cloudypm_update_cloudy && fail_because "Failed to update cloudy/cloudy." && return 2
      return 0
    fi

    declare -a packages=()
    if ! [[ "$package" ]]; then
      _cloudypm_get_installed_packages
      packages=("${_cloudypm_get_installed_packages__array[@]}")
    else
      packages=("$package");
    fi

    # Make sure cloudy/cloudy is up-to-date.
    ! _cloudypm_update_cloudy && fail_because "Failed to update cloudy/cloudy." && return 2

    for package in "${packages[@]}"; do

      # Proceed with single package.
      local package_destination_dir="$WDIR/opt/$package"
      ! [[ -d "$package_destination_dir" ]] && fail_because "Package is not installed; try pm-install $package" && return 1

      ## Now update package.
      _cloudypm_load_and_validate_package $package|| return 1
      echo_heading "$(echo_green "Package \"$package\" located.")"
      local package_destination_dir="$WDIR/opt/$package"
      local package_basename=$(basename $package_destination_dir)
      local stash=$(tempdir)

      (cd "$stash" && git clone "$cloudypm___clone_from" repo)
      [[ $? -ne 0 ]] && fail_because "Could not download new version." && return 1
      echo_heading "New version downloaded."
      rsync -a --delete --exclude=.git* "$stash/repo/" "$package_destination_dir/" || return 1
      [[ "$stash" ]] && [[ -d "$stash" ]] && rm -rf "$stash"
      [[ $? -ne 0 ]] && fail_because "Could not replace current version." && return 1
      echo_heading "Local package replaced."

      if [[ "$cloudypm___on_update" ]]; then
          [[ "$cloudypm___symlink" ]] || cloudypm___symlink="$(path_filename $cloudypm___entry_script)"
          local symlink="$WDIR/bin/$cloudypm___symlink"
          cd $WDIR && "./bin/$cloudypm___symlink" "$cloudypm___on_update" || fail_because "The command $cloudypm___on_update failed."
      fi
      _cloudypm_update_lock_file $package
      succeed_because "$package is at version $cloudypm___version."
    done

    has_failed && return 1
    return 0
}

function _cloudypm_update_lock_file() {
    local package=$1

    local lockfile="$WDIR/cloudypm.lock"
    touch $lockfile
    local find=($(grep $package $lockfile))
    [[ ${#find[@]} -gt 1 ]] && write_log_error "Data corruption detected in $lockfile; duplicate entries for \"$package\" found."
    local replace="$package:$cloudypm___version"
    if [[ "$find" ]]; then
        sed -i '' -E "s#${find}#${replace}#g" $lockfile || return 1
    else
        echo "$replace" >> $lockfile
    fi
}
_cloudypm_get_installed_packages__array=()
# Read the installed packages from cloudypm.lock
#
# Sets the value of _cloudypm_get_installed_packages__array
#
# Returns 0 if successful. 1 if not.
function _cloudypm_get_installed_packages() {
  local lockfile="$WDIR/cloudypm.lock"

  ! [[ -f "$lockfile" ]] && fail_because "Installed packages are detemined by cloudypm.lock; file does not exist in $WDIR" && return 1

  declare -a array=('value1' 'value2');
  while read -r string_split__string || [[ -n "$line" ]]; do
    string_split ':'
    _cloudypm_get_installed_packages__array=("${_cloudypm_get_installed_packages__array[@]}" "${string_split__array[0]}")
  done < $lockfile

  return 0
}
