#!/usr/bin/env bash

./bin/setup_php73.sh || build_fail_exception
./bin/run_unit_tests.sh || build_fail_exception

./bin/setup_php74.sh || build_fail_exception
./bin/run_unit_tests.sh || build_fail_exception

./bin/setup_php80.sh || build_fail_exception
./bin/run_unit_tests.sh || build_fail_exception

./bin/setup_php81.sh || build_fail_exception
./bin/run_unit_tests.sh || build_fail_exception
