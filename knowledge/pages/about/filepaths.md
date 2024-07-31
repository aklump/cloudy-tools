<!--
id: filepaths
tags: ''
-->

# Filepaths

? how do relative paths resolve?

* All relative paths in configuration will resolve to CLOUDY_BASEPATH by default.
* For greater clarity, you may use path tokens instead of relative paths in your configuration.

? what are the base path constants?

1. `CLOUDY_BASEPATH`
1. `CLOUDY_ROOT`, e.g. _opt/cloudy/cloudy_

? what are the path tokens?

1. `$CLOUDY_BASEPATH`
1. `$CLOUDY_CORE_DIR`


## What path functions exist?

_resolve_dir
