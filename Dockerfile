FROM perl:5.28

RUN apt-get update                                                       \
    && apt-get -y --no-install-recommends install default-libmysqlclient-dev libu2f-server-dev libsodium-dev

RUN cpanm DBD::mysql && cpanm -f IPC::System::Simple

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
