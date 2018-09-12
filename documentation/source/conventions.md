# Cloudy Conventions

_Cloudy_ has some opinions about how to write code, this page reveals them.

## General 

* Functions that begin with `_cloudy` should be considered private and never called by your script.  They may change in future versions.
* All functions listed in _cloudy.sh_ comprise the public API and will not change across minor version changes.

## Naming

* Function names should be readable and intuitive, e.g., `exit_with_success` is better than `success_exit`
* Function names should start with a verb if applicable, unless they are grouped by category, e.g. `stack_join` is fine because _stack_ is the common group; `join` is the verb.

## Functions

* For getters when echoing a _default value_, return 2

### Functions that operate on arrays

When a function needs to manipulate an array, the array should be assigned to a global variable, the name of which is the function with `__array` added to the end, e.g., 

    function stack_join() {
        local glue=$1
        local string
        string=$(printf "%s$glue" "${stack_join__array[@]}") && string=${string%$glue} || return 1
        echo $string
        return 0
    }
    
And here is the usage

    stack_join__array=("${_config_values[@]}")
    local options="-$(stack_join ", -"), --${option}"    

* The same is true if the function has to **return an array**.
* If a single function operates on more than one array, then the suffix should be modified as necessary.  `_cloudy_parse_option_arguments` is a good example.  You still want the suffix to begin with two underscores.

### Name your function arguments

To make your code more readible, the first line(s) of a function should name the function arguments.  Declare them as `local`.  Then follow with a blank space, after which you begin the process of the function.

    function get_config() {
        local config_key_path=$1
        local default_value="$2"
        
        # Now do the function stuff...

### Declare local variables near the top

Group all local variable names below arguments and declare them there rather than deeper in the function where they are used.  Even if no default values, declare them here anyway.

    function get_config() {
        local config_key_path=$1
        local default_value="$2"
        
        local name
        local type="string"
        
        ...    
