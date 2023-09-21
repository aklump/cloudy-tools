# Cloudy Changelog

## [Unreleased]

## [1.5.1] - 2023-09-21

### Changed

- Split _cloudy.sh_ into _inc/cloudy.api.sh_ and _cloudy.sh_ to allow cherry-picking the api functions without bootstrapping the app.

## [1.5] - 2023-04-25

### Changed

- POTENTIAL BREAKING CHANGES: The return value for fail_because(), warn_because(), and succeed_because() is now always `0`. Previously it was `1` if the message was empty AND the default was empty.

## [1.4.9] - 2022-12-07

### Fixed

- If you see an error like "line 833: cd: ... cloudy/framework/cloudy: No such file or directory", try adding `COMPOSER_VENDOR=""` to the top of your script file, e.g. _framework/script.sh_.

## [1.4.0] - 2022-07-19

### Added

- Added functions `echo_task`, `clear_task`, `echo_task_completed`, `echo_task_failed`, `choose`
- Configurable Composer vendor direct using `$COMPOSER_VENDOR`
- Added `$CLOUDY_CONFIG_HAS_CHANGED` which will be `true` if the configuration was rebuilt during boot.
- Other small improvements and bug fixes.

### Changed

- Moved Composer vendor directory from _framework/cloudy/php/vendor_ to _framework/cloudy/vendor_.

## [1.3.7] - 2022-05-02

### Added

- `array_dedupe` function

### Fixed

- `assert_contains` and `assert_not_contains` with space-containing values now works.

## [1.3.6] - 2021-09-17

### Changed

- Configuration merge algorithm to address deep merge problem.

## [1.3.0] - 2021-09-11

### Fixed

- _.gitignore_ no longer includes duplicate lines when updating a cloudy package.

### Added

- `json_set`, `json_load_file`, `json_get_value` and `json_get` for easily working with JSON.
- `echo_pass` and `echo_fail` for a consistent in test scenarios.
- A pattern for writing command access to the documentation.

### Deprecated

- `--as=ALIAS` flag has been deprecated in `exit_with_failure_if_empty_config` and `exit_with_failure_if_config_is_not_path`. Replace `exit_with_failure_if_empty_config "database.host" --as=host` with `exit_with_failure_if_empty_config "host" "database.host"` to switch to the new syntax. This was done to match `get_config_as` and `get_config` argument patterns.

## [1.2.0] - 2019-12-16

### Added

- md5_string function

### Changed

* Changed internal variable names, which should not affect your scripts.
    * `CLOUDY_OPTION__*` are now hashed variable names.
    * Configuration cached variable names now use hashes rather than plain config keys.

### Fixed

* Config variable problems with special characters.

## [1.1.0] - 2019-07-13

### Fixed

A bug when using `additional_config` together with `config_path_base`. The issue was that `additional_config` should have been relative to `config_path_base`, however it was not working correctly. After you update to 1.1.0 your app will be broken. To fix this you will need to remove the value of `config_path_base` from each of the items in `additional_config`. As an example, if before this update, your configuration was:

    config_path_base: ../../..
    additional_config:
      - ../../../bin/config/website_benchmark.yml

Your configuration should now look like this:

    config_path_base: ../../..
    additional_config:
      - bin/config/website_benchmark.yml

## [1.0.6]

### Changed

* Renamed `$parse_args__option__*` to `parse_args__options__*`.
