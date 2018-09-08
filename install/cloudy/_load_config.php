#!/usr/bin/php
<?php

/**
 * @file
 * Load configuration and echo a json string.
 */

use Symfony\Component\Yaml\Yaml;

require_once __DIR__ . '/vendor/autoload.php';
define('ROOT', $argv[1]);

$path_to_cloudy_config = $argv[2];

try {
  $data = [];
  if (($yaml = file_get_contents($path_to_cloudy_config)) && ($yaml = Yaml::parse($yaml))) {
    $data += $yaml;
  }
  $data += [
    'config' => [],
  ];

  foreach ($data['config'] as $basename) {
    $data = array_merge_recursive($data, Yaml::parse(file_get_contents(ROOT . "/$basename")));
  }

  echo json_encode($data);
  exit(0);
}
catch (\Exception $exception) {
  echo $exception->getMessage();
}
exit(1);

