use Test::More tests => 3;

use v5.20;

use File::XDG::Systemd qw< xdg >;

my $xdg = xdg( name => 'foo' );

isa_ok( $xdg, 'File::XDG' );

note('Inherited methods from File::XDG');
can_ok( $xdg, qw< config_home data_home cache_home > );
can_ok( $xdg, qw< data_dirs config_dirs > );
