#!/bin/bash

# Define the backup destination base directory
BASE_BACKUP_DEST=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

# Get today's date in the format Dec27_2024
DATE=$(date +"%b%d_%Y")
BACKUP_DEST="${BASE_BACKUP_DEST}/${DATE}"

if [ -e "${BACKUP_DEST}" ]; then
    echo "Backup destination already exists: ${BACKUP_DEST}"
    # exit 1
fi

# Ensure the backup destination exists
mkdir -p "${BACKUP_DEST}"

# Define source directories to back up
SOURCE_DIRS=(
    "$HOME/Pictures/Photos Library.photoslibrary"
    "$HOME/Documents"
    "$HOME/Downloads"
    "$HOME/Desktop"
)

VERIFICATION_LOG="${BACKUP_DEST}/backup_verification.log"

# Start the backup process
echo "Starting backup to ${BACKUP_DEST}..."
for SOURCE in "${SOURCE_DIRS[@]}"; do
    # Get the folder name
    DEST="${BACKUP_DEST}/iCloud_MacBookFiles"

    # Perform the backup using rsync
    echo "Backing up $SOURCE to $DEST..."
    mkdir -p "${DEST}"
    FOLDER_NAME=$(basename "$SOURCE")

    if [[ "$SOURCE" == "$HOME/Pictures/Photos Library.photoslibrary" ]]; then
        FOLDER_NAME="photos"
    else
        FOLDER_NAME=$(basename "$SOURCE")
    fi

    # rsync -a --progress --info=progress2 --log-file="${DEST}/${FOLDER_NAME}/backup.log" --exclude=".DS_Store" --exclude="*.tmp" "$SOURCE" "${DEST}/${FOLDER_NAME}"

    # Verify the backup using diff
    echo "Verifying backup for $SOURCE..."
    sleep 3
    if diff -rq "$SOURCE" "${DEST}/${FOLDER_NAME}" >> "${VERIFICATION_LOG}"; then
        echo "Backup and verification successful for $SOURCE" >> "${VERIFICATION_LOG}"
    else
        echo "Backup verification failed for $SOURCE" >> "${VERIFICATION_LOG}"
    fi
done

echo "All backups completed!"