<?php

/**
 * @file
 * An example PHP hook file.
 */

namespace AKlump\WebPackage;

$path = '/framework/cloudy/composer.json';
$build
  ->loadFile($argv[7] . $path, function ($json) use ($argv) {
    $data = json_decode($json, TRUE);
    $data['version'] = $argv[2];

    return json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
  })
  ->saveReplacingSourceFile();

echo "Version updated in $path" . PHP_EOL;
