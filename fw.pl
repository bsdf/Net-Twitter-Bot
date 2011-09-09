use strict;
use warnings;
use secrets;

my %config = (
    id              => "jjjjj",
    description     => "a test bot.",
    masters         => [qw/bsdf/],
    consumer_secret => $secrets{consumer},
    token_secret    => $secrets{access_token},

    refresh_timeout => 120,
    callback        => \&callback,
);

my $bot = construct( \%config );

$bot->();

sub callback {
    my $bot = shift;
    print "$bot->{id}\n";
}

sub construct {
    my $opts = shift;
    return sub {
        while (1) {
            $opts->{callback}->( $opts );
            sleep $opts->{refresh_timeout};
        }
    };
}
