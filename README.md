# Mail Server Setup for mail.sohanfahad.dev

This repository contains the configuration for a self-hosted mail server using docker-mailserver, deployed on Railway with Cloudflare DNS.

## Prerequisites

- Docker and Docker Compose installed locally for testing
- Railway account and CLI
- Cloudflare account managing sohanfahad.dev domain
- Access to configure DNS records

## ⚠️ Important Railway Limitations

**Note**: Railway may not support all mail server requirements, particularly:
- Port 25 (SMTP) is often blocked by cloud providers for security reasons
- You may need a VPS (DigitalOcean, Linode, AWS EC2) instead of Railway for full mail server functionality
- Consider using Railway only for testing; production mail servers typically need dedicated infrastructure

## Local Setup

### 1. Clone and Setup

```bash
git clone <your-repo>
cd mail-server
```

### 2. Configure DNS Records in Cloudflare

Login to your Cloudflare dashboard and add the following DNS records for `sohanfahad.dev`:

#### A Record
```
Type: A
Name: mail
Content: <Your-Server-IP>
Proxy status: DNS only (gray cloud)
TTL: Auto
```

#### MX Record
```
Type: MX
Name: @
Mail server: mail.sohanfahad.dev
Priority: 10
TTL: Auto
```

#### SPF Record (TXT)
```
Type: TXT
Name: @
Content: v=spf1 mx -all
TTL: Auto
```

### 3. Generate DKIM Keys

```bash
# Start the container first
docker compose up -d

# Generate DKIM keys
docker compose exec mailserver setup config dkim

# View the DKIM public key
cat docker-data/dms/config/opendkim/keys/sohanfahad.dev/mail.txt
```

#### Add DKIM Record to Cloudflare

Copy the content from `mail.txt` and create a TXT record:

```
Type: TXT
Name: mail._domainkey
Content: v=DKIM1; h=sha256; k=rsa; p=<your-public-key>
TTL: Auto
```

### 4. Add DMARC Record (Recommended)

```
Type: TXT
Name: _dmarc
Content: v=DMARC1; p=quarantine; rua=mailto:postmaster@sohanfahad.dev
TTL: Auto
```

### 5. SSL/TLS Certificates

For Let's Encrypt certificates, ensure:
- Port 80 and 443 are accessible
- DNS records are properly configured
- The domain resolves to your server

### 6. Create Email Accounts

```bash
# Add email accounts
docker compose exec mailserver setup email add admin@sohanfahad.dev <password>
docker compose exec mailserver setup email add info@sohanfahad.dev <password>

# List email accounts
docker compose exec mailserver setup email list

# Add aliases (if needed)
docker compose exec mailserver setup alias add admin@sohanfahad.dev your-external@gmail.com

# List aliases
docker compose exec mailserver setup alias list
```

## Railway Deployment

### 1. Install Railway CLI

```bash
npm install -g @railway/cli
```

### 2. Login to Railway

```bash
railway login
```

### 3. Initialize Railway Project

```bash
railway init
```

### 4. Add Railway Token to GitHub Secrets

1. Get your Railway token: `railway login --token`
2. Go to your GitHub repository → Settings → Secrets and variables → Actions
3. Add a new secret: `RAILWAY_TOKEN` with your token

### 5. Deploy

Push to main branch, and GitHub Actions will automatically deploy:

```bash
git add .
git commit -m "Deploy mail server"
git push origin main
```

Or manually deploy:

```bash
railway up
```

## Testing Your Mail Server

### 1. Test SMTP Connection

```bash
telnet mail.sohanfahad.dev 25
```

### 2. Send Test Email

```bash
docker compose exec mailserver setup email send admin@sohanfahad.dev test@example.com
```

### 3. Check Logs

```bash
docker compose logs -f mailserver
```

### 4. Use Online Tools

- [MXToolbox](https://mxtoolbox.com/) - Check MX records and mail server configuration
- [Mail-tester](https://www.mail-tester.com/) - Test email deliverability and spam score

## Configuration Files

- `compose.yaml` - Docker Compose configuration
- `.github/workflows/deploy-railway.yml` - GitHub Actions workflow
- `railway.json` - Railway deployment configuration

## Environment Variables

Key environment variables in `compose.yaml`:

- `ENABLE_FAIL2BAN=1` - Enable Fail2Ban for security
- `SSL_TYPE=letsencrypt` - Use Let's Encrypt for SSL
- `PERMIT_DOCKER=network` - Allow other containers to send email
- `SPOOF_PROTECTION=0` - Disable spoof protection (enable if needed)
- `ENABLE_SPAMASSASSIN=1` - Enable spam filtering
- `ENABLE_CLAMAV=1` - Enable antivirus scanning

## Troubleshooting

### Port 25 Blocked

Many cloud providers block port 25. Solutions:
- Use port 587 (submission) for sending
- Request port 25 to be unblocked from your provider
- Use a different hosting provider (VPS)

### SSL Certificate Issues

```bash
# Check certificate status
docker compose exec mailserver setup config ssl

# Manually renew Let's Encrypt
docker compose exec mailserver setup config ssl renew
```

### Email Not Sending/Receiving

1. Check DNS propagation: `dig mail.sohanfahad.dev`
2. Check MX records: `dig MX sohanfahad.dev`
3. Check SPF/DKIM/DMARC: Use MXToolbox
4. Check logs: `docker compose logs mailserver`

## Security Recommendations

1. **Firewall Configuration**: Only open required ports (25, 587, 465, 993, 143)
2. **Strong Passwords**: Use strong passwords for email accounts
3. **Regular Updates**: Keep docker-mailserver image updated
4. **Backup**: Regular backup of `docker-data/` directory
5. **Monitor Logs**: Watch for suspicious activity in logs
6. **DMARC Policy**: Start with `p=none`, then move to `p=quarantine` or `p=reject`

## Backup and Restore

### Backup

```bash
tar -czf mail-backup-$(date +%Y%m%d).tar.gz docker-data/
```

### Restore

```bash
tar -xzf mail-backup-YYYYMMDD.tar.gz
```

## Alternative to Railway

If Railway doesn't work for mail servers, consider:

1. **DigitalOcean Droplet** ($6/month)
2. **Linode VPS** ($5/month)
3. **AWS EC2** (Free tier available)
4. **Hetzner Cloud** (€4/month)
5. **Vultr** ($6/month)

These providers typically don't block port 25 and are better suited for mail servers.

## Support

For docker-mailserver specific issues:
- [Documentation](https://docker-mailserver.github.io/docker-mailserver/latest/)
- [GitHub Issues](https://github.com/docker-mailserver/docker-mailserver/issues)

## License

MIT

