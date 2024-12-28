#!/bin/bash

# Set the script's location as the base directory
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${BASE_DIR}/backups"
MINECRAFT_SAVES_DIR="${HOME}/Library/Application Support/minecraft/saves"

# Ensure the Minecraft saves directory exists
if [ ! -d "${MINECRAFT_SAVES_DIR}" ]; then
    echo "Minecraft saves directory not found: ${MINECRAFT_SAVES_DIR}"
    read -p "Press any key to exit..."
    exit 1
fi

# Ask user for the backup file to restore
echo "Available backups:"
ls "${BACKUP_DIR}"/*.tar.gz
echo ""
read -p "Enter the name of the backup file to restore (e.g., backups_1227_2024.tar.gz): " BACKUP_FILE

# Verify the selected backup file exists
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILE}"
if [ ! -f "${BACKUP_PATH}" ]; then
    echo "Backup file not found: ${BACKUP_PATH}"
    read -p "Press any key to exit..."
    exit 1
fi

# Extract the backup file to a temporary location
TEMP_DIR="${BASE_DIR}/temp_restore"
mkdir -p "${TEMP_DIR}"
echo "Extracting ${BACKUP_FILE} to temporary directory..."
tar -xzf "${BACKUP_PATH}" -C "${TEMP_DIR}"

# Restore the worlds, appending info to the save name
echo "Restoring worlds to Minecraft saves directory..."
for WORLD_DIR in "${TEMP_DIR}"/*; do
    if [ -d "${WORLD_DIR}" ]; then
        WORLD_NAME=$(basename "${WORLD_DIR}")
        TIMESTAMP=$(date +"%m%d_%Y_%H%M%S")
        NEW_WORLD_NAME="${WORLD_NAME}_restored_${TIMESTAMP}"
        DESTINATION="${MINECRAFT_SAVES_DIR}/${NEW_WORLD_NAME}"

        # Copy the world and set ownership/permissions
        cp -r "${WORLD_DIR}" "${DESTINATION}"
        chown -R "$(whoami)" "${DESTINATION}"
        chmod -R u+rw,go-rwx "${DESTINATION}"

        echo "Restored ${WORLD_NAME} as ${NEW_WORLD_NAME} with proper permissions."
    fi
done

# Clean up the temporary directory
rm -rf "${TEMP_DIR}"

echo "Restore completed successfully!"
read -p "Press any key to exit..."