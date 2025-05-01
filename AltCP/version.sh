#!/bin/bash
cd "$SRCROOT/$PRODUCT_NAME"
current_date=$(date "+%Y%m%d")
previous_build_number=$(awk -F "=" '/BUILD_NUMBER/ {print $2}' _Config.xcconfig | tr -d ' ')

previous_date="${previous_build_number:0:8}"
counter="${previous_build_number:8}"

new_counter=$((current_date == previous_date ? counter + 1 : 1))
new_build_number="${current_date}${new_counter}"
sed -i -e "/BUILD_NUMBER =/ s/= .*/= $new_build_number/" _Config.xcconfig

rm -f _Config.xcconfig-e
