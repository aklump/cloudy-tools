<!--
id: php_envvars
tags: ''
-->

# Passing Variables Between BASH and PHP

_variables.php_

{{ file_variables_php|raw }}

## Accessing Configuration via $CLOUDY_CONFIG_JSON

The configuration will be written to an environment variable `$CLOUDY_CONFIG_JSON`, which can be decoded by PHP. You may not need to do this if you are using `$PHP_FILE_RUNNER` as some configuration is already provided as context.

```php
$config = json_decode(getenv('CLOUDY_CONFIG_JSON'), TRUE);
```

## Passing Variables from PHP to BASH

If you want your PHP code to set a BASH variable, do like this:

## Passing Variables between PHP and BASH

To pass variables from BASH to PHP use the native BASH `export` and the PHP `getenv()`

```shell
export FOO=BAR
```

```php
$FOO=getenv('FOO')
```

The PHP function `cloudy_putenv()` when used with `$PHP_FILE_RUNNER` allows you to pass variables from your PHP scripts to your BASH scripts. There is nothing to do on the BASH side of things, the variable will simply be set (or overridden).

```php
cloudy_putenv('FOO=BAR');
```
