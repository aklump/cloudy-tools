<?php

/** @var \Symfony\Component\EventDispatcher\EventDispatcher $dispatcher */

use AKlump\Knowledge\Events\AssemblePages;
use AKlump\Knowledge\Events\AssembleWebpageAssets;
use AKlump\Knowledge\Model\BookPageInterface;
use AKlump\Knowledge\Model\Page;
use AKlump\Knowledge\ProcessorResults\ProblemSolution;
use AKlump\Knowledge\User\FunctionDoc;
use Symfony\Component\Filesystem\Path;
use Twig\Environment;
use Twig\Loader\FilesystemLoader;

/**
 * Create the API page by parsing the Cloudy source code.
 */
$dispatcher->addListener(AssemblePages::NAME, function (AssemblePages $event) {
  exec('which tomdoc.sh', $tomdoc);
  $tomdoc = array_pop($tomdoc);
  if (!$tomdoc) {
    return new ProblemSolution('Missing "Tomdoc.sh"', 'Make sure you have installed Tomdoc (http://tomdoc.org/)');
  }

  //
  // Process the Public API Functions.
  //
  $path_to_cloudy_script = __DIR__ . '/../framework/cloudy/cloudy.sh';
  if (!file_exists($path_to_cloudy_script)) {
    $path_to_cloudy_script = Path::canonicalize($path_to_cloudy_script);

    return new ProblemSolution("Cannot locate cloudy.sh for parsing.", "Make sure this path exists: %s", $path_to_cloudy_script);
  }

  $vars = [];

  exec(sprintf('%s %s', $tomdoc, $path_to_cloudy_script), $contents);
  $contents = implode(PHP_EOL, $contents);

  $vars['api_functions'] = array_filter(array_map([
    FunctionDoc::class,
    "processTomDocItem",
  ], preg_split("/\-{10,}/", $contents)));
  uasort($vars['api_functions'], [FunctionDoc::class, "sort"]);

  //
  // Now load the test functions.
  //
  $path_to_cloudy_testing_script = __DIR__ . '/../framework/cloudy/inc/cloudy.testing.sh';
  if (!file_exists($path_to_cloudy_testing_script)) {
    $path_to_cloudy_testing_script = Path::canonicalize($path_to_cloudy_testing_script);

    return new ProblemSolution("Cannot locate cloudy.sh for parsing.", "Make sure this path exists: %s", $path_to_cloudy_testing_script);
  }
  exec(sprintf('%s %s', $tomdoc, $path_to_cloudy_testing_script), $contents);
  $contents = implode(PHP_EOL, $contents);

  $vars['test_functions'] = array_filter(array_map([
    FunctionDoc::class,
    "processTomDocItem",
  ], preg_split("/\-{10,}/", $contents)));
  uasort($vars['test_functions'], [FunctionDoc::class, "sort"]);

  //
  // Generate the HTML.
  //
  $loader = new FilesystemLoader(dirname(__FILE__));
  $twig = new Environment($loader);
  $template = $twig->load('page--api.twig');

  // All functions for the master list.
  $vars['functions'] = array_merge($vars['api_functions'], $vars['test_functions']);
  uasort($vars['functions'], [FunctionDoc::class, "sort"]);

  $page = new Page('api', 'about');
  $page_body = $template->render($vars);
  $page->setBody($page_body, BookPageInterface::MIME_TYPE_HTML);
  $event->addPage($page);
});


