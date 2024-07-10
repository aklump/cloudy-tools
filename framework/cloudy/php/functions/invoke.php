<?php

/**
 * @file
 * Used to invoke a PHP function using source_php
 *
 * @param $argv [1] The function to call.
 * @param... Any parameters to be passed to the function.
 *
 * @code
 * source_php "$CLOUDY_CLOUDY_CORE_DIR/php/invoke.php" "create_uuid"
 * @endcode
 */

$function_args = $argv;
array_shift($function_args);
$function = array_shift($function_args);
call_user_func_array($function, $function_args);

