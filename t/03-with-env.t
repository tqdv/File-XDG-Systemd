use Test::More tests => 5;

use v5.20;

use File::XDG::Systemd qw< xdg >;

my $xdg = xdg( name => 'app' );
local $ENV{HOME} = '/home/prove';

note('With environment variables');

{
	local $ENV{XDG_BIN_HOME} = '/foo';

	is( $xdg->bin_home, '/foo', 'User XDG binary directory' );
}

{
	local $ENV{XDG_LIB_HOME} = '/foo';

	is( $xdg->lib_home, '/foo/app',
		'User application-specific XDG library directory' );

	is( $xdg->lib_home( arch => 'march' ), '/foo/march/app',
		'User application-specific XDG architecture library directory' );
}

{
	local $ENV{XDG_BIN_DIRS} = '/foo:/bar';

	is( $xdg->bin_dirs, '/foo:/bar', 'System XDG binary directories' );
}

{
	local $ENV{XDG_LIB_DIRS} = '/foo:/bar';

	is( $xdg->lib_dirs, '/foo:/bar', 'System XDG library directories' );
}
