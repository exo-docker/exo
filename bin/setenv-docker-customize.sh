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

# -----------------------------------------------------------------------------
# Check configuration variables and add default values when needed
# -----------------------------------------------------------------------------
set +u		# DEACTIVATE unbound variable check
[ -z "${EXO_DB_TYPE}" ] && EXO_DB_TYPE="mysql"
[ -z "${EXO_DB_NAME}" ] && EXO_DB_NAME="exo"
[ -z "${EXO_DB_USER}" ] && EXO_DB_USER="exo"
[ -z "${EXO_DB_PASSWORD}" ] && { echo "ERROR: you must provide a database password with EXO_DB_PASSWORD environment variable"; exit 1;}
[ -z "${EXO_DB_HOST}" ] && EXO_DB_HOST="mysql"
[ -z "${EXO_DB_PORT}" ] && EXO_DB_PORT="3306"
[ -z "${EXO_DATA_DIR}" ] && EXO_DATA_DIR="/srv/exo"
set -u		# REACTIVATE unbound variable check

# -----------------------------------------------------------------------------
# Update some configuration files when the container is created for the first time
# -----------------------------------------------------------------------------
if [ -f /opt/exo/_done.configuration ]; then
  echo "INFO: Configuration already done! skipping this step."
else
  case "${EXO_DB_TYPE}" in
    mysql)
      cat /opt/exo/conf/server-mysql.xml > /opt/exo/conf/server.xml
      sed -i 's,jdbc:mysql://localhost:3306/plf,jdbc:mysql://mysql:'${EXO_DB_PORT}'/'${EXO_DB_NAME}',g' /opt/exo/conf/server.xml
      sed -i 's,username="plf" password="plf",username="'${EXO_DB_USER}'" password="'${EXO_DB_PASSWORD}'",g' /opt/exo/conf/server.xml
      ;;
    *) echo "ERROR: you must provide a supported database type with EXO_DB_TYPE environment variable (${EXO_DB_TYPE})";
      exit 1;;
  esac

  replace_in_file /opt/exo/conf/server.xml address=\"0.0.0.0\" "address=\"0.0.0.0\"  scheme=\"https\" secure=\"false\" proxyPort=\"443\" proxyName=\"${EXO_CUSTOMER_VHOST}\""
  # Declare the new valve to pass the replace the proxy ip by the client ip
  replace_in_file /opt/exo/conf/server.xml "</Host>" "  <Valve className=\"org.apache.catalina.valves.RemoteIpValve\" remoteIpHeader=\"x-forwarded-for\" proxiesHeader=\"x-forwarded-by\" protocolHeader=\"x-forwarded-proto\" />\n      </Host>"

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
if [ -f /etc/exo/chat.properties ]; then
  sed -i 's/^chatPassPhrase=.*$/chatPassPhrase='"$(tr -dc '[:alnum:]' < /dev/urandom  | dd bs=4 count=6 2>/dev/null)"'/' /etc/exo/chat.properties
fi

# -----------------------------------------------------------------------------
# Define a better place for eXo Platform license file
# -----------------------------------------------------------------------------
CATALINA_OPTS="${CATALINA_OPTS:-} -Dexo.license.path=/etc/exo/license.xml"

# -----------------------------------------------------------------------------
# Create the DATA directory if needed
# -----------------------------------------------------------------------------
if [ ! -d "${EXO_DATA_DIR}" ]; then
  mkdir -p "${EXO_DATA_DIR}"
fi

# Change the device for antropy generation
CATALINA_OPTS="${CATALINA_OPTS:-} -Djava.security.egd=file:/dev/./urandom"

set +u		# DEACTIVATE unbound variable check
