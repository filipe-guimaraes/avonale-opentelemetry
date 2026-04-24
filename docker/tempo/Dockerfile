FROM grafana/tempo:2.4.0

# Copie o YAML estático para dentro do container
COPY tempo.yaml /etc/tempo/config.yaml

# Comando padrão
CMD ["/tempo", "-config.file=/etc/tempo/config.yaml"]