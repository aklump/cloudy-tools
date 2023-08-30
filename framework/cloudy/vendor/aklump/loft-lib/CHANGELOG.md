# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2023-06-28

### Deprecated

- The following files are too complicated to use and there are other options out there, so they have been deprecated and will be removed. Replace all implementations immediately.

- `\AKlump\LoftLib\Storage\FilePath`
- `\AKlump\LoftLib\Storage\FilePathCollection`
- `\AKlump\LoftLib\Storage\PersistentInterface`

### Added

- Support for PHP ^8.0

### Changed

- The return value of `\AKlump\LoftLib\Code\LoftXmlElement::addAttribute` is now `void`, so you can no longer chain this method, if you had done so.  **Search your codebase for chaining and fix!**
- Minimum PHP increased to ^7.3

## [1.5.0] - 2021-12-23

### Added

- New interface `\AKlump\LoftLib\Code\ShortCodesInterface`
- New method `Arrays::getClosestValueTo()`

## [1.4.0] - 2021-07-17

### Added

- Bash::confirm() for user input collection.

## [1.3.0] - 2021-06-27

### Added

- Shortcodes with `&nbsp;` work as if ` `, i.e., `[foo&nbsp;id="5"]lorem[/foo]` is the same as `[foo id="5"]lorem[/foo]`. In earlier versions `&nbsp;` was not supported.

## [1.2] - 2021-06-05

### Changed

- Minimum PHP is now 7.1

## [1.1.0] - 2019-12-16

### Changed

- Due to a design flaw in the _Bash\Configuration_ a new class has replaced the old that hashes the variable names. This should be used moving forward but requires code refactoring. If you do not want to refactor code then use the new deprecated new class _Bash\LegacyConfiguration_. Otherwise refactor your code to take advantage of the design correction.

### Fixed

- Problem with Bash variable names and special chars by rewriting \AKlump\LoftLib\Bash\Configuration.

## [1.0.21] - 2019-06-07

### Changed

- Updated tests to work with PHPUnit 6.x, 7.x
