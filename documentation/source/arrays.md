# Arrays

## How to copy an array

    new_array=("${old_array[@]}")

This comes in to play after array-based functions like `array_split`

    array_split__string="do<br />re<br />mi"
    array_split '<br />' && local words=("${array_split__array}")
