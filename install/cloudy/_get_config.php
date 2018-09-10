#!/usr/bin/php
<?php

/**
 * @file
 * Return a configuration value by key.
 */

require_once dirname(__FILE__) . '/_bootstrap.php';

$json = $g->get($argv, 2, '[]');
$config_varname = $g->get($argv, 3, '');
$config_key = $g->get($argv, 4, '');
$default_value = $g->get($argv, 5, []);
$default_type = $g->get($argv, 6, 'string');
$array_keys = $g->get($argv, 7, FALSE, function ($value, $default) {
  return $value === 'true' ? TRUE : $default;
});
$mutator = $g->get($argv, 8, NULL);

try {
  $data = json_decode($json, TRUE);
  if ($data === NULL) {
    throw new \RuntimeException("Invalid JSON");
  }

  // Typecast the default value.
  switch ($default_type) {
    case 'array':
      if (empty($default_value)) {
        $default_value = array();
      }
      break;
  }

  $value = get_value($data, $config_key, $default_value, [
    'varname' => $config_varname,
    'array_keys' => $array_keys,
    'mutator' => $mutator,
  ]);

  echo $value;
  exit(0);
}
catch (\Exception $exception) {
  echo $exception->getMessage();
}

exit(1);
