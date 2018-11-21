# Unit Testing

Cloudy offers a simple unit testing framework based on PhpUnit.  To see how you might implement unit tests, refer to the following files

* _cloudy_tools.sh_ and find how the command `tests` is handled in `on_boot`.
* _tests/cloudy.tests.sh_ to see how the tests themselves are written.
* _framework/cloudy/inc/cloudy.testing.sh_ for a list of assertions.
* It is optional to add the command to your _config.yml_ file.  It's not functionally necessary, but you might do it for documentation purposes.
* To check if code is being run from inside a test you can use `is_being_tested`, e.g.:
    
        is_being_tested && ...

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
