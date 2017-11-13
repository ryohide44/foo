#/bin/sh

rm -Rf /Users/ryota/src/tmp/sites/120960/
mkdir -p /Users/ryota/src/tmp/sites/120960/install/120960
chmod -R 0777 /Users/ryota/src/tmp/sites/120960

curl -o /Users/ryota/src/tmp/sites/120960/install/rcms.gz "https://rcms-backup.s3.amazonaws.com/120960/20171110193614/5c931b50f4ddd9b497e4b30ae9f9421a.gz?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1510915390&Signature=ikFbg%2F%2Bctt7l2ou2YZZwXOEvzcU%3D"
curl -o /Users/ryota/src/tmp/sites/120960/install/rcms.tar.gz "https://rcms-backup.s3.amazonaws.com/120960/20171110193614/5c931b50f4ddd9b497e4b30ae9f9421a.tar.gz?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1510915390&Signature=iRHt0%2FEez%2Fyb5dTeyGt%2FA52S%2FAA%3D"
tar zxvf /Users/ryota/src/tmp/sites/120960/install/rcms.tar.gz -C /Users/ryota/src/tmp/sites/120960/install/120960/

curl -o /Users/ryota/src/tmp/sites/120960/install/default.php "https://rcms-backup.s3.amazonaws.com/120960/install/default.php.20171110194310_2d435fbcdb8bde391014d43d57f31ce7?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1510915391&Signature=8y5zdoGgqgVv%2BLckBQU9Mg3P%2BoU%3D"
curl -o /Users/ryota/src/tmp/sites/120960/install/rcms120960.sql "https://rcms-backup.s3.amazonaws.com/120960/install/site.sql.20171110194310_2d435fbcdb8bde3910s14d43d57f31ce7?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1510915392&Signature=mvpxcEeNA9xOn5VNbmKaddzDRAA%3D"

curl -L "https://rcms-backup.s3.amazonaws.com/install_shell/dockerfile_2e471e41d0141dd95ed8677edbe08435?AWSAccessKeyId=15TV6X9W3KCCT8808ER2&Expires=1510915395&Signature=AeLFf7ITzz93r0w8UiCzYWEM4%2BA%3D" | docker build -t rcms-120960 - && docker run --name "aio-develop.r-cms.jp-120960-2Vj8kx6Fht8H" -v /Users/ryota/src/RCMS/RCMS-OpenDev-ClosedBeta/nfs/:/home/rcms/nfs/ -v /Users/ryota/src/tmp/sites/120960/:/home/rcms/120960/ -p 80:80 -p 22 -p 5432:5432 -d rcms-120960 /usr/bin/supervisord

docker exec aio-develop.r-cms.jp-120960-2Vj8kx6Fht8H yum install ansible -y

docker exec aio-develop.r-cms.jp-120960-2Vj8kx6Fht8H ansible-playbook /usr/local/ansible/install.yml --connection=local --skip-tags extra,env,postgresql,rcms --extra-vars "WORK_PATH=/home/rcms/120960/install SITE_PATH=/home/rcms SITE_ID=120960 DOMAIN_NAME=192.168.99.100 CORE_DIR=/home/rcms/nfs DB_USER=postgres DB_PASSWORD= DB_HOST=127.0.0.1 env_develop=1"

docker exec aio-develop.r-cms.jp-120960-2Vj8kx6Fht8H psql -d rcms120960 -U postgres -c "update t_member_header set login_id='diverta.bak' where login_id='diverta';update t_member_header set login_id='diverta',login_pwd='diverta',login_pwd_md5='\$2y\$10\$2Uk5VzdYLF6hd5xi7MS5wufiz4n2tAPapQhZexKrIxue3QIw94LHm',pass_salt=null where member_id=1;"