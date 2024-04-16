#!/bin/bash
#creating the variables
velovert_url="www.veloverte.org"
terreverte_url="www.terreverte.net"
wwwvelovertpath="/var/www/html/www.velovert.org"
wwwterrevertepath="/var/www/html/www.terreverte.net"
veloverthtml=$wwwvelovertpath/index.html
terrevertehtml=$wwwterrevertepath/index.html
velovertconf=/etc/httpd/conf.d/velovert.org.conf
terreverteconf=/etc/httpd/conf.d/terreverte.net.conf

if [ ! rpm -q httpd &> /dev/null ]; then
  echo "Apache is not installed. Installing..."
  yum -y install httpd
else
  echo  "Apache is already installed"
fi

# Start the Apache service
systemctl start httpd

# Enable Apache to start on boot
systemctl enable httpd

# Check the status of Apache
systemctl status httpd

mkdir -p $wwwvelovertpath
mkdir -p $wwwterrevertepath

# Append the configuration to velovert file
touch $veloverthtml
cat << EOF >> $veloverthtml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>www.velovert.org</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
        }
        .content {
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="content">
	<h1>WWW.VELOVERT.ORG</h1>
        <p>The website <a href="https://www.velovert.org">www.velovert.org</a> is working properly!</p>
    </div>
</body>
</html>
EOF

# Append the configuration to terreverte file
touch $terrevertehtml
cat << EOF >> $terrevertehtml
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>www.terreverte.org</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
        }
        .content {
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="content">
	<h1>WWW.TERREVERTE.NET</h1>
        <p>The website <a href="https://www.terreverte.net">www.terreverte.net</a> is working properly!</p>
    </div>
</body>
</html>
EOF

#Change the wunership of the /var/www/html* path to apache
chown -R apache:apache $wwwvelovertpath
chown -R apache:apache $wwwterrevertepath
#Change the permission to read and execute to the path
chmod -R 755 /var/www/html

#Create a virtual host file for the website www.velovert.org
touch $velovertconf
cat << EOF >> $velovertconf
<VirtualHost *:80>

  ServerName $velovert_url
  ServerAlias velovert.org
  DocumentRoot $wwwvelovertpath
  ErrorLog $wwwvelovertpath/error.log
  CustomLog $wwwvelovertpath/access.log combined

</VirtualHost>

EOF

#Create a virtual host file for the website www.terreverte.net
touch $terreverteconf
cat << EOF >> $terreverteconf
<VirtualHost *:80>

  ServerName $terreverte_url
  ServerAlias terreverte.net
  DocumentRoot $wwwterrevertepath
  ErrorLog $wwwterrevertepath/error.log
  CustomLog $wwwterrevertepath/access.log combined

</VirtualHost>

EOF

#Test de configuration files
apachectl configtest

#restart the apache service
systemctl restart httpd

