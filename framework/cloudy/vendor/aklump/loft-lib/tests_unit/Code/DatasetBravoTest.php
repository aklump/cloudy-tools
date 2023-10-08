<?php

namespace AKlump\LoftLib\Code;

use AKlump\LoftLib\Testing\DatasetTestBase;

/**
 * @covers \AKlump\LoftLib\Code\DatasetBravo
 */
class DatasetBravoTest extends DatasetTestBase {

  public function testInvalidSchemaKeyDoesntThrowOnGet() {
    $this->expectException(\Exception::class);
    $this->expectExceptionMessage('"foo" is not an accepted key in');
    DatasetBravo::dataset(['foo' => 'bar'])
      ->withContext()
      ->throwFirstProblem()
      ->get();
  }

  public function testSendingNumericKeyDoesNotThrowBecauseOurClassAllowsIt() {
    $set = [
      'integer' => 5,
      0 => [],
    ];
    $result = DatasetBravo::dataset($set)
      ->validate()
      ->throwFirstProblem()
      ->get();
    $this->assertArrayHasKey(0, $result);
    $this->assertArrayHasKey('integer', $result);
  }

  public function testSendingNumericKeyThrows() {
    $this->expectException(\Exception::class);
    DatasetBravo::dataset([
      '#integer' => 5,
      0 => [],
    ])->validate()->throwFirstProblem();
  }

  public function testThrowFirstProblemWithoutDataset() {
    $this->expectException(\Exception::class);
    $this->expectExceptionMessageMatches('/^Missing required field\: integer$/');
    $obj = DatasetBravo::dataset();
    $obj->throwFirstProblem();
  }

  public function testWithContextThrowFirstProblemIncludesDatasetAsJson() {
    $this->expectException(\Exception::class);
    $this->expectExceptionMessageMatches('{"double"\:9\.4}');
    $obj = DatasetBravo::dataset([
      'double' => 9.4,
    ]);
    $obj->withContext()->throwFirstProblem();
  }

  public function testWithContextGetProblemsIncludesDatasetAsJson() {
    $obj = DatasetBravo::dataset([
      'double' => 9.4,
    ]);
    $problems = $obj->withContext()->getProblems();
    $problem = $problems['integer'][0];
    $this->assertStringStartsWith('Missing required field: integer in', $problem);

    // Do it again and see that context is not there.
    $problems = $obj->getProblems();
    $problem = $problems['integer'][0];
    $this->assertSame('Missing required field: integer', $problem);
  }

  public function testDefaultForObjectIsStdClass() {
    $obj = DatasetBravo::dataset();
    $this->assertEquals(new \stdClass, $obj->get()['object']);
  }

  /**
   * Provides data for testDefaults.
   *
   * Enter each key and it's default value.
   */
  public static function dataForTestDefaultsProvider() {
    $tests = array();
    $tests[] = array('integer', 0);
    $tests[] = array('double', 0.0);
    $tests[] = array('float', 0.0);
    $tests[] = array('string', '');
    $tests[] = array('array', array());
    $tests[] = array('null', NULL);

    return $tests;
  }

  /**
   * Provides data for testInvalidFormatShowsProblems.
   *
   * Add some keys (string types) for with values that should not pass the
   * match().
   */
  public static function dataForTestInvalidFormatShowsProblemsProvider() {
    $tests = array();
    $tests[] = [NULL, NULL];

    return $tests;
  }

  /**
   * Provides data for testMissingKeyShowsProblem.
   *
   * List all the required keys that exist in $this->objArgs
   */
  public static function dataForTestMissingKeyShowsProblemProvider() {
    $tests = array();
    $tests[] = array('integer');

    return $tests;
  }

  public function setUp(): void {
    $this->objArgs = [
      DatasetBravo::example()->get(),
    ];
    $this->createObj();
  }

  protected function createObj() {
    list ($def) = $this->objArgs;
    $this->obj = new DatasetBravo($def);
  }
}
