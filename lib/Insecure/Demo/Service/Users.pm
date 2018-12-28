package Insecure::Demo::Service::Users;

use Crypt::Eksblowfish::Bcrypt qw/bcrypt en_base64/;
use Crypt::Sodium;
use Digest::SHA3 qw/sha3_256_hex/;
use Encode qw/is_utf8 encode_utf8/;
use MIME::Base64;
use Moo;
use String::Compare::ConstantTime;

has cookie_key    => ( is => 'ro', required => 1 );
has dbh           => ( is => 'ro', required => 1 );
has login_secret  => ( is => 'ro', required => 1 );
has password_cost => ( is => 'ro', required => 1 );

has _settings_base => ( is => 'lazy' );

use constant { HOUR => 60 * 60, };

# 1. user
# 2. password
# 3. u2f / totp
# states

# this method has the potential to allow alternative
# auth mechanisms to be redirected to
sub user_step {
    my ( $self, $user ) = @_;

    my $nonce = crypto_stream_nonce();

    # FIXME: add an expiry time
    my $time           = time;
    my $encrypted_data = encode_base64(
        $nonce
          . crypto_secretbox( "user:$user:$time", $nonce, $self->login_secret ),
        ''
    );
    return { auth_cookie => $encrypted_data, next => 'pwd' };
}

sub get_user {
    my ( $self, $data ) = @_;

    my $bin   = decode_base64($data);
    my $nonce = substr( $bin, 0, crypto_secretbox_NONCEBYTES );
    my $ct    = substr( $bin, crypto_secretbox_NONCEBYTES );
    my $user  = crypto_secretbox_open( $ct, $nonce, $self->login_secret );
    if ( $user && $user =~ /^user:(.*):(\d+)$/ ) {

        # FIXME: check expiry
        return $1;
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

        if ( $next eq 'done' ) {
            $token_key = 'user';
            $expiry    = '+8h';
        }

        return {
            expiry    => $expiry,
            next      => $next,
            token_key => $token_key,
            token     => $self->_login_token( $id, expiry_time => HOUR ),
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

sub _login_token {
    my ( $self, $id, %args ) = @_;

    my $time = $args{time} // time + $args{expiry_time} // 0;
    return
      join( ":", $id, $time ) . ':'
      . sha3_256_hex( join( "\0", $self->cookie_key, $id, $time ) );
}

sub u2f_valid {
    my ( $self, %args ) = @_;
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
