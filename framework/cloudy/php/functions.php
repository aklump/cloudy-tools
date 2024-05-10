<?php

/**
 * Sort an array by the length of it's values.
 *
 * @param string ...
 *   Any number of items to be taken as an array.
 *
 * @return array
 *   The sorted array
 */
function array_sort_by_item_length() {
  $stack = func_get_args();
  uasort($stack, function ($a, $b) {
    return strlen($a) - strlen($b);
  });

  return array_values($stack);
}

/**
 * Convert a YAML string to a JSON string.
 *
 * @return string
 *   The valid YAML string.
 *
 * @throws \RuntimeException
 *   If the YAML cannot be parsed.
 */
function yaml_to_json($yaml) {
  if (empty($yaml)) {
    return '{}';
  }
  elseif (!($data = Yaml::parse($yaml))) {
    throw new \RuntimeException("Unable to parse invalid YAML string.");
  }

  return json_encode($data);
}

/**
 * Get a value from a JSON string.
 *
 * @param string $path
 *   The dot path of the data to get.
 * @param string $json
 *   A valid JSON string.
 *
 * @return mixed
 *   The value at $path.
 */
function json_get_value($path, $json) {
  $subject = json_decode($json);
  if (json_last_error() !== JSON_ERROR_NONE) {
    throw new \RuntimeException('Invalid JSON string: ' . json_last_error_msg());
  }

  return DotKey::on($subject)->get($path);
}

/**
 * Loads a JSON file to be used with json_get.
 *
 * Always use this function instead of $(cat foo.json) as json validation and
 * escaping is handled for you.
 *
 * @param string $path
 *
 * @return string
 *   The compressed JSON if file is valid, with single quotes escaped.
 * @throws \InvalidArgumentException If the file does not exist or the file is invalid.
 */
function json_load_file(string $path): string {
  if (!file_exists($path)) {
    throw new \RuntimeException("Missing JSON file: " . $path);
  }
  $contents = file_get_contents($path);

  return json_bash_filter($contents);
}

/**
 * @param string $json
 *   A JSON string to be used by cloudy.
 *
 * @return string
 *   The compressed and escaped as appropriate JSON string.
 */
function json_bash_filter(string $json): string {
  $data = json_decode($json);
  if (json_last_error() !== JSON_ERROR_NONE) {
    throw new \RuntimeException('Invalid JSON string: ' . json_last_error_msg());
  }

  return json_encode($data, JSON_UNESCAPED_SLASHES);
}

/**
 * Load a configuration file into memory.
 *
 * @param $filepath
 *   The absolute filepath to a configuration file.
 *
 * @return array|mixed
 */
function load_configuration_data($filepath, $exception_if_not_exists = TRUE) {
  $data = [];
  if (!file_exists($filepath)) {
    if ($exception_if_not_exists) {
      throw new \RuntimeException("Missing configuration file: " . $filepath);
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
          $class = get_class($exception);
          $message = sprintf("Syntax error in configuration file: %s: %s", $filepath, $exception->getMessage());
          write_log_error($message);
          throw new $class($message, $exception->getCode());
        }
        break;

      case 'json':
        if ($json = json_decode($contents, TRUE)) {
          $data += $json;
        }
        break;

      default:
        throw new \RuntimeException("Configuration files of type \"$extension\" are not supported.");

    }
  }

  return $data;
}

/**
 * Merge an array of configuration arrays.
 *
 * @param... two or more arrays to merge.
 *
 * @return array|mixed
 *   The merged array.
 */
function merge_config() {
  $stack = func_get_args();
  $merged = [];
  while (($array = array_shift($stack))) {
    $merged = ArrayMerger::doMerge($merged, $array);
  }

  return $merged;
}

/**
 * Create a hash of a string of filenames separated by \n.
 *
 * @return string
 *   The has of filenames.
 */
function get_config_cache_id() {
  $paths = func_get_arg(0);

  return md5(str_replace("\n", ':', $paths));
}

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
 */
function _cloudy_realpath($path) {
  global $_config_path_base;

  if (!empty($_SERVER['HOME'])) {
    $path = preg_replace('/^~\//', rtrim($_SERVER['HOME'], '/') . '/', $path);
  }
  if (!empty($path) && substr($path, 0, 1) !== '/') {
    $path = ROOT . '/' . "$_config_path_base/$path";
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

##
# @link https://www.php-fig.org/psr/psr-3/
#
function write_log_emergency() {
  $args = func_get_args();
  array_unshift($args, 'emergency');
  call_user_func_array('_cloudy_write_log', $args);
}

##
# You may include 1 or two arguments; when 2, the first is a log label
#
function write_log() {
  $args = func_get_args();
  if (func_num_args() === 1) {
    array_unshift($args, 'log');
  }

  call_user_func_array('_cloudy_write_log', $args);
}

# Writes a log message using the alert level.
#
# $@ - Any number of strings to write to the log.
#
# Returns 0 on success or 1 if the log cannot be written to.
function write_log_alert() {
  $args = func_get_args();
  array_unshift($args, 'alert');
  call_user_func_array('_cloudy_write_log', $args);
}

# Write to the log with level critical.
#
# $1 - The message to write.
#
# Returns 0 on success.
function write_log_critical() {
  $args = func_get_args();
  array_unshift($args, 'critical');
  call_user_func_array('_cloudy_write_log', $args);
}

# Write to the log with level error.
#
# $1 - The message to write.
#
# Returns 0 on success.
function write_log_error() {
  $args = func_get_args();
  array_unshift($args, 'error');
  call_user_func_array('_cloudy_write_log', $args);
}

# Write to the log with level warning.
#
# $1 - The message to write.
#
# Returns 0 on success.
function write_log_warning() {
  $args = func_get_args();
  array_unshift($args, 'warning');
  call_user_func_array('_cloudy_write_log', $args);
}

##
# Log states that should only be thus during development or debugging.
#
# Adds a "... in dev only message to your warning"
#
function write_log_dev_warning() {
  $args = func_get_args();
  array_unshift($args, 'error');
  $args[] = 'This should only be the case for development/debugging.';
  call_user_func_array('_cloudy_write_log', $args);
}

# Write to the log with level notice.
#
# $1 - The message to write.
#
# Returns 0 on success.
function write_log_notice() {
  $args = func_get_args();
  array_unshift($args, 'notice');
  call_user_func_array('_cloudy_write_log', $args);
}

# Write to the log with level info.
#
# $1 - The message to write.
#
# Returns 0 on success.
function write_log_info() {
  $args = func_get_args();
  array_unshift($args, 'info');
  call_user_func_array('_cloudy_write_log', $args);
}

# Write to the log with level debug.
#
# $1 - The message to write.
#
# Returns 0 on success.
function write_log_debug() {
  $args = func_get_args();
  array_unshift($args, 'debug');
  call_user_func_array('_cloudy_write_log', $args);
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
  $logfile = getenv('LOGFILE');
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
  fwrite($stream, implode($lines, PHP_EOL));
  fclose($stream);
}
