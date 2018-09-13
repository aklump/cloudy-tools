# Events

## on_boot

If you define this function before the bootstrap it will be called once the minimum bootstrap has been called.  To see an example of this you can look to the `coretest` path in _cloudy_installer.sh_.

    #!/usr/bin/env bash
    
    ...
    
    function on_boot() {
        [[ "$1" == "coretest" ]] || return 0
        do_tests_in "cloudy_installer.tests.sh"
        exit_with_test_results
    }
    
    # Begin Cloudy Bootstrap
    s="${BASH_SOURCE[0]}";while ...
