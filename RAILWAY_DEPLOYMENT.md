# Railway Deployment Guide

This guide covers deploying your mail server to Railway using GitHub Actions.

## ⚠️ Important Limitations

**Before deploying to Railway, be aware of these critical limitations:**

1. **Port 25 Restrictions**: Railway (and most cloud platforms) block port 25 (SMTP) to prevent spam. This is the most common port for receiving emails.

2. **Alternative Ports**: While you can use ports 587 (submission) and 465 (SMTPS) for sending, receiving emails typically requires port 25.

3. **Recommendation**: For production mail servers, consider these alternatives:
   - **DigitalOcean Droplet** ($6/month) - Reliable for mail servers
   - **Linode VPS** ($5/month) - Good for mail servers
   - **AWS EC2** - More complex but flexible
   - **Hetzner Cloud** (€4/month) - European provider
   - **Vultr** ($6/month) - Mail server friendly

4. **Railway Best Use**: Railway works great for:
   - Testing mail server configuration
   - Development environment
   - Outbound-only mail relay (sending emails only)

## Prerequisites

- Railway account ([sign up here](https://railway.app/))
- GitHub repository with your mail server code
- GitHub account

## Setup Steps

### 1. Create Railway Project

#### Option A: Via Railway Dashboard

1. Go to [Railway Dashboard](https://railway.app/dashboard)
2. Click **New Project**
3. Select **Deploy from GitHub repo**
4. Choose your repository
5. Railway will auto-detect your configuration

#### Option B: Via Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project in your directory
cd /path/to/mail-server
railway init

# Link to existing project or create new one
railway link
```

### 2. Configure Environment Variables

In Railway Dashboard → your project → Variables, add:

```env
ENABLE_FAIL2BAN=1
SSL_TYPE=letsencrypt
PERMIT_DOCKER=network
SPOOF_PROTECTION=0
ENABLE_SPAMASSASSIN=1
ENABLE_CLAMAV=1
ONE_DIR=1
DMS_DEBUG=0
```

### 3. Configure Volume Mounts

Railway supports persistent volumes. In your Railway project:

1. Go to **Settings** → **Volumes**
2. Add volumes for:
   - `/var/mail` (mail data)
   - `/var/mail-state` (mail state)
   - `/var/log/mail` (logs)

**Note**: Railway's volume system differs from Docker Compose. You may need to adjust your configuration.

### 4. Setup GitHub Actions

#### Get Railway Token

```bash
# Via CLI
railway login --browserless

# This will give you a token
```

Or get it from Railway Dashboard → Account Settings → Tokens → Create New Token

#### Add GitHub Secret

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `RAILWAY_TOKEN`
5. Value: Your Railway token
6. Click **Add secret**

#### Workflow File

The workflow file `.github/workflows/deploy-railway.yml` is already created. It will:
- Trigger on push to main branch
- Install Railway CLI
- Deploy using your Railway token

### 5. Deploy

#### Automatic Deployment

Simply push to your main branch:

```bash
git add .
git commit -m "Deploy mail server to Railway"
git push origin main
```

GitHub Actions will automatically deploy to Railway.

#### Manual Deployment

```bash
# Via Railway CLI
railway up

# Or specify service
railway up --service mailserver
```

### 6. Monitor Deployment

1. Check GitHub Actions:
   - Go to your repository → **Actions** tab
   - Watch the deployment progress

2. Check Railway Dashboard:
   - Go to Railway Dashboard → your project
   - View deployment logs
   - Check service status

## Port Configuration for Railway

Since Railway doesn't support all mail ports, you may need to adjust:

### Option 1: Outbound Only (Recommended for Railway)

Modify `compose.yaml` to only expose submission ports:

```yaml
ports:
  - "587:587"  # SMTP Submission (TLS)
  - "465:465"  # SMTP Submission (SSL)
```

This configuration is good for:
- Sending emails from your application
- Using as an SMTP relay
- Development and testing

### Option 2: Full Mail Server (Not Recommended for Railway)

If you need full mail server functionality (receiving emails), Railway is not suitable. Consider:

1. **DigitalOcean**: Better for mail servers
2. **Linode**: Mail server friendly
3. **AWS EC2**: More control over networking
4. **Hetzner**: European alternative

## Alternative: Deploy to DigitalOcean with Docker

### Create Droplet

```bash
# Using doctl (DigitalOcean CLI)
doctl compute droplet create mailserver \
  --size s-1vcpu-1gb \
  --image docker-20-04 \
  --region nyc1 \
  --ssh-keys YOUR_SSH_KEY_ID
```

### Deploy via SSH

```bash
# SSH into droplet
ssh root@YOUR_DROPLET_IP

# Clone repository
git clone https://github.com/yourusername/mail-server.git
cd mail-server

# Start mail server
docker compose up -d
```

### Automate with GitHub Actions

Create `.github/workflows/deploy-digitalocean.yml`:

```yaml
name: Deploy to DigitalOcean

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to DigitalOcean
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.DO_HOST }}
          username: ${{ secrets.DO_USERNAME }}
          key: ${{ secrets.DO_SSH_KEY }}
          script: |
            cd /root/mail-server
            git pull
            docker compose pull
            docker compose up -d
```

## Troubleshooting

### Deployment Fails

**Check logs:**

```bash
# Via Railway CLI
railway logs

# Or in Railway Dashboard → your project → Deployments → View Logs
```

**Common issues:**
- Missing environment variables
- Volume mount issues
- Port conflicts
- Memory limits exceeded

### Can't Receive Emails

This is expected on Railway because:
1. Port 25 is blocked
2. No static IP address
3. PTR records can't be set

**Solution**: Use a VPS instead of Railway for receiving emails.

### Can't Send Emails

**Check:**
1. Port 587 is accessible
2. SSL certificates are valid
3. SMTP authentication is configured
4. DNS records (SPF, DKIM) are correct

```bash
# Test SMTP submission
telnet mail.sohanfahad.dev 587
```

### Railway Logs Show Errors

```bash
# View live logs
railway logs --follow

# View specific service logs
railway logs --service mailserver
```

## Cost Estimation

### Railway Pricing

- **Starter Plan**: $5/month
  - $5 of usage included
  - Additional usage billed monthly
  - Suitable for testing/development

- **Pro Plan**: $20/month
  - $20 of usage included
  - Better for production workloads

### DigitalOcean Pricing (Recommended for Production)

- **Basic Droplet**: $6/month
  - 1 GB RAM / 1 vCPU
  - 25 GB SSD
  - 1 TB transfer
  - Perfect for mail server

- **Regular Droplet**: $12/month
  - 2 GB RAM / 1 vCPU
  - 50 GB SSD
  - 2 TB transfer
  - Better performance

## Production Checklist

Before going live with your mail server:

- [ ] DNS records configured (A, MX, SPF, DKIM, DMARC)
- [ ] PTR record set by hosting provider
- [ ] SSL certificates configured (Let's Encrypt)
- [ ] Port 25 accessible (verify with hosting provider)
- [ ] Firewall rules configured
- [ ] Backup strategy in place
- [ ] Monitoring set up
- [ ] Test email sending/receiving
- [ ] Check mail-tester.com score (aim for 10/10)
- [ ] Email accounts created
- [ ] Aliases configured (if needed)

## Backup Strategy

### Manual Backup

```bash
# Create backup
./setup.sh backup

# Download from Railway
railway run backup.sh
```

### Automated Backup

Create a GitHub Actions workflow for automated backups:

```yaml
name: Backup Mail Data

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Backup mail data
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
        run: |
          npm install -g @railway/cli
          railway run ./setup.sh backup
          
      - name: Upload to S3
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - run: aws s3 cp mail-backup-*.tar.gz s3://your-backup-bucket/
```

## Monitoring

### Railway Metrics

Railway provides:
- CPU usage
- Memory usage
- Network traffic
- Deployment history

Access in Dashboard → your project → Metrics

### Custom Monitoring

Add monitoring tools:

```bash
# Healthcheck endpoint
curl https://your-railway-url.railway.app/health

# Check logs
railway logs --follow
```

## Support and Resources

### Railway Support
- [Railway Documentation](https://docs.railway.app/)
- [Railway Discord](https://discord.gg/railway)
- [Railway Status](https://status.railway.app/)

### Mail Server Support
- [docker-mailserver Docs](https://docker-mailserver.github.io/docker-mailserver/latest/)
- [docker-mailserver GitHub](https://github.com/docker-mailserver/docker-mailserver)
- [docker-mailserver Discord](https://discord.gg/docker-mailserver)

## Conclusion

**For Testing/Development**: Railway works fine with limitations.

**For Production**: Strongly recommend:
1. DigitalOcean Droplet ($6/month)
2. Linode VPS ($5/month)
3. Hetzner Cloud (€4/month)

These providers:
- Don't block port 25
- Provide static IPs
- Allow PTR record configuration
- Are optimized for mail servers

