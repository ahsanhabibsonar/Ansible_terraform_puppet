#!/bin/bash

# Get list of signed certificates
CERTS=$(sudo /opt/puppetlabs/bin/puppetserver ca list --all | awk '{print $1}' | grep -Ev "puppetmaster|Signed")

# Loop through each certificate and revoke + clean
for cert in $CERTS; do
    echo "Revoking and cleaning certificate: $cert"
    sudo /opt/puppetlabs/bin/puppetserver ca revoke --certname $cert
    sudo /opt/puppetlabs/bin/puppetserver ca clean --certname $cert
done

echo "All non-master certificates have been revoked and cleaned."

