FROM bitnamilegacy/pgpool:latest

USER root

# Копирование конфигурации
COPY conf/pgpool.conf /opt/bitnami/pgpool/conf/pgpool.conf
COPY conf/pool_hba.conf /opt/bitnami/pgpool/conf/pool_hba.conf

# Установка правильных прав (только чтение)
RUN chown 1001:1001 /opt/bitnami/pgpool/conf/pgpool.conf && \
    chown 1001:1001 /opt/bitnami/pgpool/conf/pool_hba.conf && \
    chmod 644 /opt/bitnami/pgpool/conf/pgpool.conf && \
    chmod 644 /opt/bitnami/pgpool/conf/pool_hba.conf

USER 1001