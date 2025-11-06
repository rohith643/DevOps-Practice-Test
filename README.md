**A small, portable Bash backup script for creating timestamped archives from one or more source paths to a destination. Uses a simple config file (backup.conf) and rsync for efficient transfers. Intended for personal use, maintenance, or portfolio demos.**

**Features**

- Configurable via backup.conf
- Supports multiple source directories and pattern-based excludes
- Rsync-based transfer with optional extra rsync options
- Pre-checks for config and path validity, with structured logging
- Timestamped backup directories and per-run logs
- Clear exit codes for success and error modes
- Works on Linux/macOS (or Windows with WSL/Git Bash) where Bash 4+ and rsync are available

**Requirements**

- Bash 4+
- rsync installed and available in PATH
- Writable destination path for backups and logs

Example backup.conf (place next to backup.sh at C:/Users/lenovo/OneDrive/Desktop/DevopsExample/DevOps-Practice-Test/backup-system/)

```
# Destination directory for backups (required)
DEST="/C:/Users/lenovo/OneDrive/Desktop/DevopsExample/DevOps-Practice-Test/backup-system/backups"

# Space-separated or array-style list of source paths
SOURCES=( "/C:/Users/lenovo/Documents" "/etc" )

# Patterns to exclude (glob-style)
EXCLUDES=( "node_modules" ".cache" "*.tmp" )

# Optional rsync options (example)
RSYNC_OPTS="-a --delete --partial"

# Optional log directory (defaults to ./logs if not set)
LOG_DIR="./logs"
```

**Installation (using your project path)**

1. Put backup.sh and backup.conf in:
    C:/Users/lenovo/OneDrive/Desktop/DevopsExample/DevOps-Practice-Test/backup-system/
2. Make the script executable (on WSL/Git Bash/macOS/Linux):
    chmod +x /mnt/c/Users/lenovo/OneDrive/Desktop/DevopsExample/DevOps-Practice-Test/backup-system/backup.sh
    or when in the directory:
    chmod +x ./backup.sh

**Usage examples (run from the backup-system directory or provide full paths)**

- Run with the bundled config:
  ./backup.sh
- Specify a config file explicitly:
  ./backup.sh -c /C:/Users/lenovo/OneDrive/Desktop/DevopsExample/DevOps-Practice-Test/backup-system/backup.conf
- Inspect logs in the configured LOG_DIR (defaults to ./logs)
- Backups are created under DEST as timestamped subdirectories

**Logging & validation**

- The script validates the config and source/destination paths before starting
- Logs success, skipped entries, and errors with timestamps
- Non-zero exit codes indicate configuration or runtime failures

**Exit codes**

- 0 — Success
- 1 — Configuration or validation error
- 2 — Backup/runtime failure

License
MIT License — free to use and modify.
