<?php

namespace AKlump\Cloudy\Tests\Unit;

use AKlump\Cloudy\CreateTransportPath;
use AKlump\Cloudy\Tests\Unit\TestingTraits\TestWithFilesTrait;
use PHPUnit\Framework\TestCase;
use AKlump\Cloudy\EnvVars;

/**
 * @covers \AKlump\Cloudy\PutEnv;
 */
class EnvVarsTest extends TestCase {

  use TestWithFilesTrait;

  /**
   * @var string
   */
  protected $bashTransportPath;

  public function dataFortestCanPutAsExpectedProvider() {
    $tests = [];
    $tests[] = [
      ['foo bar', 'lorem ipsum'],
      '["foo bar","lorem ipsum"]',
      [
        ['echo ${PUT_ENV_TEST_FOO[0]}', 'foo bar'],
        ['echo ${PUT_ENV_TEST_FOO[1]}', 'lorem ipsum'],
      ],
    ];
    $tests[] = [
      ['do', 're'],
      '["do","re"]',
      [
        ['echo ${PUT_ENV_TEST_FOO[0]}', 'do'],
        ['echo ${PUT_ENV_TEST_FOO[1]}', 're'],
      ],
    ];
    $tests[] = [
      'bar',
      'bar',
      [
        ['echo $PUT_ENV_TEST_FOO', 'bar'],
      ],
    ];
    $tests[] = [
      'bar baz',
      'bar baz',
      [
        ['echo $PUT_ENV_TEST_FOO', 'bar baz'],
      ],
    ];
    $tests[] = [
      123,
      '123',
      [
        ['echo $PUT_ENV_TEST_FOO', '123'],
      ],
    ];

    return $tests;
  }

  public function testPhpWriteNestedArrayThrows() {
    $value = ['foo' => ['bar' => 1]];
    $this->expectException(\InvalidArgumentException::class);
    (new EnvVars($this->bashTransportPath))->putenv('foo', $value);
  }

  /**
   * @dataProvider dataFortestCanPutAsExpectedProvider
   */
  public function testPhpWriteReadAndBashReadWorksAsExpected($write_value, $expected_php_value, array $bash_expectations) {

    // Use PHP to write a variable to the environment.
    $envvars = new EnvVars($this->bashTransportPath);
    $envvars->putenv('PUT_ENV_TEST_FOO', $write_value);

    // Access the written variable using PHP's native getenv().
    $this->assertSame($expected_php_value, getenv('PUT_ENV_TEST_FOO'), 'Assert PHP can access the env var using native getenv().');

    // Access the written variable using \AKlump\Cloudy\EnvVars::getenv()
    $this->assertSame($write_value, $envvars->getenv('PUT_ENV_TEST_FOO'));

    $this->assertSame($expected_php_value, getenv('PUT_ENV_TEST_FOO'), 'Assert PHP can access the env var using native getenv().');

    // Access the written variable using BASH by sourcing transport script.
    foreach ($bash_expectations as $bash_expectation) {
      list($command, $expected) = $bash_expectation;
      $command = sprintf('source %s; %s', $this->bashTransportPath, $command);
      $output = [];
      exec($command, $output);
      $this->assertSame($expected, $output[0]);
    }
  }

  public function testTransportFileIsCreated() {
    $this->assertFileDoesNotExist($this->bashTransportPath, 'Assert transport file does not exist.');
    (new EnvVars($this->bashTransportPath))->putenv('PUT_ENV_TEST_FOO', 'foo');
    $this->assertFileExists($this->bashTransportPath, 'Assert transport file was created.');
  }

  protected function setUp(): void {
    $cache_dir = $this->getTestFileFilepath('cache/', TRUE);
    $runtime_uuid = (string) time();
    $this->bashTransportPath = (new CreateTransportPath())($cache_dir, $runtime_uuid);
  }

  protected function tearDown(): void {
    $this->deleteTestFile('cache/');
  }

}
