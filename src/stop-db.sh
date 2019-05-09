#!/usr/bin/env bash

: '
This script will stop a running MongoDB instance on localhost.
'

# stop daemon
mongo admin --eval "db.shutdownServer()"