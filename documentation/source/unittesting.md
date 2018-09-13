# Unit Testing

Cloudy offers a simple unit testing framework based on PhpUnit.  To see how you might implement unit tests, refer to the following files

* _cloudy_installer.sh_ and find how the command `tests` is handled.
* _cloudy_installer.tests.sh_ to see how the tests themselves are written.
* _cloudy.sh_ for a list of assertions.


## Fixtures

You may use the following as test fixtures, i.e., <https://phpunit.readthedocs.io/en/7.3/fixtures.html?highlight=setup>

    setup_before_test
    teardown_after_test
