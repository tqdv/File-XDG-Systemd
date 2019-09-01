use Test::More tests => 5;

use v5.20;

use File::XDG::Systemd qw< xdg >;

my $xdg = xdg( name => 'foo' );
local $ENV{HOME} = '/home/prove';

note('Without environment variables');

{
	local undef $ENV{XDG_BIN_HOME};

	is( $xdg->bin_home, '/home/prove/.local/bin', 'User XDG binary directory' );
}

{
	local undef $ENV{XDG_LIB_HOME};

	is ($xdg->lib_home, '/home/prove/.local/lib/foo',
		'User application-specific XDG library directory' );

	is( $xdg->lib_home( arch => 'march' ), '/home/prove/.local/lib/march/foo',
		'User application-specific XDG architecture library directory' );
}

{
	local undef $ENV{XDG_BIN_DIRS};

	is( $xdg->bin_dirs, '/usr/local/bin:/usr/bin:/bin',
		'System XDG binary directories' );
}

{
	local undef $ENV{XDG_LIB_DIRS};

	is( $xdg->lib_dirs, '/usr/local/lib:/usr/lib:/lib',
		'System XDG library directories' );
}
