# Cloudy Changelog

## [Unreleased]

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

A bug when using `additional_config` together with `config_path_base`.  The issue was that `additional_config` should have been relative to `config_path_base`, however it was not working correctly.  After you update to 1.1.0 your app will be broken.  To fix this you will need to remove the value of `config_path_base` from each of the items in `additional_config`.  As an example, if before this update, your configuration was:

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
