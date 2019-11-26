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
  local EXO_CONFIG_FILE="/etc/exo/docker.properties"
  local P1="$1"
  if [ ! -f ${EXO_CONFIG_FILE} ]; then
    echo "Creating eXo Docker configuration file [${EXO_CONFIG_FILE}]"
    touch ${EXO_CONFIG_FILE}
    if [ $? != 0 ]; then
      echo "Problem during eXo Docker configuration file creation, startup aborted !"
      exit 1
    fi
  fi
  # Ensure the content will be added on a new line
  tail -c1 ${EXO_CONFIG_FILE}  | read -r _ || echo >> ${EXO_CONFIG_FILE}
  echo "${P1}" >> ${EXO_CONFIG_FILE}
}

# $1 : the full line content to insert at the end of Chat configuration file
add_in_chat_configuration() {
  local _CONFIG_FILE="/etc/exo/chat.properties"
  local P1="$1"
  if [ ! -f ${_CONFIG_FILE} ]; then
    echo "Creating Chat configuration file [${_CONFIG_FILE}]"
    touch ${_CONFIG_FILE}
    if [ $? != 0 ]; then
      echo "Problem during Chat configuration file creation, startup aborted !"
      exit 1
    fi
  fi
  echo "${P1}" >> ${_CONFIG_FILE}
}

# -----------------------------------------------------------------------------
# Check configuration variables and add default values when needed
# -----------------------------------------------------------------------------
set +u		# DEACTIVATE unbound variable check

# revert Tomcat umask change (before Tomcat 8.5 = 0022 / starting from Tomcat 8.5 = 0027)
# see https://tomcat.apache.org/tomcat-8.5-doc/changelog.html#Tomcat_8.5.0_(markt)
[ -z "${EXO_FILE_UMASK}" ] && UMASK="0022" || UMASK="${EXO_FILE_UMASK}" 

[ -z "${EXO_PROXY_VHOST}" ] && EXO_PROXY_VHOST="localhost"
[ -z "${EXO_PROXY_SSL}" ] && EXO_PROXY_SSL="true"
[ -z "${EXO_PROXY_PORT}" ] && {
  case "${EXO_PROXY_SSL}" in 
    true) EXO_PROXY_PORT="443";;
    false) EXO_PROXY_PORT="80";;
    *) EXO_PROXY_PORT="80";;
  esac
}
[ -z "${EXO_DATA_DIR}" ] && EXO_DATA_DIR="/srv/exo"
[ -z "${EXO_JCR_STORAGE_DIR}" ] && EXO_JCR_STORAGE_DIR="${EXO_DATA_DIR}/jcr/values"
[ -z "${EXO_FILE_STORAGE_DIR}" ] && EXO_FILE_STORAGE_DIR="${EXO_DATA_DIR}/files"
[ -z "${EXO_FILE_STORAGE_RETENTION}" ] && EXO_FILE_STORAGE_RETENTION="30"

[ -z "${EXO_DB_TIMEOUT}" ] && EXO_DB_TIMEOUT="60"
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
    [ -z "${EXO_DB_MYSQL_USE_SSL}" ] && EXO_DB_MYSQL_USE_SSL="false"
    ;;
  pgsql|postgres|postgresql)
    [ -z "${EXO_DB_NAME}" ] && EXO_DB_NAME="exo"
    [ -z "${EXO_DB_USER}" ] && EXO_DB_USER="exo"
    [ -z "${EXO_DB_PASSWORD}" ] && { echo "ERROR: you must provide a database password with EXO_DB_PASSWORD environment variable"; exit 1;}
    [ -z "${EXO_DB_HOST}" ] && EXO_DB_HOST="db"
    [ -z "${EXO_DB_PORT}" ] && EXO_DB_PORT="5432"
    ;;
  *)
    echo "ERROR: you must provide a supported database type with EXO_DB_TYPE environment variable (current value is '${EXO_DB_TYPE}')"
    echo "ERROR: supported database types are :"
    echo "ERROR: HSQLDB     (EXO_DB_TYPE = hsqldb)"
    echo "ERROR: MySQL      (EXO_DB_TYPE = mysql) (default)"
    echo "ERROR: Postgresql (EXO_DB_TYPE = pgsql)"
    exit 1;;
esac
[ -z "${EXO_DB_POOL_IDM_INIT_SIZE}" ] && EXO_DB_POOL_IDM_INIT_SIZE="5"
[ -z "${EXO_DB_POOL_IDM_MAX_SIZE}" ] && EXO_DB_POOL_IDM_MAX_SIZE="20"
[ -z "${EXO_DB_POOL_JCR_INIT_SIZE}" ] && EXO_DB_POOL_JCR_INIT_SIZE="5"
[ -z "${EXO_DB_POOL_JCR_MAX_SIZE}" ] && EXO_DB_POOL_JCR_MAX_SIZE="20"
[ -z "${EXO_DB_POOL_JPA_INIT_SIZE}" ] && EXO_DB_POOL_JPA_INIT_SIZE="5"
[ -z "${EXO_DB_POOL_JPA_MAX_SIZE}" ] && EXO_DB_POOL_JPA_MAX_SIZE="20"

[ -z "${EXO_UPLOAD_MAX_FILE_SIZE}" ] && EXO_UPLOAD_MAX_FILE_SIZE="200"

