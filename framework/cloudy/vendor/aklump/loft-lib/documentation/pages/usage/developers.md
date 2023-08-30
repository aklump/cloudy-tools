<!--
id: developers
tags: usage
-->

# Developing This Package

1. To develop with different php versions you can use _bin/setup\_php*.sh_ files. They rely on MAMP being used but if you study them you could see how to use some other PHP provider.
2. To run tests: `./bin/run_unit_tests.sh`.
3. To get code coverage `./bin/run_unit_tests.sh --coverage-html=reports/coverage`.

## Build

`bump build` will compile docs, test all supported PHP versions, and create all distribution files.
