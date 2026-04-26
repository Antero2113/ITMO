### Запуск контейнера

docker compose up -d

sudo chown -R 999:999 ./node_a/data
sudo chown -R 999:999 ./node_b/data
sudo chown -R 999:999 ./node_c/data

docker-compose ps

```
# Создайте правильный файл прямо в контейнере
docker exec pgpool bash -c "cat > /opt/bitnami/pgpool/conf/pool_hba.conf << 'EOF'
# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
local   all         all                               trust
host    all         all         127.0.0.1/32          trust
host    all         all         0.0.0.0/0             trust
EOF"
```