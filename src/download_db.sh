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
      echo "Downloading psts-all"
      ;;
    small)
      echo "Downloading psts-small"
      ;;
    *)
      raise_error "Unknown argument: ${SIZE}"
      display_usage
      ;;
  esac
fi


DEST="https://s3.amazonaws.com/paraphrase-sense-tagged-sentences"

curl $DEST/psts-$SIZE.zip -o ../$SIZE/psts-$SIZE.zip
