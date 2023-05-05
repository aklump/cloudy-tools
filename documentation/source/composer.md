# Enabling Installation w/Composer

> This is a WIP page.

When using Cloudy with a PHP application managed by Composer, you may follow this guide so that the Cloudy dependencies are handled as well. This is probably an easier road to travel since your dependencies are all in one place.

1. Create your cloudy script (`foo.sh`) in the desired location of your application, e.g. `cloudy new foo.sh`. (See also `cloudy core`.)
2. Open _foo.sh_ and add the path (relative to _foo.sh_) to your application's vendor directory as `COMPOSER_VENDOR`; see _script.example.sh_ for code example.
3. Add a repository reference to Cloudy in your application's _composer.json_.

   ```php
   "repositories": [
      {
         "type": "path",
         "url": "./cloudy/"

   ],
   ```   
1. Delete `cloudy/vendor` and `cloudy/composer.lock` for clarity.
4. Next, tell your app you want to require Cloudy: `composer require aklump/cloudy`
5. Ignore the following in your app's root _.gitignore_, adjusting paths as appropriate:

   ```gitignore
   /cloudy/vendor/
   /cloudy/composer.lock
   ```

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