[ -z "${EXO_HTTP_THREAD_MIN}" ] && EXO_HTTP_THREAD_MIN="10"
[ -z "${EXO_HTTP_THREAD_MAX}" ] && EXO_HTTP_THREAD_MAX="200"

[ -z "${EXO_MAIL_FROM}" ] && EXO_MAIL_FROM="noreply@exoplatform.com"
[ -z "${EXO_MAIL_SMTP_HOST}" ] && EXO_MAIL_SMTP_HOST="localhost"
[ -z "${EXO_MAIL_SMTP_PORT}" ] && EXO_MAIL_SMTP_PORT="25"
[ -z "${EXO_MAIL_SMTP_STARTTLS}" ] && EXO_MAIL_SMTP_STARTTLS="false"
[ -z "${EXO_MAIL_SMTP_USERNAME}" ] && EXO_MAIL_SMTP_USERNAME="-"
[ -z "${EXO_MAIL_SMTP_PASSWORD}" ] && EXO_MAIL_SMTP_PASSWORD="-"

[ -z "${EXO_JVM_LOG_GC_ENABLED}" ] && EXO_JVM_LOG_GC_ENABLED="false"

[ -z "${EXO_JMX_ENABLED}" ] && EXO_JMX_ENABLED="true"
[ -z "${EXO_JMX_RMI_REGISTRY_PORT}" ] && EXO_JMX_RMI_REGISTRY_PORT="10001"
[ -z "${EXO_JMX_RMI_SERVER_PORT}" ] && EXO_JMX_RMI_SERVER_PORT="10002"
[ -z "${EXO_JMX_RMI_SERVER_HOSTNAME}" ] && EXO_JMX_RMI_SERVER_HOSTNAME="localhost"
[ -z "${EXO_JMX_USERNAME}" ] && EXO_JMX_USERNAME="-"
[ -z "${EXO_JMX_PASSWORD}" ] && EXO_JMX_PASSWORD="-"

[ -z "${EXO_ACCESS_LOG_ENABLED}" ] && EXO_ACCESS_LOG_ENABLED="false"

[ -z "${EXO_MONGO_TIMEOUT}" ] && EXO_MONGO_TIMEOUT="60"
[ -z "${EXO_MONGO_HOST}" ] && EXO_MONGO_HOST="mongo"
[ -z "${EXO_MONGO_PORT}" ] && EXO_MONGO_PORT="27017"
[ -z "${EXO_MONGO_USERNAME}" ] && EXO_MONGO_USERNAME="-"
[ -z "${EXO_MONGO_PASSWORD}" ] && EXO_MONGO_PASSWORD="-"
[ -z "${EXO_MONGO_DB_NAME}" ] && EXO_MONGO_DB_NAME="chat"

[ -z "${EXO_CHAT_SERVER_STANDALONE}" ] && EXO_CHAT_SERVER_STANDALONE="false"
[ -z "${EXO_CHAT_SERVER_URL}" ] && EXO_CHAT_SERVER_URL="http://localhost:8080"
[ -z "${EXO_CHAT_SERVER_PASSPHRASE}" ] && EXO_CHAT_SERVER_PASSPHRASE="something2change"

[ -z "${EXO_ES_EMBEDDED}" ] && EXO_ES_EMBEDDED="true"
[ -z "${EXO_ES_TIMEOUT}" ] && EXO_ES_TIMEOUT="60"
[ -z "${EXO_ES_EMBEDDED_DATA}" ] && EXO_ES_EMBEDDED_DATA="/srv/exo/es"
[ -z "${EXO_ES_SCHEME}" ] && EXO_ES_SCHEME="http"
[ -z "${EXO_ES_HOST}" ] && EXO_ES_HOST="localhost"
[ -z "${EXO_ES_PORT}" ] && EXO_ES_PORT="9200"
EXO_ES_URL="${EXO_ES_SCHEME}://${EXO_ES_HOST}:${EXO_ES_PORT}"
[ -z "${EXO_ES_USERNAME}" ] && EXO_ES_USERNAME="-"
[ -z "${EXO_ES_PASSWORD}" ] && EXO_ES_PASSWORD="-"
[ -z "${EXO_ES_INDEX_REPLICA_NB}" ] && EXO_ES_INDEX_REPLICA_NB="1"
[ -z "${EXO_ES_INDEX_SHARD_NB}" ] && EXO_ES_INDEX_SHARD_NB="5"

[ -z "${EXO_LDAP_POOL_TIMEOUT}" ] && EXO_LDAP_POOL_TIMEOUT="60000"
[ -z "${EXO_LDAP_POOL_MAX_SIZE}" ] && EXO_LDAP_POOL_MAX_SIZE="100"

[ -z "${EXO_JODCONVERTER_PORTS}" ] && EXO_JODCONVERTER_PORTS="2002"

[ -z "${EXO_REGISTRATION}" ] && EXO_REGISTRATION="true"

[ -z "${EXO_CLUSTER}" ] && EXO_CLUSTER="false"
[ -z "${EXO_CLUSTER_NODE_NAME}" ] && EXO_CLUSTER_NODE_NAME="${HOSTNAME}"
[ -z "${EXO_CLUSTER_HOSTS}" ] && EXO_CLUSTER_HOSTS="-"
[ -z "${EXO_JGROUPS_ADDR}" ] && EXO_JGROUPS_ADDR="GLOBAL"
[ -z "${EXO_JGROUPS_JCR_PORT}" ] && EXO_JGROUPS_JCR_PORT="7800"
[ -z "${EXO_JGROUPS_SERVICE_PORT}" ] && EXO_JGROUPS_SERVICE_PORT="7900"

