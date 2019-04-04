package Insecure::Demo::Service::Users;

use Cpanel::JSON::XS qw/decode_json encode_json/;
use Crypt::Eksblowfish::Bcrypt qw/bcrypt en_base64/;
use Crypt::Sodium;
use Crypt::U2F::Server::Simple;
use Digest::SHA3 qw/sha3_256_hex/;
use Encode qw/is_utf8 encode_utf8/;
use MIME::Base64;
use Moo;
use String::Compare::ConstantTime;

has cookie_key    => ( is => 'ro', required => 1 );
has dbh           => ( is => 'ro', required => 1 );
has login_secret  => ( is => 'ro', required => 1 );
has password_cost => ( is => 'ro', required => 1 );
has u2f           => ( is => 'ro', required => 1 );

has _settings_base => ( is => 'lazy' );

use constant { HOUR => 60 * 60, };

# 1. user
# 2. password
# 3. u2f / totp
# states

# this method has the potential to allow alternative
# auth mechanisms to be redirected to
sub user_step {
    my ( $self, $user, %args ) = @_;

    my $nonce = crypto_stream_nonce();

    my $time = time + 2 * HOUR;
    my $data = "user:$user:$time";
    if ( $args{return_url} ) {
        $data .= ':return_url:' . $args{return_url};
    }
    my $encrypted_data = encode_base64(
        $nonce . crypto_secretbox( $data, $nonce, $self->login_secret ), '' );
    return { auth_cookie => $encrypted_data, next => 'pwd' };
}

sub get_user {
    my ( $self, $data ) = @_;

    my $bin   = decode_base64($data);
    my $nonce = substr( $bin, 0, crypto_secretbox_NONCEBYTES );
    my $ct    = substr( $bin, crypto_secretbox_NONCEBYTES );
    my $user  = crypto_secretbox_open( $ct, $nonce, $self->login_secret );
    if ( $user && $user =~ /^user:(.*):(\d+)(?::return_url:(.*))?$/ ) {
        if ( $2 > time ) {
            return ( $1, $3 );
        }
    }
    return;
}

