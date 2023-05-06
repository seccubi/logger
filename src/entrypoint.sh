#!/bin/bash
cd /fluent-bit/etc


downloadConfig () {
  rm /fluent-bit/etc/parsers.conf
  rm /fluent-bit/etc/myCA.pem
  rm /fluent-bit/etc/key.pem
  rm /fluent-bit/etc/fluent-bit.conf
  rm /fluent-bit/etc/cert.pem
  rm /fluent-bit/etc/.env
  curl $FLAGS -X GET $REACT_APP_API_ENTRYPOINT/api/v1/assets/certificates/$1 --output config.zip
  unzip -o -n config.zip  || exit 1

  rm config.zip
}

getIndicators() {
  response=$(curl $FLAGS -sI  $REACT_APP_API_ENTRYPOINT/api/v1/assets/metadata/$1 | awk '/^HTTP/ { STATUS = $2 }
                                                                            /^updated/ { UPDATED = $2 }
                                                                            /^usage/ { USAGE = $2 }
                                                                            END { printf("%s\n%s\n%s",STATUS, UPDATED, USAGE) }')

								    }


KEY=$1
getIndicators $KEY
j=0
for i in $(echo $response)
do
  if [ $j = 1 ]
  then
	  latestSync=$i
  fi
  if [ $j = 2 ]
  then
    usage=$i
  fi
  j=$((j+1))
done

downloadConfig $1

iteration=0
while :
do
  ps -aux | grep /fluent-bit/bin/fluent-bit | grep -v grep || /fluent-bit/bin/fluent-bit -vvv -c /fluent-bit/etc/fluent-bit.conf &
  iteration=$((iteration+1))
  if [ $iteration -gt 10 ]
    then
    j=0
    getIndicators $KEY
    for i in $(echo $response)
    do
        if [ $j = 1 ] && [[ $i > $latestSync ]]
        then
          echo "$(date) Restarting due to config updated\n"
          downloadConfig $1
          killall fluent-bit && /fluent-bit/bin/fluent-bit -vvv -c /fluent-bit/etc/fluent-bit.conf &
          latestSync=$i
        fi
        if [ $j = 2 ] && [ ${i:0:1} = "0" ]
        then
          echo "$(date) Restarting due to broken connection\n"
          downloadConfig $1
          killall fluent-bit && /fluent-bit/bin/fluent-bit -vvv -c /fluent-bit/etc/fluent-bit.conf &
          latestSync=$i
        fi
        j=$((j+1))
    done
    iteration=0
  fi
  curl $FLAGS -i $REACT_APP_API_ENTRYPOINT/api/v1/assets/ping/$1 > /dev/null
	sleep 60
done
