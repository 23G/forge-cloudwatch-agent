# Forge CloudWatch Agent

Automated script to install the CloudWatch agent on EC2 instances to increase monitoring options within CloudWatch (Ram/disk for example)

## How to use:

-   Make sure the EC2 Instances have an IAM Role with the role 'CloudWatchAgentServerPolicy'
-   Execute bash script depending on your architecture.

## How to use on Laravel Forge:

-   Make sure the EC2 Instances have an IAM Role with the role 'CloudWatchAgentServerPolicy'
-   Create a recipe
-   Execute the recipe on the servers neccesary
