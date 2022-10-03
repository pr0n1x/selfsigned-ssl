#!/bin/bash

# @see https://habr.com/ru/post/352722/
# @see https://askubuntu.com/a/1159454

cwd=`dirname $0`
cd $cwd

CERT_FOLDER="${CERT_FOLDER:-"cert"}"

if [ -f "${CERT_FOLDER}/rootCA.key" ] \
|| [ -f "${CERT_FOLDER}/rootCA.pem" ] \
|| [ -f "${CERT_FOLDER}/rootCA.srl" ] ; then
  echo "rootCA already created. You should to delete them before.";
  exit 1;
fi

openssl genrsa -out ${CERT_FOLDER}/rootCA.key 2048
openssl req -x509 -new -nodes -key ${CERT_FOLDER}/rootCA.key -sha256 -days 1024 -out ${CERT_FOLDER}/rootCA.pem
