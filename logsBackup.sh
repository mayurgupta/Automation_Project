

apt update -y
if ! pidof apache2 > /dev/null
    then
	    sudo apt install apache2
fi



REQUIRED_PKG="apache2"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  sudo apt install apache2
fi

if ! pidof apache2 > /dev/null
    then
	    systemctl start apache2
fi


STATUS="$(systemctl is-enabled apache2.service)"
if [ "${STATUS}" = "enabled" ]; then
    echo "Service is enabled"
else
    echo " Service not enabled... so enabling "
    sudo systemctl enable apache2.service
fi



cd /
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="mayur"
s3_bucket="upgrad-mayur01"
#tar -czvf /tmp/${myname}-httpd-logs-${timestamp}.tgz /var/log/apache3/*.log
find /var/log/apache2/ -iname '*.log' -print0 | xargs -0 tar zcvf /tmp/${myname}-httpd-logs-${timestamp}.tar
filesize=$(( $(stat -c '%s' /tmp/${myname}-httpd-logs-${timestamp}.tar)/1000 ))


aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar



FILE="/var/www/html/inventory.html"
if test -f "$FILE"; then
    echo "$FILE exists."
else
    echo "$FILE does not exists."

touch /var/www/html/inventory.html

    echo \<table\> \<tr\> >> /var/www/html/inventory.html
    header=$(cat <<-END
<th>Log Type</th>
<th>Time Created</th>
<th>Type</th>
<th>Size</th>
END
)

echo $header >> /var/www/html/inventory.html
echo \<\/table\> \<\/tr\>  >> /var/www/html/inventory.html

fi

logtype="httpd-logs" 


row=$(cat <<-END
<tr>
<td>${logtype}</td>
<td>${timestamp}</td>
<td>tar</td>
<td>${filesize} K</td>
</tr>
END
)

echo $row >> /var/www/html/inventory.html


# creating cron file

touch /etc/cron.d/automation


echo "0 11 * * * root /root/Automation_Project/logsBackup.sh" > /etc/cron.d/automation

