<!--
id: cloudy_php
tags: usage, php
-->

# PHP and Cloudy


---

@todo Beyond here needs review



## PHP Dependencies (and Composer)

[See Composer](@composer) for dependency management strategies.


### Accessing Configuration

For your PHP scripts to have access to the configuration values setup in the YAML file(s), you should decode the environment variable `CLOUDY_CONFIG_JSON`, e.g., `$config = json_decode(getenv('CLOUDY_CONFIG_JSON'), TRUE);`.
