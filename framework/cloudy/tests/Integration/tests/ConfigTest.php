<?php

namespace AKlump\Cloudy\Tests\Integration\tests;

use AKlump\Cloudy\Tests\Integration\TestingTraits\TestWithCloudyTrait;
use PHPUnit\Framework\TestCase;

/**
 * @coversNothing
 */
class ConfigTest extends TestCase {

  use TestWithCloudyTrait;

  public function testCanReadBaseConfig() {
    $output = $this->execCloudy('eval $(get_config_as "title" "title");echo $title');
    $this->assertSame('Install Type Core', $output);
  }

  public function testCanReadAdditionalConfig() {
    $output = $this->execCloudy('eval $(get_config_as "color" "color"); echo $color');
    $this->assertSame('blue', $output);
  }

  protected function setUp(): void {
    $this->bootCloudy(__DIR__ . '/../t/InstallTypeCore/config.yml');
  }

}
