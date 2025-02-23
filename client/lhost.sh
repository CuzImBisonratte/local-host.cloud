#!/bin/bash

function update_certs() {
    # Download the certificates
    curl -o /etc/lhost/cert.pem -sSL https://local-host.cloud/certs/cert.pem
    curl -o /etc/lhost/chain.pem -sSL https://local-host.cloud/certs/chain.pem
    curl -o /etc/lhost/fullchain.pem -sSL https://local-host.cloud/certs/fullchain.pem
    curl -o /etc/lhost/privkey.pem -sSL https://local-host.cloud/certs/privkey.pem
    curl -o /etc/lhost/expiry -sSL https://local-host.cloud/certs/expiry

    # Finish the installation
    echo "local-host.cloud certificates updated successfully."

    # Exit the script
    exit 0
}

function select_webserver() {
    while true; do
        echo "Choose your web server:"
        echo "1. Nginx"
        echo "2. Apache"
        read -p "Enter your choice (1 or 2): " choice

        case $choice in
        1)
        WEBSERVER="nginx"
        break
        ;;
        2)
        WEBSERVER="apache"
        break
        ;;
        *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
        esac
    done
    echo "You selected: $WEBSERVER"
}

# --- Main Script ---

# Get the command
command=$1

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi


# Download the expiry and version from the homepage 
mkdir -p /tmp/local-host.cloud
# Download the files
curl -s "https://local-host.cloud/client/version" -o /tmp/local-host.cloud/version 2> /tmp/local-host.cloud/error
curl -s "https://local-host.cloud/certs/expiry" -o /tmp/local-host.cloud/expiry 2> /tmp/local-host.cloud/error
# Check if the downloads were successful
if [ ! -f "/tmp/local-host.cloud/version" ] || [ ! -f "/tmp/local-host.cloud/expiry" ] || [ -s "/tmp/local-host.cloud/error" ]; then
    echo -e "There was an error connecting to the local-host.cloud server.\nGoing offline.\n"
    cp /etc/lhost/version /tmp/local-host.cloud/version
    cp /etc/lhost/expiry /tmp/local-host.cloud/expiry
fi
# Read the files
remote_version=$(cat /tmp/local-host.cloud/version)
remote_expiry=$(cat /tmp/local-host.cloud/expiry)
# Check if the values are numbers
if [[ ! "$remote_version" =~ ^[0-9]+$ ]] || [[ ! "$remote_expiry" =~ ^[0-9]+$ ]]; then
    echo -e "There was an error connecting to the local-host.cloud server.\nGoing offline.\n"
    remote_version=$(cat /etc/lhost/version)
    remote_expiry=$(cat /etc/lhost/expiry)
fi
# Clean up
rm -rf /tmp/local-host.cloud

# Check for updates
if [ -f /etc/lhost/version ]; then
    local_version=$(cat /etc/lhost/version)
    if [ "$local_version" != "$remote_version" ]; then
        echo -e "An update is available.\nRun 'lhost update' to install the latest version.\n"
        echo $local_version
        echo $remote_version
    fi
else
    echo -e "An update is available.\nRun 'lhost update' to install the latest version.\n"
fi

# Check if the local certs are within 30 days of expiration
if [ -f /etc/lhost/expiry ]; then
    expiry=$(cat /etc/lhost/expiry)
    if [ $(date -d "$expiry" +%s) -lt $(date -d "+30 days" +%s) ]; then
        # Check if new certificates are available (different expiry date)
        if [ $(date -d "$remote_expiry" +%s) -ne $(date -d "$expiry" +%s) ]; then
        echo -e "Your certificates are about to expire.\nRun 'lhost certs' to update them.\n"
        else 
            echo -e "Your certificates are about to expire.\nThere are no new certificates available.\nPlease check the homepage: https://local-host.cloud\n"
        fi
    fi
fi

# Check for no command or help
if [ -z "$command" ] || [ "$command" == "help" ]; then
    echo "Usage: lhost [command]"
    echo "Commands:"
        echo "  install - Certificate installation helper"
        echo "  certs - (Re-)Download the certificates"
        echo "  help - Show this help message"
        echo "  version - Show the version of the client"
    exit 1
fi

# Process the command
case $command in
    install)
        install_helper
        ;;
    certs)
        update_certs
        ;;
    version)
        echo "local-host.cloud client version: $(cat /etc/lhost/version)"
        ;;
    *)
        echo "Invalid command. Run 'lhost help' for usage."
        ;;
esac