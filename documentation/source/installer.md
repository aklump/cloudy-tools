# The Install API

If you want you may hook into the Cloudy install api, which normalizes the work of installing configuration files on and instance of your Cloudy Package.

1. Create a folder _install_ and place all files needed during installation.
1. Create a file _install/cloudypm.files_map.txt_ and define where the files go.  See below.

## The files map

This is a text file that tells what files install where.  Basically two columns, separated by a space.  The first column lists filenames in _install_.  The second column are filenames (not directories) relative to $ROOT, or absolute.

The contents of the files map must have at least one line, e.g.

    * ../../../bin/config/*

* The `*` represents all filenames in _install_.

But let's say you want one of the files to go elsewhere.  The contents of _cloudypm.files_map.txt_ might look like this:

    * ../../../bin/config/*
    _perms.custom.sh ../../../bin/_perms.custom.sh

In this case `*` represents all files except for _\_perms.custom.sh_.  They are installed as before, however _\_perms.custom.sh_ is installed at _$ROOT/../../../bin/\_perms.custom.sh_.

Remember you must indicate filenames, not directories.  And, you can rename the file by indicating a different filename in column two.

Finally let's say you want to skip over a file completely; do not include a destination for it, and it will be ignored, like this

    * ../../../bin/config/*
    _perms.custom.sh ../../../bin/_perms.custom.sh
    ignored_file.txt

## Special Handling for files named _gitignore_

If you create _install/gitignore_ (no leading dot), it will be copied to _../../../opt/.gitignore_.  (This is the recommended location by Cloudy Package Manager.)  **However, it will be merged with an existing .gitignore file, which already exists at that location.**  Do not make an entry in _cloudypm.files_map.txt_.
