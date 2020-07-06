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

DOMAIN=$1
COMMON_NAME=${2:-$1}

if [ -f ${DOMAIN}.key ]; then
	KEY_OPT="-key"
else
	KEY_OPT="-keyout"
fi

SUBJECT="/C=CA/ST=None/L=NB/O=None/CN=$COMMON_NAME"
NUM_OF_DAYS=999

echo "Create CSR... (CN: ${COMMON_NAME})"
openssl req -new -newkey rsa:2048 -sha256 -nodes $KEY_OPT ${DOMAIN}.key -subj "$SUBJECT" -out ${DOMAIN}.csr

echo "Cert Settings..."
cat settings.ext | sed s/%%DOMAIN%%/${COMMON_NAME}/g > /tmp/${DOMAIN}.ssl.ext

echo "Release Cert..."
openssl x509 -req -in ${DOMAIN}.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out ${DOMAIN}.crt -days $NUM_OF_DAYS -sha256 -extfile /tmp/${DOMAIN}.ssl.ext

echo "Clear temp files..."
rm /tmp/${DOMAIN}.ssl.ext
rm ${DOMAIN}.csr
