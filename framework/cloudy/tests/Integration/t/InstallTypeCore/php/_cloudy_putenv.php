<?php

/**
 * @file This will test: changes to cloudy vars and cloudy_export()
 */

/** @var $CLOUDY_FAILURES */

// Changes to this variable (and any other of our defined globals) are
// automatically picked up in source_php.php and bubbled up to the controller.
$CLOUDY_FAILURES .= 'Alpha Bravo' . PHP_EOL;

// New variable that we pass to the controller using cloudy_putenv().
$putenv_test_value = 'Lorem ipsum dolar sit';
cloudy_putenv('putenv_test_value=' . $putenv_test_value);
