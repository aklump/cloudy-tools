#!/usr/bin/env bash

s="${BASH_SOURCE[0]}";[[ "$s" ]] || s="${(%):-%N}";while [ -h "$s" ];do d="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$d/$s";done;__DIR__=$(cd -P "$(dirname "$s")" && pwd)

cd "$__DIR__/../"

# Do not run the Cloudy BASH tests if --filter is used.
if [[ " $* " != *" --filter "* ]]; then
  ./cloudy_tools.sh tests || exit 1
fi

./framework/cloudy/bin/run_unit_tests.sh $@ || exit 1
./framework/cloudy/bin/run_integration_tests.sh $@ || exit 1
