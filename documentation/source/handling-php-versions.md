# PHP and Cloudy

Cloudy makes heavy use of PHP and in so doing gets the PHP executable using `command -v php`.  If this is insufficient you may provide the PHP executable in [the environment variable](https://www.howtogeek.com/668503/how-to-set-environment-variables-in-bash-on-linux/) `CLOUDY_PHP`.

From [that same article](https://www.howtogeek.com/668503/how-to-set-environment-variables-in-bash-on-linux/):
> To create environment variables for your own use, add them to the bottom of your _.bashrc_ file. If you want to have the environment variables available to remote sessions, such as SSH connections, you’ll need to add them to your _.bash_profile_ file, as well.

## .bashrc and .bash_profile Example

Add the following line to one or both of these files as appropriate to your case.

```bash
export CLOUDY_PHP="/Applications/MAMP/bin/php/php7.2.20/bin/php"
```

## CLI Example
Coincidentally, if you tun the following, the test will actually fail, as it asserts that `$CLOUDY_PHP` is set to the default PHP binary, which it will not be in this case.

```bash
 export CLOUDY_PHP="/Applications/MAMP/bin/php/php7.2.20/bin/php"; ./cloudy_tools.sh tests
```

## Using PHP in Your Cloudy Project

* Always execute PHP with the following syntax--using `$CLOUDY_PHP`, never calling `php` directly:

```php
output=$("$CLOUDY_PHP" "/my/php/script/foo.php")
```

### Scoping `$CLOUDY_PHP` to Only Your App

It may be desired in your cloudy-built app to expose a different variable other than `$CLOUDY_PHP`, e.g. `$LOFT_DEPLOY_PHP`.  Here's how to do that with an [event handler](@events).  In this case the Cloudy-built app is called "Loft Deploy".

```bash
function on_pre_config() {
  if [[ "$LOFT_DEPLOY_PHP" ]]; then
    CLOUDY_PHP="$LOFT_DEPLOY_PHP"
  fi
}
```
