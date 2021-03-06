NOTE: THE SMTP CREDENTIALS THAT YOU SET AT BUILD TIME FOR YOUR APPLICATION ARE AVAILABLE AS FOLLOWS POST DEPLOYMENT:  

For wordpress: /var/www/wordpresssmtp  
For moodle: /var/www/moodlesmtp  
For Drupal: /var/www/drupalsmtp  
For Joomla: /var/www/html/configuration.php  

The SMTP service is used to send emails from the deployed applications and also system messages from the deployment infrastructure itself. 
At the time of writing, I have added 3 SMTP services for a deployer to choose from when making a build. One is www.sendpulse.com and the other is the trusty old gmail www.gmail.com and the 3rd one is Amazon SES

To send SMTP mail, the first thing you will need to do is set yourself up an account with your provider of choice. With sendpulse, you have to use an existing email address that you already own. With gmail, you will get a brand new gmail address, if you don't have one already which you can use. 

Note: If you have deployed a domain specific email server which you can do using iRedmail, so, if your domain is "darren's social network", www.darrensnet.com with emails from mail.darrensnet.com. then with Send Pulse and possibly other providers, if you register with them using your domain specific emails then the source email address will be set to your own domain name. If you use darren@yahoo.com. then that is the address your emails will be sent from telling little about the originator.

So, assuming we have an address notifications@darrensnet.com, then we can see how we need to configure the settings for our two SMTP service providers.

When you are running the deployment script ${BUILD_HOME}/AgileDeploymentToolkit.sh, you will be prompted to configure your SMTP provider.

The process will be something like this:

We need to have a smtp service for emails generated by the deployed application as well as system emails from the infrastructure to you, the webmaster.

It is therefore necessary to provide an email address which can be used both to send emails from the application and also to send system messages to

So, please enter the email address where you wish system messages to be sent

webmaster@darrensnet.com 

(You can replace this with your own email address of choice. Any email address you choose is permissible here)

=========

We also need to set up an SMTP provider to send the system status emails through

If you don't have an account with one of the supported smtp server providers, please set one up first

Which SMTP provider are you registered with?

Currently, we support 1) SMTP Pulse (www.sendpulse.com) 2) Google (gmail) 3) Amazon SES

There's a little trick of aesthetics here. Gmail is free, but mails will be sent with an email address like fred@gmail.com
SMTP pulse, for example is not free, but you can register your postmaster@yourdomain.com from your postfix deployment and mails will be personalised to your domain then

1

(So, here, we have selected SMTP pulse

========

Please enter 1) The Address you would like system emails to be sent from
notifications@darrensnet.com

Please enter your email address for your SMTP provider
darren@yahoo.com 
(This is the email address you used when you registered with your SMTP service provider of choice. If this were gmail, then it would have to be an @gmail address)

Please enter your password for your SMTP provider
sfhbfr8rxh (This is the password you set for you SMTP provider account)

=========

If you would like to use a different SMTP service provider which is not currently supported, you can easily add it to the deployment toolkit. Please see the Developer's guide for instructions on how to do this. 
