#!/usr/bin/env bash
# Использует bash для выполнения скрипта (не sh)

set -euo pipefail
# set -e: выход при любой ошибке (ненулевой код возврата)
# set -u: ошибка при использовании необъявленной (unset) переменной
# set -o pipefail: пайплайн считается проваленным, если любая команда в нём завершилась с ошибкой

# === ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ (с значениями по умолчанию и проверками) ===

export PGDATA="${PGDATA:-/var/lib/postgresql/data}"
# PGDATA: путь к директории данных PostgreSQL
# ${VAR:-default} - использует default, если VAR не установлена
# export: делает переменную доступной дочерним процессам

PRIMARY_HOST="${PRIMARY_HOST:?PRIMARY_HOST is required}"
# ${VAR:?error} - если VAR не установлена или пуста, вывести error и завершить скрипт
# Обязательная переменная - откуда реплицироваться

PRIMARY_PORT="${PRIMARY_PORT:-5432}"
# Необязательная переменная, по умолчанию стандартный порт 5432

REPLICATION_USER="${REPLICATION_USER:-replicator}"
# Пользователь для репликации, по умолчанию 'replicator'

REPLICATION_PASSWORD="${REPLICATION_PASSWORD:-replicator}"
# Пароль пользователя репликации

REPLICATION_SLOT="${REPLICATION_SLOT:?REPLICATION_SLOT is required}"
# Обязательное имя репликационного слота на PRIMARY

STANDBY_NAME="${STANDBY_NAME:?STANDBY_NAME is required}"
# Обязательное имя этого standby узла (для идентификации)

APPLY_DELAY="${APPLY_DELAY:-0s}"
# Задержка применения реплицированных данных (например '10s', '5min')
# Формат: число + единица (s=секунды, min=минуты, h=часы)

DOWNSTREAM_SLOT="${DOWNSTREAM_SLOT:-}"
# Опционально: имя слота для каскадной репликации (если этот узел будет primary для кого-то)

# === ПРОВЕРКА: НУЖНО ЛИ ИНИЦИАЛИЗИРОВАТЬ STANDBY ===

