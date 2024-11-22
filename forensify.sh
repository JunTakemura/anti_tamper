#!/bin/bash

# Check if file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

PROJECT_FILE="$1"

# Set this to your storage directory
STORAGE_DIR="/home/kali/"

# Make the storage directory if it doesn't exist
if [ ! -d "$STORAGE_DIR" ]; then
    echo "Creating storage directory: $STORAGE_DIR"
    mkdir -p "$STORAGE_DIR"
fi

# Sync system time with NTP
echo "Syncing system time with NTP..."
sudo ntpdate -u pool.ntp.org

# Hash the file
HASH_FILE="${PROJECT_FILE}.sha256"
echo "Hashing the project: $PROJECT_FILE"
sha256sum "$PROJECT_FILE" > "$HASH_FILE"

# Timestamp
echo "Timestamping the project and its hash..."
ots stamp "$PROJECT_FILE"
ots stamp "$HASH_FILE"

# Temporarily make the directory mutable
echo "Making directory mutable: $STORAGE_DIR"
sudo chattr -i "$STORAGE_DIR"

# Move the files to the directory
echo "Storing the Dradis project and hash..."
mv "$PROJECT_FILE" "$HASH_FILE" "$STORAGE_DIR"

# Make the directory immutable
echo "Making directory immutable: $STORAGE_DIR"
sudo chattr +i "$STORAGE_DIR"

echo "Project stored successfully in: $STORAGE_DIR"
