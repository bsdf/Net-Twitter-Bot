package Bot;

use strict;
use warnings;

use Net::Twitter;

sub new {
    shift;
    my (%opts) = @_;

    my $self                     = {};
    $self->{id}                  = $opts{id};
    $self->{description}         = $opts{description};
    $self->{masters}             = $opts{masters} || [];
    $self->{consumer_key}        = $opts{consumer_key};
    $self->{consumer_secret}     = $opts{consumer_secret};
    $self->{access_token}        = $opts{access_token};
    $self->{access_token_secret} = $opts{access_token_secret};
    $self->{refresh_timeout}     = $opts{refresh_timeout} || 120;
    $self->{callback}            = $opts{callback} || sub { return; };
    $self->{commands_enabled}    = $opts{commands_enabled} || 0;
    $self->{command_map}         = $opts{command_map} || ();
    $self->{last_dm_id}          = 0;

    bless( $self );

    $self->{t}                   = $self->__get_twitter;

    return $self;
}

sub id {
    my $self = shift;
    if ( @_ ) { $self->{id} = shift }
    return $self->{id};
}

sub description {
    my $self = shift;
    if ( @_ ) { $self->{description} = shift }
    return $self->{description};
}

sub masters {
    my $self = shift;
    if (@_) { @{ $self->{masters } } = @_ }
    return @{ $self->{masters} };
}

sub commands_enabled {
    my $self = shift;
    if ( @_ ) { $self->{commands_enabled} = shift }
    return $self->{commands_enabled};
}

sub consumer_key {
    my $self = shift;
    if ( @_ ) { $self->{consumer_key} = shift; }
    return $self->{consumer_key};
}

sub consumer_secret {
    my $self = shift;
    if ( @_ ) { $self->{consumer_secret} = shift; }
    return $self->{consumer_secret};
}

sub access_token {
    my $self = shift;
    if ( @_ ) { $self->{access_token} = shift; }
    return $self->{access_token};
}

sub access_token_secret {
    my $self = shift;
    if ( @_ ) { $self->{access_token_secret} = shift; }
    return $self->{access_token_secret};
}

sub refresh_timeout {
    my $self = shift;
    if ( @_ ) { $self->{refresh_timeout} = shift; }
    return $self->{refresh_timeout};
}

sub callback {
    my $self = shift;
    if ( @_ ) { $self->{callback} = shift; }
    return $self->{callback};
}

sub command_map {
    my $self = shift;
    if ( @_ ) { %{ $self->{command_map} } = @_ }
    return %{ $self->{command_map} };
}

sub __check_auth {
    my $self = shift;
    return $self->{consumer_secret} 
    && $self->{access_token_secret};
}

sub __get_twitter {
    my $self = shift;
    return Net::Twitter->new(
        traits              => [qw/API::REST OAuth API::Search RetryOnError/],
        consumer_key        => $self->{consumer_key},
        consumer_secret     => $self->{consumer_secret},
        access_token        => $self->{access_token},
        access_token_secret => $self->{access_token_secret},
    );
}

sub run {
    my $self = shift;

    if ( $self->__check_auth ) {
        print "* $self->{id} initialized\n";

        while (1) {
            # handle commands
            if ( $self->{commands_enabled} ) {
                $self->__handle_commands;
            }

            # call callback, handle error if needed
            eval {
                $self->{callback}->( $self );
            }; __handle_error() if $@;

            # sleep til next time
            sleep $self->{refresh_timeout};
        }
    }
    else {
        print "- please set correct oauth stuff.\n";
    }
}

sub __handle_error {
    use Scalar::Util qw/blessed/;
    if ( blessed $@ && $@->isa( 'Net::Twitter::Error' ) ) {
        warn $@->error;
    }
    else {
        die $@;
    }
}

sub ddump {
    print Data::Dumper->Dump([ shift ]);
}

sub __handle_commands {
    my $self = shift;
    my @dms  = $self->get_dms( $self->{masters} );

    for my $dm ( @dms ) {
        my $txt = $dm->{text};
        if ( $txt ~~ /^(\w+)(?:\s(.*))?/ ) {
            my $cmd = $1;
            if ( $self->{command_map}->{$cmd} ) {
                print "~ executing command: $cmd\n";
                $self->delete_dm( $dm->{id} );
                $self->{command_map}->{$cmd}->( $self, $2 );
            }
        }
    }
}

sub get_dms {
    my $self      = shift;
    my @filter_by = shift if @_;
    my $t         = $self->{t};

    my @dms;
    for ( my $page = 1; ; ++$page ) {
        my $r = $t->direct_messages({
                page => $page,
#           since_id => $self->{last_dm_id},
            });

        if ( $page == 1 ) {
            $self->{last_dm_id} = $r->[0]->{id}
            if ( $r->[0] );
        }

        if ( !$r || scalar @$r == 0 ) {
            last;
        }

        if ( scalar @filter_by > 0 ) {
            my @filtered;
            for ( @$r ) {
                push @filtered, $_
                if $_->{sender_screen_name} ~~ @filter_by;
            }

            push @dms, @filtered;
        }
        else {
            push @dms, @$r;
        }
    }

    return @dms;
}

sub tweet {
    my $self = shift;
    my $text = shift;

    $self->{t}->update( $text );
}

sub delete_dm {
    my $self = shift;
    my $id   = shift;

    $self->{t}->destroy_direct_message( $id )
    if $id;
}

sub search {
    my $self  = shift;
    my $query = shift;

    my $result = $self->{t}->search( $query );

    return @{ $result->{results} };
}

sub follow {
    my $self = shift;
    my $who  = shift || return;

    $self->{t}->create_friend( $who );
}

sub unfollow {
    my $self = shift;
    my $who  = shift || return;

    $self->{t}->destroy_friend( $who );
}

sub dm {
    my $self = shift;
    my $who  = shift || return;
    my $what = shift || return;

    $self->{t}->new_direct_message( $who, $what );
}

sub retweet {
    my $self = shift;
    my $id   = shift || return;

    $self->{t}->retweet( $id );
}

sub fav {
    my $self = shift;
    my $id   = shift || return;

    $self->{t}->create_favorite( $id );
}

sub followers {
    my $self = shift;
    my $t    = $self->{t};

    my @followers;
    for ( my $cursor = -1, my $r; $cursor; $cursor = $r->{next_cursor} ) {
        $r = $t->followers({ cursor => $cursor });
        push @followers, @{ $r->{users} };
    }

    return @followers;
}

sub following {
    my $self = shift;
    my $t    = $self->{t};

    my @following;
    for ( my $cursor = -1, my $r; $cursor; $cursor = $r->{next_cursor} ) {
        $r = $t->following({ cursor => $cursor });
        push @following, @{ $r->{users} };
    }

    return @following;
}

1;
