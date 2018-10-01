<?php
/**
 * @file Autogenerate Cloudy API function documentation
 */

namespace AKlump\LoftDocs;

use AKlump\LoftLib\Bash\Bash;

require_once $argv[2] . '/vendor/autoload.php';
require_once __DIR__ . '/vendor/autoload.php';

try {
  $vars = [];
  $tomdoc = Bash::which('tomdoc.sh');

  //
  // Process the Public API Functions.
  //
  $contents = Bash::exec([
    $tomdoc,
    $argv[4] . '/../framework/cloudy/cloudy.sh',
  ]);
  $vars['api_functions'] = array_filter(array_map([
    "\AKlump\LoftDocs\FunctionDoc",
    "processTomDocItem",
  ], preg_split("/\-{10,}/", $contents)));
  uasort($vars['api_functions'], ["\AKlump\LoftDocs\FunctionDoc", "sort"]);

  //
  // Now load the test functions.
  //
  $contents = Bash::exec([
    $tomdoc,
    $argv[4] . '/../framework/cloudy/inc/cloudy.testing.sh',
  ]);
  $vars['test_functions'] = array_filter(array_map([
    "\AKlump\LoftDocs\FunctionDoc",
    "processTomDocItem",
  ], preg_split("/\-{10,}/", $contents)));
  uasort($vars['test_functions'], ["\AKlump\LoftDocs\FunctionDoc", "sort"]);

  //
  // Generate the HTML.
  //
  $loader = new \Twig_Loader_Filesystem(dirname(__FILE__));
  $twig = new \Twig_Environment($loader);

  // Template file is located in /hooks as well.
  $template = $twig->load('api.md.twig');

  // All functions for the master list.
  $vars['functions'] = array_merge($vars['api_functions'], $vars['test_functions']);
  uasort($vars['functions'], ["\AKlump\LoftDocs\FunctionDoc", "sort"]);

  // Write the file using $argv[9] to the correct compilation directory.
  file_put_contents($argv[9] . '/api.md', $template->render($vars));

}
catch (\Exception $exception) {
  // Purposefully left blank.
  print $exception->getMessage();
}
