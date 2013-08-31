# path_helper

Simple replacement of Apple's `/usr/libexec/path_helper` using bash script which will prepare `PATH` to suit [Homebrew](http://brew.sh/) project.

## Install

Copying script to a better location:

    $ sudo make
    install -m 0755 ./path_helper /usr/local/bin

And checking it's output:

    $ time /usr/local/bin/path_helper
    PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/libexec:/opt/X11/bin:/Users/otaviof/.bin:/Users/otaviof/perl5/bin:/Users/otaviof/Go/bin"; export PATH;
    /usr/local/bin/path_helper  0.00s user 0.01s system 58% cpu 0.019 total

### ZSH

We also need to inform `ZSH` about the new `path_helper`:

    $ cat /etc/zshenv
    # system-wide environment settings for zsh(1)
    if [ -x /usr/libexec/path_helper ]; then
        eval `/usr/local/bin/path_helper`
    fi

## Source Files

The script will expect to have the following source files name convention, for example:

    $ ls -1 /etc/paths.d
    00-local
    10-base_system
    40-XQuartz
    50-otaviof
