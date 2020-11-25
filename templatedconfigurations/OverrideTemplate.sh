#!/bin/sh

#set -x

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
        :
fi
if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
        :
fi
if ( [ "${CLOUDHOST}" = "linode" ] )
then
    while read line
    do
        variables="${variables} `/bin/echo ${line} | /bin/grep "UDF" | /usr/bin/awk -F'"' '{print $2}' | /bin/sed '/^$/d'`"
    done < /root/StackScript

    for variable in ${variables}
    do
        /bin/sed -i "/${variable}=/d" ${templatefile}
        eval "payload=\${$variable}"
        /bin/echo "export ${variable}=\"${payload}\"" >> ${templatefile}
    done
fi
if ( [ "${CLOUDHOST}" = "vultr" ] )
then
        :
fi
if ( [ "${CLOUDHOST}" = "aws" ] )
then
        :
fi