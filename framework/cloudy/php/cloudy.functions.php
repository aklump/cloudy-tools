<?php

##
# @file Unpublished, private functions
#
# Developers should not rely on the functions in this file as they may change
# at any time.
##

use Ckr\Util\ArrayMerger;
use Symfony\Component\Yaml\Yaml;

/**
 * Expand a path based on $config_path_base.
 *
 * This function can handle:
 * - paths that begin with ~/
 * - paths that contain the glob character '*'
 * - absolute paths
 * - relative paths to `config_path_base`
 *
 * @param string $path
 *   The path to expand.
 *
 * @return array
 *   The expanded paths.  This will have multiple items when using globbing.
 *
 * @see _cloudy_get_config in cloudy.functions.sh
 */
function _cloudy_realpath($path) {
  global $_config_path_base;

  # Replace ~ with the actual home page
  if (!empty($_SERVER['HOME'])) {
    $path = preg_replace('/^~\//', rtrim($_SERVER['HOME'], '/') . '/', $path);
  }

  # Replace tokens
  if (strstr($path, '{APP_ROOT}')) {
    $app_root = rtrim(APP_ROOT, '/');
    // We support both versions: "{APP_ROOT}foo" and "{APP_ROOT}/foo"
    $path = preg_replace('#{APP_ROOT}/?#', "$app_root/", $path);
  }

  // If $path is not absolute then we need to make it so.
  $path_is_absolute = !(!empty($path) && substr($path, 0, 1) !== '/');
  if (!$path_is_absolute) {
    //    $prefix = rtrim(ROOT, '/') . '/';
    $path = implode('/', array_filter([
      rtrim(APP_ROOT, '/'),
      rtrim($_config_path_base, '/'),
      rtrim($path, '/'),
    ]));
  }
  if (strstr($path, '*')) {
    $paths = glob($path);
  }
  else {
    $paths = [$path];
  }
  $paths = array_map(function ($item) {
    return is_file($item) ? realpath($item) : $item;
  }, $paths);

  return $paths;
}


/**
 * Create a log entry if logging is enabled.
 *
 * @param string $level
 *   The log level
 * @param... string $message
 *   Any number of string parameters, each will be a single log line entry.
 *
 * @return void
 */
function _cloudy_write_log($level) {
  $logfile = getenv('CLOUDY_LOG');
  if (empty($logfile)) {
    return;
  }
  $args = func_get_args();
  $level = array_shift($args);
  $directory = dirname($logfile);
  if (!is_dir($directory)) {
    mkdir($directory, 0755, TRUE);
  }

  $date = date('D M d H:i:s T Y');
  $lines = array_map(function ($message) use ($level, $date) {
    return "[$date] [$level] $message";
  }, $args);
  $stream = fopen($logfile, 'a');
  fwrite($stream, implode(PHP_EOL, $lines) . PHP_EOL);
  fclose($stream);
}

/**
 * Merge an array of configuration arrays.
 *
 * @param... two or more arrays to merge.
 *
 * @return array|mixed
 *   The merged array.
 */
function _cloudy_merge_config() {
  $stack = func_get_args();
  $merged = [];
  while (($array = array_shift($stack))) {
    $merged = ArrayMerger::doMerge($merged, $array);
  }

  return $merged;
}

/**
 * Load a configuration file into memory.
 *
 * @param $filepath
 *   The absolute filepath to a configuration file.
 *
 * @return array|mixed
 */
function _cloudy_load_configuration_data($filepath, $exception_if_not_exists = TRUE) {
  $data = [];
  if (!file_exists($filepath)) {
    if ($exception_if_not_exists) {
      throw new RuntimeException("Missing configuration file: " . $filepath);
    }

    return $data;
  }
  if (!($contents = file_get_contents($filepath))) {
    // TODO Need a php method to write a log file, and then log this.
    //    throw new \RuntimeException("Empty configuration file: " . realpath($filepath));
  }
  if ($contents) {
    switch (($extension = pathinfo($filepath, PATHINFO_EXTENSION))) {
      case 'yml':
      case 'yaml':
        try {
          if ($yaml = Yaml::parse($contents)) {
            $data += $yaml;
          }
        }
        catch (\Exception $exception) {
          write_log_exception($exception);
          $message = sprintf("Syntax error in configuration file: %s: %s", $filepath, $exception->getMessage());
          write_log_error($message);
          $class = get_class($exception);
          throw new $class($message, $exception->getCode());
        }
        break;

      case 'json':
        if ($json = json_decode($contents, TRUE)) {
          $data += $json;
        }
        break;

      default:
        throw new RuntimeException("Configuration files of type \"$extension\" are not supported.");

    }
  }

  return $data;
}

/**
 * Create a hash of a string of filenames separated by \n.
 *
 * @return string
 *   The has of filenames.
 */
function _cloudy_get_config_cache_id() {
  $paths = func_get_arg(0);

  return md5(str_replace("\n", ':', $paths));
}
