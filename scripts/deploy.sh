#!/bin/bash
# A simple deployment script for Terraform

set -e

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform changes..."
terraform plan -out=tfplan

read -p "Apply the above changes? (y/n): " choice
if [ "$choice" == "y" ]; then
  terraform apply "tfplan"
else
  echo "Exiting without applying changes."
fi
