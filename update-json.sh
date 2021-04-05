#!/bin/bash

echo "Downloading..."
wget https://raw.githubusercontent.com/23G/forge-cloudwatch-agent/main/amazon-cloudwatch-agent.json > /dev/null 2>&1

# Move the json to correct location
sudo mv -f amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Start the agent.
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
