#!/bin/sh

# 螟画焚縺ｮ險ｭ螳�
GIT_RCMS=/Users/ryota/src/tmp;
OPENDEV_DIR=/Users/ryota/src/tmp/RCMS/RCMS-OpenDev-ClosedBeta;
SITES_DIR=/Users/ryota/src/tmp/RCMS/RCMS-sites;
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

# 繝�ぅ繝ｬ繧ｯ繝医Μ蟄伜惠繝√ぉ繝�け
if [ ! -d $GIT_RCMS ]; then
    echo "No such Directory $GIT_RCMS";
    exit;
fi;
if [ ! -d $OPENDEV_DIR ]; then
    echo "No such Directory $OPENDEV_DIR";
    exit;
fi;
if [ ! -d $SITES_DIR ]; then
    echo "No such Directory $SITES_DIR";
    exit;
fi;
if [ $SITE_ID == '' ]; then
    echo 'Error. Failed to extract SITE_ID';
    exit;
fi;
if [ `docker ps -a | grep $DOCKER_NAME |wc -l` -ge 1 ]; then
    echo \"Error. Container $DOCKER_NAME is already exist.\";
    exit;
fi;

# 繝�Φ繝昴Λ繝ｪ繝輔か繝ｫ繝縺ｫ繝繝ｳ繝励ヵ繧｡繧､繝ｫ繧偵ム繧ｦ繝ｳ繝ｭ繝ｼ繝峨☆繧�
curl -o $GIT_RCMS/sites/$SITE_ID/install/rcms.gz $DB_S3URL;
if [ $? -ne 0 ]; then echo "Failed to download DB dump."; exit; fi;
curl -o $GIT_RCMS/sites/$SITE_ID/install/rcms.tar.gz $SITE_DATA_S3URL;
if [ $? -ne 0 ]; then echo "Failed to download Site Data Files."; exit; fi;
curl -o $GIT_RCMS/sites/$SITE_ID/install/default.php $DEFAULT_PHP_S3URL;
if [ $? -ne 0 ]; then echo "Failed to download default.php."; exit; fi;
curl -o $GIT_RCMS/sites/$SITE_ID/install/rcms$SITE_ID.sql $T_SITE_SQL_S3URL;
if [ $? -ne 0 ]; then echo "Failed to download Site SQL."; exit; fi;
tar zxvf $GIT_RCMS/sites/$SITE_ID/install/rcms.tar.gz -C $GIT_RCMS/sites/$SITE_ID/install/$SITE_ID/;

# 繝輔ぃ繧､繝ｫ繧ｵ繧､繧ｺ繝√ぉ繝�け
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

# 繧ｳ繝ｳ繝�リ菴懈�
curl -L $DOCKERFILE_S3URL | docker build -t rcms-$SITE_ID - &&  docker run --privileged --name $DOCKER_NAME -v $OPENDEV_DIR/nfs/:/home/rcms/nfs/  -v $GIT_RCMS/sites/$SITE_ID/:/home/rcms/$SITE_ID/  -p 80:80 -p 22 -p 5432:5432 -d rcms-$SITE_ID;

# Ansible繧､繝ｳ繧ｹ繝医�繝ｫ
docker exec $DOCKER_NAME yum install ansible -y;

# 隲ｸ縲�そ繝�ヨ繧｢繝���医ョ繝ｼ繧ｿ繝吶�繧ｹ蜷ｫ繧��
docker exec $DOCKER_NAME ansible-playbook /usr/local/ansible/install.yml --connection=local --skip-tags extra,env,postgresql,rcms  --extra-vars "WORK_PATH=/home/rcms/$SITE_ID/install SITE_PATH=/home/rcms SITE_ID=$SITE_ID DOMAIN_NAME=192.168.99.100 CORE_DIR=/home/rcms/nfs DB_USER=postgres DB_PASSWORD= DB_HOST=127.0.0.1"; 

# 繧ｵ繧､繝�ID 驟堺ｸ九ｒ荳ｸ縺斐→繧ｳ繝斐�縺励※騾驕ｿ
docker exec $DOCKER_NAME cp -R /home/rcms/$SITE_ID /home/rcms/${SITE_ID}_back;

# 譁ｰ縺励＞蜷榊燕縺ｧ繧､繝｡繝ｼ繧ｸ菴懈�縲√さ繝ｳ繝�リ蜑企勁
CID=`docker ps |tail -1| cut -f1 -d' '`;
if [ $CID == 'CONTAINER' ]; then
    echo 'Error. Failed to create container';
    exit;
fi
docker stop $CID;
docker commit $DOCKER_NAME rcms-${SITE_ID}-new;
docker rm $CID;

