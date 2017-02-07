#!/bin/bash -eu
# -----------------------------------------------------------------------------
#
# Settings customization
#
# Refer to eXo Platform Administrators Guide for more details.
# http://docs.exoplatform.com
#
# -----------------------------------------------------------------------------
# This file contains customizations related to Docker environment.
# -----------------------------------------------------------------------------

replace_in_file() {
  local _tmpFile=$(mktemp /tmp/replace.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
  mv $1 ${_tmpFile}
  sed "s|$2|$3|g" ${_tmpFile} > $1
  rm ${_tmpFile}
}

# $1 : the full line content to insert at the end of eXo configuration file
add_in_exo_configuration() {
  local EXO_CONFIG_FILE="/etc/exo/exo.properties"
  local P1="$1"
  if [ ! -f ${EXO_CONFIG_FILE} ]; then
    echo "Creating eXo configuration file [${EXO_CONFIG_FILE}]"
    touch ${EXO_CONFIG_FILE}
    if [ $? != 0 ]; then
      echo "Problem during eXo configuration file creation, startup aborted !"
      exit 1
    fi
  fi
  echo "${P1}" >> ${EXO_CONFIG_FILE}
}

# -----------------------------------------------------------------------------
# Check configuration variables and add default values when needed
# -----------------------------------------------------------------------------
set +u		# DEACTIVATE unbound variable check
[ -z "${EXO_PROXY_VHOST}" ] && EXO_PROXY_VHOST="localhost"
[ -z "${EXO_PROXY_SSL}" ] && EXO_PROXY_SSL="true"
[ -z "${EXO_DATA_DIR}" ] && EXO_DATA_DIR="/srv/exo"
[ -z "${EXO_DB_TYPE}" ] && EXO_DB_TYPE="mysql"
case "${EXO_DB_TYPE}" in
  hsqldb)
    echo "################################################################################"
    echo "# WARNING: you are using HSQLDB which is not recommanded for production purpose."
    echo "################################################################################"
    sleep 2
    ;;
  mysql)
    [ -z "${EXO_DB_NAME}" ] && EXO_DB_NAME="exo"
    [ -z "${EXO_DB_USER}" ] && EXO_DB_USER="exo"
    [ -z "${EXO_DB_PASSWORD}" ] && { echo "ERROR: you must provide a database password with EXO_DB_PASSWORD environment variable"; exit 1;}
    [ -z "${EXO_DB_HOST}" ] && EXO_DB_HOST="db"
    [ -z "${EXO_DB_PORT}" ] && EXO_DB_PORT="3306"
    [ -z "${EXO_DB_INSTALL_DRIVER}" ] && EXO_DB_INSTALL_DRIVER="true"
    ;;
  pgsql|postgres|postgresql)
    [ -z "${EXO_DB_NAME}" ] && EXO_DB_NAME="exo"
    [ -z "${EXO_DB_USER}" ] && EXO_DB_USER="exo"
    [ -z "${EXO_DB_PASSWORD}" ] && { echo "ERROR: you must provide a database password with EXO_DB_PASSWORD environment variable"; exit 1;}
    [ -z "${EXO_DB_HOST}" ] && EXO_DB_HOST="db"
    [ -z "${EXO_DB_PORT}" ] && EXO_DB_PORT="5432"
    [ -z "${EXO_DB_INSTALL_DRIVER}" ] && EXO_DB_INSTALL_DRIVER="true"
    ;;
  oracle|ora)
    [ -z "${EXO_DB_NAME}" ] && EXO_DB_NAME="exo"
    [ -z "${EXO_DB_USER}" ] && EXO_DB_USER="exo"
    [ -z "${EXO_DB_PASSWORD}" ] && { echo "ERROR: you must provide a database password with EXO_DB_PASSWORD environment variable"; exit 1;}
    [ -z "${EXO_DB_HOST}" ] && EXO_DB_HOST="db"
    [ -z "${EXO_DB_PORT}" ] && EXO_DB_PORT="1521"
    [ -z "${EXO_DB_INSTALL_DRIVER}" ] && EXO_DB_INSTALL_DRIVER="false"
    ;;
  *)
    echo "ERROR: you must provide a supported database type with EXO_DB_TYPE environment variable (current value is '${EXO_DB_TYPE}')"
    echo "ERROR: supported database types are :"
    echo "ERROR: HSQLDB     (EXO_DB_TYPE = hsqldb)"
    echo "ERROR: MySQL      (EXO_DB_TYPE = mysql) (default)"
    echo "ERROR: Postgresql (EXO_DB_TYPE = pgsql)"
    exit 1;;
