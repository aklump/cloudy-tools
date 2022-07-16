# Enabling Installation w/Composer

> This is a WIP page.

1. Add _composer.json_ to your cloudy package.
2. Create _bin_ folder
3. Create the symlink in _bin_ to the entry script, refer to _cloudypm.yml_
4. Add this to _composer.json_ to the `bin` section
```json
{
    "bin": [
        "bin/live_dev_porter",
        "bin/ldp"
    ]
}
```
5. Add the following to _.gitignore_ to prevent core dependencies:
    ```
    /cloudy/.gitignore
    /cloudy/cache/
    /cloudy/php/composer*
    /cloudy/php/vendor/
    /cloudy/php/vendor/*
    ```
6. Except for the `vendor` line, merge _cloudy/.gitignore_ up, into your package's.
7. An your package root type `cloudy core`.
8. Change the path to cloudy in your controller file from `` to ``.
9. Move all `require` from _cloudy/composer.json_ to your package.
10. Delete _cloudy/composer._
11. Edit _cloudy/php/bootstrap.php_ autoload to `require_once __DIR__ . '/../../vendor/autoload.php';`
12. `composer require aklump/live-dev-porter:@dev` 
