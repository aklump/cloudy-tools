<?php

/**
 * @file
 * Bootstrap for all php files.
 */

use AKlump\Data\Data;

/**
 * Root directory of the Cloudy instance script.
 */
define('ROOT', $argv[1]);

/**
 * The root directory of Cloudy core.
 *
 * @var CLOUDY_ROOT
 */
define('CLOUDY_ROOT', realpath(__DIR__ . '/../'));

require_once CLOUDY_ROOT . '/vendor/autoload.php';

$g = new Data();

/**
 * Sort an array by the length of it's values.
 *
 * @param string ...
 *   Any number of items to be taken as an array.
 *
 * @return array
 *   The sorted array
 */
function array_sort_by_item_length() {
  $stack = func_get_args();
  uasort($stack, function ($a, $b) {
    return strlen($a) - strlen($b);
  });

  return array_values($stack);
}
