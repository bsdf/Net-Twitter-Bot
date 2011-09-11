use warnings;
use strict;
use secrets;
use Bot;
use Data::Dumper;

my %command_map = (
    'search'    => \&search_and_follow,
    'favsearch' => \&search_and_fav,
);

my $bot = Bot->new(
    id                  => 'dmbot',
    description         => 'a bot which tweets its dms',
    # oauth crap
    consumer_key        => $secrets{consumer_key},
    consumer_secret     => $secrets{consumer_secret},
    access_token        => $secrets{access_token},
    access_token_secret => $secrets{access_token_secret},
    # bot loop stuff
    refresh_timeout     => 60,
    callback            => \&callback,
    # support for commands over dm
    commands_enabled    => 1,
    masters             => [qw/bsdf/],
    command_map         => \%command_map,
);

$bot->run();

sub callback {
    my $t = shift;
    tweet_dms( $t );
}

sub tweet_dms {
    my $t   = shift;
    my @dms = $t->get_dms();

    for ( @dms ) {
    	eval {
            $t->delete_dm( $_->{id} );
            print "> $_->{text}\n";
            $t->tweet( $_->{text} ); 
        };
    }
}

sub search_and_follow {
    my $t     = shift;
    my $query = shift;

    for ( $t->search( $query ) ) {
    	my $user = $_->{from_user};
    	print "+ $user\n";
    	$t->follow( $user );
    }
}

sub search_and_fav {
    my $t     = shift;
    my $query = shift;

    for ( $t->search( $query ) ) {
    	print "<3 $_->{text}\n";
    	$t->fav( $_->{id} );
    }
}

sub ddump {
    print Data::Dumper->Dump([shift]);
}
