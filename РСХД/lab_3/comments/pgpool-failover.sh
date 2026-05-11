#!/usr/bin/env bash
# Скрипт вызывается Pgpool при failover (переключении primary)
# Переменные подставляются Pgpool в failover_command:
# failover_command = '/usr/local/bin/pgpool-failover.sh %d %P %m %H %M %N'

set -euo pipefail
# set -e: выход при любой ошибке
# set -u: ошибка при неопределённой переменной
# set -o pipefail: ошибка, если любая команда в пайпе провалилась

# === ПОЛУЧЕНИЕ ПАРАМЕТРОВ ОТ PGPOOL ===
# Передаются в том же порядке, что в failover_command
FAILED_NODE_ID="$1"           # %d - ID узла, который отключился (упал)
OLD_PRIMARY_NODE_ID="$2"      # %P - ID старого primary (который был до failover)
NEW_MAIN_NODE_ID="$3"         # %m - ID нового primary (кого продвигаем)
NEW_MAIN_HOST="$4"            # %H - хост нового primary
OLD_MAIN_NODE_ID="$5"         # %M - порт нового primary (не используется, названо сбивчиво)
OLD_PRIMARY_HOST="${6:-}"     # %N - application_name нового primary (не используется)

# Выводим в лог полученные параметры (для отладки)
echo "[failover] failed_node_id=${FAILED_NODE_ID} old_primary_node_id=${OLD_PRIMARY_NODE_ID} new_main_node_id=${NEW_MAIN_NODE_ID} new_main_host=${NEW_MAIN_HOST} old_primary_host=${OLD_PRIMARY_HOST}"

# === СЛУЧАЙ 1: УПАЛ НЕ PRIMARY ===
# Если отключившийся узел НЕ является старым primary (т.е. упала реплика)
if [ "$FAILED_NODE_ID" != "$OLD_PRIMARY_NODE_ID" ]; then
  echo "[failover] failed node is not old primary, nothing to promote"
  exit 0   # Выходим с успехом - ничего не делаем, primary не трогаем
fi

# === СЛУЧАЙ 2: НЕТ ЖИВОГО КАНДИДАТА ДЛЯ ПРОДВИЖЕНИЯ ===
# new_main_node_id = -1 означает, что Pgpool не нашёл подходящий standby
# new_main_host пуст - тоже нет кандидата
if [ "$NEW_MAIN_NODE_ID" = "-1" ] || [ -z "${NEW_MAIN_HOST}" ]; then
  echo "[failover] no candidate standby available"
  exit 1   # Выходим с ошибкой - failover невозможен
fi

# === ПРОДВИЖЕНИЕ STANDBY ДО PRIMARY ===
export PGPASSWORD=postgres   # Переменная окружения для psql (пароль)

# pg_promote() - функция PostgreSQL, которая превращает standby в primary
# -v ON_ERROR_STOP=1: прервать выполнение при ошибке SQL
# -h: хост (новый primary)
# -p: порт (стандартный 5432)
# -U: пользователь (postgres)
# -d: база данных (postgres)
# -c: выполнить SQL команду
psql -v ON_ERROR_STOP=1 \
  -h "$NEW_MAIN_HOST" \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "SELECT pg_promote();"

# === ОЖИДАНИЕ, ПОКА НОВЫЙ PRIMARY СТАНЕТ ТАКОВЫМ ===
# pg_is_in_recovery() возвращает:
#   - true (t): сервер в режиме восстановления (standby)
#   - false (f): сервер работает как primary (принимает запись)
# 
# -tAc: флаги psql
#   -t: вывести только строки данных (без заголовков)
#   -A: выровнять вывод (без пробелов)
#   -c: выполнить команду
# 
# grep -qx t: проверяет, что вывод команды = 't'
#   -q: quiet (не выводить результат)
#   -x: совпадение со всей строкой целиком
#   t: искомый символ
until psql -tAc "select not pg_is_in_recovery()" \
  -h "$NEW_MAIN_HOST" \
  -p 5432 \
  -U postgres \
  -d postgres | grep -qx t; do
  sleep 1   # Ждём 1 секунду между попытками
done

echo "[failover] promoted ${NEW_MAIN_HOST} to primary"
exit 0   # Успешное завершение