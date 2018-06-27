FROM alpine:3.7

MAINTAINER Jens Neuhalfen <neuhalje@neuhalfen.name>


ENV SUMMARY="Platform for building and running Python 3.6 applications" \
    DESCRIPTION="Python  available as container is a base platform for \
building and running various Python applications." \
    NAME="xuxxux/python-s2i-alpine-base"

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Python 3.6" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,python,python36,rh-python36" \
      com.redhat.component="python36-container" \
      name="centos/python-36-centos7" \
      version="1" \
      usage="s2i build https://github.com/neuhalje/python-s2i-alpine-base --context-dir=examples/setup-test-app/ $NAME python-sample-app" \
      maintainer="Jens Neuhalfen <neuhalje@neuhalfen.name>" \
      # Location of the STI scripts inside the image
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i

ENV \
  # HOME is not set by default, but is needed by some applications
  HOME=/opt/app-root/src \
  PATH=/opt/app-root/src/bin:/opt/app-root/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:$PATH 

RUN mkdir -p ${HOME} && \
    mkdir -p /usr/libexec/s2i && \
    adduser -s /bin/sh -u 1001 -G root -h ${HOME} -S -D default && \
    chown -R 1001:0 /opt/app-root && \
    apk -U upgrade && \
    apk add --no-cache --update bash curl wget \
        tar unzip findutils git gettext gdb lsof patch \
        libcurl libxml2 libxslt openssl-dev zlib-dev \
        make automake gcc g++ binutils-gold linux-headers paxctl libgcc libstdc++ \
        python3 gnupg gpgme ncurses-libs ca-certificates && \
    update-ca-certificates --fresh && \
    rm -rf /var/cache/apk/* && \
    pip install pipenv


# Copy executable utilities
COPY ./bin/ /usr/bin/

# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path
WORKDIR ${HOME}

USER 1001

CMD ["base-usage"]
