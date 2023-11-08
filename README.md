# VA-Tool
Some vulnerability assessment tools at one place.

A Vulnerability Assessment tool written in bash with a focus on reliability and simplicity. Designed to be used in combination with other tools for attack surface discovery in bug bounties and pentests.

The tool written in bash that allows you to run some other VA tools on the target server. It is a really simple tool that does run some of the other tools automatically by taking the input from the end user.

# Features
+ Comprehensive directory & file brute forcing using dirbuster, dirsearch, Hakrawler, Katana.
+ Identify web technologies including content management systems (CMS), blogging platforms, statistic/analytics packages, JavaScript libraries, web servers, and embedded devices.
+ Detecting web server misconfigurations using Nikto web scanner.
+ Performing Nuclei template-based scanning for specific vulnerability identification like SQL, XSS, LFI, cmdi, crlf, csti, redirect, RFI, SSRF, ssti, XXE etc.,
+ Network port scanning using NMAP.
+ Advanced Google dorking capabilities like Locate Sensitive Files, Find Login Pages, Directory Listing, Discover Cached Pages, Identify Technology Stack, Finding Open Redirects etc.,
+ Executing Wapiti to scan for web-application vulnerabilities.

# Installation
Download the repository using the following command:
> git clone https://github.com/madhu1234567890/VA-Tool.git

Run the below command to download the neccessary tools into the local machine.
> ./requirements.sh

# Usage
> ./final_code.sh
The above command asks the target_URL & Scope_URL.
**target_URL:** The URL of the target website that should be accessible.
**Scope_URL:** The URL that indicates the scope of our work/application (helps to find the files/folder using Hakraler, dirsearch, Katana etc.,).


