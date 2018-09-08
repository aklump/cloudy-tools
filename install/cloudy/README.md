# Cloudy

![cloudy](images/screenshot.jpg)

## Summary

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ac blandit risus. Mauris tempor a lacus a placerat. Vivamus viverra dapibus metus non finibus. Nulla ultricies est nulla, eget efficitur nibh viverra non. Sed sed est viverra nunc malesuada venenatis vitae at tellus. Suspendisse potenti. Morbi non blandit elit, sit amet consectetur mi.

**Visit <https://aklump.github.io/cloudy> for full documentation.**

## Quick Start

## Requirements

* alpha
* bravo

## Contributing

If you find this project useful... please consider [making a donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4E5KZHDQCEUV8&item_name=Gratitude%20for%20aklump%2Fcloudy).

## Installation

Add the following to the top of any shell script in which you wish to use _Cloudy_.

    source="${BASH_SOURCE[0]}"
    while [ -h "$source" ]; do # resolve $source until the file is no longer a symlink
      dir="$( cd -P "$( dirname "$source" )" && pwd )"
      source="$(readlink "$source")"
      [[ $source != /* ]] && source="$dir/$source" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    ROOT="$( cd -P "$( dirname "$source" )" && pwd )"
    source "$ROOT/cloudy/cloudy.sh"

## Usage

* Learn more about BASH with the [Advanced Bash-Scripting Guide](https://www.tldp.org/LDP/abs/html/).
