


cd /
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="mayur"
s3_bucket="upgrad-mayur01"
#tar -czvf /tmp/${myname}-httpd-logs-${timestamp}.tgz /var/log/apache3/*.log
find /var/log/apache2/ -iname '*.log' -print0 | xargs -0 tar zcvf /tmp/${myname}-httpd-logs-${timestamp}.tar



aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

