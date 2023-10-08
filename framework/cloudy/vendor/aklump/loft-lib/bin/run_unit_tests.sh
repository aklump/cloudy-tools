#!/usr/bin/env bash
s="${BASH_SOURCE[0]}";[[ "$s" ]] || s="${(%):-%N}";while [ -h "$s" ];do d="$(cd -P "$(dirname "$s")" && pwd)";s="$(readlink "$s")";[[ $s != /* ]] && s="$d/$s";done;__DIR__=$(cd -P "$(dirname "$s")" && pwd)

cd "$__DIR__/.."

./vendor/bin/phpswap use 7.3 --no-composer-restore './vendor/bin/phpunit -c tests_unit/phpunit.xml'
./vendor/bin/phpswap use 7.4 --no-composer-restore './vendor/bin/phpunit -c tests_unit/phpunit.xml'
./vendor/bin/phpswap use 8.0 --no-composer-restore './vendor/bin/phpunit -c tests_unit/phpunit.xml'
./vendor/bin/phpswap use 8.1 './vendor/bin/phpunit -c tests_unit/phpunit.xml'
