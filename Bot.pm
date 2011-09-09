package Bot;

use strict;
use warnings;
use Net::Twitter;

sub new {
    shift;
    my (%opts) = @_;

    my $self                 = {};
    $self->{id}              = $opts{id};
    $self->{description}     = $opts{description};
    $self->{masters}         = $opts{masters} || [];
    $self->{consumer_secret} = $opts{consumer_secret};
    $self->{token_secret}    = $opts{token_secret};
    $self->{refresh_timeout} = $opts{refresh_timeout} || 120;
    $self->{callback}        = $opts{callback} || sub { return; };

    bless( $self );
    return $self;
}

sub id {
    my $self = shift;
    if ( @_ ) { $self->{id} = shift }
    return $self->{id};
}

sub masters {
    my $self = shift;
    if (@_) { @{ $self->{masters } } = @_ }
    return @{ $self->{masters} };
}

sub consumer_secret {
    my $self = shift;
    if ( @_ ) { $self->{consumer_secret} = shift; }
    return $self->{consumer_secret};
}

sub token_secret {
    my $self = shift;
    if ( @_ ) { $self->{token_secret} = shift; }
    return $self->{token_secret};
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

my $check_auth = sub {
    my $self = shift;
    return $self->{consumer_secret} 
        && $self->{token_secret};
};

my $get_twitter = sub {
    my $self = shift;
    return Net::Twitter->new(
        traits              => [qw/API::REST OAuth API::Search/],
        consumer_key        => "n7hBvuBoxiHD7IVXSxSkNw",
        consumer_secret     => $self->{consumer_seceret},
        access_token        => "370399244-j0ypNWfw4Ks8ccKXj2AoWA6kxn7xVRqUOt2VF2wt",
        access_token_secret => $self->{token_secret},
    );
};

sub run {
    my $self = shift;

    if ( $check_auth->( $self ) ) {
        my $t = $self->$get_twitter();

        while (1) {
            $self->{callback}->( $t );
            sleep $self->{refresh_timeout};
        }
    }
    else {
        print "[-] please set consumer_secret and token_secret\n";
    }
}

1;
