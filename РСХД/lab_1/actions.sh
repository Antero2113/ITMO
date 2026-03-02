scp -J s368273@helios.cs.ifmo.ru:2222 0*.sh 0*.sql psql_admin.sh testuser.sh postgres2@pg196:~/


chmod +x 01_init_cluster.sh 02_create_dirs.sh 03_configure_postgresql.conf.sh 04_configure_pg_hba.conf.sh 05_start_server.sh 09_cleanup.sh

./01_init_cluster.sh
./02_create_dirs.sh

mkdir -p $HOME/zfb92/log


./03_configure_postgresql.conf.sh
./04_configure_pg_hba.conf.sh
./05_start_server.sh
 
sleep 3

psql -p 9746 -d postgres -f 06_create_objects.sql
psql -p 9746 -d loudwhiteuser -U testuser -f 06_bd_content.sql
psql -p 9746 -d loudwhiteuser -U testuser -f 07_verify.sql

pg_ctl -D /var/db/postgres2/zfb92 reload