[ -z "${EXO_PROFILES}" ] && EXO_PROFILES="all"

set -u		# REACTIVATE unbound variable check

# -----------------------------------------------------------------------------
# Update some configuration files when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/exo/_done.configuration ]; then
  echo "INFO: Configuration already done! skipping this step."
else

  if [ ! -z "${EXO_ADDONS_CATALOG_URL:-}" ]; then
    echo "The add-on manager catalog url was overriden with : ${EXO_ADDONS_CATALOG_URL}"
    _ADDON_MGR_OPTION_CATALOG="--catalog=${EXO_ADDONS_CATALOG_URL}"
  fi

  if [ ! -z "${EXO_PATCHES_CATALOG_URL:-}" ]; then
    echo "The add-on manager patches catalog url was defined with : ${EXO_PATCHES_CATALOG_URL}"
    _ADDON_MGR_OPTION_PATCHES_CATALOG="--catalog=${EXO_PATCHES_CATALOG_URL}"
  fi

  # Jcr storage configuration
  add_in_exo_configuration "exo.jcr.storage.data.dir=${EXO_JCR_STORAGE_DIR}"

  # File storage configuration
  add_in_exo_configuration "# File storage configuration"
  add_in_exo_configuration "exo.files.binaries.storage.type=fs"
  add_in_exo_configuration "exo.files.storage.dir=${EXO_FILE_STORAGE_DIR}"
  add_in_exo_configuration "exo.commons.FileStorageCleanJob.retention-time=${EXO_FILE_STORAGE_RETENTION}"

  # Database configuration
  case "${EXO_DB_TYPE}" in
    hsqldb)
      cat /opt/exo/conf/server-hsqldb.xml > /opt/exo/conf/server.xml
      ;;
    mysql)
      cat /opt/exo/conf/server-mysql.xml > /opt/exo/conf/server.xml
      replace_in_file /opt/exo/conf/server.xml "jdbc:mysql://localhost:3306/plf?autoReconnect=true" "jdbc:mysql://${EXO_DB_HOST}:${EXO_DB_PORT}/${EXO_DB_NAME}?autoReconnect=true\&amp;useSSL=${EXO_DB_MYSQL_USE_SSL}"
      replace_in_file /opt/exo/conf/server.xml 'username="plf" password="plf"' 'username="'${EXO_DB_USER}'" password="'${EXO_DB_PASSWORD}'"'
      ;;
    pgsql|postgres|postgresql)
      cat /opt/exo/conf/server-postgres.xml > /opt/exo/conf/server.xml
      replace_in_file /opt/exo/conf/server.xml "jdbc:postgresql://localhost:5432/plf" "jdbc:postgresql://${EXO_DB_HOST}:${EXO_DB_PORT}/${EXO_DB_NAME}"
      replace_in_file /opt/exo/conf/server.xml 'username="plf" password="plf"' 'username="'${EXO_DB_USER}'" password="'${EXO_DB_PASSWORD}'"'
      ;;
    *) echo "ERROR: you must provide a supported database type with EXO_DB_TYPE environment variable (current value is '${EXO_DB_TYPE}')";
      exit 1;;
  esac

  ## Remove file comments
  xmlstarlet ed -L -d "//comment()" /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (xml comments removal)"
    exit 1
  }

  # Update IDM datasource settings
  xmlstarlet ed -L -u "/Server/GlobalNamingResources/Resource[@name='exo-idm_portal']/@initialSize" -v "${EXO_DB_POOL_IDM_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-idm_portal']/@maxActive" -v "${EXO_DB_POOL_IDM_MAX_SIZE}" \
    /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (configuring datasource exo-idm_portal)"
    exit 1
  }

  # Update JCR datasource settings
  xmlstarlet ed -L -u "/Server/GlobalNamingResources/Resource[@name='exo-jcr_portal']/@initialSize" -v "${EXO_DB_POOL_JCR_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-jcr_portal']/@maxActive" -v "${EXO_DB_POOL_JCR_MAX_SIZE}" \
    /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (configuring datasource exo-jcr_portal)"
    exit 1
  }

  # Update JPA datasource settings
  xmlstarlet ed -L -u "/Server/GlobalNamingResources/Resource[@name='exo-jpa_portal']/@initialSize" -v "${EXO_DB_POOL_JPA_INIT_SIZE}" \
    -u "/Server/GlobalNamingResources/Resource[@name='exo-jpa_portal']/@maxActive" -v "${EXO_DB_POOL_JPA_MAX_SIZE}" \
    /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (configuring datasource exo-jpa_portal)"
    exit 1
  }

  ## Remove AJP connector
  xmlstarlet ed -L -d '//Connector[@protocol="AJP/1.3"]' /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (AJP connector removal)"
    exit 1
  }

  # Proxy configuration
  xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "proxyName" -v "${EXO_PROXY_VHOST}" /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (adding Connector proxyName)"
    exit 1
  }

  if [ "${EXO_PROXY_SSL}" = "true" ]; then
    xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "scheme" -v "https" \
      -s "/Server/Service/Connector" -t attr -n "secure" -v "false" \
      -s "/Server/Service/Connector" -t attr -n "proxyPort" -v "${EXO_PROXY_PORT}" \
      /opt/exo/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (configuring Connector proxy ssl)"
      exit 1
    }
    if [ "${EXO_PROXY_PORT}" = "443" ]; then
      add_in_exo_configuration "exo.base.url=https://${EXO_PROXY_VHOST}"
    else
      add_in_exo_configuration "exo.base.url=https://${EXO_PROXY_VHOST}:${EXO_PROXY_PORT}"
    fi
  else
    xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "scheme" -v "http" \
      -s "/Server/Service/Connector" -t attr -n "secure" -v "false" \
      -s "/Server/Service/Connector" -t attr -n "proxyPort" -v "${EXO_PROXY_PORT}" \
      /opt/exo/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (configuring Connector proxy)"
      exit 1
    }
    if [ "${EXO_PROXY_PORT}" = "80" ]; then
      add_in_exo_configuration "exo.base.url=http://${EXO_PROXY_VHOST}"
    else
      add_in_exo_configuration "exo.base.url=http://${EXO_PROXY_VHOST}:${EXO_PROXY_PORT}"
    fi
  fi

  # Upload size
  add_in_exo_configuration "exo.ecms.connector.drives.uploadLimit=${EXO_UPLOAD_MAX_FILE_SIZE}"

  # Tomcat HTTP Thread pool configuration
  xmlstarlet ed -L -s "/Server/Service/Connector" -t attr -n "maxThreads" -v "${EXO_HTTP_THREAD_MAX}" \
    -s "/Server/Service/Connector" -t attr -n "minSpareThreads" -v "${EXO_HTTP_THREAD_MIN}" \
    /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (adding Connector proxyName)"
    exit 1
  }

  # Tomcat valves and listeners configuration
  if [ -e /etc/exo/host.yml ]; then
    echo "Override default valves and listeners configuration"

    # Remove the default configuration
    xmlstarlet ed -L -d "/Server/Service/Engine/Host/Valve" \
        -d "/Server/Service/Engine/Host/Listener" \
        /opt/exo/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (Remove default host configuration)"
      exit 1
    }

    i=0
    while [ $i -ge 0 ]; do
      # Declare component
      type=$(yq read /etc/exo/host.yml components[$i].type)
      if [ "${type}" != "null" ]; then
        className=$(yq read /etc/exo/host.yml components[$i].className)
        echo "Declare ${type} ${className}"
        xmlstarlet ed -L -s "/Server/Service/Engine/Host" -t elem -n "${type}TMP" -v "" \
            -i "//${type}TMP" -t attr -n "className" -v "${className}" \
            /opt/exo/conf/server.xml || {
          echo "ERROR during xmlstarlet processing (adding ${className})"
          exit 1
        }

        # Add component attributes
        j=0
        while [ $j -ge 0 ]; do
          attributeName=$(yq read /etc/exo/host.yml components[$i].attributes[$j].name)
          if [ "${attributeName}" != "null" ]; then
            attributeValue=$(yq read /etc/exo/host.yml components[$i].attributes[$j].value | tr -d "'")
            xmlstarlet ed -L -i "//${type}TMP" -t attr -n "${attributeName}" -v "${attributeValue}" \
                /opt/exo/conf/server.xml || {
              echo "ERROR during xmlstarlet processing (adding ${className} / ${attributeName})"
            }

            j=$(($j + 1))
          else
            j=-1
          fi
        done

        # Rename the component to its final type
        xmlstarlet ed -L -r "//${type}TMP" -v "${type}" \
            /opt/exo/conf/server.xml || {
          echo "ERROR during xmlstarlet processing (renaming ${type}TMP)"
          exit 1
        }

        i=$(($i + 1))
      else
        i=-1
      fi
    done
  fi

  # Add a new valve to replace the proxy ip by the client ip (just before the end of Host)
  xmlstarlet ed -L -s "/Server/Service/Engine/Host" -t elem -n "ValveTMP" -v "" \
  -i "//ValveTMP" -t attr -n "className" -v "org.apache.catalina.valves.RemoteIpValve" \
  -i "//ValveTMP" -t attr -n "remoteIpHeader" -v "x-forwarded-for" \
  -i "//ValveTMP" -t attr -n "proxiesHeader" -v "x-forwarded-by" \
  -i "//ValveTMP" -t attr -n "protocolHeader" -v "x-forwarded-proto" \
  -r "//ValveTMP" -v Valve \
  /opt/exo/conf/server.xml || {
    echo "ERROR during xmlstarlet processing (adding RemoteIpValve)"
    exit 1
  }

  # Mail configuration
  add_in_exo_configuration "# Mail configuration"
  add_in_exo_configuration "exo.email.smtp.from=${EXO_MAIL_FROM}"
  add_in_exo_configuration "exo.email.smtp.host=${EXO_MAIL_SMTP_HOST}"
  add_in_exo_configuration "exo.email.smtp.port=${EXO_MAIL_SMTP_PORT}"
  add_in_exo_configuration "exo.email.smtp.starttls.enable=${EXO_MAIL_SMTP_STARTTLS}"
  if [ "${EXO_MAIL_SMTP_USERNAME:-}" = "-" ]; then
    add_in_exo_configuration "exo.email.smtp.auth=false"
    add_in_exo_configuration "#exo.email.smtp.username="
    add_in_exo_configuration "#exo.email.smtp.password="
  else
    add_in_exo_configuration "exo.email.smtp.auth=true"
    add_in_exo_configuration "exo.email.smtp.username=${EXO_MAIL_SMTP_USERNAME}"
    add_in_exo_configuration "exo.email.smtp.password=${EXO_MAIL_SMTP_PASSWORD}"
  fi
  add_in_exo_configuration "exo.email.smtp.socketFactory.port="
  add_in_exo_configuration "exo.email.smtp.socketFactory.class="

  # Cluster configuration
  if [ "${EXO_CLUSTER}" = "true" ]; then
    add_in_exo_configuration "exo.cluster.node.name=${EXO_CLUSTER_NODE_NAME}"
    JCR_CLUSTER_HOSTS=""
    SERVICE_CLUSTER_HOSTS=""
    COMETD_CLUSTER_HOSTS=""

    for cluster_host in $(echo ${EXO_CLUSTER_HOSTS} | tr ',' ' '); do
      JCR_CLUSTER_HOSTS="${JCR_CLUSTER_HOSTS}${cluster_host}[${EXO_JGROUPS_JCR_PORT}],"
      SERVICE_CLUSTER_HOSTS="${SERVICE_CLUSTER_HOSTS}${cluster_host}[${EXO_JGROUPS_SERVICE_PORT}],"
      COMETD_CLUSTER_HOSTS="${COMETD_CLUSTER_HOSTS}http://${cluster_host}:8080/cometd/cometd,"
    done

    # JGROUPS properties
    add_in_exo_configuration "exo.jcr.cluster.jgroups.tcpping.initial_hosts=${JCR_CLUSTER_HOSTS}"
    add_in_exo_configuration "exo.jcr.cluster.jgroups.tcp.bind_addr=${EXO_JGROUPS_ADDR}"
    add_in_exo_configuration "exo.jcr.cluster.jgroups.tcp.bind_port=${EXO_JGROUPS_JCR_PORT}"

    add_in_exo_configuration "exo.service.cluster.jgroups.tcpping.initial_hosts=${SERVICE_CLUSTER_HOSTS}"
    add_in_exo_configuration "exo.service.cluster.jgroups.tcp.bind_addr=${EXO_JGROUPS_ADDR}"
    add_in_exo_configuration "exo.service.cluster.jgroups.tcp.bind_port=${EXO_JGROUPS_SERVICE_PORT}"

    # WebSocket configuration
    add_in_exo_configuration "exo.cometd.oort.url=http://${EXO_CLUSTER_NODE_NAME}:8080/cometd/cometd"
    add_in_exo_configuration "exo.cometd.oort.configType=static"
    add_in_exo_configuration "exo.cometd.oort.cloud=${COMETD_CLUSTER_HOSTS}"

    # JCR configuration
    add_in_exo_configuration "gatein.jcr.config.type=cluster"
    # TODO allow to customize this
    add_in_exo_configuration "gatein.jcr.index.changefilterclass=org.exoplatform.services.jcr.impl.core.query.ispn.LocalIndexChangesFilter"

  fi

  # JMX configuration
  if [ "${EXO_JMX_ENABLED}" = "true" ]; then
    # insert the listener before the "Global JNDI resources" line
    xmlstarlet ed -L -i "/Server/GlobalNamingResources" -t elem -n ListenerTMP -v "" \
      -i "//ListenerTMP" -t attr -n "className" -v "org.apache.catalina.mbeans.JmxRemoteLifecycleListener" \
      -i "//ListenerTMP" -t attr -n "rmiRegistryPortPlatform" -v "${EXO_JMX_RMI_REGISTRY_PORT}" \
      -i "//ListenerTMP" -t attr -n "rmiServerPortPlatform" -v "${EXO_JMX_RMI_SERVER_PORT}" \
      -i "//ListenerTMP" -t attr -n "useLocalPorts" -v "false" \
      -r "//ListenerTMP" -v "Listener" \
      /opt/exo/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (adding JmxRemoteLifecycleListener)"
      exit 1
    }
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

  # Access log configuration
  if [ "${EXO_ACCESS_LOG_ENABLED}" = "true" ]; then
    # Add a new valve (just before the end of Host)
    xmlstarlet ed -L -s "/Server/Service/Engine/Host" -t elem -n "ValveTMP" -v "" \
      -i "//ValveTMP" -t attr -n "className" -v "org.apache.catalina.valves.AccessLogValve" \
      -i "//ValveTMP" -t attr -n "pattern" -v "combined" \
      -i "//ValveTMP" -t attr -n "directory" -v "logs" \
      -i "//ValveTMP" -t attr -n "prefix" -v "access" \
      -i "//ValveTMP" -t attr -n "suffix" -v ".log" \
      -i "//ValveTMP" -t attr -n "rotatable" -v "true" \
      -i "//ValveTMP" -t attr -n "renameOnRotate" -v "true" \
      -i "//ValveTMP" -t attr -n "fileDateFormat" -v ".yyyy-MM-dd" \
      -r "//ValveTMP" -v Valve \
      /opt/exo/conf/server.xml || {
      echo "ERROR during xmlstarlet processing (adding AccessLogValve)"
      exit 1
    }
  fi

  # Elasticsearch configuration
  add_in_exo_configuration "# Elasticsearch configuration"
  add_in_exo_configuration "exo.es.embedded.enabled=${EXO_ES_EMBEDDED}"
  if [ "${EXO_ES_EMBEDDED}" = "true" ]; then
    add_in_exo_configuration "es.network.host=0.0.0.0" # we listen on all IPs inside the container
    add_in_exo_configuration "es.discovery.zen.ping.multicast.enabled=false"
    add_in_exo_configuration "es.http.port=${EXO_ES_PORT}"
    add_in_exo_configuration "es.path.data=${EXO_ES_EMBEDDED_DATA}"
  else
    # Remove eXo ES Embedded add-on
    EXO_ADDONS_REMOVE_LIST="${EXO_ADDONS_REMOVE_LIST:-},exo-es-embedded"
  fi

  add_in_exo_configuration "exo.es.search.server.url=${EXO_ES_URL}"
  add_in_exo_configuration "exo.es.index.server.url=${EXO_ES_URL}"

  if [ "${EXO_ES_USERNAME:-}" != "-" ]; then
    add_in_exo_configuration "exo.es.index.server.username=${EXO_ES_USERNAME}"
    add_in_exo_configuration "exo.es.index.server.password=${EXO_ES_PASSWORD}"
    add_in_exo_configuration "exo.es.search.server.username=${EXO_ES_USERNAME}"
    add_in_exo_configuration "exo.es.search.server.password=${EXO_ES_PASSWORD}"
  else
    add_in_exo_configuration "#exo.es.index.server.username="
    add_in_exo_configuration "#exo.es.index.server.password="
    add_in_exo_configuration "#exo.es.search.server.username="
    add_in_exo_configuration "#exo.es.search.server.password="
  fi

  add_in_exo_configuration "exo.es.indexing.replica.number.default=${EXO_ES_INDEX_REPLICA_NB}"
  add_in_exo_configuration "exo.es.indexing.shard.number.default=${EXO_ES_INDEX_SHARD_NB}"

  # JOD Converter
  add_in_exo_configuration "exo.jodconverter.portnumbers=${EXO_JODCONVERTER_PORTS}"

  if [ "${EXO_REGISTRATION}" = "false" ]; then
    add_in_exo_configuration "# Registration"
    add_in_exo_configuration "exo.registration.skip=true"
  fi


  # eXo Chat configuration
  add_in_chat_configuration "# eXo Chat server configuration"
  # The password to access REST service on the eXo Chat server.
  add_in_chat_configuration "chatPassPhrase=${EXO_CHAT_SERVER_PASSPHRASE}"
  # The eXo group who can create teams.
  add_in_chat_configuration "teamAdminGroup=/platform/users"
  # We must override this to remain inside the docker container (works only for embedded chat server)
  add_in_chat_configuration "chatServerUrl=${EXO_CHAT_SERVER_URL}/chatServer"

  add_in_chat_configuration "# eXo Chat client configuration"
  # Time interval to refresh messages in a chat.
  add_in_chat_configuration "chatIntervalChat=3000"
  # Time interval to keep a chat session alive in milliseconds.
  add_in_chat_configuration "chatIntervalSession=60000"
  # Time interval to refresh user status in milliseconds.
  add_in_chat_configuration "chatIntervalStatus=20000"
  # Time interval to refresh Notifications in the main menu in milliseconds.
  add_in_chat_configuration "chatIntervalNotif=3000"
  # Time interval to refresh Users list in milliseconds.
  add_in_chat_configuration "chatIntervalUsers=5000"
  # Time after which a token will be invalid. The use will then be considered offline.
  add_in_chat_configuration "chatTokenValidity=30000"

  if [ "${EXO_CHAT_SERVER_STANDALONE}" = "false" ]; then
    # Mongodb configuration (for the Chat)
    add_in_chat_configuration "# eXo Chat mongodb configuration"
    add_in_chat_configuration "dbServerHosts=${EXO_MONGO_HOST}:${EXO_MONGO_PORT}"
    add_in_chat_configuration "dbName=${EXO_MONGO_DB_NAME}"
    if [ "${EXO_MONGO_USERNAME:-}" = "-" ]; then
      add_in_chat_configuration "dbAuthentication=false"
      add_in_chat_configuration "#dbUser="
      add_in_chat_configuration "#dbPassword="
    else
      add_in_chat_configuration "dbAuthentication=true"
      add_in_chat_configuration "dbUser=${EXO_MONGO_USERNAME}"
      add_in_chat_configuration "dbPassword=${EXO_MONGO_PASSWORD}"
    fi

    # The notifications are cleaned up every one hour by default.
    add_in_chat_configuration "chatCronNotifCleanup=0 0/60 * * * ?"
    # When a user reads a chat, the application displays messages of some days in the past.
    add_in_chat_configuration "chatReadDays=30"

  else

    # Remove the full chat-application addon and install only the client part
    # Detect the previously installed version
    if [ -f /opt/exo/addons/statuses/exo-chat.status ]; then
      EXO_CHAT_VERSION="$(jq -r ".version" /opt/exo/addons/statuses/exo-chat.status)"
      echo "[WARN] Automatically replacing exo-chat:${EXO_CHAT_VERSION} addon by exo-chat-client:${EXO_CHAT_VERSION} (EXO_CHAT_SERVER_STANDALONE=true)"
      EXO_ADDONS_REMOVE_LIST="${EXO_ADDONS_REMOVE_LIST:-},exo-chat"
      EXO_ADDONS_LIST="${EXO_ADDONS_LIST:-},exo-chat-client:${EXO_CHAT_VERSION}"
    fi


    # Force standalone configuration
    add_in_chat_configuration "# eXo Chat server configuration"
    add_in_chat_configuration "standaloneChatServer=true"

  fi

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
  echo "# eXo add-ons management start ..."
  echo "# ------------------------------------ #"

  # add-ons removal
  if [ -z "${EXO_ADDONS_REMOVE_LIST:-}" ]; then
    echo "# no add-on to uninstall from EXO_ADDONS_REMOVE_LIST environment variable."
  else
    echo "# uninstalling default add-ons from EXO_ADDONS_REMOVE_LIST environment variable:"
    echo ${EXO_ADDONS_REMOVE_LIST} | tr ',' '\n' | while read _addon ; do
      if [ -n "${_addon}" ]; then
        # Uninstall addon
        ${EXO_APP_DIR}/addon uninstall ${_addon}
        if [ $? != 0 ]; then
          echo "[ERROR] Problem during add-on [${_addon}] uninstall."
          exit 1
        fi
      fi
    done
    if [ $? != 0 ]; then
      echo "[ERROR] An error during add-on uninstallation phase aborted eXo startup !"
      exit 1
    fi
  fi

  echo "# ------------------------------------ #"

  # add-on installation
  if [ -z "${EXO_ADDONS_LIST:-}" ]; then
    echo "# no add-on to install from EXO_ADDONS_LIST environment variable."
  else
    echo "# installing add-ons from EXO_ADDONS_LIST environment variable:"
    echo ${EXO_ADDONS_LIST} | tr ',' '\n' | while read _addon ; do
      if [ -n "${_addon}" ]; then
        # Install addon
        ${EXO_APP_DIR}/addon install ${_ADDON_MGR_OPTIONS:-} ${_ADDON_MGR_OPTION_CATALOG:-} ${_addon} --force --batch-mode
        if [ $? != 0 ]; then
          echo "[ERROR] Problem during add-on [${_addon}] install."
          exit 1
        fi
      fi
    done
    if [ $? != 0 ]; then
      echo "[ERROR] An error during add-on installation phase aborted eXo startup !"
      exit 1
    fi
  fi
  echo "# ------------------------------------ #"
  echo "# eXo add-ons management done."
  echo "# ------------------------------------ #"

  # put a file to avoid doing the configuration twice
  touch /opt/exo/_done.addons
