#!/bin/bash
# Prompt the user for the target URL
read -p "Enter the target URL: " url

# Check if the URL ends with a slash and remove it if necessary
if [ "${url: -1}" == "/" ]; then
  url=${url::-1}
fi
# Construct the URL for the robots.txt file
robots_url="$url/robots.txt"

# Fetch the contents of the robots.txt file using curl
robots_content=$(curl -sL $robots_url)

# Check if the robots.txt file was found
if [ $? -eq 0 ]; then
  echo "The robots.txt file is found at $robots_url"
  echo "$robots_content"  
else
  echo "The robots.txt file is not found at $robots_url"
fi

# append /sitemap.xml to the URL
sitemap_url="$url/sitemap_index.xml"

# check if sitemap.xml exists at the URL
response_code=$(curl -s -o /dev/null -w "%{http_code}" $sitemap_url)

if [ $response_code -eq 200 ]; then
  echo "Sitemap found at $sitemap_url"
else
  echo "Sitemap not found at $sitemap_url"
fi
# run dirb with the specified target URL and wordlist
sudo dirb "$url"  -o dirb_results.txt
sudo gobuster dir --url "$url" -w /usr/share/wordlists/dirb/common.txt

url=${url#https://}
#Subfinder command
sudo subfinder -d "$url"   -o subfinder_results.txt
sudo amass enum -d "$url" -o  amass_results.txt
sudo dnsrecon -d "$url" -x dnsrecon_results.txt
sudo sublist3r.py -d  "$url" -o sublist3r_results.txt
url_with_https="https://${url}"
sudo dirsearch -u "$url" >> dirsearch.txt

url=${url#https://}
ip=$(host $url | awk '/has address/ { print $4 }')
echo "$url resolves to $ip"
sudo whois  "$ip" 
sudo nslookup -type=A "$ip" 
sudo nslookup -type=AAAA "$ip"
sudo nslookup -type=CNAME "$ip"
sudo nslookup -type=MX "$ip"  
sudo nslookup -type=SOA "$ip" 
sudo nslookup -type=TXT "$ip" 
sudo dig "$ip" A
sudo dig "$ip" AAAA
sudo dig  "$ip" CNAME
sudo dig "$ip" MX
sudo dig  "$ip" SOA
sudo dig "$ip" TXT
sudo nmap -PR -sn "$ip"/24
sudo arp-scan "$ip"/24
sudo masscan "$ip"/24 -p 80,443
sudo  nmap -sS -O  -sV "$ip" -oN ports_results.txt
