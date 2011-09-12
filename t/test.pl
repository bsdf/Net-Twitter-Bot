use Test::More;
use Data::Dumper;


use_ok( 'Bot' );
use_ok( 'secrets' );

sub bot_callback {
    print "called back.\n";
}

sub test_command {
    print "executed test_command.\n";
}

my $bot = Bot->new(
    id                  => 'testbot',
    description         => 'desc',
    # oauth crap
    consumer_key        => $secrets{consumer_key},
    consumer_secret     => $secrets{consumer_secret},
    access_token        => $secrets{access_token},
    access_token_secret => $secrets{access_token_secret},
    # bot loop stuff
    refresh_timeout     => 60,
    callback            => \&bot_callback,
    # support for commands over dm
    commands_enabled    => 1,
    masters             => [qw/_M_A_S_T_E_R_/],
    command_map         => { test_command => \&test_command },
);

ok( defined($bot), '$bot is created' );
ok( $bot->{id} eq 'testbot', '$bot->{id}' );
ok( $bot->{description} eq 'desc', '$bot->{description}' );

ok( $bot->{commands_enabled}, '$bot->{commands_enabled}' );
ok( '_M_A_S_T_E_R_' ~~ $bot->{masters}, '$bot->{masters}' );

ok( defined($bot->{t}), 'Net::Twitter is created' );

$bot->{masters} = [qw/asdf bsdf/];
ok( 'asdf' ~~ $bot->{masters}, 'masters contains asdf' );
ok( 'bsdf' ~~ $bot->{masters}, 'masters contains bsdf' );

ok( defined($bot->{command_map}), 'testing command_map' );
ok( defined($bot->{command_map}{test_command}), '  test_command exists' );


done_testing();