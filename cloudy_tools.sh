#!/usr/bin/env bash

#
# @file
# Cloudy installer script.
#

# Define the configuration file relative to this script.
CLOUDY_PACKAGE_CONFIG="cloudy_tools.yml"

# Uncomment this line to enable file logging.
[[ ! "$CLOUDY_LOG" ]] && CLOUDY_LOG="cloudy_tools.log"
# Or, set for a terminal session using `export CLOUDY_LOG="script.example.log"`.

function on_boot() {
  # Run the test command before the bootstrap to avoid conflicts.
  [[ "$(get_command)" == "tests" ]] || return 0
  source "$CLOUDY_CORE_DIR/inc/cloudy.testing.sh"
  do_tests_in "tests/cloudy.tests.sh"
  exit_with_test_results
}

function on_compile_config() {
  echo "$ROOT/cloudy_tools.runtime.yml"
}

##
 # Rsync the Cloudy core to a given directory.
 #
 # @global string $framework
 # @param string Path to the core to use as source files.  If empty then
 # $framework is used.
 #
 # @return 0 If the sync appeared successful.
 # @return 1 If something went wrong
 ##
function rsync_framework() {
  local core_dir="$1"

  local destination_dir='./cloudy/'

  if [ "" == "$core_dir" ]; then
    core_dir="$framework"
  fi
  [[ "$core_dir" ]] || return 1
  [ -d "$core_dir" ] || return 1
  [ -d "$core_dir/cloudy/" ] || return 1
  rsync -av "$core_dir/cloudy/" "$destination_dir" --exclude=*.log --exclude=cache/ --exclude=composer.lock --exclude=.DS_Store --exclude=vendor
}

##
 # Handle the installation of composer dependencies in the provided directory.
 #
 # @param string Path to Cloudy core.
 #
 # @return 0 If all is well
 # @return 1 If directory is not Cloudy core.
 # @return 2 If composer.json is missing from the provided directory.
 ##
function framework_handle_composer() {
  local path_to_core="$1"

  [ ! -f "$path_to_core/cloudy.sh" ] && fail_because "Dir is not Cloudy core: $1" && return 1
  [ ! -f "$path_to_core/composer.json" ] && fail_because "Missing file: $1/composer.json" && return 2

  (cd "$path_to_core" && composer install)
}

# Echo the source path for a specific framework version.
#
# $1 - The exact semantic version string, e.g. "1.4.13".
#
# Returns 1 if the version can't be found. 0 if it was found and echoed.
#
# @see rsync_framework
function echo_path_to_framework_version() {
    local version="$1"

    local local_source_path="$CLOUDY_CORE_DIR/cache/versions/cloudy-$version"
    local local_source_dir="$(dirname "$local_source_path")"
    if [ ! -e "$local_source_dir" ]; then
      mkdir -p "$local_source_dir"
      local source_url="https://github.com/aklump/cloudy/archive/refs/tags/$version.zip"
      (cd "$local_source_dir" && wget -q "$source_url" && unzip -q "$version.zip" && rm "$version.zip") || exit 1
    fi

    echo "$local_source_path/framework"
}

function write_version_file() {
  echo "cloudy_update__last_update=$(timestamp)" >$CLOUDY_START_DIR/cloudy/version.sh

  echo "cloudy_update__version=\"$(get_version)\"" >>$CLOUDY_START_DIR/cloudy/version.sh
  echo "cloudy_update__source=\"https://github.com/aklump/cloudy\"" >>$CLOUDY_START_DIR/cloudy/version.sh
  [ $? -eq 0 ] || fail_because "An error occurred writing $CLOUDY_START_DIR/cloudy/version.sh"
  return $?
}

function validate_cloudy_instance_or_exit_with_failure() {
  local command="$1"

  [ -d "$CLOUDY_START_DIR/cloudy" ] && return 0

  fail_because "Did you mean cloudy pm-$command?"
  exit_with_failure "No Cloudy framework found in this directory."
}

