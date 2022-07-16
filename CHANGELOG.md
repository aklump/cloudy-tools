# Cloudy Changelog

## [Unreleased]

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
