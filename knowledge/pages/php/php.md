<!--
id: php
tags: ''
-->

# Cloudy and PHP

Using PHP with Cloudy is very simple. PHP files should be included in your BASH scripts using `. "$PHP_FILE_RUNNER" <PATH> <ARG>... `. This allows your PHP file to execute within the current cloudy context and configuration. Cloudy also provides functions in PHP you will recognize from Cloudy's BASH API. You should follow the same design and code-flow patterns in PHP, that you follow with Cloudy BASH e.g., `fail_because`, etc.

## How to Include a PHP File

Let's say your Cloudy app defines the command  `json-decode`. Because PHP has a native function for this we will use PHP to do the work instead of BASH.

This excerpt, taken from the _Cloudy Package Controller_, shows how to reference the PHP file that handles the `json-decode` command provided by the user.

{{ php_usage_controller|raw }}

### The Included PHP File

Here are the contents of that PHP file, which will do the work for the command `json-decode`. Notice the use of the functions that you have been using while writing Cloudy BASH code.

{{ php_usage_php_file_runner|raw }}

## Key Points

* You must never use PHP's `exit()` function, rather use `return`.
* Never hardcode PHP into your app codebase, e.g. `php`; instead if you must point to the PHP binary then use the variable `"$CLOUDY_PHP"` instead.  **Always wrap this variable with double quotes (to support spaces in paths).**
