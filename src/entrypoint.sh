#!/bin/bash
cd /fluent-bit/etc


downloadConfig () {
  curl $FLAGS -X GET $REACT_APP_API_ENTRYPOINT/api/v1/assets/certificates/$1 --output config.zip
  unzip -o config.zip || exit 1
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
/etc/init.d/supervisor start

while :
do
  j=0
  getIndicators $KEY
  for i in $(echo $response)
  do
	  echo $i
	  echo ${i:0:10}
if [[ ${i:0:10} > $latestSync ]]
then
	fi
      if [ $j = 1 ] && [[ $i > $latestSync ]]
      then
        echo "Restarting due to config updated\n"
        downloadConfig $1
        supervisorctl restart fluentbit
        latestSync=$i
      fi
      if [ $j = 2 ] && [ ${i:0:1} = "0" ]
      then
        echo "Restarting due to broken connection\n"
        downloadConfig $1
        supervisorctl restart fluentbit
        latestSync=$i
      fi
      j=$((j+1))
  done
	sleep 1000
done
