package Bot;
use strict;

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

sub run {
	my $self = shift;

	while (1) {
		$self->{callback}->( $self );
		sleep $self->{refresh_timeout};
	}
}

1;
