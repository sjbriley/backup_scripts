#!/bin/bash

# Define the backup destination base directory
BASE_BACKUP_DEST=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

# Get today's date in the format Dec27_2024
DATE=$(date +"%b%d_%Y")
BACKUP_DEST="${BASE_BACKUP_DEST}/${DATE}"

if [ -e "${BACKUP_DEST}" ]; then
    echo "Backup destination already exists: ${BACKUP_DEST}"
    exit 1
fi

# Ensure the backup destination exists
mkdir -p "${BACKUP_DEST}"

# Define source directories to back up
SOURCE_DIRS=(
    "$HOME/Documents"
    "$HOME/Downloads"
    "$HOME/Desktop"
)

# Start the backup process
echo "Starting backup to ${BACKUP_DEST}..."
for SOURCE in "${SOURCE_DIRS[@]}"; do
    # Default destination folder for other directories
    FOLDER_NAME=$(basename "$SOURCE")
    DEST="${BACKUP_DEST}/iCloud_MacBookFiles/$FOLDER_NAME"
    mkdir -p "${DEST}"
    echo "Backing up $SOURCE to $DEST..."
    rsync -a --progress --info=progress2 --log-file="${DEST}/backup.log" --exclude=".DS_Store" --exclude="*.tmp" "$SOURCE" "${DEST}"

    # Verify the backup using diff
    echo "Verifying backup for $SOURCE..."
    if diff -rq "$SOURCE" "${DEST}" >> "${BACKUP_DEST}/backup_verification.log"; then
        echo "Backup and verification successful for $SOURCE" >> "${BACKUP_DEST}/backup_verification.log"
    else
        echo "Backup verification failed for $SOURCE" >> "${BACKUP_DEST}/backup_verification.log"
    fi
done

echo "All backups completed! Check ${BACKUP_DEST}/backup_verification.log for details."