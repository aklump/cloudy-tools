<!--
id: readme
tags: ''
-->

# Cloudy Tools

![Cloudy tools](../../images/cloudy_tools.jpg)

Used to manage a local version of [Cloudy](https://github.com/aklump/cloudy) providing a set of commands for installing and building Cloudy packages.

## Installation

Installation means downloading this repository to your system. It contains _cloudy_tools.sh_ which is used to generate new scripts, as well as the cloudy framework. It is a Cloudy script.

Here is a snippet to:

1. Clone this repo to a directory on your system _$HOME/opt/cloudy_
1. Create a symlink in _$HOME/bin/cloudy_. This assumes _~/bin_ is in your `$PATH` variable.

```shell
(cd $HOME && (test -d opt || mkdir opt) && (test -d bin || mkdir bin) && cd opt && (test -d cloudy || git clone https://github.com/aklump/cloudy.git) && (test -s $HOME/bin/cloudy || ln -s $HOME/opt/cloudy/cloudy_installer.sh $HOME/bin/cloudy)) && cloudy
```

