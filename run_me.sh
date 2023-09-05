#!/bin/bash
COOKIE_FILE='cookies.txt'

# Vérifie si le mot de passe a été passé en tant qu'argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <password>"
  exit 1
fi

# Récupère le mot de passe à partir de l'argument
password="$1"

# Function to make an HTTP request
make_request() {
  local JSON_DATA="$1"
  local HEADERS=(
    '-H "Authorization: X-Sah '$contextID'"'
    '-H "Connection: keep-alive"'
    '-H "Content-Type: application/x-sah-ws-4-call+json"'
    '-H "X-Context: '$contextID'"'
    '-H "Origin: http://livebox"'
    '-H "Referer: http://livebox/"'
    '-H "Sec-GPC: 1"'
  )
  local COMMAND="curl 'http://livebox/ws' ${HEADERS[*]} --data-raw '$JSON_DATA' --compressed --insecure -b "$COOKIE_FILE""
  # echo "$COMMAND"
  eval "$COMMAND"
  echo "Command completed. $JSON_DATA"
  echo "---------------------"
}

build_firewall_rule() {
  local destination_port="$1"
  local rule_id="$2"
  local protocol="$3"
  local JSON_DATA='{"service":"Firewall","method":"setCustomRule","parameters":{"description":"'$rule_id'","enable":true,"protocol":"'$protocol'","action":"Accept","destinationPort":"'$destination_port'","destinationPrefix":"0.0.0.0/0","sourcePort":"","sourcePrefix":"0.0.0.0/0","ipversion":4,"persistent":true,"chain":"Custom","id":"'$rule_id'"}}'
  make_request "$JSON_DATA"
}

# --------------------
# Login
# --------------------
login_response=$(curl 'http://livebox/ws' -H 'Accept: */*' -H 'Accept-Language: fr' -H 'Authorization: X-Sah-Login' -H 'Connection: keep-alive' -H 'Content-Type: application/x-sah-ws-4-call+json' -H 'Cookie: UILang=fr; 51a3cd15/accept-language=fr; lastKnownIpv6TabState=visible' -H 'Origin: http://livebox' -H 'Referer: http://livebox/' -H 'Sec-GPC: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36' --data-raw '{"service":"sah.Device.Information","method":"createContext","parameters":{"applicationName":"webui","username":"admin","password":"'$password'"}}' --compressed --insecure -c "$COOKIE_FILE")
contextID=$(echo "$login_response" | jq -r '.data.contextID')
echo "contextID: $contextID"

# --------------------
# Block websites
# --------------------
site_ids=()
site_ips=()

# 9gag
site_ids+=("9gag3")
site_ips+=("104.16.103.144")
site_ids+=("9gag4")
site_ips+=("104.16.104.144")
site_ids+=("9gag5")
site_ips+=("104.16.10.144")
site_ids+=("9gag6")
site_ips+=("104.16.106.144")
site_ids+=("9gag7")
site_ips+=("104.16.107.144")

site_ids+=("koreus")
site_ips+=("5.39.70.224")

site_ids+=("lelombrik1")
site_ips+=("188.114.97.2")
site_ids+=("lelombrik2")
site_ips+=("188.114.97.2")

# le monde
site_ids+=("lemonde")
site_ips+=("199.232.170.217")



# Trash Sites
for id in "${site_ids[@]}"; do
  JSON_DATA='{"service":"Firewall","method":"deleteCustomRule","parameters":{"id":"'$site_ids'","chain":"Custom"}}'
  make_request "$JSON_DATA" 
done

# Loop through the IP addresses 103, 104, and 105
for ((i = 0; i < ${#site_ids[@]}; i++)); do
  JSON_DATA='{"service":"Firewall","method":"setCustomRule","parameters":{"description":"'${site_ids[i]}'","enable":true,"protocol":"6","action":"Drop","destinationPort":"80-443","destinationPrefix":"'${site_ips[i]}'/32","sourcePort":"","sourcePrefix":"0.0.0.0/0","ipversion":4,"persistent":true,"chain":"Custom","id":"'${site_ids[i]}'"}}'
  make_request "$JSON_DATA" 
done

# --------------------
# Standard protocols
# --------------------
# Define arrays for destination ports and descriptions
standard_protocols_ids=(       "SSH"  "HTTP"    "HTTPS"   "POP3" "POP3S" "FTP"   "NTP" "NNTP" "NNTPS" "SMTP" "SMTPAuth" "DNS"  "IRC"        "IMAP"  "IMAPS" "VPN")
standard_protocols_ports=(     "22"   "80"      "443"     "110"  "995"   "20-21" "123" "119"  "563"   "25"   "587"      "53"   "6666-6667"  "143"   "993"   "1194")
standard_protocols_protocols=( "6,17" "6,17"    "6,17"    "6"    "6"     "6,17"  "17"  "6"    "6"     "6"    "6"        "6,17" "6"          "6"     "6"     "6,17") # UDP=17 / TCP=6

# Trash standard protocols
for id in "${standard_protocols_ids[@]}"; do
  JSON_DATA='{"service":"Firewall","method":"deleteCustomRule","parameters":{"id":"'$id'","chain":"Custom"}}'
  make_request "$JSON_DATA" 
done

# Loop through the standard protocols
for ((i = 0; i < ${#standard_protocols_ports[@]}; i++)); do
  build_firewall_rule "${standard_protocols_ports[i]}" "${standard_protocols_ids[i]}" "${standard_protocols_protocols[i]}"
done

