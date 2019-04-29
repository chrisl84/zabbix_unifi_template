#!/bin/bash

#######################################################################################
# This file is part of Zabbix UniFi Template.
#
# Zabbix UniFi Template  is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Zabbix UniFi Template  is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Zabbix UniFi Template.  If not, see <https://www.gnu.org/licenses/>.
#######################################################################################

command -v /usr/bin/curl >/dev/null 2>&1 || { echo >&2 "Curl is required. Aborting."; exit 1; }

COMMAND=
USERNAME=
PASSWORD=''
HOST=http://localhost:8080
COOKIEJAR=./cookiejar
LOGIN=api/login

CURL_CDS='-s'

WIFI_EXPERIENCE=api/s/default/stat/widget/health

OPTIND=1         # Reset in case getopts has been used previously in the shell.

show_help() {
  echo "usage: unifi_command.sh [-h]"
  echo "      REQUIRED: "
  echo "         -c COMMAND -u USERNAME"
  echo "      OPTIONAL :"
  echo "         [-p PASSWORD password for Unifi website, default '']"
  echo "         [-s SERVER URL (http(s)://<url>(:<port>)), default http://localhost:8080]"
  echo "         [-j cookieJar location, default current directory]"
  echo "         [-a show all supported API commands to website]"
}
show_commands() {
  echo "alluser - Extracts information on all users connected to the system"
}

selectCommand() {
  case "$1" in
    wifi_experience)
      COMMAND=$WIFI_EXPERIENCE
      ;;
    *)
      echo $"Command $1 is not supported."
      exit 1
  esac
}

if [ -z ${@+x} ]; then
  show_help
  exit 1
fi

while getopts "hac:u:p:s:j:" opt; do
    case "${opt}" in
    c)
        selectCommand $OPTARG
        ;;
    u)  USERNAME=${OPTARG}
        ;;
    p)  PASSWORD=${OPTARG}
        ;;
    s)  HOST=${OPTARG}
        ;;
    j) COOKIEJAR=${OPTARG}
        ;;
    a)
       show_commands
       exit 0
       ;;
    h)
      show_help
      exit 0
        ;;
    *)
      echo $opt
      show_help
      exit 1
        ;;
    esac
done

shift $((OPTIND-1))
#Command is required
if [[ -z ${COMMAND+x} || $COMMAND == '' ]]; then
  show_help
  exit 1
fi
#Username is required.
if [ -z ${USERNAME+x} ]; then
  show_help
  exit 1
fi
#Ignore error when dealing with Self-Signed Certificates
if [[ $HOST == "https"* || $HOST == "HTTPS"* ]]; then
  CURL_CDS="${CURL_CDS}k"
fi
#Attempt to retrieve the data from the UniFi Controller
get() {
    result=$(/usr/bin/curl $CURL_CDS -b $COOKIEJAR "$HOST/$COMMAND")
    echo $result
}
#Authenticate the session and store the session cookie in the cookiejar file
authenticate() {
  result=$(/usr/bin/curl $CURL_CDS -d "{\"username\":\"$USERNAME\",\"password\":\"${PASSWORD}\"}" --cookie-jar $COOKIEJAR "$HOST/$LOGIN")
  if [[ $result == *"error"* ]]; then
    echo "Failed to authenticate."
    exit 1
  fi
}
authenticate
get $COMMAND