fi

# -----------------------------------------------------------------------------
# Install patches if needed when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/exo/_done.patches ]; then
  echo "INFO: patches installation already done! skipping this step."
else
  echo "# ------------------------------------ #"
  echo "# eXo patches management start ..."
  echo "# ------------------------------------ #"

  # patches installation
  if [ -z "${EXO_PATCHES_LIST:-}" ]; then
    echo "# no patches to install from EXO_PATCHES_LIST environment variable."
  else
    echo "# installing patches from EXO_PATCHES_LIST environment variable:"
    if [ -z "${_ADDON_MGR_OPTION_PATCHES_CATALOG:-}" ]; then
      echo "[ERROR] you must configure a patches catalog url with _ADDON_MGR_OPTION_PATCHES_CATALOG variable for patches installation."
      echo "[ERROR] An error during patches installation phase aborted eXo startup !"
      exit 1
    fi
    echo ${EXO_PATCHES_LIST} | tr ',' '\n' | while read _patche ; do
      if [ -n "${_patche}" ]; then
        # Install patch
        ${EXO_APP_DIR}/addon install --conflict=overwrite ${_ADDON_MGR_OPTION_PATCHES_CATALOG:-} ${_patche} --force --batch-mode
        if [ $? != 0 ]; then
          echo "[ERROR] Problem during patch [${_patche}] install."
          exit 1
        fi
      fi
    done
    if [ $? != 0 ]; then
      echo "[ERROR] An error during patches installation phase aborted eXo startup !"
      exit 1
    fi
  fi
  echo "# ------------------------------------ #"
  echo "# eXo patches management done."
  echo "# ------------------------------------ #"

  # put a file to avoid doing the configuration twice
  touch /opt/exo/_done.patches
