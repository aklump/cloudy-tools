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

  if (isset($context['mutator']) && function_exists($context['mutator'])) {
    if (is_array($value)) {
      $value = array_map($context['mutator'], $value);
    }
    else {
      $value = $context['mutator']($value);
    }
  }

  $var_name = $context['cached_var_name'];

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
      $temp = [];
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
        foreach ($value as $k => $v) {
          if (is_scalar($v)) {
            $temp[] = "{$var_name}_{$k}=\"$v\"";
          }
        }
        $value = implode(';', $temp);
        $value = "$var_name=\"$value\"";
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
