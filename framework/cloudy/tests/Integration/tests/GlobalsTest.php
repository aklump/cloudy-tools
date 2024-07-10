<?php

namespace AKlump\Cloudy\Tests\Integration\tests;

use AKlump\Cloudy\Tests\Integration\TestingTraits\TestWithCloudyTrait;
use PHPUnit\Framework\TestCase;

/**
 * @coversNothing
 */
class GlobalsTest extends TestCase {

  use TestWithCloudyTrait;

  public function testGetEnvReturnsVariableSetByCloudyPutEnv() {
    $result = $this->execCloudy(sprintf('getenv.sh'));
    $this->assertSame("Evergreen trees are nice!", $result);
  }

  public function testControllerReceivesVariablesSetByCloudyPutEnv() {
    $result = $this->execCloudy(sprintf('cloudy_putenv.sh'));
    $this->assertSame("Alpha Bravo\nLorem ipsum dolar sit", $result);
  }

  public function dataFortestGlobalsProvider() {
    $integration_tests_dir = __DIR__ . '/../';
    $tests = [];
    $tests[] = ['CLOUDY_CORE_DIR', $this->getCloudyCoreDir()];
    $tests[] = ['CLOUDY_CACHE_DIR', $this->getCloudyCacheDir()];
    $tests[] = [
      'CLOUDY_PACKAGE_CONTROLLER',
      realpath(__DIR__ . '/../cloudy_bridge/test_runner.sh'),
    ];
    $tests[] = [
      'CLOUDY_PACKAGE_CONFIG',
      $integration_tests_dir . '/t/InstallTypeCore/config.yml',
    ];
    $tests[] = [
      'CLOUDY_BASEPATH',
      $integration_tests_dir . '/t/InstallTypeCore/',
    ];

    return $tests;
  }

  /**
   * @dataProvider dataFortestGlobalsProvider
   */
  public function testGlobals(string $var_name, string $expected) {
    $result = $this->execCloudy('echo $' . $var_name);
    $this->assertNotEmpty($result, 'Assert value for ' . $var_name);
    $result = realpath($result);
    $expected = realpath($expected);
    $this->assertSame($expected, $result, 'Assert expected path for $' . $var_name);
  }

  public function testCloudyRuntimeUuid() {
    $uuid = $this->execCloudy('echo $CLOUDY_RUNTIME_UUID');
    $this->assertMatchesRegularExpression('#^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$#', $uuid);
  }

  public function testSourcePHPProvidesExpectedVariables() {
    $result = $this->execCloudy(sprintf('source_php "%s"', __DIR__ . '/../t/InstallTypeCore/php/_variables.php'));
    $this->assertNotEmpty($result);
    $data = json_decode($result, TRUE);
    $this->assertSame($this->getCloudyCoreDir(), $data['CLOUDY_CORE_DIR'], 'Assert $CLOUDY_CORE_DIR in source_php');
    $this->assertSame($this->getCloudyCacheDir(), $data['CLOUDY_CACHE_DIR'], 'Assert $CLOUDY_CACHE_DIR in source_php');
    $this->assertSame($this->getCloudyPackageController(), $data['CLOUDY_PACKAGE_CONTROLLER'], 'Assert $CLOUDY_PACKAGE_CONTROLLER in source_php');
    $this->assertSame($this->getCloudyPackageConfig(), $data['CLOUDY_PACKAGE_CONFIG'], 'Assert $CLOUDY_PACKAGE_CONFIG in source_php');
    $expected_cloudy_basepath = realpath(__DIR__ . '/../t/InstallTypeCore/');
    $this->assertSame($expected_cloudy_basepath, $data['CLOUDY_BASEPATH'], 'Assert $CLOUDY_BASEPATH in source_php');
    $this->assertMatchesRegularExpression('#^[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}$#', $data['CLOUDY_RUNTIME_UUID']);
  }

  public function testCachedJSONContainsExpectedGlobals() {
    $result = $this->execCloudy('echo $CLOUDY_CONFIG_JSON');
    $this->assertNotEmpty($result);
    $data = json_decode($result, TRUE)['__cloudy'];
    $this->assertSame($this->getCloudyCoreDir(), $data['CLOUDY_CORE_DIR'], 'Assert $CLOUDY_CORE_DIR in \$CLOUDY_CONFIG_JSON');
    $this->assertSame($this->getCloudyCacheDir(), $data['CLOUDY_CACHE_DIR'], 'Assert $CLOUDY_CACHE_DIR in \$CLOUDY_CONFIG_JSON');
    $this->assertSame($this->getCloudyPackageConfig(), $data['CLOUDY_PACKAGE_CONFIG'], 'Assert $CLOUDY_PACKAGE_CONFIG in \$CLOUDY_CONFIG_JSON');
    $expected_cloudy_basepath = realpath(__DIR__ . '/../t/InstallTypeCore/');
    $this->assertSame($expected_cloudy_basepath, $data['CLOUDY_BASEPATH'], 'Assert $CLOUDY_BASEPATH in \$CLOUDY_CONFIG_JSON');
  }

  protected function setUp(): void {
    $this->bootCloudy(__DIR__ . '/../t/InstallTypeCore/config.yml');
  }

}
