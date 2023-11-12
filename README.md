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

The above command asks the target_URL & Scope_URL.<br>
**target_URL:** The URL of the target website that should be accessible.<br>
**Scope_URL:** The URL that indicates the scope of our work/application (helps to find the files/folder using Hakrawler, dirsearch, Katana etc.,).

**Note:** A Google Custom Search Engine (CSE) was implemented in the code for advanced google dorking. So, you need to give/append your own API keys in the code. You can create your own Google Custom Search Engine (CSE) keys for free by navigating link https://console.cloud.google.com/apis/api/customsearch.googleapis.com/metrics?project=first-discovery-400216.

**Vulnerability Scan Report:**
After the scan completed, a detailed report will be generated as a HTML file. Let's now navigate to the report.

![Screenshot (85)](https://github.com/madhu1234567890/VA-Tool/assets/46317449/d8faf176-72aa-4afb-8055-814f1f13b06e)
![Screenshot (86)](https://github.com/madhu1234567890/VA-Tool/assets/46317449/a2081255-0bb1-43a9-848b-cf33c842923a)
![Screenshot (88)](https://github.com/madhu1234567890/VA-Tool/assets/46317449/b22a3a3d-1ea0-4b52-b00a-97691132e0aa)
![Screenshot (89)](https://github.com/madhu1234567890/VA-Tool/assets/46317449/c9082fbd-3268-4090-be5c-4f0e48412a44)
![Screenshot (90)](https://github.com/madhu1234567890/VA-Tool/assets/46317449/330bad42-e09e-4865-ba24-6a6eb132d38e)


