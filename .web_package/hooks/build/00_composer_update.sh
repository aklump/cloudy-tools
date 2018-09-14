#!/usr/bin/env bash
#
# @file Do a composer update
#

composer=$(type composer >/dev/null 2>&1 && which composer)
cd "$7/install/cloudy/php" && $composer update

git add "$7/install/cloudy/php/vendor"
git add "$7/install/cloudy/php/composer.lock"
