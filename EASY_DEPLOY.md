# Easiest Way to Deploy - Railway Web Dashboard

Forget the CLI! Use the web dashboard instead - it's much simpler.

## 🚀 Deploy in 5 Minutes (Web UI)

### Step 1: Open Railway Dashboard

Go to: **https://railway.app/dashboard**

### Step 2: Open Your Project

Click on: **mail-server-2**

### Step 3: Create New Service

1. Click **"+ New"** button
2. Select **"GitHub Repo"**
3. Choose repository: **sohan-fahad/mail-server**
4. Railway will automatically detect your Dockerfile
5. Click **"Deploy"**

That's it! Railway will build and deploy automatically! 🎉

### Step 4: Watch Deployment

- You'll see build logs in real-time
- Wait for "Deployment successful" (3-5 minutes)
- Service will show as "Active"

### Step 5: Configure Volumes (Important!)

1. Click on your service
2. Go to **Settings** tab
3. Click **Volumes** section
4. Add these volumes:

| Mount Path | Size |
|------------|------|
| `/var/mail` | 5 GB |
| `/var/mail-state` | 1 GB |
| `/tmp/docker-mailserver` | 500 MB |

### Step 6: Get Service URL

1. In your service dashboard
2. Look for **"Deployments"** section
3. Copy the URL or IP address
4. Use this for your Cloudflare DNS

### Step 7: Create Email Accounts (Via Dashboard)

1. Click **"Connect"** or **"Shell"** button in service
2. This opens a web-based terminal
3. Run these commands:

```bash
setup email add admin@chalan.co password123
setup config dkim
cat /tmp/docker-mailserver/opendkim/keys/chalan.co/mail.txt
```

4. Copy the DKIM key for Cloudflare

## ✅ Done!

Your mail server is deployed! No CLI struggles needed.

## 📋 Next Steps

1. ✅ Update Cloudflare DNS with Railway IP
2. ✅ Add DKIM key to Cloudflare
3. ✅ Test email sending
4. ✅ Check deliverability

## 💡 Why This is Better

- ✅ No CLI installation issues
- ✅ No interactive prompt problems
- ✅ Visual feedback on build progress
- ✅ Easy access to logs and metrics
- ✅ One-click shell access

## 🔗 Quick Links

- **Railway Dashboard**: https://railway.app/dashboard
- **Your Project**: https://railway.app/project/mail-server-2
- **Docs**: https://docs.railway.app/

## 🆘 If You Get Stuck

Just click around the Railway dashboard - it's very intuitive:
- **Logs**: Click "Logs" tab
- **Shell**: Click "Connect" or "Shell" button
- **Settings**: Click "Settings" tab
- **Metrics**: Click "Metrics" tab

That's all! Much easier than fighting with the CLI! 🎉

