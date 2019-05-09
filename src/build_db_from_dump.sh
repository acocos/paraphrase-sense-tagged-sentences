#!/usr/bin/env bash

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
      echo "Building database PSTS-all"
      ;;
    small)
      echo "Building database PSTS-small"
      ;;
    *)
      raise_error "Unknown argument: ${SIZE}"
      display_usage
      ;;
  esac
fi


# start mongo daemon
mongod --port 27017 --bind_ip localhost --dbpath ../$SIZE/db --fork --logpath ../$SIZE/db/psts-mongo.log

# build database from dump
unzip ../$SIZE/psts-$SIZE.zip -d ../$SIZE
mongorestore --host localhost:27017 --gzip --dir ../$SIZE/dump

# stop daemon
mongo admin --eval "db.shutdownServer()"