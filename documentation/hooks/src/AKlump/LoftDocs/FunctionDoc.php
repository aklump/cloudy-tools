<?php

namespace AKlump\LoftDocs;

/**
 * Represents a documentation for a single function.
 */
class FunctionDoc {

  protected $return;

  protected $name;

  protected $options = [];

  protected $arguments = [];

  protected $description = [];

  protected $summary;

  /**
   * Use with uasort to sort instances.
   *
   * @param $a
   * @param $b
   *
   * @return bool
   */
  public static function sort($a, $b) {
    return $a->getName() > $b->getName();
  }

  /**
   * Convert a TomDoc function export to an instance of FunctionDoc.
   *
   * @param string $line
   *   The string as returned for single TomDoc function.
   *
   * @return \AKlump\LoftDocs\FunctionDoc|null
   *   An instance of \AKlump\LoftDocs\FunctionDoc.
   */
  public static function processTomDocItem($line) {
    $item = explode("\n\n", trim($line));
    if (empty($item)) {
      return NULL;
    }
    $func = new static();
    $next_line_is_summary = FALSE;
    foreach ($item as $line) {

      $line = ltrim($line);
      if ($next_line_is_summary) {
        $func->setSummary($line);
        $next_line_is_summary = FALSE;
      }
      elseif (in_array(substr($line, 0, 1), ['$', '-'])) {
        $sublines = explode(PHP_EOL, $line);
        foreach ($sublines as $subline) {
          switch (substr($subline, 0, 1)) {
            case '$':
              preg_match("/(.+?)\s*\-\s*(.+)/", ltrim($subline, '$'), $matches);
              $matches += [NULL, NULL, NULL];
              $func->addArgument($matches[1], $matches[2]);
              break;

            case '-':
              preg_match("/(.+?)\s*\-\s*(.+)/", ltrim($subline, '-'), $matches);
              $matches += [NULL, NULL, NULL];
              $func->addOption($matches[1], $matches[2]);
              break;
          }
        }
      }
      elseif (preg_match("/^Return.+/", $line)) {
        $func->setReturn($line);
      }
      elseif (strstr($line, '()')) {
        $func->setName($line);
        $next_line_is_summary = TRUE;
      }
      else {
        $func->addDescription($line);
      }
    }

    return $func->getValidated();
  }

  /**
   * Return the value of Summary.
   *
   * @param mixed $default
   *   Optional, a default value other than null.
   *
   * @return mixed
   *   Lorem.
   */
  public function getSummary($default = NULL) {
    return !is_null($this->summary) ? $this->summary : $default;
  }

  /**
   * Set the value of Summary.
   *
   * @param mixed $summary
   *   Lorem.
   *
   * @return FunctionDoc
   *   Lorem.
   */
  public function setSummary($summary) {
    $this->summary = $summary;

    return $this;
  }

  /**
   * Get a value by key.
   *
   * This is used by Twig.
   *
   * @param string $key
   *   The key to ask for.
   *
   * @return mixed
   *   The value.
   */
  public function __get($key) {
    $method = "get$key";

    return $method();
  }

  /**
   * Return the value of Arguments.
   *
   * @param mixed $default
   *   Optional, a default value other than null.
   *
   * @return array
   *   Lorem.
   */
  public function getArgs($default = []) {
    return !is_null($this->arguments) ? $this->arguments : $default;
  }

  /**
   * Return any defined options.
   *
   * @param mixed $default
   *   Optional, a default value other than null.
   *
   * @return array
   *   Lorem.
   */
  public function getOptions($default = []) {
    return !is_null($this->options) ? $this->options : $default;
  }

  /**
   * Set the value of Arguments.
   *
   * @param array $argument
   *   Add a new argument.
   *
   * @return FunctionDoc
   *   Lorem.
   */
  public function addArgument($name, $description) {
    $name = "\$$name";
    $this->arguments[$name] = $description;

    return $this;
  }

  public function addOption($name, $description) {
    $name = strlen($name) === 1 ? "-$name" : "--$name";
    $this->options[$name] = $description;

    return $this;
  }

  /**
   * Return the object only if is a valid function.
   *
   * @return $this|null
   */
  public function getValidated() {
    if (strpos($this->name, '()')) {
      return $this;
    }

    return NULL;
  }

  /**
   * Return the value of Return.
   *
   * @param mixed $default
   *   Optional, a default value other than null.
   *
   * @return mixed
   *   Lorem.
   */
  public function getReturn($default = NULL) {
    return !is_null($this->return) ? $this->return : $default;
  }

  /**
   * Set the value of Return.
   *
   * @param mixed $return
   *   Lorem.
   *
   * @return FunctionDoc
   *   Lorem.
   */
  public function setReturn($return) {
    $this->return = $return;

    return $this;
  }

  /**
   * Return the value of Name.
   *
   * @param mixed $default
   *   Optional, a default value other than null.
   *
   * @return mixed
   *   Lorem.
   */
  public function getName($default = NULL) {
    return !is_null($this->name) ? trim($this->name, '()') : $default;
  }

  /**
   * Set the value of Name.
   *
   * @param mixed $name
   *   Lorem.
   *
   * @return FunctionDoc
   *   Lorem.
   */
  public function setName($name) {
    $this->name = $name;

    return $this;
  }

  /**
   * Return the value of Description.
   *
   * @param mixed $default
   *   Optional, a default value other than null.
   *
   * @return mixed
   *   Lorem.
   */
  public function getDescription($default = NULL) {
    return !is_null($this->description) ? implode($this->description, PHP_EOL) : $default;
  }

  /**
   * Set the value of Description.
   *
   * @param mixed $description
   *   Lorem.
   *
   * @return FunctionDoc
   *   Lorem.
   */
  public function addDescription($description) {
    $this->description[] = $description;

    return $this;
  }

}
