#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will test for access and successful authentication for our
# particular provider.
# It also generates a generic configuration file for that provider. Please keep your
# config files safe as they have access keys which if leaked may render your cloudhost
# provider account susceptible to compromise
#####################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
######################################################################################
######################################################################################
#set -x

status () {
    /bin/echo "$1" | /usr/bin/tee /dev/fd/3
}

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then

    if ( [ -f ~/.config/doctl/config.yaml ] )
    then
        access_token="`/bin/cat ~/.config/doctl/config.yaml | /bin/grep "access-token" | /usr/bin/awk '{print $NF}'`"
        if ( [ "${access_token}" != "${TOKEN}" ] )
        then
           status "TOKEN mismatch detected"
           status "The token in your digital ocean configuration file is: ${access_token}"
           status "And, the access token you are provinding from your chosen template is: ${TOKEN}"
           status "Enter Y or y to update your live configuration with your the token from your template"
           read response
           if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
           then
               /bin/sed -i "/access-token/c access-token : ${TOKEN}" ~/.config/doctl/config.yaml
           fi
        fi
    else
        /usr/local/bin/doctl auth init
    fi
    /bin/echo "${TOKEN}" > ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
    /usr/local/bin/cs listVirtualMachines 2>/dev/null

    while ( [ "$?" != "0" ] || ( [ ! -f ${BUILD_HOME}/runtimedata/${cloudhost}/ACCESS_KEY ] || [ ! -f ${BUILD_HOME}/runtimedata/${cloudhost}/SECRET_KEY ] ) )
    do
        /bin/rm -r ${BUILD_HOME}/runtimedata/${cloudhost}
        /bin/mkdir ${BUILD_HOME}/runtimedata/${cloudhost}
        /bin/rm ${BUILD_HOME}/runtimedata/${cloudhost}/ACCESS_KEY 2>/dev/null
        /bin/rm ${BUILD_HOME}/runtimedata/${cloudhost}/SECRET_KEY 2>/dev/null
        /bin/rm ${HOME}/.cloudstack.ini 2>/dev/null
        status "Couldn't find valid authentication keys for Exoscale"
        status ""
        status "Welcome to the Exoscale build process using the Agile Deployment Toolkit"
        status ""
        status "You will need to set yourself up a Exoscale account (www.exoscale.ch) and obtain an Access Key and a Secret Key"
        status ""
        status "Please sign in to your exoscale account. Click on your email address at the top right, then click on Account Details"
        status "Following that, you should see your Access Key and you Secret Key under \"API Keys\""
        status ""
        status "Copy them to your clipboard"

        answer="N"
        while ( [ "${answer}" != "Y" ] )
        do
            status "Please enter your access key:"
            read ACCESS_KEY
            status "Please enter your Secret Key:"
            read SECRET_KEY
            status "Your exoscale access key is set to: ${ACCESS_KEY} and the secret key is set to ${SECRET_KEY} are you very sure that this is correct (Y or N)"
            read answer
        done

        /bin/mkdir -p ${BUILD_HOME}/runtimedata/${cloudhost}

        /bin/echo "${ACCESS_KEY}" > ${BUILD_HOME}/runtimedata/${cloudhost}/ACCESS_KEY
        /bin/echo "${SECRET_KEY}" > ${BUILD_HOME}/runtimedata/${cloudhost}/SECRET_KEY
        /bin/echo "[cloudstack]
endpoint = https://api.exoscale.ch/compute
key = ${ACCESS_KEY}
secret = ${SECRET_KEY}" > ${HOME}/.cloudstack.ini
        /bin/chown ${USER} ${HOME}/.cloudstack.ini
        /bin/chmod 400 ${HOME}/.cloudstack.ini
        /usr/local/bin/cs listVirtualMachines
    done
fi
if ( [ "${cloudhost}" = "linode" ] )
then
    if ( [ ! -f ${HOME}/.config/linode-cli ] )
    then
    	status ""
	    status "############################################################################################################################################"
	    status "IMPORTANT: Please only enable read/write access for Linodes, Object Storage and IPs from your linode admin console when you generate the key"    
	    status "############################################################################################################################################"
	    status ""
        /usr/local/bin/linode-cli configure >&3
    fi
    /bin/chown ${USER} ${HOME}/.config/linode-cli
    /bin/chmod 400 ${HOME}/.config/linode-cli
fi
if ( [ "${cloudhost}" = "vultr" ] )
then
    while ( [ "`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`" = "" ] )
    do
        status "Couldn't find valid authentication keys for Vultr"
        status ""
        status "Welcome to the Vultr build process using the Agile Deployment Toolkit"
        status ""
        status "You will need to set yourself up Vultr account (www.vultr.com) and obtain an API KEY"
        status "You can find it here: https://my.vultr.com/settings/#settingsapi"
        status "Please copy and paste it below:"

        answer="N"
        while ( [ "${answer}" != "Y" ] )
        do
            status "Please enter your API (Access) key:"
            read API_KEY
            status "Your Vultr API key is set to: ${API_KEY}, are you very sure that this is correct (Y or N)"
            read answer
        done

        /bin/echo "${API_KEY}" > ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN
    done
    export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
fi

if ( [ "${cloudhost}" = "aws" ] )
then
    if ( [ ! -f ${HOME}/.aws/config ] && [ ! -f ${HOME}/.aws/credentials ] )
    then
        status "About to configure the AWS CLI tool"
        status "#####################################################"
        status "ESSENTIAL: Leave the 'output format' option as 'None'"
        status "#####################################################"
        status "Press <enter>"
        read x
        /usr/bin/aws configure >&3
    else
        status "Your AWS access keys are set to:"
        status "############################################"
        status "${HOME}/.aws/config :"
        status "`/bin/cat ${HOME}/.aws/config`"
        status "${HOME}/.aws/credentials :"
        status "`/bin/cat ${HOME}/.aws/credentials`"
        status "Please review and if you want them altered you can manually edit the files ${HOME}/.aws/config and ${HOME}/.aws/credentials"
        status "Press <enter> to continue"
        read x
    fi
fi
