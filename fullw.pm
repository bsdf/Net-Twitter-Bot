package fullw;
use base 'Exporter';
our @EXPORT = qw( fullw );

sub fullw {
	my $DELTA = 65248;
	my $str   = shift;

	return join "", map {
		if ( $_ eq " " ) {
			"\x{3000}";
		}
		else {
			chr( ord($_) + $DELTA );
		}
	} split( //, $str );
}