fi

# -----------------------------------------------------------------------------
# Change chat add-on security token at each start
# -----------------------------------------------------------------------------
if [ -f /etc/exo/chat.properties ] && [ "${EXO_CHAT_SERVER_STANDALONE}" = "false" ]; then
  sed -i 's/^chatPassPhrase=.*$/chatPassPhrase='"$(tr -dc '[:alnum:]' < /dev/urandom  | dd bs=4 count=6 2>/dev/null)"'/' /etc/exo/chat.properties
fi


# -----------------------------------------------------------------------------
# Configure the eXo profiles for clustering if needed
# -----------------------------------------------------------------------------
if [ "${EXO_CLUSTER}" = "true" ]; then
  EXO_PROFILES="${EXO_PROFILES},cluster,cluster-jgroups-tcp"
fi

# -----------------------------------------------------------------------------
# Define a better place for eXo Platform license file
# -----------------------------------------------------------------------------
CATALINA_OPTS="${CATALINA_OPTS:-} -Dexo.license.path=/etc/exo/license.xml"

# -----------------------------------------------------------------------------
# LDAP configuration
# -----------------------------------------------------------------------------
CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.jndi.ldap.connect.pool.timeout=${EXO_LDAP_POOL_TIMEOUT}"
CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.jndi.ldap.connect.pool.maxsize=${EXO_LDAP_POOL_MAX_SIZE}"
if [ ! -z "${EXO_LDAP_POOL_DEBUG:-}" ]; then
  CATALINA_OPTS="${CATALINA_OPTS} -Dcom.sun.jndi.ldap.connect.pool.debug=${EXO_LDAP_POOL_DEBUG}"
