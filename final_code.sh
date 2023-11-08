#!/bin/bash

# Prompt the user for the URL
read -p "Enter the URL: " main_url
read -p "Enter your scope [URL]: " scope_url

# Check if the URL is empty
if [ -z "$main_url" ]; then
    echo "URL cannot be empty. Exiting."
    exit 1
fi

# Get the current date and time
current_date=$(date +%y%m%d)  # YYMMDD
current_time=$(date +%H%M%S)    # HHMM

touch temp_dirb_${current_date}${current_time}.txt 200_dirbuster_${current_date}${current_time}.txt redirection_dirbuster_${current_date}${current_time}.txt 200_dirsearch_${current_date}${current_time}.txt redirection_dirsearch_${current_date}${current_time}.txt temp_dirsearch_${current_date}${current_time}.txt hakrawler_urls_${current_date}${current_time}.txt katana_urls_${current_date}${current_time}.txt final_redirection_urls_${current_date}${current_time}.txt

##################### Dirbuster ########################################
# Run dirb and save the output to a temporary file
echo "[+] Running Dirbuster tool..."
dirb_output=$(timeout 1800 dirb "$scope_url" -l -o temp_dirb_${current_date}${current_time}.txt)

# Input file
dirb_input_file="temp_dirb_${current_date}${current_time}.txt"

# Output file
dirb_output_file="200_dirbuster_${current_date}${current_time}.txt"
dirb_redirection_urls="redirection_dirbuster_${current_date}${current_time}.txt"

# Flag to start capturing dirb_lines
capture=0

# Loop through the dirb_lines in the input file
while IFS= read -r dirb_line
do
    # Check if the dirb_line contains "---- Scanning URL:"
    if [[ $dirb_line == *"---- Scanning URL:"* ]]; then
        capture=1
        continue
    fi

    # Check if the dirb_line contains "CODE:"
    if [[ $capture -eq 1 && $dirb_line == *"(CODE:"* ]]; then
        dirb_code=$(echo "$dirb_line" | grep -oP "(?<=\(CODE:)[0-9]+")
        if [[ $dirb_code -ge 200 && $dirb_code -lt 300 ]]; then
            dirb_final_url=$(echo "$dirb_line" | awk '{print $2}')
            echo "$dirb_final_url" >> "$dirb_output_file"
        elif [[ $dirb_code -ge 300 && $dirb_code -lt 400 ]]; then
            # Capture the next dirb_line which contains the location header
            read -r next_dirb_line
            location=$(echo "$next_dirb_line" | awk -F"'" '{print $2}')
            echo "$scope_url$location" >> "$dirb_redirection_urls"
        fi
    fi

    # Check if the dirb_line is empty, indicating the end of the block
    if [[ -z "$dirb_line" && $capture -eq 1 ]]; then
        break
    fi
done < "$dirb_input_file"

echo "Dirbuster scanning completed and the results saved to 200_dirbuster_${current_date}${current_time}.txt & redirection_dirbuster_${current_date}${current_time}.txt files.."


########################### Dirsearch #############################

# Run dirsearch and append the output to the temporary file
echo "[+] Running dirsearch tool..."
dirsearch_output=$(dirsearch -u "$scope_url" -o temp_dirsearch_${current_date}${current_time}.txt)

# Input file
dirsearch_input_file="temp_dirsearch_${current_date}${current_time}.txt"

# Output file
dirsearch_output_file="200_dirsearch_${current_date}${current_time}.txt"
dirsearch_redirection_URLs="redirection_dirsearch_${current_date}${current_time}.txt"

