# Unit Testing

Cloudy offers a simple unit testing framework based on PhpUnit.  To see how you might implement unit tests, refer to the following files

* _cloudy_installer.sh_ and find how the command `tests` is handled.
* _cloudy_installer.tests.sh_ to see how the tests themselves are written.
* _cloudy.sh_ for a list of assertions.

## Setup

You will want to implement the `on_boot` hook if you want to run tests.

    ...
    # Uncomment this line to enable file logging.
    LOGFILE="install/cloudy/cache/cloudy_installer.log"
    
    function on_boot() {
        [[ "$(get_command)" == "tests" ]] || return 0
        source "$CLOUDY_ROOT/inc/cloudy.testing.sh"
        do_tests_in "cloudy_installer.tests.sh"
        do_tests_in ...
        do_tests_in ...
        exit_with_test_results
    }
    ...

## Fixtures

You may use the following as test fixtures, i.e., <https://phpunit.readthedocs.io/en/7.3/fixtures.html?highlight=setup>

    setup_before_test
    teardown_after_test
