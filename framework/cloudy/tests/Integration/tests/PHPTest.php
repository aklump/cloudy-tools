<?php

namespace AKlump\Cloudy\Tests\Integration\tests;

use AKlump\Cloudy\Tests\Integration\TestingTraits\TestWithCloudyTrait;
use PHPUnit\Framework\TestCase;

/**
 * @coversNothing
 */
class PHPTest extends TestCase {

  use TestWithCloudyTrait;

  public function _testFailBecause() {
    $this->bootCloudy(__DIR__ . '/../t/InstallTypeCore/config.yml');
    $include = __DIR__ . '/../t/InstallTypeCore/php/_error_handling.php';
    $result = $this->execCloudy("source_php '$include' 'fail_because' 'Lorem ipsum'");
    $this->assertSame('asdf', $result);
//    $this->execCloudy("source_php '$include' 'fail_because' '' 'Alpa bravo'");
//    $this->execCloudy("source_php '$include' 'fail_because' 'Lorem ipsum' 'Alpa bravo'");
  }


  public function testEmptyPhpPathReturns126() {
    $this->bootCloudy(__DIR__ . '/../t/InstallTypeCore/config.yml');
    $this->execCloudy("source_php");
    $this->assertSame(126, $this->getCloudyResultCode());
  }

  public function testNonFilePhpPathReturns125() {
    $this->bootCloudy(__DIR__ . '/../t/InstallTypeCore/config.yml');
    $include = __DIR__ . '/../t/InstallTypeCore/php/_bogus_not_found.php';
    $this->execCloudy("source_php '$include'");
    $this->assertSame(125, $this->getCloudyResultCode());
  }

  public function testExceptionWithNoCodeReturns127() {
    $this->bootCloudy(__DIR__ . '/../t/InstallTypeCore/config.yml');
    $include = __DIR__ . '/../t/InstallTypeCore/php/_functions.php';
    $this->execCloudy("source_php '$include' '_throw_runtime_exception'");
    $this->assertSame(127, $this->getCloudyResultCode());
  }

  public function dataFortestExitWithFailureProvider() {
    $tests = [];
    $tests[] = [1];
    $tests[] = [3];
    $tests[] = [99];

    return $tests;
  }

  /**
   * @dataProvider dataFortestExitWithFailureProvider
   */
  public function testExitWithFailure(int $exit_code) {
    $this->bootCloudy(__DIR__ . '/../t/InstallTypeCore/config.yml');
    $include = __DIR__ . '/../t/InstallTypeCore/php/_functions.php';
    $this->execCloudy("source_php '$include' 'exit_with_failure' $exit_code");
    $this->assertSame($exit_code, $this->getCloudyResultCode());
  }

  public function testCloudPhpPointsToAPhpExecutable() {
    $this->bootCloudy(__DIR__ . '/../t/ConfigTest/base.yml');
    $result = $this->execCloudy('echo $CLOUDY_PHP');
    $this->assertNotEmpty($result, 'Assert value for $CLOUDY_PHP');
    exec("$result -v", $output);
    $output = implode(PHP_EOL, $output);
    $this->assertMatchesRegularExpression('#PHP [\d.]+#', $output);
  }

}