# 譁ｰ縺励＞繧､繝｡繝ｼ繧ｸ縺九ｉ縲∝酔蜷阪�繧ｳ繝ｳ繝�リ繧剃ｽ懈�縲√た繝ｼ繧ｹ縺ｨ蜷梧悄繧貞峙繧�
DOCKER_RUN="docker run --privileged --name $DOCKER_NAME -v $OPENDEV_DIR/nfs/:/home/rcms/nfs/  -v $SITES_DIR/$SITE_ID/lib/modules/:/home/rcms/$SITE_ID/lib/modules/";
if [ -d $SITES_DIR/$SITE_ID/lib/smarty ]; then
    DOCKER_RUN="$DOCKER_RUN -v $SITES_DIR/$SITE_ID/lib/smarty/:/home/rcms/$SITE_ID/lib/smarty";
fi;
if [ -f $SITES_DIR/$SITE_ID/lib/config.php ]; then
    DOCKER_RUN="$DOCKER_RUN -v $SITES_DIR/$SITE_ID/lib/config.php:/home/rcms/$SITE_ID/lib/config.php"; 
fi;
if [ -f $SITES_DIR/$SITE_ID/lib/site_preload.php ]; then
    DOCKER_RUN="$DOCKER_RUN -v $SITES_DIR/$SITE_ID/lib/site_preload.php:/home/rcms/$SITE_ID/lib/site_preload.php"; 
fi;
for TMPL_DIR in `ls $SITES_DIR/$SITE_ID/templates/`;do
    DOCKER_RUN="$DOCKER_RUN -v $SITES_DIR/$SITE_ID/templates/$TMPL_DIR:/home/rcms/$SITE_ID/templates/$TMPL_DIR";
done;
DOCKER_RUN="$DOCKER_RUN -p 80:80 -p 22 -d rcms-$SITE_ID-new /usr/bin/supervisord;";
echo $DOCKER_RUN > /tmp/docker_run.sh;
chmod 755 /tmp/docker_run.sh;
/tmp/docker_run.sh;

