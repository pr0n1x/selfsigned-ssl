#!/bin/bash

# @see https://habr.com/ru/post/352722/

cwd=`dirname $0`
cd $cwd

if [ -z "$1" ]
then
	echo "Please supply a subdomain to create a certificate for";
	echo "e.g. mysite.localhost"
	exit;
fi

DOMAIN="$1"
COMMON_NAME="${2:-$1}"
CERT_FOLDER="${CERT_FOLDER:-"cert"}"

if [ -f ${CERT_FOLDER}/${DOMAIN}.key ]; then
	KEY_OPT="-key"
else
	KEY_OPT="-keyout"
fi

SUBJECT="/C=CA/ST=None/L=NB/O=None/CN=$COMMON_NAME"
NUM_OF_DAYS=999

echo "Create CSR... (CN: ${COMMON_NAME})"
openssl req -new -newkey rsa:2048 -sha256 -nodes $KEY_OPT ${CERT_FOLDER}/${DOMAIN}.key -subj "$SUBJECT" -out ${CERT_FOLDER}/${DOMAIN}.csr

echo "Cert Settings..."
cat settings.ext | sed s/%%DOMAIN%%/${COMMON_NAME}/g > ${CERT_FOLDER}/${DOMAIN}.ssl.ext

echo "Release Cert..."
openssl x509 -req -in ${CERT_FOLDER}/${DOMAIN}.csr -CA ${CERT_FOLDER}/rootCA.pem -CAkey ${CERT_FOLDER}/rootCA.key -CAcreateserial -out ${CERT_FOLDER}/${DOMAIN}.crt -days $NUM_OF_DAYS -sha256 -extfile ${CERT_FOLDER}/${DOMAIN}.ssl.ext

echo "Clear temp files..."
rm ${CERT_FOLDER}/${DOMAIN}.ssl.ext
rm ${CERT_FOLDER}/${DOMAIN}.csr