fi

# -----------------------------------------------------------------------------
# JMX configuration
# -----------------------------------------------------------------------------
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
# LOG GC configuration
# -----------------------------------------------------------------------------
if [ "${EXO_JVM_LOG_GC_ENABLED}" = "true" ]; then
  # -XX:+PrintGCDateStamps : print the absolute timestamp in the log statement (i.e. “2014-11-18T16:39:25.303-0800”)
  # -XX:+PrintGCTimeStamps : print the time when the GC event started, relative to the JVM startup time (unit: seconds)
  # -XX:+PrintGCDetails    : print the details of how much memory is reclaimed in each generation
  EXO_JVM_LOG_GC_OPTS="-XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps"
  echo "Enabling eXo JVM GC logs with [${EXO_JVM_LOG_GC_OPTS}] options ..."
  CATALINA_OPTS="${CATALINA_OPTS} ${EXO_JVM_LOG_GC_OPTS} -Xloggc:${EXO_LOG_DIR}/platform-gc.log"
  # log rotation to backup previous log file (we don't use GC Log file rotation options because they are not suitable)
  # create the directory for older GC log file
  [ ! -d ${EXO_LOG_DIR}/platform-gc/ ] && mkdir ${EXO_LOG_DIR}/platform-gc/
  if [ -f ${EXO_LOG_DIR}/platform-gc.log ]; then
    EXO_JVM_LOG_GC_ARCHIVE="${EXO_LOG_DIR}/platform-gc/platform-gc_$(date -u +%F_%H%M%S%z).log"
    mv ${EXO_LOG_DIR}/platform-gc.log ${EXO_JVM_LOG_GC_ARCHIVE}
    echo "previous eXo JVM GC log file archived to ${EXO_JVM_LOG_GC_ARCHIVE}."
  fi
  echo "eXo JVM GC logs configured and available at ${EXO_LOG_DIR}/platform-gc.log"
