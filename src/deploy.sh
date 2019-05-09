#!/usr/bin/env bash

: '
This script will deploy the PSTS resource as a MongoDB instance on localhost
as a forked background process.
'

display_usage() {
  echo
  echo "Usage: $0 <SiZE>"
  echo
  echo "<SIZE> is one of 'all' or 'small'"
  echo
}
raise_error() {
  local error_message="$@"
  echo "${error_message}" 1>&2;
}

SIZE="$1"
if [[ -z $SIZE ]] ; then
  raise_error "Expected <SIZE> to be present"
  display_usage
else
  case $SIZE in
    all)
      echo "Starting database PSTS-all"
      ;;
    small)
      echo "Starting database PSTS-small"
      ;;
    *)
      raise_error "Unknown argument: ${SIZE}"
      display_usage
      ;;
  esac
fi


mongod --port 27017 --bind_ip localhost --dbpath ../$SIZE/db --fork --logpath ../$SIZE/db/psts-mongo.log

