#!/usr/bin/env bash

source="${BASH_SOURCE[0]}"
source="${BASH_SOURCE[0]}"
if [[ ! "$source" ]]; then
  source="${(%):-%N}"
fi
while [ -h "$source" ]; do # resolve $source until the file is no longer a symlink
  dir="$( cd -P "$( dirname "$source" )" && pwd )"
  source="$(readlink "$source")"
  [[ $source != /* ]] && source="$dir/$source" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
app_root="$( cd -P "$( dirname "$source" )/../" && pwd )"

if [[ ! "$1" ]]; then
  echo "Missing argument, which should be the path to the PHP bin directory."
  exit 1
fi

export PATH="$1":"$PATH"
php -v
echo
cd "$app_root"
test -f composer.lock && rm composer.lock
composer update || exit 1
