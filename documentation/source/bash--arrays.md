# Arrays

## How to copy an array

    new_array=("${old_array[@]}")

This comes in to play after array-based functions like `string_split`

    string_split__string="do<br />re<br />mi"
    string_split '<br />' && local words=("${string_split__array}")

## How to copy and array with dynamic name

    eval copy=(\"\${$master[@]}\")

## How to shift

```bash
$ a=(a b c d e)
$ a=("${a[@]:1}")
$ echo "${a[@]}"
b c d e
```

## How to pop

```bash
a=("${a[@]:0:${#a[@]} - 1}" 
```
