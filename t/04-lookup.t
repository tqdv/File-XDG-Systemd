use Test::More tests => 2;

use v5.20;
use File::XDG::Systemd qw< xdg >;
use File::Path qw< make_path >;
use Path::Tiny;
use File::Temp qw< tempdir >;

subtest binaries => sub {
	plan tests => 3;
	test_lookup('BIN', 'bin');
};

subtest libraries => sub {
	plan tests => 3;
	test_lookup('LIB', 'lib');
};

# Test the lookup of a file named 'foo'
# $TYPE => type of lookup in uppercase as in environment variables
# $type => type of lookup in lowercase as in the api's methods
sub test_lookup {
	my ($TYPE, $type) = @_;

	# Setup

	my $dir = tempdir(CLEANUP => 1);

	my $xdg_home = "$dir/home";
	my $dir1     = "$dir/1";
	my $dir2     = "$dir/2";
	my $dirs     = join ':', ($dir1, $dir2);

	for ($xdg_home, $dir1, $dir2) {
		make_path($_);
	}

	path($xdg_home)->child('foo')->touch;
	path($dir2    )->child('foo')->touch;

	path($dir1    )->child('bar/baz')->touchpath;

	local $ENV{"XDG_${TYPE}_HOME"} = $xdg_home;
	local $ENV{"XDG_${TYPE}_DIRS"} = $dirs;

	note("HOME = $xdg_home");
	note("DIRS = $dirs");

	my $xdg = xdg( name => 'app' );
	my $lookup = $xdg->can("lookup_${type}_file");


	# Tests

	is( $xdg->$lookup( 'foo' ), "$xdg_home/foo", 'Find file' );
	is( $xdg->$lookup( 'bar', 'baz' ), "$dir1/bar/baz",
		'Find file in subdirectory' );

	# Remove it
	path("$xdg_home/foo")->remove;

	is( $xdg->can("lookup_${type}_file")->( $xdg, 'foo' ), "$dir2/foo",
		'Find file in other directoriess' );
}
