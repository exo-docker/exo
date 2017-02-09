# Dockerizing base image for eXo Platform hosting offer with:
#
# - eXo Platform
# - Libre Office

# Build:    docker build -t exoplatform/exo .
#
# Run:      docker run -ti --rm --name=exo -p 80:8080 exoplatform/exo
#           docker run -d --name=exo -p 80:8080 exoplatform/exo

FROM       exoplatform/base-jdk:jdk8
MAINTAINER eXo Platform <docker@exoplatform.com>

# Install the needed packages
RUN apt-get -qq update && \
  apt-get -qq -y upgrade ${_APT_OPTIONS} && \
  apt-get -qq -y install ${_APT_OPTIONS} xmlstarlet && \
  apt-get -qq -y install ${_APT_OPTIONS} libreoffice-calc libreoffice-draw libreoffice-impress libreoffice-math libreoffice-writer && \
  apt-get -qq -y autoremove && \
  apt-get -qq -y clean && \
  rm -rf /var/lib/apt/lists/*

# Build Arguments and environment variables
ARG EXO_VERSION=4.3.1-CP01
# this allow to specify an eXo Platform download url
ARG DOWNLOAD_URL
# this allow to specifiy a user to download a protected binary
ARG DOWNLOAD_USER
# allow to override the list of addons to package by default
ARG ADDONS="exo-chat:1.3.0 exo-tasks:1.1.0 exo-remote-edit:1.1.0"

ENV EXO_APP_DIR     /opt/exo
ENV EXO_CONF_DIR    /etc/exo
ENV EXO_DATA_DIR    /srv/exo
ENV EXO_LOG_DIR     /var/log/exo
ENV EXO_TMP_DIR     /tmp/exo-tmp

ENV EXO_USER exo
ENV EXO_GROUP ${EXO_USER}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# (we use 999 as uid like in official Docker images)
RUN useradd --create-home -u 999 --user-group --shell /bin/bash ${EXO_USER}
# giving all rights to eXo user
RUN echo "exo   ALL = NOPASSWD: ALL" > /etc/sudoers.d/exo && chmod 440 /etc/sudoers.d/exo

# Create needed directories
RUN mkdir -p ${EXO_DATA_DIR}    && chown ${EXO_USER}:${EXO_GROUP} ${EXO_DATA_DIR} && \
    mkdir -p ${EXO_TMP_DIR}     && chown ${EXO_USER}:${EXO_GROUP} ${EXO_TMP_DIR}  && \
    mkdir -p ${EXO_LOG_DIR}     && chown ${EXO_USER}:${EXO_GROUP} ${EXO_LOG_DIR}

# Install eXo Platform
RUN if [ -n "${DOWNLOAD_USER}" ]; then PARAMS="-u ${DOWNLOAD_USER}"; fi && \
    if [ ! -n "${DOWNLOAD_URL}" ]; then \
      echo "Building an image with eXo Platform version : ${EXO_VERSION}"; \
      EXO_VERSION_SHORT=$(echo ${EXO_VERSION} | awk -F "\." '{ print $1"."$2}'); \
      DOWNLOAD_URL="https://downloads.exoplatform.org/public/releases/platform/${EXO_VERSION_SHORT}/${EXO_VERSION}/platform-${EXO_VERSION}.zip"; \
    fi && \
    curl ${PARAMS} -L -o /srv/downloads/eXo-Platform-${EXO_VERSION}.zip ${DOWNLOAD_URL} && \
    unzip -q /srv/downloads/eXo-Platform-${EXO_VERSION}.zip -d /srv/downloads/ && \
    rm -f /srv/downloads/eXo-Platform-${EXO_VERSION}.zip && \
    mv /srv/downloads/platform-${EXO_VERSION}* ${EXO_APP_DIR} && \
    chown -R ${EXO_USER}:${EXO_GROUP} ${EXO_APP_DIR} && \
    ln -s ${EXO_APP_DIR}/gatein/conf /etc/exo && \
    rm -rf ${EXO_APP_DIR}/logs && ln -s ${EXO_LOG_DIR} ${EXO_APP_DIR}/logs

# Install Docker customization file
ADD bin/setenv-docker-customize.sh ${EXO_APP_DIR}/bin/setenv-docker-customize.sh
RUN chmod 755 ${EXO_APP_DIR}/bin/setenv-docker-customize.sh && \
    chown ${EXO_USER}:${EXO_GROUP} ${EXO_APP_DIR}/bin/setenv-docker-customize.sh && \
    sed -i '/# Load custom settings/i \
\# Load custom settings for docker environment\n\
[ -r "$CATALINA_BASE/bin/setenv-docker-customize.sh" ] \
&& . "$CATALINA_BASE/bin/setenv-docker-customize.sh" \
|| echo "No Docker eXo Platform customization file : $CATALINA_BASE/bin/setenv-docker-customize.sh"\n\
' ${EXO_APP_DIR}/bin/setenv.sh && \
  grep 'setenv-docker-customize.sh' ${EXO_APP_DIR}/bin/setenv.sh

COPY bin/wait-for-it.sh /opt/wait-for-it.sh
RUN chmod 755 /opt/wait-for-it.sh && \
    chown ${EXO_USER}:${EXO_GROUP} /opt/wait-for-it.sh

USER ${EXO_USER}

RUN for a in ${ADDONS}; do echo "Installing addon $a"; /opt/exo/addon install $a; done

CMD [ "/opt/exo/start_eXo.sh" ]
