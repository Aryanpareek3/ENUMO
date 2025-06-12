#!/bin/bash

set -eo pipefail

TARGET="$1"
OUTDIR="autohack-$TARGET"
SUBDOMAINS_WORDLIST="/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt"
DIR_WORDLIST="/usr/share/seclists/Discovery/Web-Content/common.txt"
DALFOX=$(command -v dalfox || echo "$HOME/go/bin/dalfox")

RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; NC="\e[0m"

warn() { echo -e "${YELLOW}[!] $1${NC}"; }
log() { echo -e "${GREEN}[+] $1${NC}"; }
error() { echo -e "${RED}[-] $1${NC}"; }

banner() {
 echo -e "${BLUE}
 A Easy to use Tool by Aryan Pareek
███████╗███╗   ██╗██╗   ██╗ ███╗   ███╗ ██████╗ 
██╔════╝████╗  ██║██║   ██║ ████╗ ████║██╔═══██╗
█████╗  ██╔██╗ ██║██║   ██║ ██╔████╔██║██║   ██║
██╔══╝  ██║╚██╗██║██║   ██║ ██║╚██╔╝██║██║   ██║
███████╗██║ ╚████║╚██████╔╝ ██║ ╚═╝ ██║╚██████╔╝
╚══════╝╚═╝  ╚═══╝ ╚═════╝  ╚═╝     ╚═╝ ╚═════╝ 
${NC}"
  echo -e "${YELLOW}🌐 AutoHack: Web Recon & Exploit Toolkit${NC}"
  echo -e "${GREEN}Target: $TARGET | Output: $OUTDIR${NC}"
}

if [ -z "$TARGET" ]; then
  error "Usage: $0 <target-ip-or-domain>"
  exit 1
fi

mkdir -p "$OUTDIR/nmap" "$OUTDIR/ffuf" "$OUTDIR/xss" "$OUTDIR/loot"

nmap_scan() {
  if [ -n "$SKIP_NMAP" ]; then
    warn "Skipping Nmap scan as per request."
    return
  fi
  log "Running full Nmap scan (all ports)..."
  nmap -sC -sV -p- "$TARGET" -oN "$OUTDIR/nmap/full.txt"
}

nmap_vuln_scan() {
  if [ -n "$SKIP_NMAP_VULN" ]; then
    warn "Skipping Nmap vulnerability scan as per request."
    return
  fi
  log "Running Nmap vulnerability scan..."
  PORTS=$(grep ^[0-9] "$OUTDIR/nmap/full.txt" | cut -d '/' -f1 | paste -sd ',' -)
  [ -z "$PORTS" ] && warn "No open ports found." && return
  nmap -p "$PORTS" --script vuln "$TARGET" -oN "$OUTDIR/nmap/vuln.txt"
}

whatweb_scan() {
  if [ -n "$SKIP_WHATWEB" ]; then
    warn "Skipping WhatWeb scan as per request."
    return
  fi
  log "Running WhatWeb technology detection..."
  whatweb "$TARGET" > "$OUTDIR/whatweb.txt" &
}

nikto_scan() {
  if [ -n "$SKIP_NIKTO" ]; then
    warn "Skipping Nikto scan as per request."
    return
  fi
  log "Running Nikto web vuln scan (background)..."
  nikto -h http://"$TARGET" -Tuning 1,2,3 > "$OUTDIR/nikto.txt" &
}

ffuf_scan() {
  if [ -n "$SKIP_FFUFDIR" ]; then
    warn "Skipping FFUF directory fuzzing as per request."
    return
  fi
  log "Running FFUF directory fuzzing (filtering HTTP codes 200,204,301,302,307,401,403)..."
  ffuf -u http://"$TARGET"/FUZZ \
       -w "$DIR_WORDLIST" \
       -t 50 \
       -mc 200,204,301,302,307,401,403 \
       -o "$OUTDIR/ffuf/result.json" -of json
}

ffuf_subdomain_scan() {
  if [ -n "$SKIP_FFUFSUB" ]; then
    warn "Skipping FFUF subdomain fuzzing as per request."
    return
  fi
  log "Running FFUF subdomain fuzzing (filtering HTTP codes 200,204,301,302,307,401,403)..."
  if [ ! -f "$SUBDOMAINS_WORDLIST" ]; then
    warn "Subdomain wordlist not found, skipping subdomain fuzzing."
    return
  fi
  ffuf -w "$SUBDOMAINS_WORDLIST" \
       -u http://FUZZ."$TARGET" \
       -t 50 \
       -mc 200,204,301,302,307,401,403 \
       -o "$OUTDIR/ffuf/subdomains.json" -of json
}

xss_scan() {
  if [ -n "$SKIP_XSS" ]; then
    warn "Skipping XSS scan as per request."
    return
  fi
  if ! command -v "$DALFOX" &> /dev/null; then
    warn "Dalfox not found, skipping XSS scan."
    return
  fi
  log "Running Dalfox XSS scan on top 5 URLs..."
  if [ ! -f "$OUTDIR/ffuf/result.json" ]; then
    warn "FFUF results not found, skipping XSS."
    return
  fi
  URLS=$(jq -r '.results[].input.FUZZ' "$OUTDIR/ffuf/result.json" | grep '=' | head -n 5)
  for path in $URLS; do
    safe_path=${path//\//_}
    log "Testing XSS at http://$TARGET/$path"
    "$DALFOX" url "http://$TARGET/$path" --no-spinner > "$OUTDIR/xss/$safe_path.txt"
  done
}

search_exploits() {
  if [ -n "$SKIP_EXPLOITS" ]; then
    warn "Skipping exploit search as per request."
    return
  fi
  log "Running exploit search (searchsploit)..."
  grep -oP '\d+/tcp\s+open\s+\S+\s+\K.*' "$OUTDIR/nmap/full.txt" | while read -r svc; do
    echo -e "\n🔍 $svc" >> "$OUTDIR/loot/exploits.txt"
    searchsploit "$svc" >> "$OUTDIR/loot/exploits.txt"
  done
}

main() {
  banner
  nmap_scan
  nmap_vuln_scan
  whatweb_scan
  nikto_scan
  ffuf_scan
  ffuf_subdomain_scan
  xss_scan
  search_exploits

  wait # wait for background tasks (whatweb, nikto)

  log "All done! Results saved in: $OUTDIR"
}

main
