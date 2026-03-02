```
ssh -J s368273@helios.cs.ifmo.ru:2222 postgres2@pg196
```


```
pg196
postgres2
6lVL8X5a
```

```
initdb -D $HOME/zfb92 --encoding=KOI8-R --locale=ru_RU.KOI8-R
```

```
vi /var/db/postgres2/zfb92/postgresql.conf
```

```
pg_ctl -D /var/db/postgres2/zfb92 -l /var/db/postgres2/zfb92/log/postgresql.log start
```

```
pg_ctl -D /var/db/postgres2/zfb92 reload
```

```
locale -a
```

### Локали

https://postgrespro.ru/docs/postgresql/current/locale

### Запуск сервера

https://postgrespro.ru/docs/postgresql/current/server-start