esac
[ -z "${EXO_DB_POOL_INIT_SIZE}" ] && EXO_DB_POOL_INIT_SIZE="5"
[ -z "${EXO_DB_POOL_MAX_SIZE}" ] && EXO_DB_POOL_MAX_SIZE="20"

[ -z "${EXO_JMX_ENABLED}" ] && EXO_JMX_ENABLED="true"
[ -z "${EXO_JMX_RMI_REGISTRY_PORT}" ] && EXO_JMX_RMI_REGISTRY_PORT="10001"
[ -z "${EXO_JMX_RMI_SERVER_PORT}" ] && EXO_JMX_RMI_SERVER_PORT="10002"
[ -z "${EXO_JMX_RMI_SERVER_HOSTNAME}" ] && EXO_JMX_RMI_SERVER_HOSTNAME="localhost"
[ -z "${EXO_JMX_USERNAME}" ] && EXO_JMX_USERNAME="-"
[ -z "${EXO_JMX_PASSWORD}" ] && EXO_JMX_PASSWORD="-"

[ -z "${EXO_MONGO_HOST}" ] && EXO_MONGO_HOST="mongo"
[ -z "${EXO_MONGO_PORT}" ] && EXO_MONGO_PORT="27017"
[ -z "${EXO_MONGO_USERNAME}" ] && EXO_MONGO_USERNAME="-"
[ -z "${EXO_MONGO_PASSWORD}" ] && EXO_MONGO_PASSWORD="-"
[ -z "${EXO_MONGO_DB_NAME}" ] && EXO_MONGO_DB_NAME="chat"
set -u		# REACTIVATE unbound variable check

# -----------------------------------------------------------------------------
# Update some configuration files when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/exo/_done.configuration ]; then
  echo "INFO: Configuration already done! skipping this step."
