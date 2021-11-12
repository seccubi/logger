#!/bin/bash
cd /fluent-bit/etc

downloadConfig () {
  curl -X GET $REACT_APP_API_ENTRYPOINT/api/v1/assets/certificates/$1 --output config.zip
  unzip -o config.zip || exit 1
  rm config.zip
}

getIndicators() {
  response=$(curl -sI  $REACT_APP_API_ENTRYPOINT/api/v1/assets/metadata/$1 | awk '/^HTTP/ { STATUS = $2 }
                                                                            /^updated:/ { UPDATED = $2 }
                                                                            END { printf("%s\n%s",STATUS, UPDATED) }')
}

getIndicators $1
j=0
for i in $(echo $response)
do
  if [ $j = 1 ]
  then
    latestSync=$i
  fi
  j=$((j+1))
done

downloadConfig $1
/etc/init.d/supervisor start
while :
do
  j=0
  getIndicators $1

  for i in $(echo $response)
  do
      if [ $j = 1 ] && [ $i -lt $latestSync ]
      then
        downloadConfig $1
        supervisorctl restart fluentbit
        latestSync=$i
      fi
      j=$((j+1))
  done
	sleep 10
done
