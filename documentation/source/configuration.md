# Configuration

Configuration is provided by YAML files.

In the header of your script you will find `CLOUDY_CONFIG`, e.g.,

        CLOUDY_CONFIG=$ROOT/script.example.config.yml
        
1. Set it's value to the path of a YAML file to use as configuration.
1. You may add additional configuration files by adding something like following:

        config:
          - _install.local.yml

1. The files are relative to `$(dirname $CLOUDY_CONFIG)`
1. You may have any number of configuration files.

## Using Config

### Scalars

To get a configuration value you will use the `get_config` function.  The following example is the contents of an imaginary _config.yml_:

    perms:
      user: aklump
      group: apache
      files: 640
      directories: 750
      
To access the perms `group` scalar value do the following:
    
    group=$(get_config "perms.group" "staff") 

* Notice the dot separation to denote parent/child.
* The second argument is a default value, e.g., `staff`.

### Non-Scalars

When the config key points to a non-scaler, associative array `get_config` echos a string ready for `eval`, which generates a nice set of BASH vars containing the values of `perms`, e.g.,

    eval $(get_config perms)
    echo $PERMS_USER
    echo $PERMS_GROUP
    echo $PERMS_FILES
    echo $PERMS_DIRECTORIES
    
* Notice the keys are converted to uppercase and include the parent path.

If the config key points to an indexed array, e.g., ....

    hooks:
      files:
        tags:
        - ignore
        - normal
        - emergency

... then the eval string is slightly different...

    `declare -a HOOKS_FILES_TAGS=("ignore" "normal" "emergency")`
    
... and you use it like this:

    eval $(get_config "hooks.files.tags")
    ${HOOKS_FILES_TAGS[0]} == "ignore"
    ${HOOKS_FILES_TAGS[1]} == "normal"
    ${HOOKS_FILES_TAGS[2]} == "emergency"

### Non-Scalars Keys

In a more complex configuration like the following, you might want to get the array keys, in this case all the "operations"; do so with `get_config_keys`.  Our example will echo a string like this: `declare -a config_keys=("_default" "help" "new")`

    operations:
      _default: help
      help:
        help: Display this help screen
      new:
        help: Create new Cloudy script file in the current directory
        options:
          config:
            help: Set the basename of the config file.
          force:
            aliases: [f]
            help: Force the overwrite of an existin file.

This is a usage example:

    eval $(get_config_keys "operations")
    
    ${config_keys[0]} == "_default"
    ${config_keys[1]} == "help"
    ${config_keys[2]} == "new"
