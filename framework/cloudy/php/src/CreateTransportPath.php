<?php

namespace AKlump\Cloudy;

class CreateTransportPath {

  /**
   * Creates a transport path based on the cache directory and runtime UUID.
   *
   * @param string $cache_dir The cache directory.
   * @param string $runtime_uuid The runtime UUID.
   *
   * @return string The transport path that will contain the BASH code, which
   * when sourced sets the BASH variables to the value put there by PHP.
   */
  public function __invoke(string $cache_dir, string $runtime_uuid): string {
    return $cache_dir . '/_runtime_vars.' . $runtime_uuid . '.sh';
  }

}
