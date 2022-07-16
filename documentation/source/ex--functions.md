# Functions

## Using Functions to Create Variable Values

Follow this pattern for best results.

```bash
function lorem_echo_color() {
  local is_colorblind="$1"
  
  [[ "$is_colorblind" == true ]] && echo "Observer is colorblind." && return 1
  echo "blue" && return 0
}
```

### Acting Only When a Variable Is Set

```bash
if color=$(lorem_echo_color); then
  echo "The color has been set to: $color"
fi
```

### Failing When a Variable Cannot Be Set

```bash
function parent_caller() {
  local color
  ! color=$(lorem_echo_color) && fail_because "$color" && return 1
}

# In this example `lorem_echo_color` is not being called from inside a parent function.
! color=$(lorem_echo_color) && fail_because "$color" && exit_with_failure
```

### Assigning Default Values Instead of Failing

```bash
# Use this pattern for an empty or default value
color=$(lorem_echo_color) || color=''
color=$(lorem_echo_color) || color='some default'
```

Points to take note of:

* Do not put `fail_because` inside of functions that echo their results. The message will get lost due due to the subshell aspect.
* Instead echo the message to be passed into `fail_because` by the caller.
* In parent functions, do not use `local` on the same line as the `color=` assignment or this will cause the `return 1` to be lost.
* Sometimes you will want a default value rather than to process a failure, use the second example in that case.
