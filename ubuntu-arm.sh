#!/bin/bash

cleanupFiles() {
  rm -f amazon-cloudwatch-agent.gpg
  rm -f amazon-cloudwatch-agent.deb
  rm -f amazon-cloudwatch-agent.deb.sig
  rm -f amazon-cloudwatch-agent.json
}

# Make sure files don't already exist.
cleanupFiles

echo "Downloading..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/assets/amazon-cloudwatch-agent.gpg > /dev/null 2>&1
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb > /dev/null 2>&1
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/arm64/latest/amazon-cloudwatch-agent.deb.sig > /dev/null 2>&1
wget https://raw.githubusercontent.com/23G/forge-cloudwatch-agent/main/amazon-cloudwatch-agent.json > /dev/null 2>&1

# Main
gpg --import amazon-cloudwatch-agent.gpg

# Check if the fingerprint matches the gpg
if gpg --fingerprint '9376 16F3 450B 7D80 6CBD 9725 D581 6730 3B78 9C72' | grep -q 'Amazon CloudWatch Agent'; then
  echo "Fingerprint OK"
else
  echo "Illegal fingerpint."

  # Delete files before quitting.
  cleanupFiles
  exit
fi

# Check if signature matches.
if gpg --verify amazon-cloudwatch-agent.deb.sig amazon-cloudwatch-agent.deb 2>&1 | grep -q 'Good signature'; then
  echo "Signature OK"
else
  echo "Illegal signature."

  # Delete files before quitting.
  cleanupFiles
  exit
fi

# Install the agent.
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Move the json to correct location
sudo mv -f amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Clean up
cleanupFiles

# Install collectd
sudo apt-get install collectd -y

# Start the agent.
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
