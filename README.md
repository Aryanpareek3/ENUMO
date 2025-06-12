# ENUMO
ENUMO — Automated Web Reconnaissance & Exploitation Toolkit

ENUMO is a powerful, easy-to-use automation script designed to streamline the process of web reconnaissance and vulnerability discovery. Combining the capabilities of trusted security tools like Nmap, WhatWeb, Nikto, FFUF, Dalfox, and Searchsploit, ENUMO provides comprehensive scanning and analysis with minimal manual effort.

Perfectly suited for penetration testers, bug bounty hunters, and CTF enthusiasts, ENUMO accelerates the enumeration and exploitation phases by automating the discovery of open ports, web technologies, directories, subdomains, potential XSS vulnerabilities, and known exploits.

Key Benefits:

Saves valuable time during CTF challenges and real-world penetration tests

Helps identify hidden attack surfaces on target machines quickly

Simplifies workflow by consolidating multiple reconnaissance tools into a single script

Modular design allows skipping specific scans as needed

Outputs well-organized reports for efficient analysis

Whether you are solving complex CTF machines or conducting authorized security assessments, ENUMO provides a solid foundation to identify vulnerabilities and move towards exploitation faster and more effectively.

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
