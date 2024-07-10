<?php

/**
 * @param string $path_to_php_file
 * @param... Additional arguments will be passed to PHP file.
 *
 * @exit 127 Unknown error
 */

$path_to_php_file = $argv[1];

//
// Context establishment
//
$vars = [];
$vars['CLOUDY_CORE_DIR'] = getenv('CLOUDY_CORE_DIR');
$vars['CLOUDY_CACHE_DIR'] = getenv('CLOUDY_CACHE_DIR');
$vars['CLOUDY_PACKAGE_CONTROLLER'] = getenv('CLOUDY_PACKAGE_CONTROLLER');
$vars['CLOUDY_PACKAGE_CONFIG'] = getenv('CLOUDY_PACKAGE_CONFIG');
$vars['CLOUDY_BASEPATH'] = getenv('CLOUDY_BASEPATH');
$vars['CLOUDY_RUNTIME_UUID'] = getenv('CLOUDY_RUNTIME_UUID');
$vars['CLOUDY_FAILURES'] = getenv('CLOUDY_FAILURES');

try {
  require_once $vars['CLOUDY_CORE_DIR'] . '/php/cloudy.api.php';
  // We want $path_to_php_file to have the perspective that it was called by
  // BASH, so we will remove this file from the argv stack.
  array_shift($argv);

  // Create an isolated environment for our PHP source file.
  (function () use ($argv, $path_to_php_file, $vars) {
    extract($vars);
    require_once $path_to_php_file;
    unset($path_to_php_file);

    // Bubble up any changes to the globals, to the calling BASH.
    foreach (get_defined_vars() as $varname => $value) {
      if (isset($vars[$varname]) && $value !== $vars[$varname]) {
        cloudy_putenv("$varname=$value");
      }
    }
  })();
}
catch (Exception $exception) {
  // If the PHP include file is going to throw an exception, it should set a
  // non-zero \Exception code.  Failure to set an \Exception code, will result
  // in an exit code of 127.
  $code = $exception->getCode();
  $code = $code ?: 127;
  exit($code);
}



