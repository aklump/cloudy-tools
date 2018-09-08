# The script "parameters"

Parameters are arguments passed to the script that begin with a double dash, e.g. `--`.  They can server as verbose flags, or they can contain values.  Here are some examples:

        ./script.example.sh --file=intro.txt --noup

* In both cases two parameters are passed.
* Order does not matter.
* `file` has a value of `intro.txt`
* `noup` has a value of `true`

## API

    has_params
    has_param {parameter}
    get_param {parameter}
