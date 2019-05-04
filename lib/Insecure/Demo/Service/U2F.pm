package Insecure::Demo::Service::U2F;

use Cpanel::JSON::XS qw/decode_json encode_json/;
use Crypt::U2F::Server::Simple;

has origin => ( is => 'ro', required => 1 );
has users  => ( is => 'ro', required => 1 );

sub u2f_valid {
    my ( $self, %args ) = @_;

    my $u2f = $self->_u2f_for_userid( user_id => $args{user_id} );
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

    my ( $key_handle, $user_key ) =
      $self->users->load_u2f_key( user_id => $args{user_id} );

    my $u2f = Crypt::U2F::Server::Simple->new(
        appId     => $self->origin,
        origin    => $self->origin,
        keyHandle => $key_handle,
        publicKey => $user_key,
    );
    return $u2f;
}

sub get_u2f_auth_challenge {
    my ( $self, %args ) = @_;

    my $challenge = $self->_u2f_for_userid(%args)->authenticationChallenge;
    return decode_json($challenge);
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
