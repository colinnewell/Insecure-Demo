FROM perl:5.30

RUN apt-get update                                                       \
    && apt-get -y --no-install-recommends install default-libmysqlclient-dev libu2f-server-dev libsodium-dev

RUN cpanm Term::ReadLine::Perl Term::ReadKey DBD::mysql LWP::Protocol::https Alien::libnewrelic NewFangle && cpanm -f IPC::System::Simple DateTimeX::Easy
RUN cpanm https://github.com/cv-library/NewFangle-Agent/releases/download/0.004/NewFangle-Agent-0.004.tar.gz

ARG EXTRA_CPANM=""
WORKDIR /opt/insecure-demo

COPY cpanfile /opt/insecure-demo/cpanfile

# test but don't install test deps.
RUN cpanm --test-only --installdeps . $EXTRA_CPANM && \
    cpanm --notest --quiet --installdeps . $EXTRA_CPANM

COPY . /opt/insecure-demo

RUN groupadd -r insecure && useradd -r -d /home/insecure -g insecure insecure
USER insecure

ENV DANCER_CONFDIR=/opt/insecure-demo
CMD starman --preload-app -I /opt/insecure-demo/lib/ /opt/insecure-demo/bin/app.psgi
