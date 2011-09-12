package twit;

use base 'Exporter';
use secrets;
use Net::Twitter;

our @EXPORT = qw( $nt );

our $nt = Net::Twitter->new(
    traits              => [qw/API::REST OAuth API::Search/],
    consumer_key        => $secrets{consumer_key},
    consumer_secret     => $secrets{consumer_secret},
    access_token        => $secrets{access_token},
    access_token_secret => $secrets{access_token_secret},
);

1;
