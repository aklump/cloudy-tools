<!--
id: logging
tags: usage
-->

# Logging to File

There is a file logging API built in to _Cloudy_.

    [Tue Sep 11 18:16:24 PDT 2018] [debug] Using filesystem to obtain config: cloudy_config_language
    [Tue Sep 11 18:16:24 PDT 2018] [debug] Using filesystem to obtain config: cloudy_config_translate_en_exit_with_success
    [Tue Sep 11 18:16:24 PDT 2018] [debug] Using filesystem to obtain config: cloudy_config_translate_en_exit_with_failure
    [Tue Sep 11 18:16:24 PDT 2018] [debug] Using filesystem to obtain config: cloudy_config_commands_coretest_options__keys
    [Tue Sep 11 18:16:24 PDT 2018] [debug] Using filesystem to obtain config: cloudy_config_commands__keys


First you must declare the filename of the log file; this enables logging.  This is relative to your script's directory and should be placed at the top of your script before the bootstrap.
    
    LOGFILE="script.example.log"
    
    # Begin Cloudy Bootstrap
    s="${BASH_SOURCE[0]}";while ...

These functions should be self-explanatory; each one takes a single argument, which is the message.

    write_log_*
    
To log an error, e.g.,

    write_log_error "Cannot load file $filepath"    
    
The one that may require explanation is `write_log`, which takes one or two arguments.

When using two arguments the first is an arbitrary log label, which appears in place of the standard log levels from above.  You can set this to anything and that will allow you to filter your log items by that key using whatever log reader you're using.  Using _Console_ in OSX is my preference.

    write_log "alpha" "Recording a value $value"    

You may also call it like this:

    write_log "No custom label"
