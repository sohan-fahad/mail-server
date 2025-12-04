FROM ghcr.io/docker-mailserver/docker-mailserver:latest

# Expose required ports
EXPOSE 25 587 465 143 993

# Set default environment variables
ENV ENABLE_FAIL2BAN=1 \
    SSL_TYPE=letsencrypt \
    PERMIT_DOCKER=network \
    SPOOF_PROTECTION=0 \
    ENABLE_SPAMASSASSIN=1 \
    ENABLE_CLAMAV=1 \
    ONE_DIR=1 \
    DMS_DEBUG=0

# The volumes will be mounted by Railway
VOLUME ["/var/mail", "/var/mail-state", "/var/log/mail", "/tmp/docker-mailserver"]

# Use the default entrypoint from docker-mailserver
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]