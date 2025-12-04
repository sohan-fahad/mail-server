# Deploy to Railway - Complete Guide

Your mail server is now working locally! Here's how to deploy it to Railway.

## ⚠️ Important Railway Limitations

**Before deploying, understand these critical points:**

1. **Port 25 may be blocked** - Railway (and most cloud platforms) block port 25 to prevent spam
2. **No PTR records** - You can't set reverse DNS records, affecting email deliverability
3. **Recommended for**: Testing, development, or outbound-only email (sending via port 587)
4. **For production mail server**: Use a VPS (DigitalOcean, Linode, Hetzner)

## 🚀 Railway Deployment Steps

### Step 1: Prepare Your Repository

Your repository should have:
- ✅ `Dockerfile` - Updated for Railway
- ✅ `railway.json` - Railway configuration
- ✅ `.github/workflows/deploy-railway.yml` - GitHub Actions
- ✅ `docker-compose.yaml` - Local development reference

### Step 2: Configure Cloudflare DNS

Add these DNS records for `chalan.co`:

```
# A Record
Type: A
Name: mail
IPv4: (You'll get this from Railway after deployment)
Proxy: DNS only (gray cloud)

# MX Record
Type: MX
Name: @
Mail server: mail.chalan.co
Priority: 10

# SPF Record
Type: TXT
Name: @
Content: v=spf1 mx -all

# DKIM Record (use your generated key)
Type: TXT
Name: mail._domainkey
Content: v=DKIM1; h=sha256; k=rsa; p=YOUR_DKIM_PUBLIC_KEY

# DMARC Record
Type: TXT
Name: _dmarc
Content: v=DMARC1; p=none; rua=mailto:postmaster@chalan.co
```

### Step 3: Deploy to Railway

#### Option A: Via Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Link to project (if already created)
railway link

# Deploy
railway up
```

#### Option B: Via GitHub Actions (Automated)

1. **Get your Railway token:**
   ```bash
   railway login --browserless
   # Copy the token shown
   ```

2. **Add to GitHub Secrets:**
   - Go to your repo: Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `RAILWAY_TOKEN`
   - Value: Your Railway token
   - Click "Add secret"

3. **Push to main branch:**
   ```bash
   git add .
   git commit -m "Deploy mail server to Railway"
   git push origin main
   ```

GitHub Actions will automatically deploy to Railway!

### Step 4: Configure Railway Volumes

**Important**: After deployment, configure persistent volumes in Railway dashboard:

1. Go to your Railway project → mailserver service
2. Click **Settings** → **Volumes**
3. Add these volumes:

| Mount Path | Size | Description |
|------------|------|-------------|
| `/var/mail` | 5GB | Mail storage |
| `/var/mail-state` | 1GB | Mail state files |
| `/tmp/docker-mailserver` | 500MB | Config & DKIM keys |

**Without volumes, your emails and DKIM keys will be lost on redeploy!**

### Step 5: Set Environment Variables (Optional)

In Railway Dashboard → Variables, you can override:

```env
ENABLE_FAIL2BAN=1
SSL_TYPE=
PERMIT_DOCKER=network
SPOOF_PROTECTION=0
ENABLE_SPAMASSASSIN=1
ENABLE_CLAMAV=1
```

### Step 6: Create Email Accounts on Railway

Once deployed, use Railway CLI to create accounts:

```bash
# Access the container
railway run bash

# Add email account
setup email add admin@chalan.co YourPassword123

# Generate DKIM keys
setup config dkim

# View DKIM public key
cat /tmp/docker-mailserver/opendkim/keys/chalan.co/mail.txt

# Exit
exit
```

Then add the DKIM public key to Cloudflare DNS.

### Step 7: Get Railway URL and IP

```bash
# Get service info
railway status

# Get assigned URL/IP
railway domain
```

Update your Cloudflare A record with this IP.

## 🧪 Testing Your Deployment

### Test SMTP Ports

```bash
# Test port 587 (submission)
telnet mail.chalan.co 587

