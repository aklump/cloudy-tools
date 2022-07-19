# Enabling Installation w/Composer

> This is a WIP page.


## Move Dependencies Into Your Application

This assumes you have already initiazed Composer for your app.

1. Install cloudy in the root of your app with `cloudy core`
2. Add the following to your root _composer.json_
```json
{
  "repositories": [
    {
      "type": "path",
      "url": "cloudy/"
    }
  ]
}
```
1. `composer require aklump/cloudy`
3. SCM ignore the following cloudy-managed Composer dependencies:
    ```
    /cloudy/.gitignore
    /cloudy/cache/
    /cloudy/composer*
    /cloudy/vendor/
    /cloudy/vendor/*
    ```
4. Except for the `vendor` line, merge _cloudy/.gitignore_ up, into your package's.
6. Make sure your bootstrap code section matches that of _cloudy/framework/script.sh_

## Setup Symlinks

1. Add this to _composer.json_ to the `bin` section

```json
{
    "bin": [
        "bin/ldp"
    ]
}
```
2. Create _bin_ folder
3. Create the symlink in _bin_ to the entry script, refer to _cloudypm.yml_

12. `composer require aklump/live-dev-porter:@dev`
