# ENUMO
**ENUOG** is an automated web reconnaissance and exploitation toolkit designed to streamline your pentesting workflow. It combines multiple powerful tools into one script for quick and thorough assessment of target domains or IP addresses.
## Requirements

Make sure the following tools are installed and accessible in your system’s PATH:

- `nmap`
- `whatweb`
- `nikto`
- `ffuf`
- `dalfox` (optional; required for XSS scanning)
- `searchsploit`
- `jq` (for JSON parsing)

Wordlists used by default are from [SecLists](https://github.com/danielmiessler/SecLists):

- Subdomains wordlist: `/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt`  
- Directory wordlist: `/usr/share/seclists/Discovery/Web-Content/common.txt`

You can modify the script to use your preferred wordlists.
