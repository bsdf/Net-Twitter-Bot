package twit;

use base 'Exporter';
use secrets;
use Net::Twitter;

our @EXPORT = qw( $nt );

our $nt = Net::Twitter->new(
    traits              => [qw/API::REST OAuth API::Search/],
    consumer_key        => "n7hBvuBoxiHD7IVXSxSkNw",
    consumer_secret     => $secrets{consumer},
    access_token        => "370399244-j0ypNWfw4Ks8ccKXj2AoWA6kxn7xVRqUOt2VF2wt",
    access_token_secret => $secrets{access_token},
);

1;