else
  # Proxy configuration
  case "${EXO_PROXY_SSL}" in
    true|1)
      replace_in_file /opt/exo/conf/server.xml "address=\"0.0.0.0\"" "address=\"0.0.0.0\" scheme=\"https\" secure=\"false\" proxyPort=\"443\" proxyName=\"${EXO_PROXY_VHOST}\"";;
    *)
      replace_in_file /opt/exo/conf/server.xml "address=\"0.0.0.0\"" "address=\"0.0.0.0\" proxyName=\"${EXO_PROXY_VHOST}\"";;
  esac

  # Declare the new valve to pass the replace the proxy ip by the client ip
  replace_in_file /opt/exo/conf/server.xml "</Host>" "  <Valve className=\"org.apache.catalina.valves.RemoteIpValve\" remoteIpHeader=\"x-forwarded-for\" proxiesHeader=\"x-forwarded-by\" protocolHeader=\"x-forwarded-proto\" />\n      </Host>"

  # Database configuration
  case "${EXO_DB_TYPE}" in
    hsqldb)
      cat /opt/exo/conf/server-hsqldb.xml > /opt/exo/conf/server.xml
      ;;
    mysql)
      cat /opt/exo/conf/server-mysql.xml > /opt/exo/conf/server.xml
      replace_in_file /opt/exo/conf/server.xml "jdbc:mysql://localhost:3306/plf" "jdbc:mysql://${EXO_DB_HOST}:${EXO_DB_PORT}/${EXO_DB_NAME}"
      replace_in_file /opt/exo/conf/server.xml 'username="plf" password="plf"' 'username="'${EXO_DB_USER}'" password="'${EXO_DB_PASSWORD}'"'
      if [ "${EXO_DB_INSTALL_DRIVER}" = "true" ]; then
        ${EXO_APP_DIR}/addon install ${_ADDON_MGR_OPTIONS:-} exo-jdbc-driver-mysql --batch-mode
      else
        echo "WARNING: no database driver will be automatically installed (EXO_DB_INSTALL_DRIVER=false)."
      fi
      ;;
    pgsql|postgres|postgresql)
      cat /opt/exo/conf/server-postgres.xml > /opt/exo/conf/server.xml
      replace_in_file /opt/exo/conf/server.xml "jdbc:postgresql://localhost:5432/plf" "jdbc:postgresql://${EXO_DB_HOST}:${EXO_DB_PORT}/${EXO_DB_NAME}"
      replace_in_file /opt/exo/conf/server.xml 'username="plf" password="plf"' 'username="'${EXO_DB_USER}'" password="'${EXO_DB_PASSWORD}'"'
      if [ "${EXO_DB_INSTALL_DRIVER}" = "true" ]; then
        ${EXO_APP_DIR}/addon install ${_ADDON_MGR_OPTIONS:-} exo-jdbc-driver-postgresql --batch-mode
      else
        echo "WARNING: no database driver will be automatically installed (EXO_DB_INSTALL_DRIVER=false)."
      fi
      ;;
    oracle|ora)
      cat /opt/exo/conf/server-oracle.xml > /opt/exo/conf/server.xml
      replace_in_file /opt/exo/conf/server.xml "jdbc:oracle:thin:@localhost:1521:plf" "jdbc:oracle:thin://${EXO_DB_HOST}:${EXO_DB_PORT}/${EXO_DB_NAME}"
      replace_in_file /opt/exo/conf/server.xml 'username="plf" password="plf"' 'username="'${EXO_DB_USER}'" password="'${EXO_DB_PASSWORD}'"'
      add_in_exo_configuration "exo.jcr.datasource.dialect=org.hibernate.dialect.Oracle10gDialect"
      add_in_exo_configuration "exo.jpa.hibernate.dialect=org.hibernate.dialect.Oracle10gDialect"
      if [ "${EXO_DB_INSTALL_DRIVER}" = "true" ]; then
        ${EXO_APP_DIR}/addon install ${_ADDON_MGR_OPTIONS:-} exo-jdbc-driver-oracle --batch-mode
      else
        echo "WARNING: no database driver will be automatically installed (EXO_DB_INSTALL_DRIVER=false)."
      fi
      ;;
    *) echo "ERROR: you must provide a supported database type with EXO_DB_TYPE environment variable (current value is '${EXO_DB_TYPE}')";
      exit 1;;
  esac
  replace_in_file /opt/exo/conf/server.xml 'initialSize="5" maxActive="20"' 'initialSize="'${EXO_DB_POOL_INIT_SIZE}'" maxActive="'${EXO_DB_POOL_MAX_SIZE}'"'

  ## Remove file comments
  xmlstarlet ed -L -d "//comment()" /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (xml comments removal)"
    exit 1
  }

  ## Remove AJP connector
  xmlstarlet ed -L -d '//Connector[@protocol="AJP/1.3"]' /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (AJP connector removal)"
    exit 1
  }

  # JMX configuration
  if [ "${EXO_JMX_ENABLED}" = "true" ]; then
    # insert the listener before the "Global JNDI resources" line
    sed -i '/<!-- Global JNDI resources/i \
    <Listener className="org.apache.catalina.mbeans.JmxRemoteLifecycleListener" rmiRegistryPortPlatform="'${EXO_JMX_RMI_REGISTRY_PORT}'" rmiServerPortPlatform="'${EXO_JMX_RMI_SERVER_PORT}'" useLocalPorts="false" />\
    ' /opt/exo/conf/server.xml
    # Create the security files if required
    if [ "${EXO_JMX_USERNAME:-}" != "-" ]; then
      if [ "${EXO_JMX_PASSWORD:-}" = "-" ]; then
        EXO_JMX_PASSWORD="$(tr -dc '[:alnum:]' < /dev/urandom  | dd bs=2 count=6 2>/dev/null)"
      fi
    # /opt/exo/conf/jmxremote.password
    echo "${EXO_JMX_USERNAME} ${EXO_JMX_PASSWORD}" > /opt/exo/conf/jmxremote.password
    # /opt/exo/conf/jmxremote.access
    echo "${EXO_JMX_USERNAME} readwrite" > /opt/exo/conf/jmxremote.access
    fi
  fi

  # Mongodb configuration (for the Chat)
  add_in_exo_configuration "# eXo Chat mongodb configuration"
  add_in_exo_configuration "chat.dbServerHost=${EXO_MONGO_HOST}"
  add_in_exo_configuration "chat.dbServerPort=${EXO_MONGO_PORT}"
  add_in_exo_configuration "chat.dbName=${EXO_MONGO_DB_NAME}"
  if [ "${EXO_MONGO_USERNAME:-}" = "-" ]; then
    add_in_exo_configuration "chat.dbAuthentication=false"
    add_in_exo_configuration "#chat.dbUser="
    add_in_exo_configuration "#chat.dbPassword="
  else
    add_in_exo_configuration "chat.dbAuthentication=true"
    add_in_exo_configuration "chat.dbUser=${EXO_MONGO_USERNAME}"
    add_in_exo_configuration "chat.dbPassword=${EXO_MONGO_PASSWORD}"
  fi

  # eXo Chat configuration
  add_in_exo_configuration "# eXo Chat server configuration"
  # The password to access REST service on the eXo Chat server.
  add_in_exo_configuration "chat.chatPassPhrase=something2change"
  # The notifications are cleaned up every one hour by default.
  add_in_exo_configuration "chat.chatCronNotifCleanup=0 0/60 * * * ?"
  # The eXo group who can create teams.
  add_in_exo_configuration "chat.teamAdminGroup=/platform/users"
  # When a user reads a chat, the application displays messages of some days in the past.
  add_in_exo_configuration "chat.chatReadDays=30"
  # The number of messages that you can get in the Chat room.
  add_in_exo_configuration "chatReadTotalJson=200"
  # We must override this to remain inside the docker container (works only for embedded chat server)
  add_in_exo_configuration "chat.chatServerBase=http://localhost:8080"

  add_in_exo_configuration "# eXo Chat client configuration"
  # Time interval to refresh messages in a chat.
  add_in_exo_configuration "chat.chatIntervalChat=3000"
  # Time interval to keep a chat session alive in milliseconds.
  add_in_exo_configuration "chat.chatIntervalSession=60000"
  # Time interval to refresh user status in milliseconds.
  add_in_exo_configuration "chat.chatIntervalStatus=20000"
  # Time interval to refresh Notifications in the main menu in milliseconds.
  add_in_exo_configuration "chat.chatIntervalNotif=3000"
  # Time interval to refresh Users list in milliseconds.
  add_in_exo_configuration "chat.chatIntervalUsers=5000"
  # Time after which a token will be invalid. The use will then be considered offline.
  add_in_exo_configuration "chat.chatTokenValidity=30000"

  # put a file to avoid doing the configuration twice
  touch /opt/exo/_done.configuration
