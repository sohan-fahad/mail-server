# Cloudflare DNS Setup for mail.sohanfahad.dev

This guide walks you through setting up all necessary DNS records in Cloudflare for your mail server.

## Prerequisites

- Cloudflare account with `sohanfahad.dev` domain
- Access to Cloudflare DNS management
- Your server's public IP address

## Step-by-Step Setup

### 1. Login to Cloudflare

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select your domain `sohanfahad.dev`
3. Navigate to **DNS** → **Records**

### 2. Add A Record for Mail Subdomain

Click **Add record** and enter:

```
Type: A
Name: mail
IPv4 address: <YOUR_SERVER_IP>
Proxy status: DNS only (click to turn off proxy - gray cloud ☁️)
TTL: Auto
```

**Important**: The proxy status MUST be "DNS only" (gray cloud), not proxied (orange cloud). Mail servers cannot work behind Cloudflare proxy.

### 3. Add MX Record

Click **Add record** and enter:

```
Type: MX
Name: @ (this represents sohanfahad.dev)
Mail server: mail.sohanfahad.dev
Priority: 10
TTL: Auto
```

### 4. Add SPF Record (TXT)

Click **Add record** and enter:

```
Type: TXT
Name: @ (this represents sohanfahad.dev)
Content: v=spf1 mx -all
TTL: Auto
```

**SPF Explanation:**
- `v=spf1` - SPF version 1
- `mx` - Allow mail servers listed in MX records to send email
- `-all` - Reject all other sources (strict policy)

**Alternative SPF policies:**
- `~all` - Soft fail (for testing)
- `?all` - Neutral (not recommended)

### 5. Generate and Add DKIM Record

#### Generate DKIM Keys

First, start your mail server and generate DKIM keys:

```bash
# Start the mail server
./setup.sh start

# Generate DKIM keys
./setup.sh generate-dkim
```

Or manually:

```bash
docker compose up -d
docker compose exec mailserver setup config dkim
```

#### View DKIM Public Key

```bash
cat docker-data/dms/config/opendkim/keys/sohanfahad.dev/mail.txt
```

You'll see something like:

```
mail._domainkey IN TXT ( "v=DKIM1; h=sha256; k=rsa; "
    "p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA..." ) ; ----- DKIM key mail for sohanfahad.dev
```

#### Add to Cloudflare

Click **Add record** and enter:

```
Type: TXT
Name: mail._domainkey
Content: v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
TTL: Auto
```

**Important**: 
- Remove the parentheses and quotes
- Combine all parts into a single line
- Only include the content between the first quote and last quote

### 6. Add DMARC Record (TXT)

Click **Add record** and enter:

```
Type: TXT
Name: _dmarc
Content: v=DMARC1; p=none; rua=mailto:postmaster@sohanfahad.dev; ruf=mailto:postmaster@sohanfahad.dev; fo=1
TTL: Auto
```

**DMARC Policy Options:**
- `p=none` - Monitor only (recommended for initial setup)
- `p=quarantine` - Suspicious emails go to spam (use after testing)
- `p=reject` - Reject suspicious emails (strictest, use when confident)

**DMARC Explanation:**
- `v=DMARC1` - DMARC version
- `p=none` - Policy for domain
- `rua` - Aggregate report email
- `ruf` - Forensic report email
- `fo=1` - Forensic reporting option

### 7. Add PTR Record (Reverse DNS)

**Note**: PTR records are typically managed by your hosting provider, not Cloudflare.

Contact your hosting provider (Railway, DigitalOcean, etc.) and request:

```
PTR Record: <YOUR_SERVER_IP> → mail.sohanfahad.dev
```

This is crucial for email deliverability!

### 8. Optional: Add CAA Record

This restricts which Certificate Authorities can issue certificates for your domain:

Click **Add record** and enter:

```
Type: CAA
Name: mail
Tag: issue
Value: letsencrypt.org
TTL: Auto
```

## Verification

### Wait for DNS Propagation

DNS changes can take 5 minutes to 48 hours to propagate globally. Usually takes 10-30 minutes.

### Check DNS Records

Use the setup script:

```bash
./setup.sh check-dns
```

Or manually:

```bash
# Check A record
dig mail.sohanfahad.dev A

# Check MX record
dig sohanfahad.dev MX

# Check SPF record
dig sohanfahad.dev TXT

# Check DKIM record
dig mail._domainkey.sohanfahad.dev TXT

# Check DMARC record
dig _dmarc.sohanfahad.dev TXT
```

### Online Tools

Use these tools to verify your setup:

1. **MXToolbox** - https://mxtoolbox.com/SuperTool.aspx
   - Check MX records
   - Check SPF records
   - Check DKIM records
   - Check DMARC records
   - Check blacklist status

2. **MX Lookup** - https://mxtoolbox.com/MXLookup.aspx
   - Verify MX records

3. **SPF Record Checker** - https://mxtoolbox.com/SPFRecordGenerator.aspx
   - Verify SPF record

4. **DKIM Checker** - https://mxtoolbox.com/dkim.aspx
   - Verify DKIM record

5. **DMARC Checker** - https://mxtoolbox.com/DMARC.aspx
   - Verify DMARC record

6. **Mail Tester** - https://www.mail-tester.com/
   - Send a test email and get a score
   - Comprehensive analysis of email deliverability

## Complete DNS Configuration Summary

Here's what your Cloudflare DNS should look like:

| Type | Name | Content | Proxy | TTL |
|------|------|---------|-------|-----|
| A | mail | YOUR_SERVER_IP | DNS only | Auto |
| MX | @ | mail.sohanfahad.dev (Priority: 10) | - | Auto |
| TXT | @ | v=spf1 mx -all | - | Auto |
| TXT | mail._domainkey | v=DKIM1; h=sha256; k=rsa; p=... | - | Auto |
| TXT | _dmarc | v=DMARC1; p=none; rua=mailto:... | - | Auto |

## Troubleshooting

### DNS Not Resolving

```bash
# Clear local DNS cache (macOS)
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Clear local DNS cache (Linux)
sudo systemd-resolve --flush-caches

# Check with different DNS servers
dig @8.8.8.8 mail.sohanfahad.dev
dig @1.1.1.1 mail.sohanfahad.dev
```

### SPF Too Long

If your SPF record is too long (>255 characters), split it or simplify:

```
v=spf1 mx include:_spf.sohanfahad.dev -all
```

Then create another TXT record at `_spf.sohanfahad.dev` with additional includes.

### DKIM Not Working

1. Ensure DKIM selector is correct: `mail._domainkey`
2. Check that public key is properly formatted (single line, no quotes)
3. Wait for DNS propagation
4. Test with: `dig mail._domainkey.sohanfahad.dev TXT`

### Email Going to Spam

1. Check all DNS records are correct
2. Verify PTR record is set
3. Ensure SPF, DKIM, and DMARC are passing
4. Test with mail-tester.com
5. Check if your IP is blacklisted: https://mxtoolbox.com/blacklists.aspx
6. Warm up your IP by sending gradually increasing volumes

## Security Best Practices

1. **Use DNS only (gray cloud)** - Never proxy mail records through Cloudflare
2. **Enable DNSSEC** - In Cloudflare Dashboard → DNS → Settings
3. **Start with p=none** - For DMARC, then gradually move to quarantine/reject
4. **Monitor reports** - Review DMARC reports sent to your rua email
5. **Keep records updated** - If you change servers, update A and PTR records

## Next Steps

After DNS is configured:

1. Start your mail server: `./setup.sh start`
2. Generate DKIM keys: `./setup.sh generate-dkim`
3. Add email accounts: `./setup.sh add-email admin@sohanfahad.dev yourpassword`
4. Send test emails
5. Check mail-tester.com score
6. Monitor logs: `./setup.sh logs`

## Resources

- [Cloudflare DNS Documentation](https://developers.cloudflare.com/dns/)
- [SPF Record Syntax](https://www.spf-record.com/)
- [DKIM Specifications](https://www.dkim.org/)
- [DMARC Guide](https://dmarc.org/)
- [Email Deliverability Best Practices](https://postmarkapp.com/guides/email-deliverability)