fi
# -----------------------------------------------------------------------------
# Create the DATA directories if needed
# -----------------------------------------------------------------------------
if [ ! -d "${EXO_DATA_DIR}" ]; then
  mkdir -p "${EXO_DATA_DIR}"
fi

if [ ! -d "${EXO_FILE_STORAGE_DIR}" ]; then
  mkdir -p "${EXO_FILE_STORAGE_DIR}"
fi

# Change the device for antropy generation
CATALINA_OPTS="${CATALINA_OPTS:-} -Djava.security.egd=file:/dev/./urandom"

# Wait for database availability
case "${EXO_DB_TYPE}" in
  mysql)
    echo "Waiting for database ${EXO_DB_TYPE} availability at ${EXO_DB_HOST}:${EXO_DB_PORT} ..."
    wait-for ${EXO_DB_HOST}:${EXO_DB_PORT} -s -t ${EXO_DB_TIMEOUT}
    if [ $? != 0 ]; then
      echo "[ERROR] The ${EXO_DB_TYPE} database ${EXO_DB_HOST}:${EXO_DB_PORT} was not available within ${EXO_DB_TIMEOUT}s ! eXo startup aborted ..."
      exit 1
    fi
    ;;
  pgsql|postgres|postgresql)
    echo "Waiting for database ${EXO_DB_TYPE} availability at ${EXO_DB_HOST}:${EXO_DB_PORT} ..."
    wait-for ${EXO_DB_HOST}:${EXO_DB_PORT} -s -t ${EXO_DB_TIMEOUT}
    if [ $? != 0 ]; then
      echo "[ERROR] The ${EXO_DB_TYPE} database ${EXO_DB_HOST}:${EXO_DB_PORT} was not available within ${EXO_DB_TIMEOUT}s ! eXo startup aborted ..."
      exit 1
    fi
    ;;
