# path_helper

Hard-coding strings is bad, yet you probably hard-code your `PATH`. This way is far more organised. You could even target it with your app! 

Interested? Then read on!

- [WHAT IS IT?](#what-is-it-)
- [WHAT DOES THAT DO?](#what-does-that-do-)
- [HOW DOES THE APPLE ONE WORK?](#how-does-the-apple-one-work-)
- [WHY REPLACE IT?](#why-replace-it-)
- [MORE DRAWBACKS](#more-drawbacks)
- [ALTERNATIVELY...](#alternatively---)
- [DO I NEED TO BE ON APPLE TO USE IT?](#do-i-need-to-be-on-apple-to-use-it-)
- [HOW DOES PATH_HELPER KNOW WHAT TO PUT IN THE PATH?](#how-does-path-helper-know-what-to-put-in-the-path-)
- [PER USER PATHS](#per-user-paths)
- [PRE-REQ](#pre-req)
- [WAY 1: USE THE PATHS, LUKE](#way-1--use-the-paths--luke)
- [WAY 2: PATHS.D/](#way-2--paths-d-)
- [WHY USE THE PATHS.D SUB DIRECTORY?](#why-use-the-paths-d-sub-directory)
- [ORDERING](#ordering)
- [WHY LIBRARY/PATHS/PATHS AND NOT LIBRARY/PATHS?](#why-library-paths-paths-and-not-library-paths-)
- [MAN and DYLD and C_INCLUDE and PKG_CONFIG](#man-and-dyld-and-c-include-and-pkg-config)
- [MANPATH](#manpath)
- [DYLD_FALLBACK_LIBRARY_PATH and DYLD_FALLBACK_FRAMEWORK_PATH](#dyld-fallback-library-path-and-dyld-fallback-framework-path)
- [C_INCLUDE_PATH](#c-include-path)
- [PKG_CONFIG_PATH](#pkg-config-path)
- [HOW DO I GET THIS WONDERFUL JOYFUL EVENT MAKER INTO MY LIFE? A.K.A. install instructions](#how-do-i-get-this-wonderful-joyful-event-maker-into-my-life-)
- [FOR EXAMPLE](#for-example-)
- [YOU KNOW WHAT ELSE IS HELPFUL](#you-know-what-else-is-helpful-)
- [DEVELOPMENT](#development)
- [TO GET SET UP FOR DEVELOPMENT](#to-get-set-up-for-development)
- [TO RUN THE SPECS](#to-run-the-specs)
- [SHELL IN AND HAVE A PLAY](#shell-in-and-have-a-play)
- [LICENCE](#licence)

## <a name="what-is-it-">WHAT IS IT?</a>

A replacement for Apple's `/usr/libexec/path_helper`.

## <a name="what-does-that-do-">WHAT DOES THAT DO?</a>

It helps set the PATH and MANPATH environment variables.

## <a name="how-does-the-apple-one-work-">HOW DOES THE APPLE ONE WORK?</a>

Segments of the path are defined in text files under `/etc/paths.d` and in `/etc/path`. For example, on my machine:

```shell
$ tree /etc/paths.d
/etc/paths.d
├── 10-BitKeeper
├── 10-pkgsrc
├── 15-macports
├── 20-XCode
├── MacGPG2
├── dotnet
├── dotnet-cli-tools
├── go
├── mono-commands
└── workbooks

$ cat /etc/paths /etc/paths.d/*
/usr/local/bin
/usr/local/sbin
/usr/bin
/usr/sbin
/bin
/sbin
/Applications/GPAC.app/Contents/MacOS/
/Applications/BitKeeper.app/Contents/Resources/bitkeeper
/opt/pkg/sbin
/opt/pkg/bin
/opt/local/bin
/Library/Developer/CommandLineTools/usr/bin
/usr/local/MacGPG2/bin
/usr/local/share/dotnet
~/.dotnet/tools
/usr/local/go/bin
/Library/Frameworks/Mono.framework/Versions/Current/Commands
/Applications/Xamarin Workbooks.app/Contents/SharedSupport/path-bin
/usr/local/sbin
/usr/bin
/usr/sbin
/bin
/sbin
/Applications/GPAC.app/Contents/MacOS/
```

## <a name="why-replace-it-">WHY REPLACE IT?</a>

Because Apple's one loads the system libraries to the front, take a look:

```shell
$ /usr/libexec/path_helper
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/Applications/GPAC.app/Contents/MacOS/:/usr/local/go/bin:/Library/Developer/CommandLineTools/usr/bin:<snip!>
```
  
…the rest of the items are added *after*, which means anything you add to `/etc/paths.d/` will end up after the system libraries.
  
Want your up-to-date OpenSSL installed via [Macports](https://trac.macports.org/) to be first in the PATH? 
Apple says *"too bad!"*
  
Want your much newer version of LLVM installed via [pkgsrc](https://pkgsrc.joyent.com/) to be hit first?
Apple says *"too bad!"*

Well, there are alternatives.

## <a name="more-drawbacks">MORE DRAWBACKS</a>

Where the Apple `path_helper` falls down is:

- It puts things in `/etc`, meaning you need elevated permissions to add/remove path segments.
- Being in `/etc` also makes them system wide.
- It's only for `PATH` and `MANPATH` but development and administration often need headers and libraries accessible in the same way too.
- The string it returns is designed to be `eval`'d. I know that `eval` isn't *always* evil but why not just return the `PATH` string and allow it to be set to a variable? Maybe there's more to be added.

## <a name="alternatively---">ALTERNATIVELY...</a>

This path\_helper fixes those problems and extends the concept to include other paths:
  
- `C_INCLUDE_PATH`
- `DYLD_FALLBACK_FRAMEWORK_PATH`
- `DYLD_FALLBACK_LIBRARY_PATH`
- `PKG_CONFIG_PATH`

and of course, `PATH` and `MANPATH`.

## <a name="do-i-need-to-be-on-apple-to-use-it-">DO I NEED TO BE ON APPLE TO USE IT?</a>

No, it should work on any unix-like system. It has one dependency, and that is Ruby. It should work with any system running Ruby 2.3.7 or above, as that is the version that ships with a Mac.

## <a name="how-does-path-helper-know-what-to-put-in-the-path-">HOW DOES PATH_HELPER KNOW WHAT TO PUT IN THE PATH?</a>

Apple has put paths in `/etc/paths` and further files are there for the user or apps to add under `/etc/paths.d/`. If you want to order them then prefixing a number works well, e.g.

```shell
$ tree /etc/paths.d
/etc/paths.d
├── 10-pkgsrc
└── MacGPG2
└── ImageMagick
```

The format of the file is simply a path per line, e.g.

```shell
$ cat /etc/paths.d/10-pkgsrc
/opt/pkg/bin
/opt/pkg/sbin

$ cat /etc/paths            
/usr/local/bin
/usr/local/sbin
/usr/bin
/usr/sbin
/bin
/sbin
```

The order *within* the file matters as well as the order the files are read/concatenated.

### Note: ###

The `/etc/paths` file in Apple isn't set out fully or in the order I'd want so I changed mine, you may want to do the same.


## <a name="per-user-paths">PER USER PATHS</a>

This is the bit I like best.

Apple's path\_helper doesn't help with paths that may only be applicable for a single user. This version will check the following per user directories for path info:

- `~/Library/Paths/paths.d` and
- `~/Library/Paths/paths`
- `~/.config/paths.d/` and
- `~/.config/paths`

You can use the `--setup` switch to have the path_helper set up the directory layout and files, you just have to fill them!

You can also use the tilde `~` character in a path by replacing it with the `HOME` env variable. For example, if I install Haskell and want to put it in my path I can do the following:

### <a name="pre-req">PRE-REQ</a>

```shell
path_helper --setup --no-config --no-etc
```

This would set up the `~/Library/Paths` for you, which fits a Mac very well.

```shell
path_helper --setup --no-lib --no-etc
```

You might choose this way if you're on a Mac or using Linux. It's up to you.

### <a name="way-1--use-the-paths--luke">WAY 1: USE THE PATHS, LUKE</a>

On my Mac, Haskell resides in `~/Library/Haskell`.

```shell
$ echo '~/Library/Haskell/bin' > ~/Library/Paths/paths

$ tree ~/Library/Paths 
/Users/iainb/Library/Paths
├── paths
└── paths.d

$ cat ~/Library/Paths/paths                          
~/Library/Haskell/bin
```

That puts `/Users/iainb/Library/Haskell/bin` at the front of my path and will only apply to my account's `PATH`.

### <a name="way-2--paths-d-">WAY 2: PATHS.D/</a>

```shell
$ touch ~/Library/Paths/paths.d/60-Haskell

$ tree ~/Library/Paths 
/Users/iainb/Library/Paths
├── paths
└── paths.d
    └── 60-Haskell
```

## <a name="why-use-the-paths-d-sub-directory">WHY USE THE PATHS.D SUB DIRECTORY?</a>

Perhaps if I show you my actual set up it'll become clearer:

```shell
$ tree ~/Library/Paths 
/Users/iainb/Library/Paths
├── paths
└── paths.d
    ├── 05-pkgsrc
    ├── 08-homebrew
    ├── 10-keybase
    ├── 30-oh-my-zshell
    ├── 50-ngrok
    ├── 55-Crystal-opt
    ├── 60-Crystal
    ├── 61-Opam
    ├── 62-Haskell
    ├── 63-Erlang
    ├── 63-Go
    ├── 64-Pyenv
    ├── 65-Rust
    └── 66-Antigen
```

Imagine uninstalling Haskell and wanting to remove it from the PATH - are you sure you removed all of it? All the right parts? Did you make a typo?

Imagine you've developed a tool but on install you have to get the user to manually edit their PATH, or perhaps you're going to rely on `PATH="/my/obnoxious/munging:$PATH"`?

Once you start installing various things it makes sense to keep their paths in their own file, it's easier to organise (and remove). It's also easy for apps to target this to easily add things to a path. Some apps already do this by adding to `/etc/paths.d` (although that obviously needs elevated privileges and makes things system wide, so again, per user paths are better).

## <a name="ordering">ORDERING</a>

path_helper will read files in this order:

1. `~/Library/Paths/paths.d`
2. `~/Library/Paths/paths`
3. `~/.config/paths.d`
4. `~/.config/paths`
5. `/etc/paths.d`
6. `/etc/paths`

If you don't have any of those dirs/files, they are skipped. Files within the `.d` dirs are read in file system order.

## <a name="why-library-paths-paths-and-not-library-paths-">WHY LIBRARY/PATHS/PATHS AND NOT LIBRARY/PATHS?</a>

Because this is such a useful pattern that it can be extended for headers and includes, so `~/Library/Paths/paths` is for the PATH, `~/Library/Paths/manpaths` is for the MANPATH etc.

## <a name="man-and-dyld-and-c-include-and-pkg-config">MAN and DYLD and C_INCLUDE and PKG_CONFIG</a>

### <a name="manpath">MANPATH</a>

Apple has already dictated that `/etc/manpaths` and `/etc/manpaths.d/` are the default paths for setting `MANPATH`, so the same pattern has been followed for that as with `PATH`:

- `~/Library/Paths/manpaths.d/`
- `~/Library/Paths/manpaths`
- `~/.config/manpaths.d/`
- `~/.config/manpaths`
- `/etc/manpaths.d/`
- `/etc/manpaths`

I can tell you it's a very pleasant experience typing `man blah` for the thing I just installed and getting the correct man page up.


### <a name="dyld-fallback-library-path-and-dyld-fallback-framework-path">DYLD_FALLBACK_LIBRARY_PATH and DYLD_FALLBACK_FRAMEWORK_PATH</a>

Same goes for DYLD_FALLBACK_LIBRARY_PATH and DYLD_FALLBACK_FRAMEWORK_PATH:

- `~/Library/Paths/dyld_library_paths.d/`
- `~/Library/Paths/dyld_library_paths`
- `~/.config/dyld_library_paths.d/`
- `~/.config/dyld_library_paths`
- `/etc/dyld_library_paths.d/`
- `/etc/dyld_library_paths`

and:

- `~/Library/Paths/dyld_framework_paths.d/`
- `~/Library/Paths/dyld_framework_paths`
- `~/.config/dyld_framework_paths.d/` 
- `~/.config/dyld_framework_paths` 
- `/etc/dyld_framework_paths.d/`
- `/etc/dyld_framework_paths`


### <a name="c-include-path">C_INCLUDE_PATH</a>

Same again for `C_INCLUDE_PATH`:

- `~/Library/Paths/include_paths.d/`
- `~/Library/Paths/include_paths`
- `~/.config/include_paths.d/`
- `~/.config/include_paths`
- `/etc/include_paths.d/`
- `/etc/include_paths`

### <a name="pkg-config-path">PKG_CONFIG_PATH</a>

Did you know that there's a `PKG_CONFIG_PATH`? There is, check the man page, it's very helpful.

- `~/Library/Paths/pkg_config_paths.d/`
- `~/Library/Paths/pkg_config_paths`
- `~/.config/pkg_config_paths.d/`
- `~/.config/pkg_config_paths`
- `/etc/pkg_config_paths.d/`
- `/etc/pkg_config_paths`


## <a name="how-do-i-get-this-wonderful-joyful-event-maker-into-my-life-">HOW DO I GET THIS WONDERFUL JOYFUL EVENT MAKER INTO MY LIFE?</a>

### A.K.A. install instructions

- Download it (use `git clone` or a download link, you can even just copy and past the [script](exe/path_helper))
- Make sure it has the correct permissions (`chmod +x`)
- Have a look at the help by running it with `-h`.
- Run the `--setup` (take note of the `--lib` and `--config` and their `--no-` counterparts)
- Copy and paste the bit setup tells you to, and put it in your `~/.zshenv` or `~/.bashenv`
- Find your life is so much better now it's easy to manage your paths

*It doesn't need to be in* `/usr/local/bin`, or any special place, just `chmod +x` it and call it by the full path and it'll plop out a string for you.

## <a name="for-example-">FOR EXAMPLE:</a>

You could put the path_helper in `/usr/local/libexec` and mirror the Apple set up, so that other accounts to be able to access its goodness, but you can put it anywhere you like.

```shell
sudo mkdir -p /usr/local/libexec
```

Currently I run one from `~/bin` so I don't bother with that.

```shell
mkdir ~/bin
```

Download the file then make sure it has the correct permissions:

```shell
chmod +x ~/bin/path_helper
```

Look at the help because you're not like everyone else, you read instructions ;-)

```shell
~/bin/path_helper --help
```

You need `sudo` to add the folders in `/etc`, see the `--help` if you don't want that. I don't want that, and let's say I prefer using `~/.config` to `~/Library` because I'm on a Linux system:

```shell
~/bin/path_helper --setup --no-etc --no-lib
```

See what's already there and why:

```shell
~/bin/path_helper --path --debug
```

**Note**: Apple's path_helper is in `/usr/libexec`, this install won't touch it, you can always use it or return to it if you wish.

And checking its output (debug shows you that too):

```shell
$ ~/bin/path_helper --path
    /opt/pkg/sbin:/opt/pkg/bin:/opt/X11/bin:/opt/ImageMagick/bin:/usr/local/MacGPG2/bin:/usr/local/git/bin:/opt/puppetlabs/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin"
```

To put it into the PATH via the command line:

```shell
$ PATH=$(~/bin/path_helper -p)
$ export PATH
```

but you'll probably use the helpful instructions `--setup` provides at the end of setting up:

```shell
# Put this in your ~/.bashrc or your ~/.zshenv
if [ -x /Users/$USER/Projects/path_helper/exe/path_helper ]; then
  C_INCLUDE_PATH=$(ruby /Users/$USER/Projects/path_helper/exe/path_helper -c)
  DYLD_FALLBACK_FRAMEWORK_PATH=$(ruby /Users/$USER/Projects/path_helper/exe/path_helper --dyld-fram)
  DYLD_FALLBACK_LIBRARY_PATH=$(ruby /Users/$USER/Projects/path_helper/exe/path_helper --dyld-lib)
  MANPATH=$(ruby /Users/$USER/Projects/path_helper/exe/path_helper -m)
  PKG_CONFIG_PATH=$(ruby /Users/$USER/Projects/path_helper/exe/path_helper -pc)
  PATH=$(ruby /Users/$USER/Projects/path_helper/exe/path_helper -p)
fi

export C_INCLUDE_PATH
export DYLD_FALLBACK_FRAMEWORK_PATH
export DYLD_FALLBACK_LIBRARY_PATH
export MANPATH
export PKG_CONFIG_PATH
export PATH
```

### NOTE!

Remember, it **won't set the PATH**, it *returns* a path, **you have to set the path** with it e.g. `PATH=$(/usr/local/libexec/path_helper.rb -p)`. Call `/usr/local/libexec/path_helper -h` to see all the options.

### Another NOTE!

The because the Ruby team decided to spam us with warnings about everything so quite often recently I get a lot of unhelpful stuff filling up my terminal on open. Thanks, Ruby core team!

To quieten it down change:

```shell
PATH=$(ruby /path/to/path_helper -p)
```

to:

```shell
PATH=$(ruby /path/to/path_helper -p 2>/dev/null)
```

## <a name="you-know-what-else-is-helpful-">YOU KNOW WHAT ELSE IS HELPFUL?</a>

The `--debug` flag. For example:

```shell
$ exe/path_helper -p --debug           
Name: PATH
Options: {:name=>"PATH", :current_path=>nil, :debug=>true, :verbose=>true}
Search order: [:config, :etc]
  /root/.config/paths/paths.d
  /root/.config/paths/paths
  /etc/paths.d
  /etc/paths

Results: (duplicates marked by ✗)

/root/.config/paths/paths.d/03-libiconv
 └── ~/Library/Frameworks/Libiconv.framework/Versions/Current/bin
/root/.config/paths/paths.d/04-llvm
 ├── /opt/local/libexec/llvm-11/bin
 ├── /opt/pkg/bin
 └── ~/Library/Frameworks/LLVM.framework/Programs
/root/.config/paths/paths.d/05-pkgsrc
 ├── /opt/pkg/bin ✗
 ├── /opt/pkg/sbin
 └── /opt/pkg/gnu/bin
/root/.config/paths/paths.d/10-keybase
 ├── $HOME/gopath
 └── $HOME/gopath/bin
/root/.config/paths/paths.d/30-oh-my-zshell
 └── ~/.oh-my-zsh/custom/plugins/fzf/bin
/root/.config/paths/paths.d/50-ngrok
 └── ~/Applications/ngrok
/root/.config/paths/paths.d/55-Crystal-opt
 ├── /opt/crystal/bin
 └── /opt/crystal/embedded/bin
/root/.config/paths/paths.d/60-Crystal
 ├── ~/Library/Frameworks/Crystal.framework/Versions/Current/bin
 └── ~/Library/Frameworks/Crystal.framework/Versions/Current/embedded/bin
/root/.config/paths/paths.d/61-Opam-and-OCaml
 ├── ~/Library/Frameworks/Opam.framework/Programs
 ├── ~/.opam/4.10.0/bin
 └── ~/.opam/4.10.0/sbin
/root/.config/paths/paths.d/62-Haskell
 └── ~/Library/Haskell/bin
/root/.config/paths/paths.d/63-Erlang
 └── ~/Library/Frameworks/Erlang.framework/Programs
/root/.config/paths/paths.d/63-Go
 └── ~/go/bin
/root/.config/paths/paths.d/64-Pyenv
 └── ~/.pyenv/bin
/root/.config/paths/paths.d/65-Rust
 └── ~/.cargo/bin
/root/.config/paths/paths.d/66-Antigen
 └── ~/bin
/root/.config/paths/paths.d/67-Lua
 └── ~/.lua/bin
/root/.config/paths/paths.d/68-Zig
 └── ~/Library/Frameworks/Zig.framework/Programs
/root/.config/paths/paths.d/docker-scripts
 └── ~/Projects/ThePrintedBird/scripts/docker
/root/.config/paths/paths.d/gcc
 ├── /opt/pkg/gcc7/bin
 └── /opt/pkg/gcc48/bin
/root/.config/paths/paths
 └── /opt/local/sbin
/etc/paths

Env var:
/root/Library/Frameworks/Libiconv.framework/Versions/Current/bin:/opt/local/libexec/llvm-11/bin:/opt/pkg/bin:/root/Library/Frameworks/LLVM.framework/Programs:/opt/pkg/sbin:/opt/pkg/gnu/bin:$HOME/gopath:$HOME/gopath/bin:/root/.oh-my-zsh/custom/plugins/fzf/bin:/root/Applications/ngrok:/opt/crystal/bin:/opt/crystal/embedded/bin:/root/Library/Frameworks/Crystal.framework/Versions/Current/bin:/root/Library/Frameworks/Crystal.framework/Versions/Current/embedded/bin:/root/Library/Frameworks/Opam.framework/Programs:/root/.opam/4.10.0/bin:/root/.opam/4.10.0/sbin:/root/Library/Haskell/bin:/root/Library/Frameworks/Erlang.framework/Programs:/root/go/bin:/root/.pyenv/bin:/root/.cargo/bin:/root/bin:/root/.lua/bin:/root/Library/Frameworks/Zig.framework/Programs:/root/Projects/ThePrintedBird/scripts/docker:/opt/pkg/gcc7/bin:/opt/pkg/gcc48/bin:/opt/local/sbin
```

Everything you need to know! Very useful for working out when other things are manipulating the path too.

## <a name="development">Development</a>

I'm happy to hear from you, email me or open an issue. Pull requests are fine too, try to bring me a spec or an example if you want a feature or find a bug.

### To get set up for development

Run:

```shell
packer build docker/docker.pkr.hcl
```


### <a name="to-run-the-specs">To run the specs</a>

```shell
docker run --rm yb66/path_helper:4.0.0-ph-r237
docker run --rm yb66/path_helper:4.0.0-ph-r270
```

### <a name="shell-in-and-have-a-play">Shell in and have a play</a>

```shell
docker run --rm -ti --entrypoint="" yb66/path_helper sh
```

Run some tests yourself:

```shell
./spec/shell_spec.sh
```

Set up some paths using the test fixtures:

```shell
./exe/path_helper --setup --no-lib
cp -R spec/fixtures/moredirs/* ~/.config/paths
```

Have a look at the output by running through the available paths:

```shell
./exe/path_helper -p
./exe/path_helper -c
./exe/path_helper -f
./exe/path_helper -l
./exe/path_helper -m
./exe/path_helper --pc
./exe/path_helper -p --debug
```

Add colour support to the terminal so you can see the prettiness:

```shell
apk add ncurses
./exe/path_helper -p --debug
```

You may want to have the env vars set. Run:

```shell
source ~/.ashenv
echo $PATH
echo $C_INCLUDE_PATH
# etc
```

Modify some of the path files

```shell
apk add vim
vim ~/.config/paths/paths.d/03-libiconv
vim ~/.config/paths/paths.d/01-Nim
./exe/path_helper -p
# ...
exit
```

## <a name="#licence">LICENCE</a>

See the LICENCE file.

