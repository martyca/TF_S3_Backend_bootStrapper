#!/usr/bin/env bash
echo This script repatriates the S3 backend state, back to local state.
read -r -p "Do you wish to repatriate the state file? [y/N] " response
case "$response" in
  [yY][eE][sS]|[yY])
    rm provider.tf
    mv temp_provider.bak temp_provider.tf
    yes yes | terraform init -migrate-state
    echo State has been repatriated back to local, you can now delete the S3 backend.
    ;;
  *)
    exit
    ;;
esac