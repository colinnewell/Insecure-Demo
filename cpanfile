requires "Auth::GoogleAuth"                   => "0";
requires "Bread::Board"                       => "0";
requires "CGI::Compile"                       => "0";
requires "CGI::Emulate::PSGI"                 => "0";
requires "Cpanel::JSON::XS"                   => "0";
requires "Crypt::Eksblowfish::Bcrypt"         => "0";
requires "Crypt::Sodium"                      => "0";
requires "Crypt::U2F::Server::Simple"         => "0";
requires "Dancer2"                            => "0";
requires "Dancer2::Template::Alloy"           => "0";
requires "DateTime"                           => "0";
requires "DBD::mysql"                         => "0";
requires "DBI"                                => "0";
requires "DBIx::Class::Candy"                 => "0";
requires "Digest::SHA3"                       => "0";
requires "File::ShareDir"                     => "0";
requires "HTML::FormHandler"                  => "0";
requires "Moo"                                => "0";
requires "Path::Tiny"                         => "0";
requires "Plack::Builder"                     => "0";
requires "Plack::Middleware::CSRFBlock"       => "0";
requires "Plack::Middleware::Session"         => "0";
requires "Plack::Middleware::Session::Cookie" => "0";
requires "Scalar::Util"                       => "0";
requires "SQL::Abstract::More"                => "0";
requires "Starman"                            => "0";
requires "strict"                             => "0";
requires "strictures"                         => "2";
requires "String::Compare::ConstantTime"      => "0";
requires "Template"                           => "0";
requires "Template::Alloy"                    => "0";
requires "Template::Plugin::JSON"             => "0";
requires "warnings"                           => "0";

on 'test' => sub {
    requires "ExtUtils::MakeMaker" => "0";
    requires "File::Spec"          => "0";
    requires "Test2::V0"           => "0";
    requires "Test::DBIx::Class"   => "0";
    requires "Test::mysqld"        => "0";
};

on 'test' => sub {
    recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
    requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
    requires "File::Spec" => "0";
    requires "IO::Handle" => "0";
    requires "IPC::Open3" => "0";
    requires "Test::More" => "0";
    requires "Test::Pod"  => "1.41";
    requires "blib"       => "1.01";
    requires "perl"       => "5.006";
};
