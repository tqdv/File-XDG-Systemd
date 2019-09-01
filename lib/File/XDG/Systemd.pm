package File::XDG::Systemd;

=encoding utf8

=head1 NAME

C<File::XDG::Systemd> – Implementation of the systemd extension to the
XDG base directory specification

=cut

use v5.20;

use Carp;
use Exporter;

use Path::Class qw< dir file >;

use parent qw< File::XDG Exporter>;

our $VERSION = v0.040_001;
our @EXPORT_OK = qw< xdg >;


=head1 SYNOPSIS

 # Initialization

 my $xdg = File::XDG::Systemd->new( name => app );
 # or
 use File::XDG::Systemd qw( xdg );
 my $xdg = xdg( name => app );

 # Usage
 
 $xdg->config_home;
 $xdg->data_dirs;
 $xdg->lookup_bin_file( 'foo', 'bar.txt')

=head1 DESCRIPTION

This modules extends the implementation of L<File::XDG> based on systemd's usage
of them.

It adds support for the directories F<~/.local/bin> and F<~/.local/lib>;
and for the I<"new"> environment variables C<XDG_BIN_HOME>, C<XDG_LIB_HOME>,
C<XDG_BIN_DIRS> and C<XDG_LIB_DIRS> with reasonable defaults for the latter two.

=head1 CONSTRUCTOR

=head2 $xdg = File::XDG::Systemd->new( %args )

Returns a new instance of a C<File::XDG::Systemd> object. The named argument
C<name> is mandatory and specifies the application name.

=head2 $xdg = xdg( %args )

Convenience alias for the constructor.

=cut

sub new {
	my $class = shift;
	my (%args) = @_;

	my $xdg = File::XDG->new( %args );
	bless $xdg, $class;

	return $xdg;
}

sub xdg {
	return File::XDG::Systemd->new(@_);
}


sub _get_home {
	my $self = shift;
	my $home = $ENV{HOME};
	$home = File::XDG::_win if ($^O eq 'MSWin32');

	unless (defined $home) { croak 'Could not find home directory' }

	return $home;
}

sub _home {
	my $self = shift;
	my ($type, %args) = @_;

	my $home = $self->_get_home;

	my %locations = (
		bin => ($ENV{XDG_BIN_HOME} // "$home/.local/bin"),
		lib => ($ENV{XDG_LIB_HOME} // "$home/.local/lib"),
	);

	my $dir;
	$dir = $locations{$type} if exists $locations{$type};

	if ($type eq 'lib' && exists $args{arch}) {
		$dir .= '/' . $args{arch};
	}

	return $dir if defined $dir;
	
	return File::XDG::_home(@_);
}

sub _dirs {
	my $self = shift;
	my ($type) = @_;

	my %locations = (
		bin => ($ENV{XDG_BIN_DIRS} // '/usr/local/bin:/usr/bin:/bin'),
		lib => ($ENV{XDG_LIB_DIRS} // '/usr/local/lib:/usr/lib:/lib'),
	);

	my $dirs;
	$dirs = $locations{$type} if exists $locations{$type};

	return $dirs if defined $dirs;

	return File::XDG::_dirs(@_);
}

sub _lookup_file {
	my $self = shift;
	my ($type, @subpath) = @_;

	unless (@subpath) { croak 'subpath not specified' }

    my @dirs = ($self->_home($type), split(':', $self->_dirs($type)));
    my @paths = map { file($_, @subpath) } @dirs;
    my ($match) = grep { -f $_ } @paths;

    return $match;
}


=head1 METHODS

=head2 $xdg->bin_home()

Returns the binary directory for the user, eg. C<~/.local/bin> as a
C<Path::Class> object. B<Note> that this method does not return an
application-specific directory.

=head2 $xdg->lib_home( %args )

Returns the user-specific library directory for the application as a
C<Path::Class> object.

It accepts a named argument of C<arch> whose value is the
architecture-specific directory to return. Eg. C<x86_64-linux-gnu> for
C<~/.local/lib/x86_64-linux-gnu/app-name>.

=cut

sub bin_home {
	my $self = shift;

	my $dir = $self->_home('bin');
	return dir($dir);
}

sub lib_home {
	my $self = shift;
	my (%args) = @_;

	my $dir = $self->_home('lib', %args);

	return dir($dir, $self->{name});
}

=head2 $xdg->bin_dirs()

Returns the system binary directories as a :-delimited string.
This is an extension to the specification. It returns C<$XDG_BIN_DIRS> and
defaults to C</bin:/usr/bin:/usr/local/bin>.

=head2 $xdg->lib_dirs()

Returns the system library directories as a :-delimited string.
This is an extension to the specification,
and the value defaults to C</lib:/usr/lib:/usr/local/lib>.

=cut

sub bin_dirs {
	my $self = shift;

	return $self->_dirs('bin');
}

sub lib_dirs {
	my $self = shift;

	return $self->_dirs('lib');
}

=head2 $xdg->lookup_bin_file( 'path', 'to', 'file' )

Finds a binary file named F<./path/to/file> relative to all directories
specified by C<$XDG_BIN_HOME> and C<$XDG_BIN_DIRS>. It fallsback to default
values for each of them if unset. Returns a C<Path::Class> object.

=head2 $xdg->lookup_lib_file( 'path', 'to', 'file' )

Finds a binary file named F<./path/to/file> relative to all directories
specified by C<$XDG_LIB_HOME> and C<$XDG_LIB_DIRS>. It fallsback to default
values for each of them if unset. Returns a C<Path::Class> object.

=cut

sub lookup_bin_file {
	my $self = shift;
	my (@subpath) = @_;

	return $self->_lookup_file('bin', @subpath);
}

sub lookup_lib_file {
	my $self = shift;
	my (@subpath) = @_;

	return $self->_lookup_file('lib', @subpath);
}


"I hope this was useful to you";
__END__


=head1 SEE ALSO

=over 4

=item L<systemd – file-hierarchy §Home Directory|https://www.freedesktop.org/software/systemd/man/file-hierarchy.html#Home%20Directory>

=item L<File::XDG>

=item L<File::Which>

=back

=head1 AUTHOR

Tilwa Qendov <tilwa.qendov@gmail.com>
