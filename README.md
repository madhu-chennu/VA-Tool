# VA-Tool

A Vulnerability Assessment tool written in bash with a focus on reliability and simplicity. Designed to be used in combination with other tools for attack surface discovery in bug bounties and pentests.

# Features
+ Comprehensive directory & file brute forcing using dirbuster, dirsearch, Hakrawler, Katana.
+ Identify web technologies including content management systems (CMS), blogging platforms, statistic/analytics packages, JavaScript libraries, web servers, and embedded devices.
+ Detecting web server misconfigurations using Nikto web scanner.
+ Performing Nuclei template-based scanning for specific vulnerability identification like SQL, XSS, LFI, cmdi, crlf, csti, redirect, RFI, SSRF, ssti, XXE etc.,
+ Network port scanning using NMAP.
+ Advanced Google dorking capabilities like Locate Sensitive Files, Find Login Pages, Directory Listing, Discover Cached Pages, Identify Technology Stack, Finding Open Redirects etc.,
+ Executing Wapiti to scan for web-application vulnerabilities.
+ Accessing all the recognized URLs simultaneously in a web browser with a single click.

# Installation
Download the repository using the following command:
```
git clone https://github.com/madhu-chennu/VA-Tool.git
```

Run the below command to download the neccessary tools into the local machine.
```
./requirements.sh
```

# Usage
```
./VA_Scanner.sh
```

The above command asks the target_URL & Scope_URL.<br>
**Target_URL:** The URL of the target website that should be accessible.<br>
**Scope_URL:** The URL that indicates the scope of our work/application (helps to find the files/folder using Hakrawler, dirsearch, Katana etc.,).

**Note:** A Google Custom Search Engine (CSE) was implemented in the code for advanced google dorking. So, you need to give/append your own API keys in the code. You can create your own Google Custom Search Engine (CSE) keys for free by navigating link https://console.cloud.google.com/apis/api/customsearch.googleapis.com/metrics?project=first-discovery-400216.

# Vulnerability Scan Report:
After the scan completed, a detailed report will be generated as a HTML file. Let's now navigate to the report.

![Screenshot (85)](https://github.com/madhu-chennu/VA-Tool/assets/46317449/2ff86c3c-c976-4294-9c39-0d144af70d71)
![Screenshot (86)](https://github.com/madhu-chennu/VA-Tool/assets/46317449/9560a469-5da0-4653-b7b9-4126f3040076)
![Screenshot (88)](https://github.com/madhu-chennu/VA-Tool/assets/46317449/6af76618-5f2c-4528-9859-a429f538e68e)
![Screenshot (89)](https://github.com/madhu-chennu/VA-Tool/assets/46317449/ad047c34-035c-4c42-986e-661923cca68e)
![Screenshot (90)](https://github.com/madhu-chennu/VA-Tool/assets/46317449/0d343f4a-6ee7-4bed-a10b-aa1650e8087f)

Happy Hunting :)
