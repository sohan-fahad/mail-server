# Quick Start Guide

Get your mail server running in 10 minutes!

## Prerequisites

- Docker and Docker Compose installed
- Domain `sohanfahad.dev` managed in Cloudflare
- Server with public IP (DigitalOcean, Linode, etc.)

## 5-Step Quick Start

### Step 1: Clone and Setup (2 minutes)

```bash
git clone <your-repository>
cd mail-server
chmod +x setup.sh
```

### Step 2: Configure DNS in Cloudflare (3 minutes)

Add these records in Cloudflare Dashboard → DNS:

```
A       mail    YOUR_SERVER_IP   (DNS only, gray cloud)
MX      @       mail.sohanfahad.dev   Priority: 10
TXT     @       v=spf1 mx -all
```

**Wait 5-10 minutes for DNS propagation**

### Step 3: Start Mail Server (1 minute)

```bash
./setup.sh start
```

### Step 4: Generate DKIM and Add to Cloudflare (2 minutes)

```bash
./setup.sh generate-dkim
```

Copy the output and add to Cloudflare:

```
Type: TXT
Name: mail._domainkey
Content: (paste the DKIM key)
```

### Step 5: Create Email Accounts (2 minutes)

```bash
./setup.sh add-email admin@sohanfahad.dev YourSecurePassword123
./setup.sh add-email info@sohanfahad.dev YourSecurePassword123
```

## Test Your Setup

```bash
# Check server status
./setup.sh status

# View logs
./setup.sh logs

# Check DNS
./setup.sh check-dns
```

## Send Test Email

Use your email client:

- **SMTP Server**: mail.sohanfahad.dev
- **Port**: 587 (TLS) or 465 (SSL)
- **Username**: admin@sohanfahad.dev
- **Password**: YourSecurePassword123

## Verify Email Deliverability

1. Go to https://www.mail-tester.com/
2. Send an email to the provided address
3. Check your score (aim for 9+/10)

## Add DMARC (Optional but Recommended)

In Cloudflare, add:

```
Type: TXT
Name: _dmarc
Content: v=DMARC1; p=none; rua=mailto:postmaster@sohanfahad.dev
```

## Common Commands

```bash
./setup.sh start              # Start mail server
./setup.sh stop               # Stop mail server
./setup.sh restart            # Restart mail server
./setup.sh logs               # View logs
./setup.sh status             # Check status
./setup.sh add-email EMAIL PASS   # Add email account
./setup.sh list-emails        # List all accounts
./setup.sh backup             # Create backup
./setup.sh check-dns          # Check DNS records
```

## Troubleshooting

### DNS Not Resolving
```bash
dig mail.sohanfahad.dev
```
Wait 10-30 minutes for propagation.

### Can't Send Emails
- Check port 587 is open: `telnet mail.sohanfahad.dev 587`
- Verify credentials
- Check logs: `./setup.sh logs`

### Can't Receive Emails
- Verify MX record: `dig sohanfahad.dev MX`
- Check port 25 is open: `telnet mail.sohanfahad.dev 25`
- Check SPF/DKIM/DMARC records

### Emails Going to Spam
1. Verify all DNS records (SPF, DKIM, DMARC)
2. Set PTR record (contact your hosting provider)
3. Test on https://www.mail-tester.com/
4. Warm up your IP gradually

## Next Steps

- Read [CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md) for detailed DNS configuration
- Read [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md) for Railway deployment
- Configure PTR record with your hosting provider
- Set up email aliases if needed
- Configure your email client (Thunderbird, Apple Mail, etc.)
- Set up automated backups

## Important Notes

⚠️ **Railway Limitations**: If deploying to Railway, note that port 25 may be blocked. For production mail servers, use DigitalOcean, Linode, or similar VPS providers.

📧 **Email Deliverability**: Having correct DNS records (especially PTR) is crucial for emails not going to spam.

🔒 **Security**: Use strong passwords and keep your mail server updated.

💾 **Backups**: Run `./setup.sh backup` regularly to backup your mail data.

## Getting Help

- Check logs: `./setup.sh logs`
- Check status: `./setup.sh status`
- Review detailed guides in repository
- [docker-mailserver docs](https://docker-mailserver.github.io/docker-mailserver/latest/)

## Full Documentation

For comprehensive guides, see:
- [README.md](README.md) - Complete documentation
- [CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md) - Detailed DNS setup
- [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md) - Railway deployment guide

---

Happy mailing! 📬

