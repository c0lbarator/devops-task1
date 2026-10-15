#!/usr/bin/bash
if [ -z "$1" ]; then
    echo "Использование: $0 <SERVICE_NAME>"
    exit 1
fi
SERVICE="$1"
STATUS=$(systemctl is-active "$SERVICE" 2>/dev/null)
EXIT_CODE=$?
if [ "$STATUS" = "active" ]; then
    echo "Сервис '$SERVICE' в статусе active"
elif [ $EXIT_CODE -eq 4 ]; then
    echo "Сервис '$SERVICE' не найден"
    exit 1
else
    echo "Сервис '$SERVICE' в статусе $STATUS"
    echo "Лог сервиса:"
    echo "-------------"
    journalctl -u "$SERVICE" -n 10 --no-pager
    echo "-------------"
fi

if [ ! -r "/var/log/syslog" ]; then
    echo "Файл /var/log/syslog недоступен для чтения"
    echo "Пробуем прочитать журнал с помощью journalctl"
    ERR_COUNT=$(journalctl -u "$SERVICE" --since "1 hour ago" --no-pager 2>/dev/null | grep -icE 'error|fatal|panic|fail|crit')
    echo "Количество ошибок за последний час: $ERR_COUNT"
else
    ISO_LIMIT=$(date -d '1 hour ago' +%Y-%m-%dT%H:%M:%S)
    echo -n "Количество ошибок за последний час: "
    grep -iE "$SERVICE(\[[0-9]+\])?:" /var/log/syslog | grep -iE 'error|fatal|panic|fail|crit' | awk -v limit="$ISO_LIMIT" '
    $1 >= limit { count++ }
    END { print count + 0 }
    '
fi