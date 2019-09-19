---
id: app_root
---
# Application Root

The application root is by default the same as `$ROOT`, which is the directory containing your cloudy entry script file.  However you may want to alter that by the use of `config_path_base` to point to a higher directory, such as the case with [Cloudy Packages](@packages).

`$APP_ROOT` should point to the most logical top-level directory in the context where the cloudy script is used.

## What does it do?

* Relative paths read in with `get_config_path` are made absolute using `$APP_ROOT`.
* Paths shortened via `path_shorten` use `$APP_ROOT` as the basis for prefix removal.
