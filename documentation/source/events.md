# Events

* Event handlers are functions that must be defined before the Cloudy bootstrap.

        #!/usr/bin/env bash
        
        ...
        
        #
        # Define all event handlers here.
        #
        
        # Begin Cloudy Bootstrap
        s="${BASH_SOURCE[0]}";while ...

* To see the available events look at _framework/cloudy.events.sh_.

## on_boot

If you define this function before the bootstrap it will be called once the minimum bootstrap has been called.  To see an example of this you can look to the `tests` path in _cloudy_installer.sh_.
