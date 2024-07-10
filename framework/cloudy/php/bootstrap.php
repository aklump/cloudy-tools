<?php

/**
 * @file
 * Bootstrap for all php files.
 */

require_once __DIR__ . '/cloudy.api.php';
require_once __DIR__ . '/error_handler.php';
require_once __DIR__ . '/cloudy.functions.php';

/**
 * Root directory of the Cloudy instance script.
 */
define('ROOT', getenv('ROOT'));
if (empty(ROOT)) {
  throw new RuntimeException('Environment var "ROOT" cannot be empty.');
}
define('CLOUDY_BASEPATH', getenv('CLOUDY_BASEPATH'));
if (empty(CLOUDY_BASEPATH)) {
  throw new RuntimeException('Environment var "CLOUDY_BASEPATH" cannot be empty.');
}
$composer_vendor = getenv('COMPOSER_VENDOR');
if (empty($composer_vendor)) {
  throw new RuntimeException('Environment var "$composer_vendor" cannot be empty.');
}

/** @var \Composer\Autoload\ClassLoader $class_loader */
$class_loader = require_once $composer_vendor . '/autoload.php';