esac

# Wait for mongodb availability (if chat is installed)
if [ -f /opt/exo/addons/statuses/exo-chat.status ]; then
  echo "Waiting for mongodb availability at ${EXO_MONGO_HOST}:${EXO_MONGO_PORT} ..."
  wait-for ${EXO_MONGO_HOST}:${EXO_MONGO_PORT} -s -t ${EXO_MONGO_TIMEOUT}
  if [ $? != 0 ]; then
    echo "[ERROR] The mongodb database ${EXO_MONGO_HOST}:${EXO_MONGO_PORT} was not available within ${EXO_MONGO_TIMEOUT}s ! eXo startup aborted ..."
    exit 1
  fi
fi

# Wait for elasticsearch availability (if external)
if [ "${EXO_ES_EMBEDDED}" != "true" ]; then
  echo "Waiting for external elastic search availability at ${EXO_ES_HOST}:${EXO_ES_PORT} ..."
  wait-for ${EXO_ES_HOST}:${EXO_ES_PORT} -s -t ${EXO_ES_TIMEOUT}
  if [ $? != 0 ]; then
    echo "[ERROR] The external elastic search ${EXO_ES_HOST}:${EXO_ES_PORT} was not available within ${EXO_ES_TIMEOUT}s ! eXo startup aborted ..."
    exit 1
  fi
fi

set +u		# DEACTIVATE unbound variable check
