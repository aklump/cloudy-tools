# The script "flags"

Flags are arguments passed to the script that begin with a single `-`.  Here are some examples:

        ./script.example.sh -f -h -p
        ./script.example.sh -fhp

* In both cases three flags are passed.
* Order does not matter.

## API

    has_flags
    has_flag {flag}
