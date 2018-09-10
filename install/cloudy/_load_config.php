#!/usr/bin/php
<?php

/**
 * @file
 * Load configuration and echo a json string.
 */

use JsonSchema\Constraints\Constraint;
use JsonSchema\Validator;
use Symfony\Component\Yaml\Yaml;

require_once dirname(__FILE__) . '/_bootstrap.php';

$path_to_cloudy_config = $argv[2];

try {
  $data = [];
  if (!file_exists($path_to_cloudy_config)) {
    throw new \RuntimeException("Missing configuration file: $path_to_cloudy_config");
  }
  if (($yaml = file_get_contents($path_to_cloudy_config)) && ($yaml = Yaml::parse($yaml))) {
    $data += $yaml;
  }
  $data += [
    'config' => [],
  ];

  foreach ($g->get($data, 'additional_config', []) as $basename) {
    $path = ROOT . "/$basename";
    if (!file_exists($path)) {
      throw new \RuntimeException("Missing configuration file: $path");
    }
    $data = array_merge_recursive($data, Yaml::parse(file_get_contents($path)));
  }

  // Validate against base-config.schema.json.
  $validator = new Validator();
  $validate_data = json_decode(json_encode($data));
  try {
    $validator->validate($validate_data, (object) ['$ref' => 'file://' . __DIR__ . '/base-config.schema.json'], Constraint::CHECK_MODE_EXCEPTIONS);
  }
  catch (\Exception $exception) {
    $class = get_class($exception);
    throw new $class("Configuration Syntax Error in \"" . basename($path_to_cloudy_config) . '": ' . $exception->getMessage());
  }

  echo json_encode($data);
  exit(0);
}
catch (\Exception $exception) {
  echo $exception->getMessage();
}
exit(1);