# 騾驕ｿ縺励◆繧ｵ繧､繝�ID驟堺ｸ九ｒ蠕ｩ蜈�
docker exec $DOCKER_NAME mv /home/rcms/${SITE_ID}_back/install/${SITE_ID}/data /home/rcms/$SITE_ID/
docker exec $DOCKER_NAME mv /home/rcms/${SITE_ID}_back/install/${SITE_ID}/db /home/rcms/$SITE_ID/
docker exec $DOCKER_NAME mv /home/rcms/${SITE_ID}_back/install/${SITE_ID}/html /home/rcms/$SITE_ID/
docker exec $DOCKER_NAME cp -r /home/rcms/${SITE_ID}_back/install/${SITE_ID}/templates /home/rcms/$SITE_ID/
docker exec $DOCKER_NAME mkdir /home/rcms/$SITE_ID/cache/
docker exec $DOCKER_NAME mkdir /home/rcms/$SITE_ID/log/
docker exec $DOCKER_NAME mkdir /home/rcms/$SITE_ID/templates_c/
docker exec $DOCKER_NAME mv /home/rcms/${SITE_ID}_back/install/default.php /home/rcms/$SITE_ID/lib/
docker exec $DOCKER_NAME mv /home/rcms/${SITE_ID}_back/install/${SITE_ID}/lib/bat_controller.php /home/rcms/$SITE_ID/lib/
docker exec $DOCKER_NAME mv /home/rcms/${SITE_ID}_back/install/${SITE_ID}/lib/init_controller.php /home/rcms/$SITE_ID/lib/
docker exec $DOCKER_NAME mv /home/rcms/${SITE_ID}_back/install/${SITE_ID}/lib/limit.php /home/rcms/$SITE_ID/lib/
docker exec $DOCKER_NAME mv /home/rcms/${SITE_ID}_back/install/${SITE_ID}/lib/site_preload.php /home/rcms/$SITE_ID/lib/
docker exec $DOCKER_NAME chmod 755 /home/rcms/${SITE_ID}/html
docker exec $DOCKER_NAME chown -R apache:apache /home/rcms/${SITE_ID}/html
docker exec $DOCKER_NAME chmod 755 /home/rcms/${SITE_ID}/cache
docker exec $DOCKER_NAME chown -R apache:apache /home/rcms/${SITE_ID}/cache
docker exec $DOCKER_NAME chmod 755 /home/rcms/${SITE_ID}/data
docker exec $DOCKER_NAME chown -R apache:apache /home/rcms/${SITE_ID}/data
docker exec $DOCKER_NAME chmod 755 /home/rcms/${SITE_ID}/templates
docker exec $DOCKER_NAME chown -R apache:apache /home/rcms/${SITE_ID}/templates
docker exec $DOCKER_NAME chmod 755 /home/rcms/${SITE_ID}/templates_c
docker exec $DOCKER_NAME chown -R apache:apache /home/rcms/${SITE_ID}/templates_c
docker exec $DOCKER_NAME chmod 755 /home/rcms/${SITE_ID}/log
docker exec $DOCKER_NAME chown -R apache:apache /home/rcms/${SITE_ID}/log
docker exec $DOCKER_NAME chmod 755 /home/rcms/${SITE_ID}/db
docker exec $DOCKER_NAME chown -R apache:apache /home/rcms/${SITE_ID}/db
docker exec $DOCKER_NAME rm -rf /var/cache/*
docker exec $DOCKER_NAME sudo -u postgres /usr/pgsql-9.6/bin/postgres -D /var/lib/pgsql/9.6/data &
docker exec $DOCKER_NAME sed -i -e 's/9.4/9.6/g' /etc/supervisord.d/service.conf;

# 繝｡繝ｳ繝舌�ID:1逡ｪ縺ｮ莠ｺ縺ｮ諠��ｱ繧呈嶌縺肴鋤縺医ｋ
docker exec $DOCKER_NAME /usr/bin/psql -d rcms$SITE_ID -U postgres -c "update t_member_header set login_id='diverta.bak' where login_id='diverta';update t_member_header set login_id='diverta',login_pwd='${PASSWORD}',login_pwd_md5='${PASSWORD_MD5}',pass_salt=null where member_id=1;";

# default.php縺ｮ繝峨Γ繧､繝ｳ蜷阪ｒ譖ｸ縺肴鋤縺医ｋ
docker exec $DOCKER_NAME sed -i -e 's/"ROOT_URL","http\(\|s\):\/\/aio-develop.r-cms.jp"/"ROOT_URL","http:\/\/192.168.99.100"/g' $DEFAULT_PHP;
docker exec $DOCKER_NAME sed -i -e 's/"ROOT_SSL_URL","http\(\|s\):\/\/aio-develop.r-cms.jp"/"ROOT_SSL_URL","http:\/\/192.168.99.100"/g' $DEFAULT_PHP;
docker exec $DOCKER_NAME sed -i -e 's/"LIB_PATH","\/lib"/"LIB_PATH","\/home\/rcms\/nfs\/lib"/g' $DEFAULT_PHP;
docker exec $DOCKER_NAME sed -i -e 's/"TEMPLATE_PATH","\/templates"/"TEMPLATE_PATH","\/home\/rcms\/nfs\/templates"/g' $DEFAULT_PHP;
docker exec $DOCKER_NAME sed -i -e 's/"ORIGINAL_DIR","\/original"/"ORIGINAL_DIR","\/home\/rcms\/nfs\/original"/g' $DEFAULT_PHP;
docker exec $DOCKER_NAME sed -i -e 's/"RCMS_DEV_MODE","0"/"RCMS_DEV_MODE","1"/g' $DEFAULT_PHP;
docker exec $DOCKER_NAME rm -f /home/rcms/$SITE_ID/html/management/.htaccess;

# Docker蜀��繧ｷ繝ｳ繝懊Μ繝�け繝ｪ繝ｳ繧ｯ繧呈嶌縺肴鋤縺医ｋ
docker exec $DOCKER_NAME ln -sf /home/rcms/original/images /home/rcms/$SITE_ID/html/images;
docker exec $DOCKER_NAME ln -sf /home/rcms/original/css /home/rcms/$SITE_ID/html/css;
docker exec $DOCKER_NAME ln -sf /home/rcms/original/js /home/rcms/$SITE_ID/html/js;
docker exec $DOCKER_NAME ln -sf /home/rcms/original/tools /home/rcms/$SITE_ID/html/tools;
docker exec $DOCKER_NAME ln -sf /home/rcms/original/wysiwyg /home/rcms/$SITE_ID/html/wysiwyg;

# 繝�Φ繝昴Λ繝ｪ繝輔か繝ｫ繝縺ｮ蜑企勁
sudo rm -fr $GIT_RCMS/sites/$SITE_ID/install;

# 繝ｭ繧ｰ蜃ｺ蜉�
NOW_STR=`date '+%Y/%m/%d %H:%M:%S %Z'`;
echo "$NOW_STR $SITE_ID $DOCKER_NAME" >> $GIT_RCMS/docker_install.log;
echo "$GIT_RCMS/docker_install.log 縺ｫ繝ｭ繧ｰ繧呈嶌縺崎ｾｼ縺ｿ縺ｾ縺励◆";
