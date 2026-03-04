#!/bin/bash
# Load the filtered layout file
dconf load /org/cinnamon/ < ./cinnamon_layout_only.conf

# Restart Cinnamon to force it to re-draw the panels on the external screens
cinnamon --replace &