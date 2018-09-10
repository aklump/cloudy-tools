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

  if ($path && isset($config[$key]) && is_array($config[$key])) {
    return get_value($config[$key], $path, $default_value, $context);
  }

  $value = isset($config[$key]) ? $config[$key] : $default_value;

  if (isset($context['mutator']) && function_exists($context['mutator'])) {
    if (is_array($value)) {
      $value = array_map($context['mutator'], $value);
    }
    else {
      $value = $context['mutator']($value);
    }
  }

  $varname = 'cloudy_config_' . implode('_', $context['parents']);

  $value_type = gettype($value);
  switch ($value_type) {
    case 'NULL':
      $value = "$varname=null";
      break;

    case 'boolean':
      $value = $value ? 'true' : 'false';
      $value = "$varname=$value";
      break;

    case 'object':
      $value = $value->__toString();
      $value = "$varname=\"$value\"";
      break;

    case 'array':
      $temp = [];
      if (empty($value)) {
        $value = 'declare -a ' . $varname . '=()';
      }
      elseif (is_numeric(key($value))) {
        $value = 'declare -a ' . $varname . '=("' . implode('" "', $value) . '")';
      }
      elseif (is_array(reset($value)) || $context['array_keys']) {
        $value = 'declare -a ' . $varname . '=("' . implode('" "', array_keys($value)) . '")';
      }
      else {
        foreach ($value as $k => $v) {
          $temp[] = "{$varname}_{$k}=\"$v\"";
        }
        $value = implode(';', $temp);
      }
      break;

    case 'integer':
    case 'double':
      $value = "$varname=$value";
      break;

    case 'string':
      $value = "$varname=\"$value\"";
      break;
  }

  return implode('|', [
    $varname,
    $value,
  ]);
}

function stack_sort_length() {
  $stack = func_get_args();
  uasort($stack, function ($a, $b) {
    return strlen($a) - strlen($b);
  });

  return $stack;
}

function _cloudy_declare_array($function, array $array) {
  if (is_numeric(key($array))) {
    return $function . '_array=("' . implode('" "', $array) . '")';
  }
}

function _cloudy_realpath($value) {
  $path = substr($value, 0, 1) === '/' ? $value : ROOT . "/$value";
  $path = realpath($path);
  if (!$path) {
    $path = ROOT . "/$value";
  }

  return $path;
}
