#!/bin/bash

# Mail Server Setup Script for mail.sohanfahad.dev
# This script helps automate common setup tasks

set -e

DOMAIN="chalan.co"
MAIL_DOMAIN="mail.chalan.co"
COMPOSE_FILE="docker-compose.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Mail Server Setup for ${MAIL_DOMAIN}${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Function to check if docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not running. Please start Docker and try again.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker is running${NC}"
}

# Function to start mail server
start_server() {
    echo -e "\n${YELLOW}Starting mail server...${NC}"
    docker compose -f $COMPOSE_FILE up -d
    echo -e "${GREEN}✓ Mail server started${NC}"
}

# Function to stop mail server
stop_server() {
    echo -e "\n${YELLOW}Stopping mail server...${NC}"
    docker compose -f $COMPOSE_FILE down
    echo -e "${GREEN}✓ Mail server stopped${NC}"
}

# Function to generate DKIM keys
generate_dkim() {
    echo -e "\n${YELLOW}Generating DKIM keys...${NC}"
    docker compose -f $COMPOSE_FILE exec mailserver setup config dkim
    echo -e "${GREEN}✓ DKIM keys generated${NC}"
    
    echo -e "\n${YELLOW}DKIM Public Key:${NC}"
    if [ -f "docker-data/dms/config/opendkim/keys/${DOMAIN}/mail.txt" ]; then
        cat "docker-data/dms/config/opendkim/keys/${DOMAIN}/mail.txt"
        echo -e "\n${YELLOW}Add this to Cloudflare as a TXT record:${NC}"
        echo -e "Name: mail._domainkey"
        echo -e "Content: (paste the content above)"
    else
        echo -e "${RED}Error: DKIM key file not found. Make sure the mail server is running.${NC}"
    fi
}

# Function to add email account
add_email() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}Usage: $0 add-email <email> <password>${NC}"
        exit 1
    fi
    
    echo -e "\n${YELLOW}Adding email account: $1${NC}"
    docker compose -f $COMPOSE_FILE exec mailserver setup email add "$1" "$2"
    echo -e "${GREEN}✓ Email account added${NC}"
}

# Function to list email accounts
list_emails() {
    echo -e "\n${YELLOW}Email accounts:${NC}"
    docker compose -f $COMPOSE_FILE exec mailserver setup email list
}

# Function to add alias
add_alias() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}Usage: $0 add-alias <from-email> <to-email>${NC}"
        exit 1
    fi
    
    echo -e "\n${YELLOW}Adding alias: $1 -> $2${NC}"
    docker compose -f $COMPOSE_FILE exec mailserver setup alias add "$1" "$2"
    echo -e "${GREEN}✓ Alias added${NC}"
}

# Function to list aliases
list_aliases() {
    echo -e "\n${YELLOW}Email aliases:${NC}"
    docker compose -f $COMPOSE_FILE exec mailserver setup alias list
}

# Function to show logs
show_logs() {
    echo -e "\n${YELLOW}Showing mail server logs (Ctrl+C to exit)...${NC}"
    docker compose -f $COMPOSE_FILE logs -f mailserver
}

# Function to check DNS records
check_dns() {
    echo -e "\n${YELLOW}Checking DNS records...${NC}\n"
    
    echo -e "${YELLOW}A Record for mail:${NC}"
    dig +short mail.${DOMAIN} A
    
    echo -e "\n${YELLOW}MX Record:${NC}"
    dig +short ${DOMAIN} MX
    
    echo -e "\n${YELLOW}SPF Record:${NC}"
    dig +short ${DOMAIN} TXT | grep "spf1"
    
    echo -e "\n${YELLOW}DKIM Record:${NC}"
    dig +short mail._domainkey.${DOMAIN} TXT
    
    echo -e "\n${YELLOW}DMARC Record:${NC}"
    dig +short _dmarc.${DOMAIN} TXT
}

# Function to show status
show_status() {
    echo -e "\n${YELLOW}Mail server status:${NC}"
    docker compose -f $COMPOSE_FILE ps
}

# Function to backup
backup() {
    BACKUP_FILE="mail-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    echo -e "\n${YELLOW}Creating backup: ${BACKUP_FILE}${NC}"
    
    if [ -d "docker-data" ]; then
        tar -czf "$BACKUP_FILE" docker-data/
        echo -e "${GREEN}✓ Backup created: ${BACKUP_FILE}${NC}"
    else
        echo -e "${RED}Error: docker-data directory not found${NC}"
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "Usage: $0 [command] [arguments]"
    echo ""
    echo "Commands:"
    echo "  start              - Start the mail server"
    echo "  stop               - Stop the mail server"
    echo "  restart            - Restart the mail server"
    echo "  status             - Show mail server status"
    echo "  logs               - Show mail server logs"
    echo "  generate-dkim      - Generate DKIM keys"
    echo "  add-email          - Add email account (requires email and password)"
    echo "  list-emails        - List all email accounts"
    echo "  add-alias          - Add email alias (requires from-email and to-email)"
    echo "  list-aliases       - List all email aliases"
    echo "  check-dns          - Check DNS records"
    echo "  backup             - Create backup of mail data"
    echo "  help               - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 generate-dkim"
    echo "  $0 add-email admin@${DOMAIN} mypassword123"
    echo "  $0 add-alias admin@${DOMAIN} external@gmail.com"
    echo "  $0 check-dns"
}

# Main script
case "${1:-help}" in
    start)
        check_docker
        start_server
        ;;
    stop)
        check_docker
        stop_server
        ;;
    restart)
        check_docker
        stop_server
        sleep 2
        start_server
        ;;
    status)
        check_docker
        show_status
        ;;
    logs)
        check_docker
        show_logs
        ;;
    generate-dkim)
        check_docker
        generate_dkim
        ;;
    add-email)
        check_docker
        add_email "$2" "$3"
        ;;
    list-emails)
        check_docker
        list_emails
        ;;
    add-alias)
        check_docker
        add_alias "$2" "$3"
        ;;
    list-aliases)
        check_docker
        list_aliases
        ;;
    check-dns)
        check_dns
        ;;
    backup)
        backup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}\n"
        show_help
        exit 1
        ;;
esac

