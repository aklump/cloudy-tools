<!--
id: cloudy_php
tags: usage, php
-->

# PHP and Cloudy

To execute PHP you should use `source_php` with the path to the PHP include file, like this:

```shell
source_php "/Users/aklump/opt/cloudy/framework/cloudy/tests/Integration/tests/../t/InstallTypeCore/php/_variables.php"
```

_variables.php_

```php
{{ file_variables_php|raw }}
```

## Error Handling

You are encouraged to use the Cloudy error handling functions even in PHP:

* `fail_because`
* `exit_with_failure`

You may throw exceptions as well. In that case the exception message will automatically be passed to:

1. fail_because
2. write_log_error

## Passing Variables between PHP and BASH

To pass variables from BASH to PHP use the native BASH `export` and the PHP `getenv()`

```shell
export FOO=BAR
```

```php
$FOO=getenv('FOO')
```

The PHP function `cloudy_putenv()` when used inside the BASH function `source_php` allows you to pass variables from your PHP scripts to your BASH scripts. There is nothing to do on the BASH side of things, the variable will simply be set (or overridden).

```php
cloudy_putenv('FOO=BAR');
```

---

@todo Beyond here needs review

Cloudy uses quite a bit of PHP under the hood.

## PHP Version

The value of the [environment variable](https://www.howtogeek.com/668503/how-to-set-environment-variables-in-bash-on-linux/) `CLOUDY_PHP` will be used to locate the PHP binary. You may set that explicitly (see below) or let Cloudy do it automatically. See `cloudy_bootstrap_php()` for details.

### Setting Cloudy's PHP Version Globally

Add the following line to _~/.bashrc_ or _~/.bash\_profile_ as appropriate to your case.  [Learn more...](https://www.howtogeek.com/668503/how-to-set-environment-variables-in-bash-on-linux/)

```bash
export CLOUDY_PHP="/Applications/MAMP/bin/php/php7.2.20/bin/php"
```

### Setting Cloudy's PHP Version at Runtime

Coincidentally, if you run the following, the test will actually fail, as it asserts that `$CLOUDY_PHP` is set to the default PHP binary, which it will not be in this case.

```bash
 export CLOUDY_PHP="/Applications/MAMP/bin/php/php7.2.20/bin/php"; ./cloudy_tools.sh tests
```

### Setting PHP in Your Controller

Let's say the PHP path exists in another global variable. You may pass that off to Cloudy in the `on_pre_config` [event handler](@events), like this:

```bash
function on_pre_config() {
  if [[ "$PHP_PATH" ]]; then
    CLOUDY_PHP="$PHP_PATH"
  fi
}
```

### Setting PHP in Additional Config

_foo.core.yml_

```yaml
additional_config:
  - .foo/config.local.yml
```

You may provide the PHP path using an `additional_config` file that matches _*.local.yml_. It might contain the following:

_.foo/config.local.yml_

```yaml
shell_commands:
  php: /usr/local/bin/php
```

In the controller file, in `on_pre_config`, you must add the following line so that the local config is read during bootstrap.

```bash
function on_pre_config() {
  source "$CLOUDY_ROOT/inc/cloudy.read_local_config.sh"
}
```

## PHP Dependencies (and Composer)

[See Composer](@composer) for dependency management strategies.

## Writing Code

When writing your app's source code, never hardcode PHP as `php` nor as a path. Instead use `"$CLOUDY_PHP"`, as shown below.  **Always wrap this variable with double quotes (to support spaces in paths).** This will ensure consistent PHP versions throughout execution.

```php
"$CLOUDY_PHP" "/my/php/script/foo.php"
```

### Accessing Configuration

For your PHP scripts to have access to the configuration values setup in the YAML file(s), you should decode the environment variable `CLOUDY_CONFIG_JSON`, e.g., `$config = json_decode(getenv('CLOUDY_CONFIG_JSON'), TRUE);`.
