<?php

/**
 * @file
 * Bootstrap for all php files.
 */

use AKlump\Data\Data;
use AKlump\LoftLib\Bash\Configuration;
use Symfony\Component\Yaml\Yaml;

/**
 * Root directory of the Cloudy instance script.
 */
define('ROOT', $argv[1]);

/**
 * The root directory of Cloudy core.
 *
 * @var string
 */
define('CLOUDY_ROOT', realpath(__DIR__ . '/../'));

require_once __DIR__ . '/vendor/autoload.php';

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

/**
 * Load a configuration file into memory.
 *
 * @param $filepath
 *   The absolute filepath to a configuration file.
 *
 * @return array|mixed
 */
function load_configuration_data($filepath) {
  $data = [];
  if (!file_exists($filepath)) {
    throw new \RuntimeException("Missing configuration file: $filepath");
  }
  if (!($contents = file_get_contents($filepath))) {
    throw new \RuntimeException("Empty configuration files: $filepath");
  }
  switch (($extension = pathinfo($filepath, PATHINFO_EXTENSION))) {
    case 'yml':
    case 'yaml':
      if ($yaml = Yaml::parse($contents)) {
        $data += $yaml;
      }
      break;

    case 'json':
      if ($json = json_decode($contents, TRUE)) {
        $data += $json;
      }
      break;

    default:
      throw new \RuntimeException("Configuration files of type \"$extension\" are not supported.");

  }

  return $data;
}

function drupal_array_merge_deep_array($arrays) {
  $result = array();
  foreach ($arrays as $array) {
    foreach ($array as $key => $value) {

      // Renumber integer keys as array_merge_recursive() does. Note that PHP
      // automatically converts array keys that are integer strings (e.g., '1')
      // to integers.
      if (is_integer($key)) {
        $result[] = $value;
      }
      elseif (isset($result[$key]) && is_array($result[$key]) && is_array($value)) {
        $result[$key] = drupal_array_merge_deep_array(array(
          $result[$key],
          $value,
        ));
      }
      else {
        $result[$key] = $value;
      }
    }
  }

  return $result;
}
