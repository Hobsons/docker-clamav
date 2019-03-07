#!/usr/bin/env bash

set -e

if freshclam | grep -q 'bytecode.* is up to date'; then
  echo "freshclam running successfully"
  echo "X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*" > /eicar.com
  chown clamav: /eicar.com

  if clamdscan eicar.com | grep -q 'Infected files: 1'; then
    echo "Clamd running successfully"
    exit 0
  else
    echo "Clamd not running"
    exit 1
  fi
else
  echo "freshclam not running"
  exit 1
fi
