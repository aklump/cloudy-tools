#!/usr/bin/php
<?php

/**
 * @file
 * Load actual configuration file and echo a json string.
 *
 * This is the first step in the configuration compiling.
 *
 * @group configuration
 * @see json_to_bash.php
 */

use JsonSchema\Constraints\Constraint;
use JsonSchema\Validator;

require_once __DIR__ . '/bootstrap.php';
$filepath_to_schema_file = $argv[1];
$filepath_to_config_file = getenv('CONFIG');
$skip_config_validation = $g->get($argv, 2, FALSE) === 'true';
$runtime = array_filter(explode("\n", trim($g->get($argv, 3, ''))));
try {
  $data = [
    '__cloudy' => [
      'CLOUDY_NAME' => getenv('CLOUDY_NAME'),
      'ROOT' => ROOT,
      'SCRIPT' => realpath(getenv('SCRIPT')),
      'CONFIG' => $filepath_to_config_file,
      'WDIR' => getenv('WDIR'),
      'LOGFILE' => getenv('LOGFILE'),
    ],
  ];
  $data += load_configuration_data($filepath_to_config_file);
  $_config_path_base = $data['config_path_base'] ?? '';
  $merge_config = array_filter(array_merge($runtime, $g->get($data, 'additional_config', [])));
  foreach ($merge_config as $path_or_glob) {
    $paths = _cloudy_realpath($path_or_glob);
    foreach ($paths as $path) {
      try {
        $additional_data = load_configuration_data($path);
        $data = merge_config($data, $additional_data);
      }
      catch (\Exception $exception) {
        // Purposefully left blank because we will allow missing additional
        // configuration files.  This will happen if the app allows for a home
        // directory config file, this should be optional and not throw an
        // error.
      }
    }
  }

  // Validate against cloudy_config.schema.json.
  $validator = new Validator();
  $validate_data = json_decode(json_encode($data));
  try {
    if (!($schema = json_decode(file_get_contents($filepath_to_schema_file)))) {
      throw new \RuntimeException("Invalid JSON in $filepath_to_schema_file");
    }
    if (!$skip_config_validation) {
      $validator->validate($validate_data, $schema, Constraint::CHECK_MODE_EXCEPTIONS);
    }
  }
  catch (\Exception $exception) {
    $class = get_class($exception);
    throw new $class("Configuration syntax error in \"" . basename($filepath_to_config_file) . '": ' . $exception->getMessage());
  }

  echo json_encode($data, JSON_UNESCAPED_SLASHES);
  exit(0);
}
catch (\Exception $exception) {
  echo $exception->getMessage();
}
exit(1);
