#!/bin/bash

# === Load Configuration ===
CONFIG_FILE="./backup.config"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Config file missing"
  exit 1
fi
source "$CONFIG_FILE"

# === Lock File ===
LOCK_FILE="/tmp/backup.lock"
if [ -f "$LOCK_FILE" ]; then
  echo "Error: Backup already running"
  exit 1
fi
touch "$LOCK_FILE"

# === Logging ===
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$BACKUP_DESTINATION/backup.log"
}

# === Cleanup on Exit ===
cleanup() {
  rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# === Dry Run Mode ===
if [[ "$1" == "--dry-run" ]]; then
  SOURCE_DIR="$2"
  echo "[DRY RUN] Would backup: $SOURCE_DIR"
  echo "[DRY RUN] Would save to: $BACKUP_DESTINATION"
  echo "[DRY RUN] Would exclude: $EXCLUDE_PATTERNS"
  echo "[DRY RUN] Would delete backups older than policy"
  exit 0
fi

# === Input Validation ===
SOURCE_DIR="$1"
if [ -z "$SOURCE_DIR" ]; then
  echo "Error: No source folder provided"
  exit 1
fi
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source folder not found"
  exit 1
fi
if [ ! -r "$SOURCE_DIR" ]; then
  echo "Error: Cannot read folder, permission denied"
  exit 1
fi
if [ ! -d "$BACKUP_DESTINATION" ]; then
  mkdir -p "$BACKUP_DESTINATION"
fi

# === Disk Space Check ===
AVAILABLE=$(df "$BACKUP_DESTINATION" | awk 'NR==2 {print $4}')
if [ "$AVAILABLE" -lt 100000 ]; then
  echo "Error: Not enough disk space"
  exit 1
fi

# === Timestamp and File Names ===
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BACKUP_NAME="backup-$TIMESTAMP.tar.gz"
BACKUP_PATH="$BACKUP_DESTINATION/$BACKUP_NAME"
CHECKSUM_PATH="$BACKUP_PATH.sha256"

# === Create Backup ===
log "INFO: Starting backup of $SOURCE_DIR"
IFS=',' read -ra EXCLUDES <<< "$EXCLUDE_PATTERNS"
EXCLUDE_ARGS=()
for pattern in "${EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=("--exclude=$pattern")
done

tar -czf "$BACKUP_PATH" "${EXCLUDE_ARGS[@]}" "$SOURCE_DIR"
if [ $? -ne 0 ]; then
  log "ERROR: Failed to create backup"
  exit 1
fi
log "SUCCESS: Backup created: $BACKUP_NAME"

# === Generate Checksum ===
sha256sum "$BACKUP_PATH" > "$CHECKSUM_PATH"
log "INFO: Checksum saved: $(basename "$CHECKSUM_PATH")"

# === Verify Backup ===
sha256sum -c "$CHECKSUM_PATH" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  log "FAILED: Checksum verification failed"
  exit 1
fi

TEST_FILE=$(tar -tzf "$BACKUP_PATH" | head -n 1)
tar -xzf "$BACKUP_PATH" -C /tmp "$TEST_FILE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  log "FAILED: Test extraction failed"
  exit 1
fi
rm -f "/tmp/$TEST_FILE"
log "SUCCESS: Backup verified successfully"

# === Delete Old Backups ===
cd "$BACKUP_DESTINATION" || exit 1
for file in backup-*.tar.gz; do
  DATE_STR=$(echo "$file" | cut -d'-' -f2-4 | tr -d '.tar.gz')
  FILE_DATE=$(date -d "$DATE_STR" +%s 2>/dev/null)
  TODAY=$(date +%s)
  AGE_DAYS=$(( (TODAY - FILE_DATE) / 86400 ))

  KEEP=false
  if [ "$AGE_DAYS" -le "$DAILY_KEEP" ]; then KEEP=true; fi
  if [ "$AGE_DAYS" -le $((7 * WEEKLY_KEEP)) ] && [ "$(date -d "$DATE_STR" +%u)" -eq 7 ]; then KEEP=true; fi
  if [ "$(date -d "$DATE_STR" +%d)" -eq 1 ] && [ "$AGE_DAYS" -le $((30 * MONTHLY_KEEP)) ]; then KEEP=true; fi

  if [ "$KEEP" = false ]; then
    rm -f "$file" "$file.sha256"
    log "INFO: Deleted old backup: $file"
  fi
done