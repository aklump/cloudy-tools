<!--
id: composer
tags: usage, php, composer, dependencies
-->

# Building a Cloudy-based App w/ Composer

By default Cloudy handles it's own PHP dependencies internally using Composer; however it includes the vendor directory in the codebase so that one using the framework need not think about Composer at all.

This strategy becomes unnecessary and possibly confusing if the app you are building will also manage dependencies using Composer. When this is the case you should make the following modifications to consolidate the dependencies into a single _vendor/_ directory and follow Composer best-practices by excluding the vendor directory from your app's code repository.

## Tell Composer About Cloudy

1. Add a repository reference to Cloudy in your application's _composer.json_...

   ```php
   "repositories": [
      {
         "type": "path",
         "url": "./cloudy/"

   ],
   ```   
1. ... then tell Composer where to find Cloudy: `composer require aklump/cloudy`.
1. Delete `cloudy/vendor` and `cloudy/composer.lock`; these will no longer be used...
1. ... and just to be sure, set those same files to be ignored by source control, e.g.,

   ```gitignore
   /cloudy/vendor/
   /cloudy/composer.lock
   ```

## Tell Cloudy About Composer

1. Let's say your Cloudy-based controller is called _foo.sh_.
1. Open _foo.sh_ and add the path (relative to _foo.sh_) to the vendor directory as `COMPOSER_VENDOR`. See _script.example.sh_ for code example.
