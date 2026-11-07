# atomicboolean.me

Static marketing site. No build step, no dependencies, no JavaScript.

```
index.html      landing page
privacy.html    privacy policy
terms.html      terms of service
404.html        not-found page (GitHub Pages serves this automatically)
styles.css      all styling
CNAME           custom domain for GitHub Pages
.nojekyll       stops Jekyll from processing the folder
robots.txt
sitemap.xml
_headers        security headers — Cloudflare Pages only, ignored by GitHub
setup.ps1       rebrand helper (name + domain in one command)
```

Preview locally:

```powershell
cd C:\Users\lenovo\startup-site
python -m http.server 8080
# open http://localhost:8080
```

---

## Deploy to GitHub Pages

1. Copy every file in this folder into the root of your Pages repo.
   **This overwrites the current `index.html`** — if the live site has content you
   want to keep, move it aside first.

2. Commit and push to the branch Pages is configured to serve (usually `main`, root `/`).

3. Repo → Settings → Pages → confirm **Source: Deploy from a branch**, branch `main`, folder `/ (root)`.

4. Custom domain should already read `atomicboolean.me` because of the `CNAME` file.
   If it doesn't, type it in and save.

5. Tick **Enforce HTTPS** once the certificate finishes provisioning (can take up to an hour).

### DNS the domain needs

For an apex domain on GitHub Pages:

| Type | Name | Value |
|---|---|---|
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |
| AAAA | `@` | `2606:50c0:8000::153` |
| AAAA | `@` | `2606:50c0:8001::153` |
| AAAA | `@` | `2606:50c0:8002::153` |
| AAAA | `@` | `2606:50c0:8003::153` |
| CNAME | `www` | `<your-github-username>.github.io` |

If the site is already live on the domain, these are already in place. Leave them alone.

**Do not proxy these through Cloudflare** (orange cloud) unless you know what you're
doing — GitHub Pages plus a proxy is a common source of redirect loops. DNS-only
(grey cloud) is the safe setting.

---

## Email on the domain

This is the part the AWS application actually looks at. You need to be able to
**receive** at `founder@atomicboolean.me` and **send** from it.

### Receive — 5 minutes

Check your registrar first. Porkbun and Namecheap both include free email forwarding;
if yours does, use it and skip the rest.

Otherwise, ImprovMX (free tier, works with any DNS):

1. `improvmx.com` → add domain `atomicboolean.me`
2. Add the records it shows you:

| Type | Name | Value | Priority |
|---|---|---|---|
| MX | `@` | `mx1.improvmx.com` | 10 |
| MX | `@` | `mx2.improvmx.com` | 20 |
| TXT | `@` | `v=spf1 include:spf.improvmx.com ~all` | — |

3. Create the alias `founder@atomicboolean.me` → forwards to your Gmail
4. Confirm the verification email

**Done when:** you send from your phone to `founder@atomicboolean.me` and it lands in Gmail.

### Send — 10 minutes

Gmail → Settings → **Accounts and Import** → "Send mail as" → **Add another email address**:

```
Name:           Atomic Boolean
Email:          founder@atomicboolean.me
Treat as alias: unchecked
SMTP server:    smtp.gmail.com
Port:           465 (SSL)
Username:       your.address@gmail.com
Password:       an App Password (myaccount.google.com/apppasswords, needs 2FA)
```

Caveat: messages are signed by Gmail, so strict DMARC receivers show "via gmail.com".
Fine for replying to a reviewer. If you later want it clean, Migadu ($19/yr) or
Purelymail ($10/yr) give you real SMTP with DKIM on your own domain.

Add a DMARC record regardless:

| Type | Name | Value |
|---|---|---|
| TXT | `_dmarc` | `v=DMARC1; p=none; rua=mailto:founder@atomicboolean.me` |

### Test it

Send a message from `founder@atomicboolean.me` to the address at `mail-tester.com`.
8/10 or better means you're authenticated. If SPF fails, you have two SPF TXT records —
merge them into one.

---

## Before you apply

The site exists to make the domain look like a real company. These are the things
a reviewer checks, in order of how often they fail:

- [ ] `https://atomicboolean.me` loads with a padlock, no warning
- [ ] `founder@atomicboolean.me` receives and sends
- [ ] The **team block** in `index.html` (~line 239) has your real name and LinkedIn URL
- [ ] No placeholder text anywhere:

```powershell
Select-String -Path *.html -Pattern 'Your Name|TODO|Lorem|example\.com'
```

The only expected hit is `<h3>Your Name</h3>`. Everything else should be clean.

---

## Rebranding again

If the name or domain ever changes:

```powershell
.\setup.ps1 -Name "New Name" -Domain "newdomain.me"
```

Updates all HTML, XML, TXT and CSS files, then reports leftovers. It does not touch
`README.md` or `CNAME` — update those by hand.