# Test port 25 (if not blocked)
telnet mail.chalan.co 25
```

### Test Email Sending

Use an email client or script:

```python
import smtplib
from email.mime.text import MIMEText

msg = MIMEText("Test email from Railway")
msg['Subject'] = 'Test'
msg['From'] = 'admin@chalan.co'
msg['To'] = 'test@example.com'

server = smtplib.SMTP('mail.chalan.co', 587)
server.login('admin@chalan.co', 'YourPassword123')
server.send_message(msg)
server.quit()
```

### Check Email Deliverability

1. Send test email to: https://www.mail-tester.com/
2. Check your score (aim for 9+/10)
3. Review any issues flagged

## 📊 Monitor Your Deployment

### View Logs

```bash
# Via Railway CLI
railway logs

# Follow logs
railway logs --follow
```

### Check Service Status

```bash
railway status
```

## 🔧 Troubleshooting

### Port 25 Blocked

**Symptom**: Can't receive emails

**Solution**: 
- Railway likely blocks port 25
- Use Railway only for **sending** emails (port 587)
- For receiving, use a VPS instead

### Emails Going to Spam

**Check**:
1. ✅ SPF record configured
2. ✅ DKIM record configured
3. ✅ DMARC record configured
4. ✅ PTR record (requires VPS, not possible on Railway)
5. ✅ Not on blacklist: https://mxtoolbox.com/blacklists.aspx

### Service Keeps Restarting

**Check**:
1. Railway logs: `railway logs`
2. Ensure volumes are configured
3. Check memory usage (mail server with ClamAV needs ~1GB RAM)
4. Disable ClamAV if low on resources: `ENABLE_CLAMAV=0`

### Can't Access Mail Server

**Check**:
1. Railway service is running
2. DNS records propagated (use `dig mail.chalan.co`)
3. Firewall/port settings in Railway
4. Service is publicly accessible (Railway should handle this)

## 💰 Railway Costs

**Estimated monthly cost:**
- Starter: $5/month (includes $5 usage credit)
- Usage: ~$10-20/month for mail server (depends on volume)

**To reduce costs:**
- Disable ClamAV: `ENABLE_CLAMAV=0`
- Reduce replica count to 1
- Use smaller volumes

## 🎯 Production Recommendations

For a **production mail server**, strongly consider:

### Option 1: DigitalOcean Droplet
```bash
# $6/month
# 1GB RAM, 25GB SSD
# Port 25 available
# PTR records supported
```

### Option 2: Linode VPS
```bash
# $5/month
# 1GB RAM, 25GB SSD
# Mail-server friendly
```

### Option 3: Hetzner Cloud
```bash
# €4/month (~$4.50)
# European provider
# Great for mail servers
```

Deploy using the same `docker-compose.yaml`:

```bash
# SSH into VPS
ssh root@your-vps-ip

# Clone repo
git clone https://github.com/yourusername/mail-server.git
cd mail-server

# Start mail server
docker compose up -d

# Setup email accounts
docker compose exec mailserver setup email add admin@chalan.co password123

# Generate DKIM
docker compose exec mailserver setup config dkim
```

## 📚 Additional Resources

- [Railway Docs](https://docs.railway.app/)
- [docker-mailserver Docs](https://docker-mailserver.github.io/docker-mailserver/latest/)
- [Cloudflare DNS Docs](https://developers.cloudflare.com/dns/)
- [Email Deliverability Guide](https://postmarkapp.com/guides/email-deliverability)

## 🆘 Need Help?

- Railway: https://discord.gg/railway
- docker-mailserver: https://github.com/docker-mailserver/docker-mailserver/issues
- Your local setup is working, so most issues will be Railway-specific

---

**Remember**: Railway is great for testing, but for a production mail server handling important emails, use a VPS! 🚀

