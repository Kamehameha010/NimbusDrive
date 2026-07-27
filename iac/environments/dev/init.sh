#!/bin/bash

echo "floci starting..."

floci start

eval $(floci env)

echo "floci started..."


echo "s3 bucket creating..."

aws s3 mb s3://terraform-states

echo "Terraform-states was created"

aws s3 ls


KEY_ID=$(aws kms create-key --description "My App Key" --query KeyMetadata.KeyId --output text)
echo "Generated Key ID: $KEY_ID"