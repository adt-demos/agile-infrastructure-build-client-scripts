###################################################################################################################################################
# Description: If you have bought your own ssl certificate from a 3rd party, then you can use this script to update your chain file and your private
# key when that certificate expires. Typically a certificate is valid for a period of 1 year and up.
# Author: Peter Winter
# Date: 30/04/2017
###################################################################################################################################################
#!/bin/sh

if ( [ ! -f  ./ManuallyUpdateSSLCertificate.sh ] )
then
    /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
    exit
fi

BUILD_HOME="`/bin/cat ../buildconfiguration/buildhome`"
/bin/echo
/bin/echo "I can currently find the following domains"
domains="`/bin/ls ${BUILD_HOME}/ssl`"
/bin/echo
/bin/echo ${domains}
/bin/echo
/bin/echo "Please enter the URL for the domain you are updating"
read WEBSITE_URL

while ( [ "`/bin/echo ${domains} | /bin/grep ${WEBSITE_URL}`" = "" ] )
do
    /bin/echo "Sorry, that is not a matched domain name, please try again..."
    read WEBSITE_URL
done

if ( [ -f ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ] )
then
    /bin/echo "Found a certificate for this domain. For your info, this is its expiry date"
    /usr/bin/openssl x509 -in ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem -noout -enddate
fi

/bin/echo "Please paste your new SSL certificate chain. <ctrl-d> when done and please make sure the chain is exactly as intended"
/bin/echo "ESSENTIAL - Only copy from the first dash in the file '-' to the last dash in the file. Do not copy any prefixed whitespace or suffixed whitespace"

chain=`cat`

/bin/cp ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem.previous.`/bin/date | /bin/sed 's/ //g'`

/bin/echo "${chain}" > ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem

/bin/echo

/bin/echo "Please paste your new SSL private key. <ctrl-d> when done and please make sure the chain is exactly as intended"
/bin/echo "ESSENTIAL - Only copy from the first dash in the file '-' to the last dash in the file. Do not copy any prefixed whitespace or suffixed whitespace"

privkey=`cat`

/bin/cp ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem.previous.`/bin/date | /bin/sed 's/ //g'`

/bin/echo "${privkey}" > ${BUILD_HOME}/ssl/${WEBSITE_URL}/privkey.pem

cd ${BUILD_HOME}/helperscripts

sourcefile="SSL"
/bin/echo
/bin/echo "OK, about to update the copy of your SSL certificate on the autoscaler. Are you sure? <enter> for yes, <ctrl-c> for no"
read x
. ./CopyToAutoscaler.sh

/bin/echo
/bin/echo "OK, about to update the copy of your SSL certificate on the webserver(s). Are you sure? <enter> for yes, <ctrl-c> for no"
read x
. ./CopyToWebserver.sh



