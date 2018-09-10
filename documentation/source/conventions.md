## Cloudy Conventions

* For getters when echoing a default value, return 2
* Functions that begin with `_cloudy` should be considered private and never called by your script.
* Function names should be readable and intuitive
    * `exit_with_success` is better than `success_exit`
* Function names should start with a verb if applicable, unless they are grouped by category, e.g. `stack_join` is fine because _stack_ is the common group.

## Functions that operation on arrays

When a function needs to manipulate an array, the array should be assigned to a global variable, the name of which is the function with `_array` added to the end, e.g., 

    function stack_join() {
        local glue=$1
        local string
        string=$(printf "%s$glue" "${stack_join_array[@]}") && string=${string%$glue} || return 1
        echo $string
        return 0
    }
    
And here is the usage

    stack_join_array=("${_config_values[@]}")
    local options="-$(stack_join ", -"), --${option}"    