fi

# -----------------------------------------------------------------------------
# Install add-ons if needed when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/exo/_done.addons ]; then
  echo "INFO: add-ons installation already done! skipping this step."
else
  echo "# ------------------------------------ #"
  echo "# eXo add-ons installation start ..."
  echo "# ------------------------------------ #"

  if [ ! -z "${EXO_ADDONS_CATALOG_URL:-}" ]; then
    echo "The add-on manager catalog url was overriden with : ${EXO_ADDONS_CATALOG_URL}"
    _ADDON_MGR_OPTIONS="--catalog=${EXO_ADDONS_CATALOG_URL}"
  fi

  if [ -z "${EXO_ADDONS_LIST:-}" ]; then
    echo "# no add-on to install from EXO_ADDONS_LIST environment variable."
  else
    echo "# installing add-ons from EXO_ADDONS_LIST environment variable:"
    echo ${EXO_ADDONS_LIST} | tr ',' '\n' | while read _addon ; do
      # Install addon
      ${EXO_APP_DIR}/addon install ${_ADDON_MGR_OPTIONS:-} ${_addon} --force --batch-mode
      if [ $? != 0 ]; then
        echo "Problem during add-on install, startup aborted !"
        exit 1
      fi
    done
  fi
  echo "# ------------------------------------ #"
  if [ -f "/etc/exo/addons-list.conf" ]; then
    echo "# installing add-ons from /etc/exo/addons-list.conf file:"
    _addons_list="/etc/exo/addons-list.conf"
    while read -r _addon; do
      # Don't read empty lines
      [ -z "${_addon}" ] && continue
      # Don't read comments
      [ "$(echo "$_addon" | awk  '{ string=substr($0, 1, 1); print string; }' )" = '#' ] && continue
      # Install addon
      ${EXO_APP_DIR}/addon install ${_ADDON_MGR_OPTIONS:-} ${_addon} --force --batch-mode
      if [ $? != 0 ]; then
        echo "Problem during add-on install, startup aborted !"
        exit 1
      fi
    done < "$_addons_list"
  else
    echo "# no add-on to install from addons-list.conf because /etc/exo/addons-list.conf file is absent."
  fi
  echo "# ------------------------------------ #"
  echo "# eXo add-ons installation done."
  echo "# ------------------------------------ #"

  # put a file to avoid doing the configuration twice
  touch /opt/exo/_done.addons
