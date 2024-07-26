<!--
id: php_file_runner
tags: ''
-->

# Embedding PHP Within Cloudy

## The BASH Side of Things

### Basic PHP File Inclusion Syntax

```php
. "$PHP_FILE_RUNNER" <php_file> <args...>
```

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

## The PHP Side of Things

* Use [echo](https://www.php.net/manual/en/function.echo.php) as you would in a BASH function or sourced file.
* Return values are always ignored; however [return](https://www.php.net/manual/en/function.return.php) may be used for early exit and/or code flow.
* Never use [exit](https://www.php.net/manual/en/function.exit.php).
* To indicate failure use `fail_because` or `exit_with_failure`. To set exit status pass the number to one of those functions.
* Any exception will be automatically converted to `exit_with_failure` and the script will stop immediately.
* The BASH parent script can be known by looking at `$PHP_FILE_RUN_CONTROLLER`
