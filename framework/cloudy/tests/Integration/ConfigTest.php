<?php

namespace AKlump\Cloudy\Tests\Integration;

use AKlump\Cloudy\Tests\Integration\TestingTraits\TestWithCloudyTrait;
use PHPUnit\Framework\TestCase;

/**
 * @coversNothing
 */
class ConfigTest extends TestCase {

  use TestWithCloudyTrait;

  public function testCanReadBaseConfig() {
    $output = $this->execCloudy('TitleTest.sh');
    $this->assertSame('Foo', $output);
  }

  public function testCanReadAdditonalConfig() {
    $output = $this->execCloudy('ColorTest.sh');
    $this->assertSame('red', $output);
  }

  protected function setUp(): void {
    $this->bootCloudy(__DIR__ . '/t/ConfigTest/base.yml');
  }

}
