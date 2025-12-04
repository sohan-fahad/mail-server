FROM ghcr.io/docker-mailserver/docker-mailserver:latest

# Expose mail server ports
EXPOSE 25 587 465 143 993

# Set default environment variables for Railway deployment
# Note: SSL_TYPE is empty for Railway (Railway handles SSL termination)
ENV ENABLE_FAIL2BAN=1 \
    SSL_TYPE= \
    PERMIT_DOCKER=network \
    SPOOF_PROTECTION=0 \
    ENABLE_SPAMASSASSIN=1 \
    ENABLE_CLAMAV=1 \
    ENABLE_POSTGREY=1 \
    ONE_DIR=1 \
    DMS_DEBUG=0

# Railway doesn't allow VOLUME directive, volumes must be configured in Railway dashboard
# The container will use Railway's persistent volumes for:
# - /var/mail (mail data)
# - /var/mail-state (mail state)
# - /tmp/docker-mailserver (config/DKIM keys)

# Use the default entrypoint and command from the base image