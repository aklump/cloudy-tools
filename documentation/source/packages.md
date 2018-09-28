# Cloudy Packages

## Create a package info file

    name: aklump/perms
    clone_from: https://github.com/aklump/website-perms
    entry_script: perms.sh
    on_install: install
    on_update: update

1. The name must follow `vendor/name` format.
1. The schema of the file can be seen [here](https://github.com/aklump/cloudy/blob/master/framework/cloudy/cloudypm_info.schema.json).
1. The `on_*` are commands that will be fired at the end of that event.  They are optional.

## Add Package to the Registry

1. The registry file is located [here](https://github.com/aklump/cloudy/blob/master/cloudy_package_registry.txt).
1. Add the _vendor/name_ and _a link to cloudypm.yml or cloudypm.json_ for your package.  These must be separated by a single space, e.g.

        aklump/perms https://raw.githubusercontent.com/aklump/website-perms/master/cloudypm.yml?token=AAZ_CajHqKkAfvJNQT5WKrtqwcYZivzGks5btjkEwA%3D%3D

1. You do this by cloning and creating a pull request with your addition.
