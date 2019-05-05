package Insecure::Demo::Service::U2F;

use Cpanel::JSON::XS qw/decode_json encode_json/;
use Crypt::U2F::Server::Simple;
use Moo;

has origin => ( is => 'ro', required => 1 );
has users  => ( is => 'ro', required => 1 );

sub u2f_valid {
    my ( $self, %args ) = @_;

    my $u2f = $self->_u2f_for_userid(
        user_id => $args{user_id},
        key     => $args{auth_response}{keyHandle}
    )->{u2f};
    $u2f->setChallenge( $args{challenge} );
    my $authok =
      $u2f->authenticationVerify( encode_json( $args{auth_response} ) );
}

sub get_u2f_registration_challenge {
    my ( $self, $user_id ) = shift;

    # FIXME: perhaps store the challenge against the user?
    my $u2f = Crypt::U2F::Server::Simple->new(
        appId  => $self->origin,
        origin => $self->origin,
    );
    return $u2f->registrationChallenge;
}

sub _u2f_for_userid {
    my ( $self, %args ) = @_;

    my $keys = $self->users->load_u2f_keys(
        key     => $args{key},
        user_id => $args{user_id},
    );
    return unless $keys;
    my ($key) = @$keys;

    my $u2f = Crypt::U2F::Server::Simple->new(
        appId     => $self->origin,
        origin    => $self->origin,
        keyHandle => $key->{key_handle},
        publicKey => $key->{user_key},
    );
    die 'Unable to setup u2f: ' . Crypt::U2F::Server::Simple::lastError() unless $u2f;
    return { keys => $keys, u2f => $u2f };
}

sub get_u2f_auth_challenge {
    my ( $self, %args ) = @_;

    my $u2f_info  = $self->_u2f_for_userid(%args);
    my $u2f = $u2f_info->{u2f};
    my $challenge = $u2f->authenticationChallenge;
    die 'Unable to setup u2f: ' . $u2f->lastError()  unless $challenge;
    return { challenge => decode_json($challenge), keys => $u2f_info->{keys} };
}

sub set_u2f_registration_challenge {
    my ( $self, %args ) = @_;

    my $u2f = Crypt::U2F::Server::Simple->new(
        appId  => $self->origin,
        origin => $self->origin,
    );
    $u2f->setChallenge( $args{response}{challenge} );

    # C library being used expects us to pass it json, so repackage
    # up the bits it wants.
    my $data = encode_json(
        {
            clientData       => $args{response}{clientData},
            registrationData => $args{response}{registrationData},
        }
    );
    my ( $keyHandle, $userKey ) = $u2f->registrationVerify($data);
    die 'Registration failed: ' . $u2f->lastError unless $keyHandle;
    $self->users->store_u2f_key(
        key_handle => $keyHandle,
        user_key   => $userKey,
        user_id    => $args{user_id}
    );
}

1;
