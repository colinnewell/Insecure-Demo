FROM perl:5.28

RUN apt-get update                                                       \
    && apt-get -y --no-install-recommends install default-libmysqlclient-dev

RUN cpanm DBD::mysql@4.046

ARG EXTRA_CPANM=""
WORKDIR /opt/insecure-demo

COPY cpanfile /opt/insecure-demo/cpanfile

# test but don't install test deps.
RUN cpanm --test-only --installdeps . $EXTRA_CPANM && \
    cpanm --notest --quiet --installdeps . $EXTRA_CPANM

COPY . /opt/insecure-demo

RUN groupadd -r insecure && useradd -r -d /home/insecure -g insecure insecure
USER insecure

CMD starman --preload-app -I /opt/insecure-demo/lib/ /opt/insecure-demo/bin/app.psgi
