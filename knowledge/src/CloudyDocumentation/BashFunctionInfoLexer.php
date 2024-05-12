<?php

namespace AKlump\Knowledge\User\CloudyDocumentation;

use Doctrine\Common\Lexer\AbstractLexer;
use ReflectionClass;

class BashFunctionInfoLexer extends AbstractLexer {

  const T_NAME = 1;

  const T_SUMMARY = 2;

  const T_DESCRIPTION = 3;

  const T_GLOBAL = 4;

  const T_PARAMETER = 5;

  const T_OPTION = 6;

  const T_ECHO = 7;

  const T_RETURN = 8;

  protected $hasSummary = FALSE;

  protected $description = '';

  protected $indent = NULL;

  /**
   * @inheritDoc
   */
  protected function getCatchablePatterns(): array {
    return [
      'function\s+[^{]+',
      '#.+?\n',
    ];
  }

  /**
   * @inheritDoc
   */
  protected function getNonCatchablePatterns(): array {
    return [
      // This is the '#!/bin...' header.
      '^\#!.+\n',
    ];
  }

  /**
   * @inheritDoc
   */
  protected function getType(&$value): int {
    $tags = $this->getDocBlockTags();
    $tags_regex = '#(' . implode('|', $tags) . ')\s+([^\n]+)#siu';
    preg_match($tags_regex, $value, $matches);
    if ($matches) {
      array_shift($matches);

      return $this->handleDocBlockTagTokens($matches, $value);
    }

    if (preg_match('#function\s+([^({]+)#', $value, $matches)) {
      $value = $matches[1];

      return self::T_NAME;
    }

    if (!preg_match('/^#/', $value)) {
      return 0;
    }

    if (preg_match('/^#!\//', $value)) {
      return 0;
    }

    // Detect the indentation.
    if (!isset($this->indent)) {
      preg_match('#^\#\s+#', $value, $matches);
      $this->indent = $matches[0] ?? '';
    }

    // Remove the indent.
    if ($this->indent && strpos($value, $this->indent) === 0) {
      $value = substr($value, strlen($this->indent));
    }

    if (!$this->hasSummary) {
      $this->hasSummary = TRUE;
      $value = trim($value, "\n");

      return self::T_SUMMARY;
    }

    // Every other line will be concantenated into the description.
    $value = ltrim($value, '#');
    $this->description .= $value;
    $value = trim($this->description, "\n");

    return self::T_DESCRIPTION;
  }

  /**
   * {@inheritdoc}
   */
  public function reset() {
    $this->description = '';
    $this->indent = NULL;
    $this->hasSummary = FALSE;
    parent::reset();
  }

  private function handleDocBlockTagTokens(array $parsed, &$value): int {
    list($flag, $line) = $parsed;

    $type = NULL;
    if (in_array($flag, [
      DocBlockTags::GLOBAL,
      DocBlockTags::PARAM,
      DocBlockTags::OPTION,
      DocBlockTags::RETURN,
    ])) {
      $enum = (new ReflectionClass(VarTypes::class))->getConstants();
      if (preg_match('#^(' . implode('|', $enum) . ') (.+)#i', $line, $matches)) {
        list(, $type, $line) = $matches;
      }
    }

    switch ($flag) {
      case DocBlockTags::GLOBAL:
        $name = '';
        if (preg_match('#(\$\S+)(?:\s+([^\n]*))?#', $line, $matches)) {
          $name = $matches[1] ?? '';
          $line = $matches[2] ?? '';
        }
        $value = new FunctionGlobal($name, $line, $type);

        return self::T_GLOBAL;

      case DocBlockTags::PARAM:
        $type = $type ?? VarTypes::STRING;
        $value = new FunctionParameter($line, $type);

        return self::T_PARAMETER;

      case DocBlockTags::OPTION:
        $value = $this->parseOption($line, $type);

        return self::T_OPTION;

      case DocBlockTags::ECHO:
        $value = new FunctionEcho($line);

        return self::T_ECHO;

      case DocBlockTags::RETURN:
        $value = 0;
        if (preg_match('#(\d+)\s([^\n]*)#', $line, $matches)) {
          $value = (int) $matches[1];
          $line = $matches[2] ?? '';
        }
        $value = new FunctionReturn($value, $line);

        return self::T_RETURN;
      default:
        return 0;
    }
  }

  private function parseOption(string $line, $type): FunctionOption {
    $regex = '#--([^\s=]+)(?:=(\S+))?([^\n]*)#';
    if (!preg_match($regex, $line, $matches)) {
      $regex = '#-(\S)()([^\n]*)#';
      preg_match($regex, $line, $matches);
      $type = 'void';
    }
    $name = $matches[1] ?? '';
    $enum = [];
    if (isset($matches[2])) {
      $enum = array_filter(explode('|', $matches[2]));
    }
    $description = trim($matches[3] ?? '');

    // We'll let the explicit type trump... but if no =value then it's void.
    if (is_null($type) && empty($matches[2])) {
      $type = VarTypes::VOID;
    }
    $type = $type ?? VarTypes::STRING;

    return new FunctionOption($name, $description, $type, $enum);
  }

  private function getDocBlockTags(): array {
    return (new ReflectionClass(DocBlockTags::class))->getConstants();
  }

}
