#!/usr/bin/php
<?php

/**
 * @file
 * Return a configuration value by key.
 */

require_once dirname(__FILE__) . '/_bootstrap.php';

$args = $argv;
array_shift($args);
$function = array_shift($args);

if (!function_exists($function)) {
  exit(1);
}

$result = call_user_func_array($function, $args);

if (is_array($result)) {
  echo _cloudy_declare_array($function, $result);
  exit(0);
}




