#!/usr/bin/php
<?php

/**
 * @file
 * Return a configuration value by key.
 */

require_once dirname(__FILE__) . '/_bootstrap.php';

$json = $g->get($argv, 2, '[]');
$config_key = $g->get($argv, 3, '');
$default_value = $g->get($argv, 4, []);
$default_type = $g->get($argv, 5, 'string');
$array_keys = $g->get($argv, 6, FALSE);

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
    'array_keys' => $array_keys,
  ]);

  echo $value;
  exit(0);
}
catch (\Exception $exception) {
  echo $exception->getMessage();
}

exit(1);
