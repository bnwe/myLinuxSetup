#!/bin/bash
# Dump the whole config to a temp file
dconf dump /org/cinnamon/ > ./temp_full_config.conf

# Use grep to only save lines related to panels and applets
# This keeps your keybindings safe!
grep -E "panels-enabled|enabled-applets|panels-height|panels-autohide|panel-zone|panels-hide-delay|panels-show-delay|next-applet-id" ./temp_full_config.conf > ./cinnamon_layout_only.conf

# Add the required header so dconf knows where these settings belong
sed -i '1i \[/\]' ./cinnamon_layout_only.conf

rm ./temp_full_config.conf
echo "Backup complete: Only panels and applets were saved."
