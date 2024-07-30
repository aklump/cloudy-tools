<!--
id: php_file_runner
tags: ''
-->

# Writing Cloudy PHP

Mixing PHP with BASH using Cloudy is quite simple.

## On the BASH Side

### Basic PHP File Inclusion Syntax

```php
. "$PHP_FILE_RUNNER" <php_file> <args...>
```

The above pattern allows your PHP file to execute within the current cloudy context and configuration. Cloudy also provides functions in PHP you will recognize from Cloudy's BASH API.

### Capturing php_file's Output

This is just like you'd do sourcing a BASH file or function.

```php
php_file_output=$(. "$PHP_FILE_RUNNER" <php_file> <args...>)
```

### Get php_file's Exit Status

The exit status of `$PHP_FILE_RUNNER` will reflect if `fail_because` was used by php_file, indicated by a 1. However, a number > 1 will result if `fail_because` was passed that number as the explicit exit status. An exit status of 0 represents success, as usual.  ** Be careful here, and make sure you read the documentation on how to trigger errors from Cloudy PHP.**

```shell
. "$PHP_FILE_RUNNER" <php_file> <args...>
exit_status=$?
if [[ $exit_status -ne 0 ]]; then
  # Respond to the failure.
fi 
```

The following can be used as an alternative to the above pattern, with the subtle difference that it will take into account the failure state, i.e. `$CLOUDY_EXIT_STATUS -ne 0`, that may have existed before php_file was run. Therefore it does not check ONLY the result of php_file, but the failure state of the entire app at that point.

```shell
. "$PHP_FILE_RUNNER" <php_file> <args...>
if has_failed; then
  # Respond to the failure.
fi 
```

## On the PHP Side

* Use [echo](https://www.php.net/manual/en/function.echo.php) as you would in a BASH function or sourced file.
* Return values are always ignored; however [return](https://www.php.net/manual/en/function.return.php) may be used for early exit and/or code flow.
* Never use [exit](https://www.php.net/manual/en/function.exit.php).
* To indicate failure use `fail_because` or `exit_with_failure`. To set exit status pass the number to one of those functions.
* Any exception will be automatically converted to `exit_with_failure` and the script will stop immediately.
* The BASH parent script can be known by looking at `$PHP_FILE_RUN_CONTROLLER`
* Never hardcode PHP into your app codebase, e.g. `php`; instead if you must point to the PHP binary then use the variable `"$CLOUDY_PHP"`

## Complete Code Example

Let's say your Cloudy app defines the command  `json-decode`. Because PHP has a native function for this we will use PHP to do the work instead of BASH.

This excerpt, taken from the _Cloudy Package Controller_, shows how to reference the PHP file that handles the `json-decode` command provided by the user.

{{ php_usage_controller|raw }}

Here are the contents of a PHP file, which will do the work for the command `json-decode`. Notice the use of the functions that you have been using while writing Cloudy BASH code.

{{ php_usage_php_file_runner|raw }}
