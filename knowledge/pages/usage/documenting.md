<!--
id: documenting
tags: usage
-->

# Documenting Code

## CloudyDocumentation

@todo

## TomDoc

Cloudy scripts should include function documentation per [TomDoc](http://tomdoc.org) syntax.

Documentation can be extracted using [tomdoc.sh](https://github.com/tests-always-included/tomdoc.sh)

Here is an example docblock.

    # Prompt for a Y or N confirmation.
    #
    # $1 - The confirmation message
    # --caution - Use when answering Y requires caution.
    # --danger - Use when answering Y is a dangerous thing.
    #
    # Returns 0 if the user answers Y; 1 if not.
    function confirm() {
        local message="$1"
        ...
