#!/bin/bash

# @see https://habr.com/ru/post/352722/

cwd=`dirname $0`
cd $cwd

openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem
