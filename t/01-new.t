use Test::More tests => 2;

use v5.20;

use Scalar::Util qw< blessed >;


{
	require File::XDG::Systemd;
	my $xdg = File::XDG::Systemd->new( name => 'test' );

	isa_ok( $xdg, 'File::XDG::Systemd', '::->new' );
}

{
	require File::XDG::Systemd;
	File::XDG::Systemd::->import( 'xdg' );

	my $xdg = xdg( name => 'test' );

	isa_ok( $xdg, 'File::XDG::Systemd', 'xdg(...)' );
}
