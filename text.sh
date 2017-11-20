#!/bin/sh

GIT_RCMS=/Volumes/MYHARD/src/tmp;
OPENDEV_DIR=/Volumes/MYHARD/src/RCMS/RCMS-OpenDev-ClosedBeta;
SITES_DIR=/Volumes/MYHARD/src/RCMS/RCMS-sites;
SITE_ID=120960;
DB_S3URL="https://rcms-backup.s3.amazonaws.com/120960/20171117145447/ec1c0373e600ea522a2fe06422df359e.gz?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1511502972&Signature=%2Fq5TYXIwSJHBYDk2SBbELIDn61k%3D";
SITE_DATA_S3URL="https://rcms-backup.s3.amazonaws.com/120960/20171117145447/ec1c0373e600ea522a2fe06422df359e.tar.gz?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1511502972&Signature=Jb5ScObgldkypor9Z6O8FS1Q6MQ%3D";
DOCKERFILE_S3URL="https://rcms-backup.s3.amazonaws.com/install_shell/dockerfile_5d98d00edfdb9eb26f605310ae260a93?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1511502978&Signature=MR77hOrUZE8nzL3o9fppJ11TXlA%3D";
DOCKER_NAME=aio-develop.r-cms.jp-120960-8LhGgzK4MQZe;
PASSWORD=8LhGgzK4MQZe;
PASSWORD_MD5="\$2y\$10\$4/US42vgHZLyDe8UXIXDvuHsdDsJ4iVen4Nc/WXv8BNEA.Eo3itSm";
DEFAULT_PHP=/home/rcms/$SITE_ID/lib/default.php;
DEFAULT_PHP_S3URL="https://rcms-backup.s3.amazonaws.com/120960/install/default.php.20171117145612_b29cbcf667df479937174b7192e9b997?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1511502973&Signature=IbnZFEBfMpEZ59ZV5HY%2BysYz7A8%3D";
T_SITE_SQL_S3URL="https://rcms-backup.s3.amazonaws.com/120960/install/site.sql.20171117145612_b29cbcf667df479937174b7192e9b997?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1511502974&Signature=XYKqFIxkn4U9Qo3gX3pfFSe4swg%3D";

curl -o $GIT_RCMS/sites/$SITE_ID/install/rcms.gz $DB_S3URL;
if [ $? -ne 0 ]; then echo "Failed to download DB dump."; exit; fi;
curl -o $GIT_RCMS/sites/$SITE_ID/install/rcms.tar.gz $SITE_DATA_S3URL;
if [ $? -ne 0 ]; then echo "Failed to download Site Data Files."; exit; fi;
curl -o $GIT_RCMS/sites/$SITE_ID/install/default.php $DEFAULT_PHP_S3URL;
if [ $? -ne 0 ]; then echo "Failed to download default.php."; exit; fi;
curl -o $GIT_RCMS/sites/$SITE_ID/install/rcms$SITE_ID.sql $T_SITE_SQL_S3URL;
if [ $? -ne 0 ]; then echo "Failed to download Site SQL."; exit; fi;
tar zxvf $GIT_RCMS/sites/$SITE_ID/install/rcms.tar.gz -C $GIT_RCMS/sites/$SITE_ID/install/$SITE_ID/;

SIZE=`wc -c $GIT_RCMS/sites/$SITE_ID/install/rcms.gz | awk '{print $1}'`
if [ $SIZE -lt 5000 ]; then
    echo 'Error. Failed to download rcms.gz';
    exit;
fi;
SIZE=`wc -c $GIT_RCMS/sites/$SITE_ID/install/rcms.tar.gz | awk '{print $1}'`
if [ $SIZE -lt 5000 ]; then
    echo 'Error. Failed to download rcms.tar.gz';
    exit;
fi;
SIZE=`wc -c $GIT_RCMS/sites/$SITE_ID/install/default.php | awk '{print $1}'`
if [ $SIZE -lt 100 ]; then
    echo 'Error. Failed to download default.php';
    exit;
fi;
SIZE=`wc -c $GIT_RCMS/sites/$SITE_ID/install/rcms$SITE_ID.sql | awk '{print $1}'`
if [ $SIZE -lt 100 ]; then
    echo 'Error. Failed to download rcms$SITE_ID.sql';
    exit;
fi;

curl -L $DOCKERFILE_S3URL | docker build -t rcms-$SITE_ID - &&  docker run --privileged --name $DOCKER_NAME -v $OPENDEV_DIR/nfs/:/home/rcms/nfs/  -v $GIT_RCMS/sites/$SITE_ID/:/home/rcms/$SITE_ID/  -p 80:80 -p 22 -p 5432:5432 -d rcms-$SITE_ID;


docker exec $DOCKER_NAME yum install ansible -y;