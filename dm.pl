use warnings;
use strict;

use secrets;
use Bot;
use Data::Dumper;
use fullw;

my %command_map = (
    'search'    => \&search_and_follow,
    'favsearch' => \&search_and_fav,
    'follow'    => \&follow,
    'prune'     => \&prune,
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
    update_colors( $t );
    tweet_dms( $t );
}

sub tweet_dms {
    my $t   = shift;
    my @dms = $t->get_dms();

    for ( @dms ) {
        eval {
            $t->delete_dm( $_->{id} );
            print "> $_->{text}\n";
            $t->tweet( fullw( $_->{text} ) ); 
        }; $t->__handle_error() if $@;
    }
}

sub update_colors {
    my $t = shift;

    $t->{t}->update_profile_colors({
        profile_text_color           => random_color(),
        profile_link_color           => random_color(),
        profile_sidebar_fill_color   => random_color(),
        profile_sidebar_border_color => random_color(),
    });
}

sub search_and_follow {
    my $t     = shift;
    my $query = shift;

    my @results = $t->search( $query );
    my %uniq = map { $_->{from_user}, 1 } @results;

    for ( keys %uniq ) {
        $t->follow( $_ );
        print "+ $_\n";
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

sub follow {
    my $t = shift;
    my $q = shift || return;
    
    print "+ following $q\n";
    $t->follow( $q );
}

sub prune {
    my $t = shift;

    my %followers = map { $_->{id}, $_->{screen_name} } $t->followers;
    my %following = map { $_->{id}, $_->{screen_name} } $t->following;
    my @masters   = $t->masters;

    async {
        for ( keys %following ) {
            if ( not $followers{$_} and not $following{$_} ~~ @masters ) {
                $t->unfollow( $_ );
                print "- $_\n";
            }
        }
    }
}

sub ddump {
    print Data::Dumper->Dump([shift]);
}

sub random_color {
    return join( "", map { sprintf "%02x", rand(255) } (0..2) );
}
