<?php

/**
 * @file
 * Bootstrap for all php files.
 */

use AKlump\Data\Data;

define('ROOT', $argv[1]);

require_once dirname(__FILE__) . '/vendor/autoload.php';

$g = new Data();

/**
 * Get a nested value using $path.
 *
 * @param array $config
 *   A nested configuration array.
 * @param string|array $path
 *   A space-delimited path to the config value.
 *
 * @return mixed
 *   The value of the configuration
 *
 * @throws \RuntimeException
 *   When the configuration is not found.
 */
function get_value(array $config, $path, $default_value, $context = []) {
  $path = is_string($path) ? explode('.', $path) : $path;
  $key = array_shift($path);
  $context['parents'][] = $key;

  if ($path) {
    $value = isset($config[$key]) ? $config[$key] : [];

    return get_value($value, $path, $default_value, $context);
  }

  $value = isset($config[$key]) ? $config[$key] : $default_value;

  if (!empty($context['mutator']) && function_exists($context['mutator'])) {
    if (is_array($value)) {
      $value = array_map($context['mutator'], $value);
    }
    else {
      $value = $context['mutator']($value);
    }
  }

  $var_name = $context['cached_var_name'];

  // This is extra code that will be added to the cached file and returned
  // in the eval code from get_config.
  $suffix = '';

  $value_type = gettype($value);
  switch ($value_type) {
    case 'NULL':
      $value = "$var_name=null";
      break;

    case 'boolean':
      $value = $value ? 'true' : 'false';
      $value = "$var_name=$value";
      break;

    case 'object':
      $value = $value->__toString();
      $value = "$var_name=\"$value\"";
      break;

    case 'array':
      if (empty($value)) {
        $value = 'declare -a ' . $var_name . '=()';
      }
      elseif (is_numeric(key($value))) {
        $value = 'declare -a ' . $var_name . '=("' . implode('" "', $value) . '")';
      }
      elseif ($context['array_keys']) {
        $value = 'declare -a ' . $var_name . '=("' . implode('" "', array_keys($value)) . '")';
      }
      else {
        $suffix = [];
        foreach ($value as $k => $v) {
          if (is_scalar($v)) {
            $suffix[] = "{$var_name}_{$k}=\"$v\"";
          }
        }
        $suffix = implode(';', $suffix);
        $value = "${var_name}=true";
      }
      break;

    case 'integer':
    case 'double':
      $value = "$var_name=$value";
      break;

    case 'string':
      $value = "$var_name=\"$value\"";
      break;
  }

  return implode('|', [
    $value_type,
    $var_name,
    $value,
    $suffix ? ';' . trim($suffix, ';') : '',
  ]);
}

function array_sort_by_item_length() {
  $stack = func_get_args();
  uasort($stack, function ($a, $b) {
    return strlen($a) - strlen($b);
  });

  return array_values($stack);
}

function _cloudy_declare_array($function, array $array) {
  if (is_numeric(key($array))) {
    return $function . '__array=("' . implode('" "', $array) . '")';
  }
}

function _cloudy_realpath($value) {
  if (substr($value, 0, 1) === '/') {
    if (!($path = realpath($value))) {
      $path = $value;
    }
  }
  else {
    if (!($path = realpath(ROOT . "/$value"))) {
      $path = ROOT . "/$value";
    }
  }

  return $path;
}
