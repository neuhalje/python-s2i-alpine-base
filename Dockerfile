FROM alpine:3.7

MAINTAINER Jens Neuhalfen <neuhalje@neuhalfen.name>


ENV SUMMARY="Platform for building and running Python 3.6 applications" \
    DESCRIPTION="Python  available as container is a base platform for \
building and running various Python applications." \
    NAME="xuxxux/python-s2i-alpine-base" \
    APP_ROOT=/opt/app-root \
    # The $HOME is not set by default, but some applications needs this variable
    HOME="/opt/app-root/src" \
    S2I_SCRIPTS="/usr/libexec/s2i"

LABEL \
      name="${NAME}" \
      version="1" \
      maintainer="Jens Neuhalfen <neuhalje@neuhalfen.name>" \
      summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Python 3.6" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,python,python36,rh-python36" \
      com.redhat.component="python36-container" \
      usage="s2i build https://github.com/neuhalje/python-s2i-alpine-base --context-dir=examples/pipenv-test-app/ $NAME python-sample-app" \
      # Location of the STI scripts inside the image
      io.openshift.s2i.scripts-url="image://${S2I_SCRIPTS}"

ENV \
  # HOME is not set by default, but is needed by some applications
  PATH=${HOME}/bin:${APP_ROOT}/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:$PATH 

RUN mkdir -p ${HOME} && \
    mkdir -p /usr/libexec/s2i && \
    adduser -s /bin/sh -u 1001 -G root -h ${HOME} -S -D default && \
    chown -R 1001:0 /opt/app-root && \
    apk add --no-cache --update \
        bash python3 gnupg gpgme ca-certificates && \
    update-ca-certificates --fresh && \
    rm -rf /var/cache/apk/* && \
    pip3 install pipenv


# Copy executable utilities
COPY ./bin/ /usr/libexec/s2i/

# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path
WORKDIR ${HOME}

# - Create a Python virtual environment for use by any application to avoid
#   potential conflicts with Python packages preinstalled in the main Python
#   installation.
# - In order to drop the root user, we have to make some directories world
#   writable as OpenShift default security model is to run the container
#   under random UID.
RUN virtualenv ${APP_ROOT} && \
    chown -R 1001:0 ${APP_ROOT} && \
    ${S2I_SCRIPTS}/fix-permissions ${APP_ROOT} -P

USER 1001

CMD ["base-usage"]
