#!/bin/bash
AMI_ID=ami-0220d79f3f480ecf5
SG_ID=sg-0c05c24867a0de439
ZONE_ID=Z09260871ALCRUTIR75TM  
DOMAIN_NAME=easydevops.fun
INSTANCES=("frontend" "catalogue" "cart" "payment" "shipping" "user" "dispatch" "rabbitmq" "mongodb" "mysql" "redis")

for instance in "${INSTANCES[@]}"; do
  echo "Creating $instance instance..."
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type t2.micro \
    --security-group-ids "$SG_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text)

  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"  # Wait for boot

  if [ "$instance" != "frontend" ]; then
    IP_ADDRESS=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].PrivateIpAddress" \
      --output text)
    echo "Private IP of $instance: $IP_ADDRESS"
    RECORD_NAME="$instance.$DOMAIN_NAME"
  else
    IP_ADDRESS=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].PublicIpAddress" \
      --output text)
    echo "Public IP of frontend: $IP_ADDRESS"
    RECORD_NAME="$DOMAIN_NAME"
  fi

# Update Route 53 DNS record
aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" --change-batch "{
  \"Changes\": [
    {
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"$RECORD_NAME\",
        \"Type\": \"A\",
        \"TTL\": 1,
        \"ResourceRecords\": [
          {
            \"Value\": \"$IP_ADDRESS\"
          }
        ]
      }
    }
  ]
}"

done
