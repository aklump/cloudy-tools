# The Script "Operation"

The script operation is defined as the first _argument_ passed.  In all of the following examples it is `alpha`.

    ./script.example.sh alpha bravo charlie
    ./script.example.sh -f alpha
    ./script.example.sh --test alpha -f

If no argument is passed then the YAML configuration file may define a default operation like this:

    operations:
      _default: help

If the configuration file is as above, then these two are identical:

    ./script.example.sh    
    ./script.example.sh help    

## API

    get_op
    get_config "operations._default"
