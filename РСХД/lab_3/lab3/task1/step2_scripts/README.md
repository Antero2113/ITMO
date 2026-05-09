```bash id="2mxy2s"
# 1. Подготовка (внутри client)
docker cp 1_prepare.sh lab3_client:/tmp/1_prepare.sh
docker exec -it lab3_client bash /tmp/1_prepare.sh
```

```bash id="vjjlwm"
# 2. Симуляция падения primary (с хоста)
./2_simulate_primary_crash.sh
```

```bash id="yk7h4i"
# 3. Просмотр логов (с хоста)
./3_show_failover_logs.sh
```

```bash id="9v4zmx"
# 4. Promotion pg_b -> primary (с хоста)
./4_promote_standby.sh
```

```bash id="1bnx8j"
# 5. Проверка работы после failover (внутри client)
docker cp 5_post_failover_check.sh lab3_client:/tmp/5_post_failover_check.sh
docker exec -it lab3_client bash /tmp/5_post_failover_check.sh
```

```bash id="fjjlwm"
# 6. Возврат старого primary (с хоста)
./6_restore_old_primary.sh
```

```bash id="6nsx7i"
# 7. Rejoin pg_a как standby (с хоста)
./7_rejoin_old_primary.sh
```

```bash id="q5ww84"
# 8. Финальная проверка (внутри client)
docker cp 8_final_cluster_check.sh lab3_client:/tmp/8_final_cluster_check.sh
docker exec -it lab3_client bash /tmp/8_final_cluster_check.sh
```

```
docker logs lab3_pg_a --tail 100
docker exec -u postgres lab3_pg_a psql -c "select pg_is_in_recovery();"
docker exec -u postgres lab3_pg_b psql -c "select pg_is_in_recovery();"
docker exec -u postgres lab3_pg_c psql -c "select pg_is_in_recovery();"
```