#!/bin/bash

# === Load Configuration ===
CONFIG_FILE="./backup.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[ERROR] Config file not found: $CONFIG_FILE"
  exit 1
fi
source "$CONFIG_FILE"

# === Lock File ===
LOCK_FILE="/tmp/backup.lock"
if [[ -f "$LOCK_FILE" ]]; then
  echo "[ERROR] Backup already running"
  exit 1
fi
touch "$LOCK_FILE"

# === Cleanup on Exit ===
cleanup() {
  rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# === Logging ===
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "INFO: Backup script started"

# === Disk Space Check ===
AVAILABLE=$(df "$DEST_DIR" | awk 'NR==2 {print $4}')
if [[ "$AVAILABLE" -lt 100000 ]]; then
  log "ERROR: Not enough disk space"
  exit 1
fi

# === Timestamp and File Names ===
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BACKUP_NAME="backup-$TIMESTAMP.tar.gz"
BACKUP_PATH="$DEST_DIR/$BACKUP_NAME"
CHECKSUM_PATH="$BACKUP_PATH.sha256"

# === Prepare Exclude Patterns ===
IFS=' ' read -ra EXCLUDES <<< "$EXCLUDE_PATTERNS"
EXCLUDE_ARGS=()
for pattern in "${EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=(--exclude="$pattern")
done

# === Create Backup ===
TEMP_DIR="/tmp/backup_$TIMESTAMP"
mkdir -p "$TEMP_DIR"

for SRC in $SOURCE_DIRS; do
  if [[ -d "$SRC" ]]; then
    cp -r "$SRC" "$TEMP_DIR"
    log "INFO: Copied $SRC to temp"
  else
    log "WARN: Source not found: $SRC"
  fi
done

tar -czf "$BACKUP_PATH" "${EXCLUDE_ARGS[@]}" -C "$TEMP_DIR" .
if [[ $? -ne 0 ]]; then
  log "ERROR: Failed to create backup archive"
  rm -rf "$TEMP_DIR"
  exit 1
fi
rm -rf "$TEMP_DIR"
log "SUCCESS: Backup created: $BACKUP_NAME"

# === Generate Checksum ===
sha256sum "$BACKUP_PATH" > "$CHECKSUM_PATH"
log "INFO: Checksum saved: $(basename "$CHECKSUM_PATH")"

# === Verify Backup ===
sha256sum -c "$CHECKSUM_PATH" > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  log "FAILED: Checksum verification failed"
  exit 1
fi

TEST_FILE=$(tar -tzf "$BACKUP_PATH" | grep -v '/$' | head -n 1)
if [[ -n "$TEST_FILE" && "$TEST_FILE" != "." && "$TEST_FILE" != "/" ]]; then
  tar -xzf "$BACKUP_PATH" -C /tmp "$TEST_FILE" > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    log "FAILED: Test extraction failed"
    exit 1
  fi
  rm -f "/tmp/$TEST_FILE"
  log "SUCCESS: Backup verified successfully"
else
  log "WARN: No valid file found in archive for test extraction"
fi

# === Delete Old Backups ===
cd "$DEST_DIR" || exit 1
for file in backup-*.tar.gz; do
  DATE_STR=$(echo "$file" | cut -d'-' -f2-4 | tr -d '.tar.gz')
  FILE_DATE=$(date -d "$DATE_STR" +%s 2>/dev/null)
  TODAY=$(date +%s)
  AGE_DAYS=$(( (TODAY - FILE_DATE) / 86400 ))

  KEEP=false
  if [[ "$AGE_DAYS" -le "$DAILY_KEEP" ]]; then KEEP=true; fi
  if [[ "$AGE_DAYS" -le $((7 * WEEKLY_KEEP)) ]] && [[ "$(date -d "$DATE_STR" +%u)" -eq 7 ]]; then KEEP=true; fi
  if [[ "$(date -d "$DATE_STR" +%d)" -eq 1 ]] && [[ "$AGE_DAYS" -le $((30 * MONTHLY_KEEP)) ]]; then KEEP=true; fi

  if [[ "$KEEP" = false ]]; then
    rm -f "$file" "$file.sha256"
    log "INFO: Deleted old backup: $file"
  fi
done

log "INFO: Backup process completed"
