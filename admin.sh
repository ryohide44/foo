#/bin/sh

rm -Rf /Users/ryota/src/tmp/sites/120673/
mkdir -p /Users/ryota/src/tmp/sites/120673/install/120673
chmod -R 0777 /Users/ryota/src/tmp/sites/120673

curl -o /Users/ryota/src/tmp/sites/120673/install/rcms.gz "https://rcms-backup.s3.amazonaws.com/120673/20171110194529/fc41b78b0cdc3a95db5ac0f63adec1ed.gz?AWSAc/Users/ryota/src/tmpcessKeyId=15TV6X9W3KCCT8808ER2&Expires=1510915632&Signature=AtUn%2Fe%2B6nZhExWWlixXk2Gjp2eU%3D"
curl -o /Users/ryota/src/tmp/sites/120673/install/rcms.tar.gz "https://rcms-backup.s3.amazonaws.com/120673/20171110194529/fc41b78b0cdc3a95db5ac0f63adec1ed.tar.gz?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1510915632&Signature=sy2Q9ECI6oAEDByo7psXWMYAkFs%3D"
tar zxvf /Users/ryota/src/tmp/sites/120673/install/rcms.tar.gz -C /Users/ryota/src/tmp/sites/120673/install/120673/

curl -o /Users/ryota/src/tmp/sites/120673/install/default.php "https://rcms-backup.s3.amazonaws.com/120673/install/default.php.20171110194712_c9b8fde8630971e620824fba70a0b3c6?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1510915634&Signature=mk4hBf7v4Cec5r88%2BBIYsg59Q4I%3D"
curl -o /Users/ryota/src/tmp/sites/120673/install/rcms120673.sql "https://rcms-backup.s3.amazonaws.com/120673/install/site.sql.20171110194712_c9b8fde8630971e620824fba70a0b3c6?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1510915635&Signature=WHb%2F7pFJlRTQjhHLvW4scmZ7JGw%3D"

curl -L "https://rcms-backup.s3.amazonaws.com/install_shell/dockerfile_8ca03827751bb1bca03d7e0ffa76dea8?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1510915638&Signature=fLfXDbzejkrV1o136K13w5k%2Fuy8%3D" | docker build -t rcms-120673 - && docker run --name "aio-admin.r-cms.jp-120673-9vsLniDHK2u9" -v /Users/ryota/src/RCMS/RCMS-OpenDev-ClosedBeta/nfs/:/home/rcms/nfs/ -v /Users/ryota/src/tmp/sites/120673/:/home/rcms/120673/ -p 80:80 -p 22 -p 5432:5432 -d rcms-120673 /usr/bin/supervisord


docker exec aio-admin.r-cms.jp-120673-9vsLniDHK2u9 yum install ansible -y

docker exec aio-admin.r-cms.jp-120673-9vsLniDHK2u9 ansible-playbook /usr/local/ansible/install.yml --connection=local --skip-tags extra,env,postgresql,rcms --extra-vars "WORK_PATH=/home/rcms/120673/install SITE_PATH=/home/rcms SITE_ID=120673 DOMAIN_NAME=192.168.99.100 CORE_DIR=/home/rcms/nfs DB_USER=postgres DB_PASSWORD= DB_HOST=127.0.0.1 env_develop=1" 

docker exec aio-admin.r-cms.jp-120673-9vsLniDHK2u9 psql -d rcms120673 -U postgres -c "update t_member_header set login_id='diverta.bak' where login_id='diverta';update t_member_header set login_id='diverta',login_pwd='diverta',login_pwd_md5='\$2y\$10\$9SUX24zzpHhueiDFg7F.FujLdOvmZb/uTTnfiwpw/h7dwJkNLy.dC',pass_salt=null where member_id=1;"
