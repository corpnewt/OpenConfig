#!/usr/bin/env bash

clear

echo "Locating OpenCore EFI..."

disk_uuid="$(nvram 4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:boot-path | sed 's/.*GPT,\([^,]*\),.*/\1/')"

if [ -z "$disk_uuid" ]; then
    echo " - No OpenCore disk UUID found.  Please make sure ExposeSensitiveData"
    echo "   is setup properly in your config.plist!"
    exit 1
fi

echo " - Located with UUID: $disk_uuid"
echo "Checking mount status..."

if [ -z "$(diskutil info "$disk_uuid" | grep -i Mounted | grep -i Yes)" ]; then
    echo " - Not mounted - mounting..."
    sudo diskutil mount "$disk_uuid"
    if [ -z "$(diskutil info "$disk_uuid" | grep -i Mounted | grep -i Yes)" ]; then
        echo " - Something went wrong when mounting!"
        exit 1
    fi
else
    echo " - Mounted"
fi

echo "Determining mount point..."

mount_point_desc="$(diskutil info "$disk_uuid" | grep -i "Mount Point")"

if [ -z "$mount_point_desc" ]; then
    echo " - Could not locate - aborting..."
    exit 1
fi

mount_point="${mount_point_desc:30}" # Extract the actual mount point

echo " - Located at $mount_point"
echo "Checking for config.plist..."

if [ -e "$mount_point/EFI/OC/config.plist" ]; then
    echo " - Located at $mount_point/EFI/OC/config.plist"
    echo " - Opening..."
    open "$mount_point/EFI/OC/config.plist"
else
    echo " - Could not locate - aborting..."
    exit 1
fi