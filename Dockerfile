# Dockerizing base image for eXo Platform hosting offer with:
#
# - eXo Platform
# - Libre Office
# - Oracle JAI (Java Advanced Imaging) API
# - Oracle JAI (Java Advanced Imaging) Image I/O Tools
# - Oracle JAI (Java Advanced Imaging) ICC Profiles

# Build:    docker build -t exoplatform/exo .
#
# Run:      docker run -ti --rm --name=exo -p 80:8080 exoplatform/exo
#           docker run -d --name=exo -p 80:8080 exoplatform/exo

FROM  exoplatform/base-jdk:jdk8
LABEL maintainer="eXo Platform <docker@exoplatform.com>"

# Install the needed packages
RUN echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-backports main universe multiverse restricted" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main universe multiverse restricted" >> /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-security main universe multiverse restricted" >> /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-updates main universe multiverse restricted" >> /etc/apt/sources.list
RUN apt-get -qq update && \
  apt-get -qq -y upgrade ${_APT_OPTIONS} && \
  apt-get -qq -y install ${_APT_OPTIONS} xmlstarlet && \
  echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections && \
  echo "ttf-mscorefonts-installer msttcorefonts/present-mscorefonts-eula note" | debconf-set-selections && \
  apt-get -qq -y install ${_APT_OPTIONS} ttf-mscorefonts-installer && \
  apt-get -qq -y install ${_APT_OPTIONS} libreoffice-calc libreoffice-draw libreoffice-impress libreoffice-math libreoffice-writer && \
  apt-get -qq -y autoremove && \
  apt-get -qq -y clean && \
  rm -rf /var/lib/apt/lists/*
# Check if the released binary was modified and make the build fail if it is the case
RUN wget -q -O /usr/bin/yaml https://github.com/mikefarah/yaml/releases/download/1.10/yaml_linux_amd64 && \
  echo "0e24302f71a14518dcc1bcdc6ff8d7da /usr/bin/yaml" | md5sum -c - \
  || { \
    echo "ERROR: the [/usr/bin/yaml] binary downloaded from a github release was modified while is should not !!"; \
    return 1; \
  } && chmod a+x /usr/bin/yaml

# Build Arguments and environment variables
ARG EXO_VERSION=5.0.0-RC04
# this allow to specify an eXo Platform download url
ARG DOWNLOAD_URL
# this allow to specifiy a user to download a protected binary
ARG DOWNLOAD_USER
# allow to override the list of addons to package by default
ARG ADDONS="exo-jdbc-driver-mysql:1.1.0"
# Default base directory on the plf archive
ARG ARCHIVE_BASE_DIR=platform-${EXO_VERSION}-trial

ENV EXO_APP_DIR            /opt/exo
ENV EXO_CONF_DIR           /etc/exo
ENV EXO_DATA_DIR           /srv/exo
ENV EXO_SHARED_DATA_DIR    /srv/exo/shared
ENV EXO_LOG_DIR            /var/log/exo
ENV EXO_TMP_DIR            /tmp/exo-tmp

ENV EXO_USER exo
ENV EXO_GROUP ${EXO_USER}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# (we use 999 as uid like in official Docker images)
RUN useradd --create-home -u 999 --user-group --shell /bin/bash ${EXO_USER}
# giving all rights to eXo user
RUN echo "exo   ALL = NOPASSWD: ALL" > /etc/sudoers.d/exo && chmod 440 /etc/sudoers.d/exo

# Create needed directories
RUN mkdir -p ${EXO_DATA_DIR}         && chown ${EXO_USER}:${EXO_GROUP} ${EXO_DATA_DIR} && \
    mkdir -p ${EXO_SHARED_DATA_DIR}  && chown ${EXO_USER}:${EXO_GROUP} ${EXO_SHARED_DATA_DIR} && \
    mkdir -p ${EXO_TMP_DIR}          && chown ${EXO_USER}:${EXO_GROUP} ${EXO_TMP_DIR}  && \
    mkdir -p ${EXO_LOG_DIR}          && chown ${EXO_USER}:${EXO_GROUP} ${EXO_LOG_DIR}

# Install eXo Platform
RUN if [ -n "${DOWNLOAD_USER}" ]; then PARAMS="-u ${DOWNLOAD_USER}"; fi && \
    if [ ! -n "${DOWNLOAD_URL}" ]; then \
      echo "Building an image with eXo Platform version : ${EXO_VERSION}"; \
      EXO_VERSION_SHORT=$(echo ${EXO_VERSION} | awk -F "\." '{ print $1"."$2}'); \
      DOWNLOAD_URL="https://downloads.exoplatform.org/public/releases/platform/${EXO_VERSION_SHORT}/${EXO_VERSION}/platform-trial-${EXO_VERSION}.zip"; \
    fi && \
    curl ${PARAMS} -L -o /srv/downloads/eXo-Platform-${EXO_VERSION}.zip ${DOWNLOAD_URL} && \
    unzip -q /srv/downloads/eXo-Platform-${EXO_VERSION}.zip -d /srv/downloads/ && \
    rm -f /srv/downloads/eXo-Platform-${EXO_VERSION}.zip && \
    mv /srv/downloads/${ARCHIVE_BASE_DIR} ${EXO_APP_DIR} && \
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

# Install JAI (Java Advanced Imaging) API in the JVM
# We don't install the shared library because the jvm complains about stack guard disabling
# && chmod 755 /tmp/jai-*/lib/*.so \
# && mv -v /tmp/jai-*/lib/*.so "${JAVA_HOME}/jre/lib/amd64/" \
RUN wget -q --no-cookies --no-check-certificate \
  --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
  -O "/tmp/jai.tar.gz" "http://download.oracle.com/otn-pub/java/jai/1.1.2_01-fcs/jai-1_1_2_01-lib-linux-i586.tar.gz" \
  && cd "/tmp" \
  && tar --no-same-owner -xvf "/tmp/jai.tar.gz" \
  && mv -v /tmp/jai-*/lib/jai_*.jar "${JAVA_HOME}/jre/lib/ext/" \
  && mv -v /tmp/jai-*/*-jai.txt "${JAVA_HOME}/" \
  && mv -v /tmp/jai-*/UNINSTALL-jai "${JAVA_HOME}/" \
  && rm -rf /tmp/*

# Install JAI (Java Advanced Imaging) Image I/O Tools in the JVM
# We don't install the shared library because the jvm complains about stack guard disabling
# && chmod 755 /tmp/jai_imageio-*/lib/*.so \
# && mv /tmp/jai_imageio-*/lib/*.so "${JAVA_HOME}/jre/lib/amd64/" \
RUN wget -q --no-cookies --no-check-certificate \
  --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
  -O "/tmp/jai_imageio.tar.gz" "http://download.oracle.com/otn-pub/java/jai_imageio/1.0_01/jai_imageio-1_0_01-lib-linux-i586.tar.gz" \
  && cd "/tmp" \
  && tar --no-same-owner -xvf "/tmp/jai_imageio.tar.gz" \
  && mv -v /tmp/jai_imageio-*/lib/jai_*.jar "${JAVA_HOME}/jre/lib/ext/" \
  && mv -v /tmp/jai_imageio-*/*-jai_imageio.txt "${JAVA_HOME}/" \
  && mv -v /tmp/jai_imageio-*/UNINSTALL-jai_imageio "${JAVA_HOME}/" \
  && rm -rf /tmp/*

# Install JAI (Java Advanced Imaging) ICC Profiles in the JVM
RUN wget -q --no-cookies --no-check-certificate \
  --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
  -O "/tmp/jai_ccm.tar.gz" "http://download.oracle.com/otn-pub/java/jai_jaicmm/1.0/JAICMM.tar.gz" \
  && cd "/tmp" \
  && tar --no-same-owner -xvf "/tmp/jai_ccm.tar.gz" \
  && mv -v /tmp/*.pf "${JAVA_HOME}/jre/lib/cmm/" \
  && rm -rf /tmp/*

USER ${EXO_USER}

RUN for a in ${ADDONS}; do echo "Installing addon $a"; /opt/exo/addon install $a; done

CMD [ "/opt/exo/start_eXo.sh" ]
