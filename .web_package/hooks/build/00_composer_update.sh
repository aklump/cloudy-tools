#!/usr/bin/env bash
#
# @file Do a composer update
#

composer=$(type composer >/dev/null 2>&1 && which composer)
cd "$7/framework/cloudy/php" && $composer update --optimize-autoloader

git add "$7/framework/cloudy/php/vendor"
git add "$7/framework/cloudy/php/composer.lock"
