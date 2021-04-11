#!/bin/bash
cd /fluent-bit/etc

curl -X GET $REACT_APP_API_ENTRYPOINT/api/v1/assets/certificates/$1 --output config.zip

unzip -o config.zip || exit 1
rm config.zip

/fluent-bit/bin/fluent-bit -c ./fluent-bit.conf

