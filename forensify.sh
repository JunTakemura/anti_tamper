#!/bin/bash

# Check if file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

PROJECT_FILE="$1"

# Set this to your storage directory
STORAGE_DIR="/home/kali/forensify"

# Set log file name based on project file name
LOG_FILE="$STORAGE_DIR/$(basename "$PROJECT_FILE").log"

# Function to log messages to the log file
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $message" >> "$LOG_FILE"
}

# Make storage directory if it doesn't exist
if [ ! -d "$STORAGE_DIR" ]; then
    echo "Creating storage directory: $STORAGE_DIR"
    mkdir -p "$STORAGE_DIR"
fi


# Initialize log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo "Initializing log file: $LOG_FILE"
    touch "$LOG_FILE"
    echo "Forensic Log - Initialized on $(date)" >> "$LOG_FILE"
    echo "===================================" >> "$LOG_FILE"
    log_message "Initialized log file."
fi

# Sync system time with NTP
echo "Syncing system time with NTP..."
sudo ntpdate -u pool.ntp.org

# Hash the file
HASH_FILE="${PROJECT_FILE}.sha256"
echo "Hashing the project: $PROJECT_FILE"
sha256sum "$PROJECT_FILE" > "$HASH_FILE"
log_message "Computed hash for file '$PROJECT_FILE': $(cat "$HASH_FILE")."

# Timestamp
echo "Timestamping the project and its hash..."
ots stamp "$PROJECT_FILE"
ots stamp "$HASH_FILE"
log_message "Timestamped files '$PROJECT_FILE' and '$HASH_FILE'."

# Temporarily make the directory mutable
echo "Making directory mutable: $STORAGE_DIR"
sudo chattr -i "$STORAGE_DIR"
log_message "Changed immutability of '$STORAGE_DIR' to -i."

# Move the files to the directory
echo "Storing the project and hash..."
mv "$PROJECT_FILE" "$HASH_FILE" "$STORAGE_DIR"
log_message "Moved files '$PROJECT_FILE' and '$HASH_FILE' to '$STORAGE_DIR'."

# Make the directory immutable
echo "Making directory immutable: $STORAGE_DIR"
sudo chattr +i "$STORAGE_DIR"
log_message "Changed immutability of '$STORAGE_DIR' to +i."

echo "Project stored successfully in: $STORAGE_DIR"
