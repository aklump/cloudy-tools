# Handling PHP Versions

In some cases you may want your script to be able to accept different PHP versions.  Here is a strategy to achieve this.  Place this early in your controller script.  In this example the application is called _Loft Deploy_ and it uses `$loft_deploy_php` when running it's php processes.
    
    # Determine the version of php to use based on:
    # 1. The option --php
    # 2. ENV var LOFT_DEPLOY_PHP
    # 3. the system 'php'
    loft_deploy_php="php"
    if [[ "$LOFT_DEPLOY_PHP" ]]; then
        loft_deploy_php="$LOFT_DEPLOY_PHP"
    fi
    [[ ! -x "$loft_deploy_php" ]] && fail_because "$loft_deploy_php is not a path to a valid PHP executable" && exit_with_failure

You would instruct users to define `$LOFT_DEPLOY_PHP` in _.bashrc_ or pass it in the CLI arguments, e.g. `export LOFT_DEPLOY_PHP=/Applications/MAMP/bin/php/php7.1.12/bin/php;...`.
