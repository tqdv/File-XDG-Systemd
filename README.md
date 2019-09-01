# NAME

`File::XDG::Systemd` – Implementation of the systemd extension to the
XDG base directory specification

# SYNOPSIS

    # Initialization

    my $xdg = File::XDG::Systemd->new( name => app );
    # or
    use File::XDG::Systemd qw( xdg );
    my $xdg = xdg( name => app );

    # Usage
    
    $xdg->config_home;
    $xdg->data_dirs;
    $xdg->lookup_bin_file( 'foo', 'bar.txt')

# DESCRIPTION

This modules extends the implementation of [File::XDG](https://metacpan.org/pod/File::XDG) based on systemd's usage
of them.

It adds support for the directories `~/.local/bin` and `~/.local/lib`;
and for the _"new"_ environment variables `XDG_BIN_HOME`, `XDG_LIB_HOME`,
`XDG_BIN_DIRS` and `XDG_LIB_DIRS` with reasonable defaults for the latter two.

# CONSTRUCTOR

## $xdg = File::XDG::Systemd->new( %args )

Returns a new instance of a `File::XDG::Systemd` object. The named argument
`name` is mandatory and specifies the application name.

## $xdg = xdg( %args )

Convenience alias for the constructor.

# METHODS

## $xdg->bin\_home()

Returns the binary directory for the user, eg. `~/.local/bin` as a
`Path::Class` object. **Note** that this method does not return an
application-specific directory.

## $xdg->lib\_home( %args )

Returns the user-specific library directory for the application as a
`Path::Class` object.

It accepts a named argument of `arch` whose value is the
architecture-specific directory to return. Eg. `x86_64-linux-gnu` for
`~/.local/lib/x86_64-linux-gnu/app-name`.

## $xdg->bin\_dirs()

Returns the system binary directories as a :-delimited string.
This is an extension to the specification. It returns `$XDG_BIN_DIRS` and
defaults to `/bin:/usr/bin:/usr/local/bin`.

## $xdg->lib\_dirs()

Returns the system library directories as a :-delimited string.
This is an extension to the specification,
and the value defaults to `/lib:/usr/lib:/usr/local/lib`.

## $xdg->lookup\_bin\_file( 'path', 'to', 'file' )

Finds a binary file named `./path/to/file` relative to all directories
specified by `$XDG_BIN_HOME` and `$XDG_BIN_DIRS`. It fallsback to default
values for each of them if unset. Returns a `Path::Class` object.

## $xdg->lookup\_lib\_file( 'path', 'to', 'file' )

Finds a binary file named `./path/to/file` relative to all directories
specified by `$XDG_LIB_HOME` and `$XDG_LIB_DIRS`. It fallsback to default
values for each of them if unset. Returns a `Path::Class` object.

# SEE ALSO

- [systemd – file-hierarchy §Home Directory](https://www.freedesktop.org/software/systemd/man/file-hierarchy.html#Home%20Directory)
- [File::XDG](https://metacpan.org/pod/File::XDG)
- [File::Which](https://metacpan.org/pod/File::Which)

# AUTHOR

Tilwa Qendov <tilwa.qendov@gmail.com>