if [ ! -f "$PGDATA/standby.signal" ] && [ ! -s "$PGDATA/postgresql.auto.conf" ]; then
# [ ! -f "$PGDATA/standby.signal" ] - проверяет, НЕ существует ли файл-маркер standby
# [ ! -s "$PGDATA/postgresql.auto.conf" ] - проверяет, пуст ли файл конфигурации репликации
# -f: существует ли файл (file)
# -s: файл существует и не пуст (size > 0)
# &&: логическое И - оба условия должны быть истинны
# Если оба условия истинны → база данных не инициализирована как standby, нужно настроить

  echo "[standby] Waiting for primary ${PRIMARY_HOST}:${PRIMARY_PORT}..."
  until pg_isready -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U postgres -d postgres >/dev/null 2>&1; do
    # pg_isready: утилита PostgreSQL, проверяющая готовность сервера принимать подключения
    # -h: хост (host)
    # -p: порт (port)
    # -U: пользователь (user)
    # -d: база данных (database)
    # >/dev/null: перенаправить stdout в никуда (подавить вывод)
    # 2>&1: перенаправить stderr (ошибки) в stdout (тоже в никуда)
    # until ... do ... done: цикл, выполняющийся ПОКА команда НЕ вернёт успех (код 0)
    sleep 2
    # sleep 2: пауза 2 секунды между попытками
  done

  echo "[standby] Taking base backup for ${STANDBY_NAME}..."
  rm -rf "${PGDATA:?}"/*
  # rm -rf: рекурсивное (r) и принудительное (f) удаление
  # ${PGDATA:?} - вызовет ошибку, если PGDATA не установлена (защита от rm -rf /)
  
  export PGPASSWORD="$REPLICATION_PASSWORD"
  # export: делает пароль доступным для pg_basebackup через переменную окружения
  
  pg_basebackup \
    -h "$PRIMARY_HOST" \        # -h: host (хост PRIMARY)
    -p "$PRIMARY_PORT" \        # -p: port (порт PRIMARY)
    -U "$REPLICATION_USER" \    # -U: user (пользователь для подключения)
    -D "$PGDATA" \              # -D: directory (куда положить бэкап)
    -R \                        # -R: write recovery config (создать standby.signal + postgresql.auto.conf)
    -X stream \                 # -X: wal-method (метод передачи WAL) - stream = потоковая во время бэкапа
    -S "$REPLICATION_SLOT" \    # -S: slot (использовать существующий репликационный слот)
    -c fast                     # -c: checkpoint (тип контрольной точки) - fast = быстрая
    # -c spread (по умолчанию)	Распределить запись на диск во времени, чтобы не нагружать систему
    # -c fast	Записать всё сразу и быстро (высокая нагрузка на диск)
    # pg_basebackup: создаёт клон БД с PRIMARY для инициализации standby

  # === ДОПОЛНЯЕМ КОНФИГУРАЦИЮ РЕПЛИКАЦИИ ===
  {
    echo "primary_conninfo = 'host=${PRIMARY_HOST} port=${PRIMARY_PORT} user=${REPLICATION_USER} password=${REPLICATION_PASSWORD} application_name=${STANDBY_NAME}'"
    # primary_conninfo: строка подключения к PRIMARY для WAL receiver
    # application_name: идентификатор этого standby (виден в pg_stat_replication)
    
    echo "primary_slot_name = '${REPLICATION_SLOT}'"
    # primary_slot_name: имя слота на PRIMARY, который будет использовать этот standby
    
    echo "recovery_min_apply_delay = '${APPLY_DELAY}'"
    # recovery_min_apply_delay: минимальная задержка применения WAL на standby
    # Полезно для защиты от случайного удаления данных на PRIMARY
  } >> "$PGDATA/postgresql.auto.conf"
  # >>: перенаправление с ДОБАВЛЕНИЕМ в конец файла (не перезаписывает)
  # postgresql.auto.conf: файл, который автоматически применяется поверх postgresql.conf

  # === КОПИРУЕМ ПОЛЬЗОВАТЕЛЬСКИЕ КОНФИГИ ===
  cp /etc/postgresql/custom/postgresql.conf "$PGDATA/postgresql.conf"
  cp /etc/postgresql/custom/pg_hba.conf "$PGDATA/pg_hba.conf"
  # cp: copy (копирование файлов)
  
  # === УСТАНАВЛИВАЕМ ПРАВИЛЬНЫЕ ПРАВА ДОСТУПА ===
  chown -R postgres:postgres "$PGDATA"
  # chown: change owner (сменить владельца)
  # -R: рекурсивно (для всех поддиректорий)
  # postgres:postgres: пользователь:группа (стандартный пользователь PostgreSQL в Docker)
  
  chmod 700 "$PGDATA"
  # chmod: change mode (сменить права доступа)
  # 700: rwx------ (только владелец postgres может читать/писать/выполнять)
fi
# Конец блока инициализации

# === ЗАПУСК POSTGRESQL ===
su postgres -c "
# su: substitute user (переключиться на пользователя postgres)
# -c: выполнить команду в shell нового пользователя

postgres \
  -c 'config_file=$PGDATA/postgresql.conf' \
  -c 'hba_file=$PGDATA/pg_hba.conf'
" &
# postgres: запуск сервера PostgreSQL
# -c: установить параметр конфигурации (override)
# config_file: путь к основному конфигурационному файлу
# hba_file: путь к файлу аутентификации pg_hba.conf
# &: запуск в фоновом режиме (не блокирует скрипт)

pg_pid=$!
# $!: специальная переменная, содержащая PID последнего фонового процесса

# === ОЖИДАНИЕ ГОТОВНОСТИ POSTGRESQL ===
until pg_isready -h 127.0.0.1 -p 5432 -U postgres >/dev/null 2>&1; do
  # Проверяет, готов ли PostgreSQL принимать подключения
  # 127.0.0.1: локальный хост (loopback)
  sleep 1
done

# === СОЗДАНИЕ СЛОТА ДЛЯ КАСКАДНОЙ РЕПЛИКАЦИИ (опционально) ===
if [ -n "${DOWNSTREAM_SLOT:-}" ]; then
  # -n: проверяет, что строка НЕ пустая
  # Если DOWNSTREAM_SLOT установлен и не пуст
  
  echo "[standby] Creating downstream replication slot ${DOWNSTREAM_SLOT}"

  su postgres -c "psql -U postgres -d postgres" <<SQL
# psql: клиент PostgreSQL
# -U: пользователь
# -d: база данных
# <<SQL ... SQL: heredoc (многострочный ввод)

SELECT pg_create_physical_replication_slot('${DOWNSTREAM_SLOT}')
# pg_create_physical_replication_slot: функция создания физического слота репликации
# Возвращает: (slot_name, consistent_point, snapshot_name, output_plugin)

WHERE NOT EXISTS (
  # Подзапрос: проверяет, существует ли уже слот с таким именем
  SELECT 1
  FROM pg_replication_slots
  # pg_replication_slots: системное представление со всеми слотами
  WHERE slot_name='${DOWNSTREAM_SLOT}'
);
# Если слот уже существует - ничего не делает (условие WHERE ложно)
SQL
fi

# === ОЖИДАНИЕ ЗАВЕРШЕНИЯ POSTGRESQL ===
pg_pid=$!
# Перезаписываем pg_pid (хотя он уже был установлен ранее)
# ВНИМАНИЕ: это потенциальный баг - потеря исходного PID

wait "$pg_pid"
# wait: блокирует выполнение скрипта до завершения процесса с указанным PID
# Когда PostgreSQL остановится (по SIGTERM или ошибке), скрипт продолжит выполнение
# В текущем скрипте после wait ничего нет - контейнер завершится