fi

# -----------------------------------------------------------------------------
# Change chat add-on security token at each start
# -----------------------------------------------------------------------------
if [ -f /etc/exo/exo.properties ]; then
  sed -i 's/^chat.chatPassPhrase=.*$/chat.chatPassPhrase='"$(tr -dc '[:alnum:]' < /dev/urandom  | dd bs=4 count=6 2>/dev/null)"'/' /etc/exo/exo.properties
fi

# -----------------------------------------------------------------------------
# Define a better place for eXo Platform license file
# -----------------------------------------------------------------------------
CATALINA_OPTS="${CATALINA_OPTS:-} -Dexo.license.path=/etc/exo/license.xml"

# JMX configuration
if [ "${EXO_JMX_ENABLED}" = "true" ]; then
  CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote=true"
  CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
  CATALINA_OPTS="${CATALINA_OPTS} -Djava.rmi.server.hostname=${EXO_JMX_RMI_SERVER_HOSTNAME}"
  if [ "${EXO_JMX_USERNAME:-}" = "-" ]; then
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
  else
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.authenticate=true"
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.password.file=/opt/exo/conf/jmxremote.password"
    CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.management.jmxremote.access.file=/opt/exo/conf/jmxremote.access"
  fi
fi

# -----------------------------------------------------------------------------
# Create the DATA directory if needed
# -----------------------------------------------------------------------------
if [ ! -d "${EXO_DATA_DIR}" ]; then
  mkdir -p "${EXO_DATA_DIR}"
fi

# Change the device for antropy generation
CATALINA_OPTS="${CATALINA_OPTS:-} -Djava.security.egd=file:/dev/./urandom"

# Wait for database availability
case "${EXO_DB_TYPE}" in
  mysql)
    echo "Waiting for database ${EXO_DB_TYPE} availability at ${EXO_DB_HOST}:${EXO_DB_PORT} ..."
    /opt/wait-for-it.sh ${EXO_DB_HOST}:${EXO_DB_PORT} -s -t 60
    ;;
  pgsql|postgres|postgresql)
    echo "Waiting for database ${EXO_DB_TYPE} availability at ${EXO_DB_HOST}:${EXO_DB_PORT} ..."
    /opt/wait-for-it.sh ${EXO_DB_HOST}:${EXO_DB_PORT} -s -t 60
    ;;
  oracle|ora)
    echo "Waiting for database ${EXO_DB_TYPE} availability at ${EXO_DB_HOST}:${EXO_DB_PORT} ..."
    /opt/wait-for-it.sh ${EXO_DB_HOST}:${EXO_DB_PORT} -s -t 60
    ;;
esac

# Wait for mongodb availability (if chat is installed)
if [ -f /opt/exo/addons/statuses/exo-chat.status ]; then
  echo "Waiting for mongodb availability at ${EXO_MONGO_HOST}:${EXO_MONGO_PORT} ..."
  /opt/wait-for-it.sh ${EXO_MONGO_HOST}:${EXO_MONGO_PORT} -s -t 60
fi

set +u		# DEACTIVATE unbound variable check
