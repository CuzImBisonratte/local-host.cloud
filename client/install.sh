#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Delete any old data
rm -rf /etc/lhost
rm -f /bin/lhost

# Download the latest version of the client
curl -o /bin/lhost -sSL https://local-host.cloud/client/lhost.sh && chmod +x /bin/lhost

# Create the working directory
mkdir -p /etc/lhost

# Download the certificates
curl -o /etc/lhost/cert.pem -sSL https://local-host.cloud/certs/cert.pem
curl -o /etc/lhost/chain.pem -sSL https://local-host.cloud/certs/chain.pem
curl -o /etc/lhost/fullchain.pem -sSL https://local-host.cloud/certs/fullchain.pem
curl -o /etc/lhost/privkey.pem -sSL https://local-host.cloud/certs/privkey.pem
curl -o /etc/lhost/expiry -sSL https://local-host.cloud/certs/expiry
curl -o /etc/lhost/version -sSL https://local-host.cloud/client/version

# Finish the installation
echo -e "Local Host client installed successfully.\nYou can now start using the client by running 'lhost'."