<?php

/**
 * @file
 * Bootstrap for all php files.
 */

use Ckr\Util\ArrayMerger;
use Symfony\Component\Yaml\Yaml;
use Jasny\DotKey;

/**
 * Root directory of the Cloudy instance script.
 */
define('ROOT', getenv('ROOT'));

/** @var \Composer\Autoload\ClassLoader $class_loader */
$class_loader = require_once getenv('COMPOSER_VENDOR') . '/autoload.php';
require_once __DIR__ . '/functions.php';
