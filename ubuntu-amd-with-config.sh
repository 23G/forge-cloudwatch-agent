#!/bin/bash

cleanupFiles() {
  rm -f amazon-cloudwatch-agent.gpg
  rm -f amazon-cloudwatch-agent.deb
  rm -f amazon-cloudwatch-agent.deb.sig
  rm -f amazon-cloudwatch-agent.json
}




generateConfig() {

    # get hostname
    hostname=`cat /etc/hostname`
    
    echo '{
            "agent": {
                    "run_as_user": "root"
            },
            "logs": {
                    "logs_collected": {
                            "files": {
                                    "collect_list": [
                                            ' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json

    for f in /home/forge/*; do

        if [ -d "$f" ]; then
        # $f is a directory

        echo `pwd`"/$f"
        #projectname="${f//./-}"

        startpath='/home/forge/'
        domain=${f/#$startpath}


        echo "domain: $domain"
        #echo "projectname: $projectname"

            # add nginx access and error logs
            echo "                          {
                                                    \"file_path\": \"/var/log/nginx/${domain}-access.log\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${domain}-access.log\"
                                            },
                                            {
                                                    \"file_path\": \"/var/log/nginx/${domain}-error.log\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${domain}-error.log\"
                                            }," >> /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json

            # check if the laravel log exists
            FILE="/home/forge/$f/storage/logs/laravel.log"
            if [ -f "$FILE" ]; then
                                                    echo "                      {
                                                                                        \"file_path\": \"/home/forge/${domain}/storage/logs/laravel.log\",
                                                                                        \"log_group_name\": \"23G/${hostname}\",
                                                                                        \"log_stream_name\": \"${domain}-laravel-$f.log\"
                                                                                }," >> /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json
            fi


        fi
    done

    # check if the mongodb log exists
    FILE="/var/log/mongodb/mongod.log"
    if [ -f "$FILE" ]; then
                                            echo "                      {
                                                                                \"file_path\": \"/var/log/mongodb/mongod.log\",
                                                                                \"log_group_name\": \"23G/${hostname}\",
                                                                                \"log_stream_name\": \"${hostname}-mongodb-$f.log\"
                                                                        }," >> /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json                                       
    fi


    echo "                                  
                                            {
                                                    \"file_path\": \"/var/log/messages\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${hostname}-messages\"
                                            },
                                            {
                                                    \"file_path\": \"/var/log/secure\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${hostname}-secure\"
                                            },
                                            {
                                                    \"file_path\": \"/var/log/auth.log\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${hostname}-auth.log\"
                                            },
                                            {
                                                    \"file_path\": \"/var/log/boot.log\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${hostname}-boot.log\"
                                            },
                                            {
                                                    \"file_path\": \"/var/log/dmesg\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${hostname}-dmesg\"
                                            },
                                            {
                                                    \"file_path\": \"/var/log/kern.log\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${hostname}-kern.log\"
                                            },
                                            {
                                                    \"file_path\": \"/var/log/faillog\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${hostname}-faillog\"
                                            },
                                            {
                                                    \"file_path\": \"/var/log/cron\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${hostname}-cron\"
                                            },
                                            {
                                                    \"file_path\": \"/var/log/syslog\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${hostname}-syslog\"
                                            },
                                            {	
                                                    \"file_path\": \"/home/forge/.bash_history\",
                                                    \"log_group_name\": \"23G/${hostname}\",
                                                    \"log_stream_name\": \"${hostname}-forge-bash_history\"
                                            }
                                    ]
                            }
                    }
            }," >> /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json
echo  '
        "metrics": {
            "append_dimensions": {
                "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
                "ImageId": "${aws:ImageId}",
                "InstanceId": "${aws:InstanceId}",
                "InstanceType": "${aws:InstanceType}"
            },
            "metrics_collected": {
                "collectd": {
                    "metrics_aggregation_interval": 300
                },
                "disk": {
                    "measurement": ["used_percent", "inodes_free", "inodes_total"],
                    "metrics_collection_interval": 300,
                    "resources": ["/"]
                },
                "mem": {
                    "measurement": ["mem_used_percent"],
                    "metrics_collection_interval": 300
                },
                "swap": {
                    "measurement": ["swap_used_percent"],
                    "metrics_collection_interval": 300
                }
            }
        }
    }
    ' >> /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json
}


# Make sure files don't already exist.
cleanupFiles

echo "Downloading..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/assets/amazon-cloudwatch-agent.gpg > /dev/null 2>&1
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb > /dev/null 2>&1
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb.sig > /dev/null 2>&1
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
#sudo mv -f amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Clean up
cleanupFiles

# generated the config
generateConfig

# Install collectd
sudo apt-get install collectd -y

# Start the agent.
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.d/file_amazon-cloudwatch-agent.json