#!/bin/sh

# <-----------------------------------README---------------------------------->
# This script assumes you want to update the root domain and not some subdomain
# If this is not your case, feel free to adapt the script to your needs
# according to the license (see LICENSE)

# <--------------------------------CONFIGURATION------------------------------>
# Use this network interface, it should have internet access
NET_INTERFACE="whatever"

# The API key obtained in the Arsys web panel
API_KEY="whatever"

# The root domain, mydomain.es
DOMAIN="whatever"
# <--------------------------------------------------------------------------->

# Get current IPv4 and IPv6 in the root domain
DNS_IPV4="$(dig A $DOMAIN +short)"
DNS_IPV6="$(dig AAAA $DOMAIN +short)"

# Get current public IPv4 and IPv6 on the device
CURRENT_IPV4="$(curl -s --interface $NET_INTERFACE -4 https://api.ipify.org)"
CURRENT_IPV6="$(curl -s --interface $NET_INTERFACE -6 https://api6.ipify.org)"

# Comparison flags
CHANGED_IPV4=0
CHANGED_IPV6=0

# Did IPv4 change?
if [ "$DNS_IPV4" == "$CURRENT_IPV4" ]; then
	echo "IPv4 address did not change ($DNS_IPV4 | $CURRENT_IPV4)"
else
	echo "IPv4 address changed ($DNS_IPV4 | $CURRENT_IPV4)"
	CHANGED_IPV4=1
fi

# Did IPv6 change?
if [ "$DNS_IPV6" == "$CURRENT_IPV6" ]; then
	echo "IPv6 address did not change ($DNS_IPV6 | $CURRENT_IPV6)"
else
	echo "IPv6 address changed ($DNS_IPV6 | $CURRENT_IPV6)"
	CHANGED_IPV6=1
fi

# Do we have something to do?
if [ $CHANGED_IPV4 -eq 0 ] && [ $CHANGED_IPV6 -eq 0 ]; then
	echo "No public IP address changed, nothing to do..."
	exit 0
fi

# If any changed, update the domain A or AAAA records accordingly
## IPv4
if [ $CHANGED_IPV4 -eq 1 ]; then
	echo "Updating $DOMAIN A record..."
	API_REQUEST="$(cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<soap:Body>
		<ModifyDNSEntry xmlns="ModifyDNSEntry">
			<input>
				<domain xsi:type="xsd:string">$DOMAIN</domain>
				<dns xsi:type="xsd:string">$DOMAIN</dns>
				<currenttype xsi:type="xsd:string">A</currenttype>
				<currentvalue xsi:type="xsd:string">$DNS_IPV4</currentvalue>
				<newvalue xsi:type="xsd:string">$CURRENT_IPV4</newvalue>
			</input>
		</ModifyDNSEntry>
	</soap:Body>
</soapenv:Envelope>
EOF
)"
	echo -e "Request sent, response:\n$(curl -s \
    --interface $NET_INTERFACE \
    -4 \
    -X POST \
    -H "Content-Type: text/xml" \
    -u "$DOMAIN:$API_KEY" \
    --data "$API_REQUEST" \
    https://api.servidoresdns.net:54321/hosting/api/soap/index.php)"
	echo "Updated A record!"
fi

## IPv6
if [ $CHANGED_IPV6 -eq 1 ]; then
	echo "Updating $DOMAIN AAAA record..."
	API_REQUEST="$(cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<soap:Body>
		<ModifyDNSEntry xmlns="ModifyDNSEntry">
			<input>
				<domain xsi:type="xsd:string">$DOMAIN</domain>
				<dns xsi:type="xsd:string">$DOMAIN</dns>
				<currenttype xsi:type="xsd:string">AAAA</currenttype>
				<currentvalue xsi:type="xsd:string">$DNS_IPV6</currentvalue>
				<newvalue xsi:type="xsd:string">$CURRENT_IPV6</newvalue>
			</input>
		</ModifyDNSEntry>
	</soap:Body>
</soapenv:Envelope>
EOF
)"
	echo -e "Request sent, response:\n$(curl -s \
    --interface $NET_INTERFACE \
    -4 \
    -X POST \
    -H "Content-Type: text/xml" \
    -u "$DOMAIN:$API_KEY" \
    --data "$API_REQUEST" \
    https://api.servidoresdns.net:54321/hosting/api/soap/index.php)"
	echo "Updated AAAA record"
fi

exit 0
