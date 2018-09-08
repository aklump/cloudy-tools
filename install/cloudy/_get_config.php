#!/usr/bin/php
<?php

/**
 * @file
 * Return a configuration value by key.
 */

require_once dirname(__FILE__) . '/_bootstrap.php';

$json = $argv[2];
$config_key = isset($argv[3]) ? $argv[3] : '';
$default_value = isset($argv[4]) ? $argv[4] : NULL;
$array_keys = isset($argv[5]);

try {
  $data = json_decode($json, TRUE);
  if ($data === NULL) {
    throw new \RuntimeException("Invalid JSON");
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
