<!--
id: cloudy_php
tags: usage, php
-->

# PHP and Cloudy

Cloudy uses quite a bit of PHP under the hood.  

## PHP Version

The value of the [environment variable](https://www.howtogeek.com/668503/how-to-set-environment-variables-in-bash-on-linux/) `CLOUDY_PHP` will be used to locate the PHP binary. You may set that explicitly (see below) or let Cloudy do it automatically. See `cloudy_bootstrap_php()` for details.

> The value of the environment variable `CLOUDY_PHP` will be used to locate the PHP binary.

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

## PHP Dependencies (and Composer)

[See Composer](@composer) for dependency management strategies.

## Writing Code

When writing your app's source code, never hardcode PHP as `php` nor as a path. Instead use `"$CLOUDY_PHP"`, as shown below. This will ensure consistent PHP versions throughout execution. **Notice the surrounding double-quotes that ensure space-containing paths will still work.**

```php
"$CLOUDY_PHP" "/my/php/script/foo.php"
```

### Accessing Configuration

For your PHP scripts to have access to the configuration values setup in the YAML file(s), you should decode the environment variable `CLOUDY_CONFIG_JSON`, e.g., `$config = json_decode(getenv('CLOUDY_CONFIG_JSON'), TRUE);`.

**You will need to add `export CLOUDY_CONFIG_JSON` to your controller file.**

### Aliasing the PHP version variable

Let's say you want users to provide the path to the PHP for a Cloudy-based app that you are building called _Fission_. You want them to set the variable `FISSION_PHP` with the path. To hand that off to Cloudy so it uses that same PHP binary you should do like this in your controller script, in the [event handler](@events) sections

```bash
function on_pre_config() {
  if [[ "$FISSION_PHP" ]]; then
    CLOUDY_PHP="$FISSION_PHP"
  fi
}
```
