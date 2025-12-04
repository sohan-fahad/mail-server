# Webmail and Admin UI Setup

docker-mailserver doesn't include a web UI by default, but you can easily add one! Here are your options:

## 🎨 Web UI Options

### 1. **Roundcube** (Recommended for Production)
Modern, feature-rich webmail interface

**Features:**
- ✅ Read and send emails via web browser
- ✅ Contact management
- ✅ Calendar integration
- ✅ Multiple accounts support
- ✅ Mobile-responsive
- ✅ Plugin ecosystem

### 2. **Rainloop** 
Fast and simple webmail client

**Features:**
- ✅ Clean, modern interface
- ✅ Multiple accounts
- ✅ Contacts management
- ✅ Very lightweight

### 3. **SnappyMail**
Fork of Rainloop with modern features

**Features:**
- ✅ Modern UI
- ✅ Fast performance
- ✅ Active development
- ✅ Better security

### 4. **MailCrab** (For Development/Testing)
Email testing tool that catches all outgoing emails

**Features:**
- ✅ See all sent emails in web UI
- ✅ Perfect for development
- ✅ No actual email sending
- ✅ Real-time updates

## 🚀 Quick Setup with Roundcube

### Option 1: Use the Complete Setup

I've created `docker-compose-with-webmail.yaml` for you with Roundcube included!

```bash
# Stop current mail server
docker compose down

# Start with webmail
docker compose -f docker-compose-with-webmail.yaml up -d

# Access webmail at:
# http://localhost:8080
```

**Login with:**
- Username: `admin@chalan.co`
- Password: `SecurePassword123` (the password you set)

### Option 2: Add to Existing Setup

Add this to your `docker-compose.yaml`:

```yaml
  roundcube:
    image: roundcube/roundcubemail:latest
    container_name: roundcube
    ports:
      - "8080:80"
    environment:
      - ROUNDCUBEMAIL_DEFAULT_HOST=ssl://mailserver
      - ROUNDCUBEMAIL_DEFAULT_PORT=993
      - ROUNDCUBEMAIL_SMTP_SERVER=tls://mailserver
      - ROUNDCUBEMAIL_SMTP_PORT=587
    volumes:
      - ./docker-data/roundcube/www:/var/www/html
      - ./docker-data/roundcube/db/sqlite:/var/roundcube/db
    depends_on:
      - mailserver
    restart: always
    networks:
      - mail-network

networks:
  mail-network:
    driver: bridge
```

Then update mailserver service to use the network:

```yaml
services:
  mailserver:
    # ... existing config ...
    networks:
      - mail-network
```

## 🌐 Production Deployment

For production with a domain:

### 1. Add DNS Record

```
Type: A
Name: webmail
IPv4 address: YOUR_SERVER_IP
Proxy status: Proxied (orange cloud 🟠)
```

### 2. Update Roundcube Port

In `docker-compose.yaml`, change:

```yaml
roundcube:
  ports:
    - "80:80"  # or "443:443" for HTTPS
```

### 3. Access Your Webmail

Visit: `http://webmail.chalan.co`

Or set up SSL with Let's Encrypt for: `https://webmail.chalan.co`

## 📊 Alternative: Admin Panels

### PostfixAdmin
Manage email accounts, domains, and aliases via web UI

```yaml
  postfixadmin:
    image: postfixadmin/postfixadmin:latest
    container_name: postfixadmin
    ports:
      - "8081:80"
    environment:
      - POSTFIXADMIN_DB_TYPE=sqlite
      - POSTFIXADMIN_SETUP_PASSWORD=changeme
    volumes:
      - ./docker-data/postfixadmin:/var/www/html
    networks:
      - mail-network
```

Access at: `http://localhost:8081`

### Mailu Admin
Complete email server with built-in admin panel

**Note**: Mailu is a complete alternative to docker-mailserver, not an add-on.

## 🔧 Testing with MailCrab (Development)

MailCrab is included in the webmail setup! Access it at:

```
http://localhost:1080
```

**Use Cases:**
- Test email sending without actually sending
- See email formatting and content
- Debug email issues
- Safe testing environment

## 📱 Mobile Email Clients

You can also use mobile/desktop email clients:

### iOS Mail
- Server: `mail.chalan.co`
- IMAP Port: 993 (SSL)
- SMTP Port: 587 (STARTTLS)
- Username: `admin@chalan.co`
- Password: Your password

### Android Gmail App
- Add account → Other
- IMAP: `mail.chalan.co:993`
- SMTP: `mail.chalan.co:587`

### Thunderbird (Desktop)
- Add Mail Account
- Auto-detect settings should work
- Manual: IMAP 993 (SSL), SMTP 587 (STARTTLS)

### Apple Mail (macOS)
- Add Account → Other Mail Account
- Server: `mail.chalan.co`
- Auto-configuration should work

## 🎯 Recommended Setup

### For Development/Testing
```bash
docker compose -f docker-compose-with-webmail.yaml up -d
```

Access:
- Roundcube: http://localhost:8080
- MailCrab: http://localhost:1080

### For Production
1. Use `docker-compose-with-webmail.yaml`
2. Change Roundcube port to 80 or 443
3. Add DNS record for `webmail.chalan.co`
4. Set up SSL with Let's Encrypt
5. Optionally add PostfixAdmin for user management

## 🔒 Security Tips

1. **Use SSL in Production**
   - Always use HTTPS for webmail
   - Configure Let's Encrypt certificates

2. **Secure Roundcube**
   ```yaml
   environment:
     - ROUNDCUBEMAIL_PLUGINS=password,enigma  # Enable encryption
     - ROUNDCUBEMAIL_ASPELL_DICTS=en  # Spell checking
   ```

3. **Change Default Passwords**
   - Set strong database passwords
   - Use environment variables for secrets

4. **Enable 2FA**
   - Use Roundcube plugins for two-factor authentication

## 📝 Quick Commands

```bash
# Start with webmail
docker compose -f docker-compose-with-webmail.yaml up -d

# View logs
docker compose -f docker-compose-with-webmail.yaml logs -f roundcube

# Restart webmail only
docker compose -f docker-compose-with-webmail.yaml restart roundcube

# Access roundcube container
docker compose exec roundcube bash

# Stop all services
docker compose -f docker-compose-with-webmail.yaml down
```

## 🌟 Comparison Table

| Feature | Roundcube | Rainloop | SnappyMail | MailCrab |
|---------|-----------|----------|------------|----------|
| Purpose | Webmail | Webmail | Webmail | Testing |
| UI Quality | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Performance | Medium | Fast | Fast | Very Fast |
| Plugins | Many | Some | Growing | N/A |
| Mobile Support | Yes | Yes | Yes | Yes |
| Active Development | Yes | No | Yes | Yes |
| Best For | Production | Simple setup | Modern features | Development |

## 🎬 Next Steps

1. Choose your webmail solution (Roundcube recommended)
2. Start with the webmail setup
3. Access the web UI and login
4. Configure your email client or use webmail
5. Send test emails

Ready to try it? Run:

```bash
docker compose -f docker-compose-with-webmail.yaml up -d
```

Then visit: **http://localhost:8080** 🎉

