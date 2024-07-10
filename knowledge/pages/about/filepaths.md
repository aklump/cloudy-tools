<!--
id: filepaths
tags: ''
-->

# Filepaths

? how do relative paths resolve?

* All relative paths in configuration will resolve to APP_ROOT by default.
* For greater clarity, you may use path tokens instead of relative paths in your configuration.

? what are the base path constants?

1. `APP_ROOT`
1. `CLOUDY_ROOT`, e.g. _opt/cloudy/cloudy_

? what are the path tokens?

1. `{APP_ROOT}`
1. `{CLOUDY_ROOT}`

? what is the path token syntax?

? Should it be `{APP_ROOT}` or `$APP_ROOT` or `${APP_ROOT}`

## What path functions exist?

_resolve_dir
