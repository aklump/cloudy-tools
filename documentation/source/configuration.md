# Configuration

## Overview

Configuration files are YAML or JSON.  They are connected to your script in one, two, or three ways.

1. The main configuration file is required and is hardcoded in your script as `$CONFIG`.
1. Within that file, you may indicate additional configuration files using the key `additional_config`, which defines an array.  Be aware that these paths are relative to `config_path_base`, see below for more info.
1. Finally, configuration files may be provided dynamically at run time listening to the event `compile_config`.

If configuration values conflict, those that came later will take prescendence; note: arrays will be merged.

## In Depth

The following examples will be shown with YAML.

In the header of your script you will find `$CONFIG`, this is for the base configuration file, e.g.,

        CONFIG=script.example.yml
        
1. Set it's value to the path of a supported file to use as configuration, absolute paths must begin with a forward slash, otherwise the path will be taken relative to the directory containing the script, i.e., `$(dirname your_cloudy_script.sh)`
1. You may add additional configuration files by adding something like following in the YAML of the base configuration file.  Notice the use of `~` to reference the user's home directory; this is a nice way to allow per-user configuration overrides.  Additional configuration files are optional and will only be included if they exist.

        additional_config:
          - _install.local.yml
          - ~/.my_project.yml

1. Thirdly, you may provide configuration paths at run-time:

        function on_compile_config() {
            echo "some/other/config.yml"
        }
        
1. You may have any number of configuration files.
1. Consider limited file permissions on your configuration files; e.g. `chmod go-rwx`.

## Using Config

### Scalars

To get a configuration value you will use the `get_config` function.  The following example is the contents of an imaginary _config.yml_:

    perms:
      user: aklump
      group: apache
      files: 640
      directories: 750
      
To access the perms `group` scalar value do one of the following:
    
    eval $(get_config "perms.group" "staff")
    # [ perms_group = 'apache' ]

* Notice the dot separation to denote parent/child.
* The second argument is a default value, e.g., `staff`.

You can also assign to a different variable like this:

    eval $(get_config_as "group" "perms.group" "staff") 
    # [ group = 'apache' ]

### Arrays

Arrays are handled differntly depending upon a few things: if the config key points to a multi-dimensional array, an single-level associative array, or an single-level indexed array.  For examples turn to the following configuration YAML:

    user:
      images:
        tags:
        - nature
        - space
        - religion
        types:
        - jpg
        - png

Let's see what `$(get_config -a 'user.images.tags')` returns us:




When the config key points to an array `get_config` echos a string ready for `eval`, which generates a nice set of BASH vars containing the values of `perms`, e.g.,

    eval $(get_config perms)
    echo $perms_user
    echo $perms_group
    echo $perms_files
    echo $perms_directories

If the config key points to an indexed array, e.g., ....


### Non-Scalars Keys

In a more complex configuration like the following, you might want to get the array keys, in this case all the "operations"; do so with `get_config`.  Our example will echo a string like this: `declare -a config_keys=("help" "new")`

    commands:
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

    eval $(get_config_keys "commands")
    
    ${config_keys[0]} == "_default"
    ${config_keys[1]} == "help"
    ${config_keys[2]} == "new"

### Filepaths

Configuration values which are filepaths can be added to the YAML as relative paths:

    webroot: ../web
    path_to_binaries: .
    public_files: ../web/sites/default/files
    
Then when you access the configuration use `get_config_path`, e.g.,

    eval $(get_config_path "webroot")
    
The value of `$webroot` will be an an absolute filepath.

#### How are relative filepaths made absolute?

1. By default `$ROOT` is used as the basepath, which is the directory that contains your Cloudy script.
1. You can alter this behavior by setting the configuration variable as `config_path_base` with a value, which is either an absolute path, or a relative path, relative to `$ROOT`.  Both of the following are valid values:

        # relative to $ROOT
        config_path_base: ../../..
        
        # or using an absolute path...
        config_path_base: /Users/aklump/config
        
#### Pro Tip

If you put a stack of paths under a single key, like so:

    files:
    - webroot: ../web
    - bin: .
    - public: ../web/sites/default/files
    
You can import all of them with one line like this:

    eval $(get_config_path "files")
    
And you will have access to:

    $files_webroot        
    $files_bin        
    $files_public

If the yaml is an indexed array like so:

    files:
    - ../web
    - .
    - ../web/sites/default/files
    
You have one extra step of variable assignment.

    eval $(get_config_path "writeable_directories")
    writeable_directories=($_config_values[@]})    