# Loop through each dirsearch_line in the input file
while IFS= read -r dirsearch_line; do
    # Extract the status code and URL from the dirsearch_line
    dirsearch_status_code=$(echo "$dirsearch_line" | awk '{print $1}')
    dirsearch_final_url=$(echo "$dirsearch_line" | awk '{print $3}')

    if [[ $dirsearch_line == \#* ]]; then
        continue
    fi

    # Check if the status code is in the range 200-299
    if [[ $dirsearch_status_code -ge 200 && $dirsearch_status_code -lt 300 ]]; then
        echo "$dirsearch_final_url" >> "$dirsearch_output_file"

    # Check if the status code is in the range 300-399
    elif [[ $dirsearch_status_code -ge 300 && $dirsearch_status_code -lt 400 ]]; then
        dirsearch_redirected_url=$(echo "$dirsearch_line" | awk -F '->' '{print $2}' | sed 's/REDIRECTS TO://' | tr -d '[:space:]')
        #check_status $dirsearch_redirected_url
        if  [[ $dirsearch_redirected_url == http* ]]; then 
            echo "$dirsearch_redirected_url" >> "$dirsearch_redirection_URLs"
        else
            echo "$scope_url$dirsearch_redirected_url" >> "$dirsearch_redirection_URLs"
        fi

    elif [[ $dirsearch_status_code -ge 400 ]]; then
        continue
    fi
done < "$dirsearch_input_file"

echo "Dirsearch scan completed and results was saved into 200_dirsearch_${current_date}${current_time}.txt & redirection_dirsearch_${current_date}${current_time}.txt files.."

######################### Hakrawler ##########################

echo "[+] Running hakrawler tool..."
echo "$scope_url" | hakrawler >> hakrawler_urls_${current_date}${current_time}.txt

########################### GAU ##############################

#echo "[+] Running GAU tool..."
#gau "$main_url" --mc 200 >> gau_urls_${current_date}${current_time}.txt

######################### Katana ###########################

echo "[+] Running Katana tool..."
katana -u "$scope_url" >> katana_urls_${current_date}${current_time}.txt

####################### Filtering ########################

final_redirection_urls="final_redirection_urls_${current_date}${current_time}.txt"

httpx -l "$dirb_redirection_urls" -mc 200 -silent >> "$final_redirection_urls"
httpx -l "$dirsearch_redirection_URLs" -mc 200 -silent >> "$final_redirection_urls"

cat 200_dirbuster_${current_date}${current_time}.txt 200_dirsearch_${current_date}${current_time}.txt hakrawler_urls_${current_date}${current_time}.txt katana_urls_${current_date}${current_time}.txt final_redirection_urls_${current_date}${current_time}.txt | sort | uniq > total_urls_${current_date}${current_time}.txt

# Extract the domain name without the port
domain_name_for_nuclei=$(echo "$main_url" | awk -F[/:] '{print $4}')

cat total_urls_${current_date}${current_time}.txt | grep "$domain_name_for_nuclei" > final_urls_${current_date}${current_time}.txt

echo "files/directory enumeration was completed and the results saved to final_urls_${current_date}${current_time}.txt file.."

############### Nikto #############

echo "[+} Running Nikto tool..."
# timeout 4000 nikto -h "$main_url" >> nikto_result_${current_date}${current_time}.txt
nikto -h "$main_url" >> nikto_result_${current_date}${current_time}.txt

############### Nuclei ###############

echo "[+] Running Nuclei tool..."
#timeout 2400 nuclei -u "$main_url" --no-color >> nuclei_result.txt

# Get the current user's home directory
home_dir=$(eval echo ~$USER)

# Check if ParamSpider is already cloned and installed
if [ ! -d "$home_dir/ParamSpider" ]; then
    echo "Cloning ParamSpider..."
    git clone https://github.com/0xKayala/ParamSpider "$home_dir/ParamSpider"
fi

# Check if fuzzing-templates is already cloned.
if [ ! -d "$home_dir/fuzzing-templates" ]; then
    echo "Cloning fuzzing-templates..."
    git clone https://github.com/projectdiscovery/fuzzing-templates.git "$home_dir/fuzzing-templates"
fi

# Check if nuclei is installed, if not, install it
if ! command -v nuclei &> /dev/null; then
    echo "Installing Nuclei..."
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
fi

# Extract the domain name without the port
# domain_name_for_nuclei=$(echo "$main_url" | awk -F[/:] '{print $4}')

# Get the vulnerable parameters of the given domain name using ParamSpider tool and save the output into a text file
python3 "$home_dir/ParamSpider/paramspider.py" -d "$domain_name_for_nuclei" --exclude png,jpg,gif,jpeg,swf,woff,gif,svg --level high --quiet -o output/paramSpider_result_${current_date}${current_time}.txt

# Finally run the Nuclei Fuzzing templates on the extracted URL's
cat output/paramSpider_result_${current_date}${current_time}.txt final_urls_${current_date}${current_time}.txt > all_urls_for_nuclei_${current_date}${current_time}.txt
#nuclei -l all_urls_for_nuclei_${current_date}${current_time}.txt -t "$home_dir/fuzzing-templates","/root/all_cves/" -rl 05 --no-color >> nuclei_result_${current_date}${current_time}.txt
#nuclei -l all_urls_for_nuclei_${current_date}${current_time}.txt -t "$home_dir/fuzzing-templates","/root/all_cves/" -rl 05 --no-color | sed -r "s/\x1B\[[0-9;]*[JKmsu]//g" >> nuclei_result_${current_date}${current_time}.txt
nuclei -l all_urls_for_nuclei_${current_date}${current_time}.txt -t "$home_dir/fuzzing-templates","/root/all_cves/" -rl 05 --no-color | sed -r "s/\x1B\[[0-9;]*[JKmsu]//g" >> nuclei_result_${current_date}${current_time}.txt

echo "[+] Completed: [*******.......] 50%"

################ Nmap #######################

echo "[+] Running NMAP..."

port_number=$(echo "$main_url" | awk -F: '{print $3}' | cut -d'/' -f1)
# If there is no port specified in the URL, default to 80
if [ -z "$port_number" ]; then
    port_number=80
fi

# Extract the domain name without the port
domain_name_without_port=$(echo "$main_url" | awk -F[/:] '{print $4}')

domain_name=$(echo "$main_url" | sed -E 's#^(https?://)?([0-9a-zA-Z.-]+).*#\2#')
timeout 3000 nmap -A -sV --script vuln "$domain_name" -p80,443,$port_number >> nmap_result_${current_date}${current_time}.txt

################# Google Dorking ##################

echo "[+] Running Google Dorking..."
# Define our Google Custom Search Engine (CSE) ID and API key
cse_id="5514f3e81558048c5"
api_key="AIzaSyCw4dxpwnN2L7ShpT6wn5j9ZAYhNZMfGVE"

# Define the base URL
#base_url="http://testphp.vulnweb.com"

# Define the list of queries along with custom headings
queries=(
  "Directory Listings: site:$domain_name intitle:index.of"
  "Locate Sensitive Files: site:$domain_name intitle:\"Apache HTTP Server Test Page\" | \"backup\" | \"config\""
  "Find Login Pages: site:$domain_name inurl:login"
  "Discover Cached Pages: site:$domain_name cache:"
  "Identify Technology Stack: site:$domain_name \"Powered by\" | \"Built with\""
  "Finding Open Redirects: site:$domain_name inurl:redir"
)

# Create an HTML file to store all results
output_file="GoogleDorking_results_${current_date}${current_time}.html"
echo "<html><body>" > "$output_file"

# Loop through the queries and execute them
for query in "${queries[@]}"; do
  # Split the query into heading and search query
  heading=$(echo "$query" | cut -d ':' -f 1)
  search_query=$(echo "$query" | cut -d ':' -f 2-)

  # URL encode the search query
  encoded_query=$(echo "$search_query" | sed 's/ /+/g')

  # Construct the API request URL
  api_url="https://www.googleapis.com/customsearch/v1?q=$encoded_query&cx=$cse_id&key=$api_key"

  # Use curl to fetch search results from the Google Custom Search API
  search_results=$(curl -s "$api_url")

  # Check if there are search results before processing
  if [ "$(jq -r 'if has("items") then .items | length else 0 end' <<< "$search_results")" -gt 0 ]; then
      # Extract and append URLs of search results with headings and bold text
      echo "<h3><strong>$heading:</strong></h3>" >> "$output_file"
      echo "<ul>" >> "$output_file"
      jq -r '.items[].link' <<< "$search_results" | while read -r link; do
          echo "<li><strong><a href=\"$link\">$link</a></strong></li>" >> "$output_file"
      done
      echo "</ul><br>" >> "$output_file"
  fi
done

# Close the HTML file
echo "</body></html>" >> "$output_file"

############# Whatweb or techology detect ############

echo "[+] Techology detect..."
whatweb "$main_url" | sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> technology_${current_date}${current_time}.txt
echo "" >> technology_${current_date}${current_time}.txt
httpx -u "$main_url" -td -server -silent | sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> technology_${current_date}${current_time}.txt

echo "[+] Completed: [*********.....] 70%"

################## Wapiti scanning tool ######################

echo "[+] Running wapiti scanning tool..."
wapiti -u "$main_url" -o wapiti_result_folder

# Set the search_directory to the current directory followed by /folder1/
search_directory="$(pwd)/wapiti_result_folder/"

# Use 'find' to search for files in the specified directory and its subdirectories
# '-type f' specifies that we're looking for files
# '-name' specifies the pattern to match for filenames
# The '-print' option is used to print the matching filenames
wapiti_filename="$(find "$search_directory" -type f -name "*$domain_name*" -print)"

# Scanning completed...


########################## Report Generation ###############################

echo "[+] Scanning completed and generating a report..."
echo "[+] Completed: [************..] 95%"

# Get the current date and time
# current_date=$(date +%y%m%d)  # YYMMDD
# current_time=$(date +%H%M)    # HHMM

# Define the output HTML file
output_file="${domain_name}_${current_date}${current_time}.html"

# Create the initial HTML structure
echo "<html>" >> "$output_file"
echo "<head>" >> "$output_file"
echo "<title>Vunerability Assessment Report</title>" >> "$output_file"

echo "<style>" >> "$output_file"
echo "/* Basic CSS for layout */" >> "$output_file"
echo "body {" >> "$output_file"
echo "    font-family: Arial, sans-serif;" >> "$output_file"
echo "    margin: 0;" >> "$output_file"
echo "    padding: 0;" >> "$output_file"
echo "    display: flex;" >> "$output_file"
echo "}" >> "$output_file"
echo ".container {" >> "$output_file"
echo "    width: 100%;" >> "$output_file"
echo "    overflow: hidden;" >> "$output_file"
echo "    display: flex;" >> "$output_file"
echo "}" >> "$output_file"
echo ".menu {" >> "$output_file"
echo "    flex: 1;" >> "$output_file"
echo "    background-color: #333;" >> "$output_file"
echo "    color: #fff;" >> "$output_file"
echo "    padding: 11px;" >> "$output_file"
echo "    width: 240px;" >> "$output_file"
echo "    position: fixed;" >> "$output_file"
echo "    height: 100%;" >> "$output_file"
echo "    overflow-y: auto; /* Enable vertical scrolling if content exceeds viewport */" >> "$output_file"
echo "}" >> "$output_file"
echo ".data {" >> "$output_file"
echo "    flex: 3;" >> "$output_file"
echo "    padding: 45px;" >> "$output_file"
echo "    margin-left: 260px; /* Add a margin to the right of the data to account for the menu */" >> "$output_file"
echo "    overflow-y: auto; /* Enable vertical scrolling if content exceeds viewport */" >> "$output_file"
echo "}" >> "$output_file"
echo ".menu ol {" >> "$output_file"
echo "    list-style-type: decimal;" >> "$output_file"
echo "    padding-left: 20px;" >> "$output_file"
echo "    margin: 0;" >> "$output_file"
echo "}" >> "$output_file"
echo ".menu li {" >> "$output_file"
echo "    margin-bottom: 10px;" >> "$output_file"
echo "}" >> "$output_file"
echo ".menu a {" >> "$output_file"
echo "    text-decoration: none;" >> "$output_file"
echo "    color: #fff;" >> "$output_file"
echo "}" >> "$output_file"
echo ".menu h2 {" >> "$output_file"
echo "    margin-top: 0;" >> "$output_file"
echo "}" >> "$output_file"
echo "</style>" >> "$output_file"
echo "</head>" >> "$output_file"
echo "<body>" >> "$output_file"
echo "<pre id='nikto-results'>" >> "$output_file"
echo "<!-- Contents of nikto_result1.txt will be appended here with preserved formatting -->" >> "$output_file"
echo "</pre>" >> "$output_file"

echo "<div class='container'>" >> "$output_file"
echo "<div class='menu'>" >> "$output_file"
echo "<h2>Menu</h2>" >> "$output_file"
echo "<ol>" >> "$output_file"

# List of tool names and corresponding text files
tools=("Tech-detect" "Directory/Files Enumeration" "Nikto" "Nuclei" "Nmap" "Google Dorking" "Advance Scan")
text_files=("technology_${current_date}${current_time}.txt" "final_urls_${current_date}${current_time}.txt" "nikto_result_${current_date}${current_time}.txt" "nuclei_result_${current_date}${current_time}.txt" "nmap_result_${current_date}${current_time}.txt" "GoogleDorking_results_${current_date}${current_time}.html" "$wapiti_filename")


# Loop through the tools and create menu links
for ((i=0; i<${#tools[@]}; i++)); do
    tool_name="${tools[$i]}"
    text_file="${text_files[$i]}"
    echo "<li><a href='#$tool_name'>$tool_name</a></li>" >> "$output_file"
    if (( i==1 )); then
        echo "<button id='openUrlsButton'>Browse</button>" >> "$output_file"
    fi
done


        echo "</ol>" >> "$output_file"
    echo "</div>" >> "$output_file"


    echo "<div class="data">" >> "$output_file"

# Create sections for each tool's results
for ((i=0; i<${#tools[@]}; i++)); do
    tool_name="${tools[$i]}"
    text_file="${text_files[$i]}"

    # Add a section header
    echo "<h1 id='$tool_name'>$tool_name</h1>" >> "$output_file"
    # Include the content of the corresponding text file
    #awk 'BEGIN{print "<pre id=\"nikto-results\">"} {gsub("high","<span style=\"color:red\">high</span>");gsub("medium","<span style=\"color:yellow\">medium</span>");gsub("low","<span style=\"color:blue\">low</span>");gsub("info","<span style==\"color:green\">info</span>");gsub("CVE-2[^ ]+","<span style=\"color:red\">&</span>")} {print} END{print "</pre>"}' "$text_file" >> "$output_file"
    awk 'BEGIN{print "<pre id=\"nikto-results\">"} {gsub("high","<span style=\"color:red\">high</span>");gsub("critical","<span style=\"color:red\">crtitical</span>");gsub("medium","<span style=\"color:yellow\">medium</span>");gsub("low","<span style=\"color:blue\">low</span>");gsub("info","<span style=\"color:green\">info</span>");gsub("CVE-2[^ ]+","<span style=\"color:red\">&</span>")} {print} END{print "</pre>"}' "$text_file" >> "$output_file"

done


    echo "</div>" >> "$output_file"

# Add JavaScript code to open URLs in new tabs when the button is clicked
echo "<script>document.addEventListener('DOMContentLoaded', function () {" >> "$output_file"
echo "  var openUrlsButton = document.getElementById('openUrlsButton');" >> "$output_file"
echo "  openUrlsButton.addEventListener('click', function () {" >> "$output_file"

echo "  var urls = [" >> "$output_file"
# Read the URLs from the input file and add them to the JavaScript array
input_urls_file="final_urls_${current_date}${current_time}.txt"
while IFS= read -r url; do
  echo "    '$url'," >> "$output_file"
done < "$input_urls_file"
echo "  ];" >> "$output_file"

echo "    for (var i = 0; i < urls.length; i++) {" >> "$output_file"
echo "      window.open(urls[i], '_blank');" >> "$output_file"
echo "    }" >> "$output_file"
echo "  });" >> "$output_file"
echo "});</script>" >> "$output_file"
echo "</div>" >> "$output_file"
echo "</body>" >> "$output_file"
echo "</html>" >> "$output_file"

# Removing all the created files
rm -rf 200_dirbuster_${current_date}${current_time}.txt redirection_dirbuster_${current_date}${current_time}.txt temp_dirb_${current_date}${current_time}.txt 200_dirsearch_${current_date}${current_time}.txt redirection_dirsearch_${current_date}${current_time}.txt temp_dirsearch_${current_date}${current_time}.txt hakrawler_urls_${current_date}${current_time}.txt katana_urls_${current_date}${current_time}.txt final_redirection_urls_${current_date}${current_time}.txt nuclei_result_${current_date}${current_time}.txt nikto_result_${current_date}${current_time}.txt nmap_result_${current_date}${current_time}.txt GoogleDorking_results_${current_date}${current_time}.html technology_${current_date}${current_time}.txt wapiti_result_folder/ reports/ final_urls_${current_date}${current_time}.txt total_urls_${current_date}${current_time}.txt paramSpider_result_${current_date}${current_time}.txt all_urls_for_nuclei_${current_date}${current_time}.txt

echo "[+] Scan Completed..."
echo ""
echo "[*] A report has been generated with the name $output_file, open it in a browser to see the report."

############################### The End #################################

