#!/bin/bash

# Set the script's location as the base directory
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${BASE_DIR}/backups"

# Get the current date for the backup name
DATE=$(date +"%m%d_%Y")
BASE_BACKUP_NAME="backups_${DATE}"
FINAL_BACKUP_NAME="${BASE_BACKUP_NAME}"

# Dynamically append a number if the directory or file already exists
COUNTER=1
while [ -e "${BACKUP_DIR}/${FINAL_BACKUP_NAME}" ] || [ -e "${BACKUP_DIR}/${FINAL_BACKUP_NAME}.tar.gz" ]; do
    FINAL_BACKUP_NAME="${BASE_BACKUP_NAME}_${COUNTER}"
    COUNTER=$((COUNTER + 1))
done

FINAL_BACKUP_DIR="${BACKUP_DIR}/${FINAL_BACKUP_NAME}"

# Minecraft worlds directory (Java Edition)
MINECRAFT_WORLDS_DIR="${HOME}/Library/Application Support/minecraft/saves"

# Ensure the backup directory exists
mkdir -p "${FINAL_BACKUP_DIR}"

# Copy Minecraft saved worlds to the backup directory
echo "Backing up Minecraft worlds from ${MINECRAFT_WORLDS_DIR} to ${FINAL_BACKUP_DIR}..."
cp -r "${MINECRAFT_WORLDS_DIR}"/* "${FINAL_BACKUP_DIR}"

# Compress the backup directory
TAR_FILE="${FINAL_BACKUP_DIR}.tar.gz"
echo "Compressing backup into ${TAR_FILE}..."
tar -czf "${TAR_FILE}" -C "${FINAL_BACKUP_DIR}" .

# Optionally remove uncompressed backup directory
echo "Cleaning up uncompressed backup directory..."
rm -rf "${FINAL_BACKUP_DIR}"

# Completion message
echo "Backup completed successfully: ${TAR_FILE}"
read -p "Press any key to exit..."