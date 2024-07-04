<?php

namespace AKlump\Cloudy\Tests\Integration\TestingTraits;

use InvalidArgumentException;

/**
 * A trait for Integration testing Cloudy.
 */
trait TestWithCloudyTrait {

  private $cloudyConfig;

  private $cloudyTestDir;

  private $cloudyOutput;

  private $cloudyResultCode;

  /**
   * Load a cloudy config and set the directory for testing.
   *
   * @param string $base_config A YAML file which defines the Cloudy app.  It's
   * parent directory -- APP_ROOT -- will be used to resolve the paths to be
   * tested, and should therefore contain them.
   *
   * @return void
   */
  protected function bootCloudy(string $base_config): void {
    if (!file_exists($base_config)) {
      throw new InvalidArgumentException(sprintf('$base_config not found at: %s', $base_config));
    }
    $this->cloudyConfig = $base_config;
    $this->cloudyTestDir = dirname($base_config);
  }

  /**
   * Execute a script in a fully booted cloudy environment.
   *
   * @param string $test_script Path to the bash test file to execute; it must
   * be relative to the dirname of the $base_config.
   *
   * @return string
   *   The output from the execution.
   */
  protected function execCloudy($test_script): string {
    $test_script = $this->cloudyTestDir . "/$test_script";
    if (!file_exists($test_script)) {
      throw new InvalidArgumentException(sprintf('$test_script not found at: %s', $test_script));
    }
    $this->cloudyOutput = [];
    $this->cloudyResultCode = NULL;
    exec(sprintf(__DIR__ . '/../cloudy_bridge/test_runner.sh "%s" "%s"', $this->cloudyConfig, $test_script), $this->cloudyOutput, $this->cloudyResultCode);

    return implode(PHP_EOL, $this->cloudyOutput);
  }

  public function getCloudyResultCode(): int {
    return $this->cloudyResultCode;
  }

}