# Begin Cloudy Bootstrap
s="${BASH_SOURCE[0]}"
while [ -h "$s" ]; do
  dir="$(cd -P "$(dirname "$s")" && pwd)"
  s="$(readlink "$s")"
  [[ $s != /* ]] && s="$dir/$s"
done
r="$(cd -P "$(dirname "$s")" && pwd)"
source "$r/framework/cloudy/cloudy.sh"
[[ "$ROOT" != "$r" ]] && echo "$(tput setaf 7)$(tput setab 1)Bootstrap failure, cannot load cloudy.sh$(tput sgr0)" && exit 1
# End Cloudy Bootstrap

# Input validation
validate_input || exit_with_failure "Input validation failed."

implement_cloudy_basic

framework=$(realpath $CLOUDY_CORE_DIR/..) || exit_with_failure "Missing Cloudy framework"
installation_info_filepath="$CLOUDY_START_DIR/cloudy/version.sh"

# Handle other commands.
command=$(get_command)
case $command in

"version")
  exit_with_success "Cloudy version $(get_version)"
  ;;

"pm-show")
  # TODO Upscan to find .lock
  # TODO Add descriptions
  # TODO Columnize
  # TODO Write cloudy version to cloudy.lock
  ! [ -f "$CLOUDY_START_DIR/cloudypm.lock" ] && fail_because "Missing file $(path_make_pretty "$CLOUDY_START_DIR/cloudypm.lock")" && exit_with_failure
  source "$CLOUDY_START_DIR/opt/cloudy/cloudy/version.sh"
  echo "aklump/cloudy:$cloudy_update__version"
  cat "$CLOUDY_START_DIR/cloudypm.lock"
  exit_with_success
  ;;

"pm-clear-cache")
  cache_dir="${CLOUDY_CORE_DIR}/cache/cpm"
  [[ ! "${CLOUDY_CORE_DIR}" ]] && exit_with_failure "Invalid cache directory ${cache_dir}"
  event_dispatch "pm_clear_cache" "$cache_dir" || exit_with_failure "Clearing pm caches failed."
  if dir_has_files "$cache_dir"; then
    clear=$(rm -rv "$cache_dir/"*)
    status=$?
    [ $status -eq 0 ] || exit_with_failure "Could not remove all cached pm files in $cache_dir"
    file_list=($clear)
    for i in "${file_list[@]}"; do
      succeed_because "$(echo_green "$(basename $i)")"
    done
    exit_with_success "Local Cloudy package info has been flushed."
  fi
  exit_with_success "Cloudy package info will be fetched from the remote registry when needed."
  ;;

"pm-update")
  source "$ROOT/inc/cloudy.pm.sh"
  echo_title "Package Updater"
  package=$(get_command_arg 0)
  _cloudypm_update_package "$package" || fail
  has_failed && [[ "$package" ]] && exit_with_failure "Could not update \"$package\"."
  has_failed && exit_with_failure "Nothing updated."
  exit_with_success_elapsed "Update process complete."
  ;;

"pm-install")
  source "$ROOT/inc/cloudy.pm.sh"
  echo_title "Package Installer"
  package=$(get_command_arg 0)
  ! has_option 'yes' && ! confirm --caution "Install $package in $CLOUDY_START_DIR?" && exit_with_failure "User cancelled."
  _cloudypm_install_package $package
  has_failed && exit_with_failure "Could not install \"$package\"."
  exit_with_success_elapsed "$package was installed."
  ;;

"flush")
  validate_cloudy_instance_or_exit_with_failure 'flush'
  exit_with_cache_clear "$CLOUDY_START_DIR/cloudy"
  ;;

"install")
  echo_title "Cloudy Framework Installer"
  validate_cloudy_instance_or_exit_with_failure 'install'
  [ -f "$installation_info_filepath" ] || exit_with_failure "Cannot determine installed version; missing file $installation_info_filepath."
  source $installation_info_filepath

  source_dir="$(echo_path_to_framework_version "$cloudy_update__version")"
  ! [[ "$source_dir" ]] && fail_because "Can't find version $cloudy_update__version" && exit_with_failure "Failed to install Cloudy"
  rsync_framework "$source_dir" || exit_with_failure
  framework_handle_composer "$PWD/cloudy" || exit_with_failure
  exit_with_success_elapsed "Cloudy version $cloudy_update__version files are installed."
  ;;

"update")
  echo_title "Cloudy Framework Updater"
  validate_cloudy_instance_or_exit_with_failure 'update'
  [ -f "$installation_info_filepath" ] || exit_with_failure "Cannot determine installed version; missing file $installation_info_filepath."
  source $installation_info_filepath

  # TODO Consider using the latest published version from github instead of local?
  available_version=$(get_version)

  # Check current version of instance.
  echo_key_value "Cloudy Directory" "$CLOUDY_START_DIR/cloudy"
  echo_key_value "Installed Version" "$cloudy_update__version"
  echo_key_value "Available System Version" "$available_version"

  has_latest_version=false
  [[ "$cloudy_update__version" == "$available_version" ]] && has_latest_version=true
  has_latest_version=false

  [[ false == "$has_latest_version" ]] && echo && echo_yellow "Your version $cloudy_update__version is out-of-date."

  if ! has_option "f" && [[ true == "$has_latest_version" ]]; then
    echo_heading "Composer"
    framework_handle_composer "$PWD/cloudy" >/dev/null || exit_with_failure
    exit_with_success "You're already up-to-date."
  fi

  has_option "dry_run" && exit_with_success "This was a dry run; nothing was changed."

  # Ask if they want to update.
  ! has_option 'y' && ! confirm --caution "Do you want to update now?" && exit_with_failure "Update cancelled"

  rsync_framework || exit_with_failure "An error occurred while updating this Cloudy framework."
  echo_heading "Composer"
  framework_handle_composer "$PWD/cloudy" || exit_with_failure
  write_version_file

  ! has_failed && exit_with_success "Framework has been updated"
  ;;

"core")
  [ -e ./cloudy ] && exit_with_success "Cloudy is already installed.  Did you mean \"update\"?"
  rsync_framework || fail_because "Could not copy Cloudy core to $CLOUDY_START_DIR."
  framework_handle_composer "$PWD/cloudy" || exit_with_failure
  if ! has_failed; then
    write_version_file
  fi
  has_failed && exit_with_failure "Failed to install core in current directory."
  write_log_notice "Installed Cloudy core in $CLOUDY_START_DIR"
  exit_with_success_elapsed "Core installed."
  ;;

"new")
  basename=$(get_command_arg 0 "cloudy_script.sh")
  script_filename=$(path_filename "$basename")
  has_option 'config' && script_filename=$(path_filename $(get_option "config"))
  config_file="$script_filename.yml"
  has_option "json" && config_file="$script_filename.json"

  example_script="script.example.sh"

  # Protect an existing script by that name.
  [ -e "$basename" ] && ! has_option "force" && fail_because "$basename already exists. Use --force, -f to proceed."

  ! has_option 'y' && ! confirm --caution "Create $script_filename in the current directory?" && exit_with_failure "Nothing accomplished."

  if ! has_failed; then
    rsync_framework || fail_because "Could not copy Cloudy core to $CLOUDY_START_DIR."
    framework_handle_composer "$PWD/cloudy" || exit_with_failure
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
      # TODO Rewrite using $PHP_FILE_RUNNER
      echo $("$CLOUDY_PHP" $CLOUDY_CORE_DIR/php/config/normalize.php "$CLOUDY_CORE_DIR/cloudy_config.schema.json" "script.yml") >${config_file} || fail_because "Could not convert $(path_filename $config_file) to JSON"
      [ $? -eq 0 ] && rm script.yml

      # TODO Rewrite using $PHP_FILE_RUNNER
      echo $("$CLOUDY_PHP" $CLOUDY_CORE_DIR/php/config/normalize.php "$CLOUDY_CORE_DIR/cloudy_config.schema.json" "$CLOUDY_START_DIR/script.example.yml") >script.example.config.json || fail_because "Could not convert script.example.yml to JSON"
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
  write_log_notice "Installed new script at $CLOUDY_START_DIR/$basename"
  exit_with_success_elapsed "New script $basename created."
  ;;

esac

throw "Unhandled command \"$command\"".
