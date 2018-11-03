FROM perl:5.28

COPY cpanfile /opt/insecure-demo/cpanfile
WORKDIR /opt/insecure-demo

# test but don't install test deps.
ARG EXTRA_CPANM=""
RUN cpanm --test-only --installdeps . $EXTRA_CPANM && cpanm --notest --quiet --installdeps . $EXTRA_CPANM
COPY . /opt/insecure-demo

RUN groupadd -r insecure && useradd -r -d /home/insecure -g insecure insecure
USER insecure

CMD starman --preload-app -I /opt/insecure-demo/lib/ /opt/insecure-demo/bin/app.psgi
