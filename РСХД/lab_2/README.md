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

```

