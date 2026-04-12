### Основной узел
pg196
postgres2
6lVL8X5a


### Резервный узел

```
pg199
postgres2
76BIUysT
```

### Подключение
```
ssh -J s368273@helios.cs.ifmo.ru:2222 postgres2@pg196
ssh -J s368273@helios.cs.ifmo.ru:2222 postgres2@pg199


```

### Копирование скриптов
```
scp -J s368273@helios.cs.ifmo.ru:2222 *.bash postgres2@pg196:~/
scp -J s368273@helios.cs.ifmo.ru:2222 pg2* postgres2@pg199:~/

```

```
tail -n 50 $HOME/zfb92/log/postgresql.log
pg_ctl -D $PGDATA -l $PGDATA/log/postgresql.log reload
pg_ctl -D $PGDATA -l $PGDATA/log/postgresql.log start
```

```
export PGDATA=$HOME/zfb92

rm -f $PGDATA/recovery.signal
rm -f $PGDATA/standby.signal

sed -i '' '/restore_command/d' $PGDATA/postgresql.conf 2>/dev/null
sed -i '' '/recovery_target_time/d' $PGDATA/postgresql.conf 2>/dev/null

pg_ctl -D $PGDATA -l $PGDATA/log/postgresql.log start
```