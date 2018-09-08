# This script "arguments"

Cloudy makes it easy to react to script arguments.  For example:

    ./install.sh dev install --tree=blue -abc

Here we have:

* The script file _install.sh_
* The operation `operation=$(get_op)`, e.g. `dev`
* One argument `arg=$(get_arg 0)`, e.g., `install`.
* One parameter, `tree`, `param=$(get_param "tree")`, e.g., `blue`
* Three flags: `a,b,c`, `has_flag "a"`

## Check for a flag

    has_flag b && echo "has b flag"
    
## Check for a parameter and get it's output

    has_param tree && echo "tree's value is $(get_param tree)"

             
