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
function get_value(array $config, $path, $context = []) {
  $path = is_string($path) ? explode('.', $path) : $path;
  $key = array_shift($path);
  $context['parents'][] = $key;

  if ($path) {
    $value = isset($config[$key]) ? $config[$key] : [];

    return get_value($value, $path, $context);
  }

  $value = isset($config[$key]) ? $config[$key] : $context['default'];

  if (!empty($context['mutator']) && function_exists($context['mutator'])) {
    if (is_array($value)) {
      $value = array_map($context['mutator'], $value);
    }
    else {
      $value = $context['mutator']($value);
    }
  }

  $var_name = $context['var_name'];

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
    $var_name,
    $value,
  ]);
}

function array_sort_by_item_length() {
  $stack = func_get_args();
  uasort($stack, function ($a, $b) {
    return strlen($a) - strlen($b);
  });

  return array_values($stack);
}

function _cloudy_bash_typecast_value($value) {
  if ($value === NULL) {
    $value = 'null';
  }
  if ($value === TRUE) {
    $value = 'true';
  }
  if ($value === FALSE) {
    $value = 'false';
  }

  return $value;
}

/**
 * Ensure proper quotes around a variable value.
 *
 * @param mixed $value
 *   The variable value.
 *
 * @return mixed
 *   The quoted variable value.
 */
function _cloudy_bash_quote_value($value, $force = FALSE) {
  $value = str_replace('"', '\"', $value);

  if (!$force && is_numeric($value)) {
    $value = $value * 1;
  }
  if (!$force && in_array($value, ['true', 'false', 'null'])) {
    $value = $value;
  }
  else {
    $value = '"' . $value . '"';
  }

  return $value;
}

/**
 * Create a BASH eval declaration for a variable and value.
 *
 * @param string $var_name
 *   The bash variable name to use.
 * @param mixed $value
 *   The value of the variable.
 *
 * @return string
 *   Code to be used by BASH eval.
 */
function _cloudy_declare_bash_variable($var_name, $value) {
  if (is_array($value)) {
    array_walk($value, function (&$value) {
      $value = _cloudy_bash_typecast_value($value);
      // Array values appear to need quotes always.
      $value = _cloudy_bash_quote_value($value, TRUE);
    });

    if (empty($value)) {
      return "declare -a $var_name='()'";
    }

    $open = substr($value[0], 0, 1) === '"' ? '' : '"';
    $close = substr($value[count($value) - 1], -1) === '"' ? '' : '"';

    return "declare -a $var_name='($open" . implode(' ', $value) . $close . ")'";
  }

  $value = _cloudy_bash_typecast_value($value);

  return $var_name . '=' . _cloudy_bash_quote_value($value);
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
