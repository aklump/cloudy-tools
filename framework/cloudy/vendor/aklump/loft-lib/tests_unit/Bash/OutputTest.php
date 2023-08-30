<?php

namespace AKlump\LoftLib\Bash;

use PHPUnit\Framework\TestCase;

/**
 * @covers \AKlump\LoftLib\Bash\Output
 */
class OutputTest extends TestCase {

  public function testList() {
    $output = Output::tree(['do', 're', 'mi']);
    $this->assertSame("├── do\n├── re\n└── mi\n", $output);
  }

}
