<#
.SYNOPSIS
    Rebrands the site in one command: product name + domain.

.DESCRIPTION
    Replaces the placeholder brand "Relayline" and the placeholder domain
    "relayline.me" across every HTML, XML, TXT and CSS file in this folder,
    then reports any placeholders still left behind.

.EXAMPLE
    .\setup.ps1 -Name "Acme" -Domain "acme.me"

.EXAMPLE
    .\setup.ps1 -Name "Northwind Labs" -Domain "northwind.dev"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9 .&''\-]{0,40}$')]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9][a-z0-9\-]{0,60}(\.[a-z]{2,20}){1,2}$')]
    [string]$Domain
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

$oldName   = 'Relayline'
$oldDomain = 'relayline.me'

if ($Name -eq $oldName -and $Domain -eq $oldDomain) {
    Write-Host 'Nothing to do - name and domain already set.' -ForegroundColor Yellow
    exit 0
}

$targets = Get-ChildItem -Path $root -File -Recurse |
    Where-Object { $_.Extension -in '.html', '.xml', '.txt', '.css' -and $_.Name -ne 'setup.ps1' }

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$changed = 0

foreach ($file in $targets) {
    $before = [System.IO.File]::ReadAllText($file.FullName)
    $after = $before.
        Replace($oldDomain, $Domain).
        Replace($oldName, $Name).
        Replace($oldName.ToLowerInvariant(), $Name.ToLowerInvariant())

    if ($after -ne $before) {
        [System.IO.File]::WriteAllText($file.FullName, $after, $utf8NoBom)
        Write-Host ("  updated  {0}" -f $file.Name)
        $changed++
    }
}

Write-Host ''
Write-Host ("{0} file(s) updated -> {1} / {2}" -f $changed, $Name, $Domain) -ForegroundColor Green

# --- leftover check -------------------------------------------------------
Write-Host ''
Write-Host 'Checking for placeholders...' -ForegroundColor Cyan

$patterns = 'Relayline|relayline\.me|Your Name|yourdomain\.me|TODO|Lorem ipsum|example\.com|FIXME'
$leftovers = Select-String -Path (Join-Path $root '*.html') -Pattern $patterns -AllMatches

if ($leftovers) {
    Write-Host 'Placeholders still present:' -ForegroundColor Yellow
    foreach ($hit in $leftovers) {
        Write-Host ("  {0}:{1}  {2}" -f $hit.Filename, $hit.LineNumber, $hit.Line.Trim())
    }
    Write-Host ''
    Write-Host 'The team block in index.html is intentional - fill it with your real name and LinkedIn URL.' -ForegroundColor Yellow
}
else {
    Write-Host '  clean.' -ForegroundColor Green
}

# --- summary --------------------------------------------------------------
Write-Host ''
Write-Host 'Next:' -ForegroundColor Cyan
Write-Host '  1. Edit the .team block in index.html (real name, real LinkedIn URL)'
Write-Host '  2. Rewrite the hero + #product copy if your product is not webhook delivery'
Write-Host ("  3. Set up email routing so you can send as hello@{0}" -f $Domain)
Write-Host ("  4. Commit, push. GitHub Pages serves the repo root. CNAME file must contain {0}" -f $Domain)
Write-Host '  5. Apply at https://aws.amazon.com/startups/credits (Founders tier)'
