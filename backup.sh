#!/bin/bash

echo "[DEBUG] Loading config..."
CONFIG_FILE="./backup.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[ERROR] Config file not found: $CONFIG_FILE"
  exit 1
fi
source "$CONFIG_FILE"

echo "[DEBUG] Config loaded"
echo "[DEBUG] SOURCE_DIRS=$SOURCE_DIRS"
echo "[DEBUG] DEST_DIR=$DEST_DIR"
echo "[DEBUG] LOG_FILE=$LOG_FILE"
echo "[DEBUG] EXCLUDE_PATTERNS=$EXCLUDE_PATTERNS"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FOLDER="$DEST_DIR/backup_$TIMESTAMP"
echo "[DEBUG] Creating backup folder: $BACKUP_FOLDER"
mkdir -p "$BACKUP_FOLDER"

echo "[DEBUG] Starting backup loop..."
for SRC in $SOURCE_DIRS; do
  echo "[DEBUG] Checking source: $SRC"
  if [[ -d "$SRC" ]]; then
    echo "[DEBUG] Running rsync for $SRC"
    rsync -av --exclude=$EXCLUDE_PATTERNS "$SRC"/ "$BACKUP_FOLDER"/ >> "$LOG_FILE" 2>&1
    echo "[INFO] Backed up: $SRC" >> "$LOG_FILE"
  else
    echo "[WARN] Source not found: $SRC" >> "$LOG_FILE"
    echo "[DEBUG] Skipped missing source: $SRC"
  fi
done

echo "[DEBUG] Backup completed"
echo "[INFO] Backup completed at $(date)" >> "$LOG_FILE"