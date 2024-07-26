<!--
id: php_version
tags: ''
-->

# Setting the PHP Version Used by Cloudy

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