sub user_valid {
    my ( $self, $user, $password ) = @_;

    my ( $id, $password_hash, $u2f, $totp ) = $self->dbh->selectrow_array(
        'SELECT id, password, u2f, totp FROM users WHERE username = ?',
        undef, $user );

    if (
        String::Compare::ConstantTime::equals(
            $password_hash // 'wrong',
            $self->_hash( $password, $password_hash // $self->_hash_settings )
        )
      )
    {
        my $next      = 'done';
        my $token_key = 'userid';
        my $expiry    = '1 hours';

        if ($u2f) {
            $next = 'u2f';
        }
        elsif ($totp) {
            $next = 'totp';
        }

        my $multiplier = 1;
        if ( $next eq 'done' ) {
            $token_key  = 'user';
            $expiry     = '+8h';
            $multiplier = 8;
        }

        return {
            expiry    => $expiry,
            next      => $next,
            token_key => $token_key,
            token =>
              $self->_login_token( $id, expiry_time => $multiplier * HOUR ),
        };
    }
    return { fail => 1 };
}

sub get_user_id {
    my ( $self, $token ) = @_;

    my ( $id, $time ) = split /:/, $token;
    if ( $time > time ) {
        if (
            String::Compare::ConstantTime::equals(
                $token, $self->_login_token( $id, time => $time )
            )
          )
        {
            return $id;
        }
    }
    return;
}

sub user_details {
    my ( $self, $id ) = @_;

    return unless $id =~ /\d+/ && $id > 0 && $id < 1000;

    my $users = $self->dbh->selectall_arrayref( "
        SELECT id       AS ID_ID,
               name     AS ID_NAME,
               username AS ID_USERNAME,
               admin    AS ID_ADMIN
        FROM users
        WHERE id = $id", { Slice => {} } );

    return unless $users;
    return $users->[0];
}

sub add_user {
    my ( $self, $name, $user, $password ) = @_;

    $self->dbh->do(
        'INSERT INTO users (name, username, password) VALUES (?, ?, ?);',
        undef, $name, $user, $self->_hash($password) );
}

sub edit_user {
    my ( $self, %args ) = @_;

    $self->dbh->do(
        'UPDATE users
            SET name = ?, admin = ?, username = ?
          WHERE id = ?',
        undef, $args{name}, $args{admin}, $args{username}, $args{id}
    );
}

sub user_list {
    my $self = shift;

    return $self->dbh->selectall_arrayref(
        'SELECT id, name, username
        FROM users
        ORDER BY name', { Slice => {} }
    );
}

sub _login_token {
    my ( $self, $id, %args ) = @_;

    my $time = $args{time} // time + $args{expiry_time} // 0;
    return
      join( ":", $id, $time ) . ':'
      . sha3_256_hex( join( "\0", $self->cookie_key, $id, $time ) );
}

sub u2f_valid {
    my ( $self, %args ) = @_;

    my $u2f = $self->_u2f_for_userid( user_id => $args{user_id} );
    $u2f->setChallenge( $args{challenge} );
    my $authok =
      $u2f->authenticationVerify( encode_json( $args{auth_response} ) );
}

sub get_u2f_registration_challenge {
    my ( $self, $user_id ) = shift;

    # FIXME: probably store the challenge against the user?
    return $self->u2f->registrationChallenge;
}

sub _u2f_for_userid {
    my ( $self, %args ) = @_;

    my ( $key_handle, $user_key ) =
      $self->_load_u2f_key( user_id => $args{user_id} );

    my $u2f = Crypt::U2F::Server::Simple->new(
        appId     => $self->u2f->{origin},
        origin    => $self->u2f->{origin},
        keyHandle => $key_handle,
        publicKey => $user_key,
    );
    return $u2f;
}

sub get_u2f_auth_challenge {
    my ( $self, %args ) = @_;

    my $challenge = $self->_u2f_for_userid(%args)->authenticationChallenge;
    return { challenge => decode_json($challenge) };
}

sub set_u2f_registration_challenge {
    my ( $self, %args ) = @_;

    $self->u2f->setChallenge( $args{response}{challenge} );

    # C library being used expects us to pass it json, so repackage
    # up the bits it wants.
    my $data = encode_json(
        {
            clientData       => $args{response}{clientData},
            registrationData => $args{response}{registrationData},
        }
    );
    my ( $keyHandle, $userKey ) = $self->u2f->registrationVerify($data);
    die 'Registration failed: ' . $self->u2f->lastError unless $keyHandle;
    $self->_store_u2f_key(
        key_handle => $keyHandle,
        user_key   => $userKey,
        user_id    => $args{user_id}
    );
}

sub _store_u2f_key {
    my ( $self, %args ) = @_;

    $self->dbh->do(
        'INSERT INTO u2f_keys (user_id, key_handle, user_key)
         VALUES (?, ?, ?)', undef, @args{qw/user_id key_handle user_key/}
    );
    $self->dbh->do( 'UPDATE users SET u2f = 1 WHERE id = ?',
        undef, $args{user_id} );
}

sub _load_u2f_key {
    my ( $self, %args ) = @_;

    return $self->dbh->selectrow_array(
        'SELECT key_handle, user_key FROM u2f_keys WHERE user_id = ?',
        undef, $args{user_id} );
}

sub _hash {
    my ( $self, $password, $settings_str ) = @_;

    if ( is_utf8($password) ) {
        $password = encode_utf8($password);
    }

    unless ($settings_str) {
        $settings_str = $self->_hash_settings;
    }
    return bcrypt( $password, $settings_str );
}

sub _hash_settings {
    my $self = shift;
    my $salt = randombytes_buf(16);
    return $self->_settings_base . en_base64($salt);
}

sub _build__settings_base {
    my $self = shift;

    my $cost = sprintf( "%02i", $self->password_cost );
    return '$2a$' . $cost . '$';
}

1;
