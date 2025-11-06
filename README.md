# backup.sh — Configurable Backup Automation Script
**A small, portable Bash backup script for creating timestamped archives from one or more source paths to a destination. Uses a simple config file (backup.conf) and rsync for efficient transfers. Intended for personal use, maintenance, or portfolio demos.**

A reliable and portable Bash script for automated backups with flexible configuration, exclusion support, and output validation. Ideal for personal use, system maintenance, or portfolio demonstration.
**Features**

Features
- Configurable via backup.conf
- Supports multiple source directories and pattern-based excludes
- Rsync-based transfer with optional extra rsync options
- Pre-checks for config and path validity, with structured logging
- Timestamped backup directories and per-run logs
- Clear exit codes for success and error modes
- Works on Linux/macOS (or Windows with WSL/Git Bash) where Bash 4+ and rsync are available

Configurable via backup.conf
Supports multiple source directories
Excludes files/folders using pattern matching
Validates output and logs errors
Timestamped backups and logs
Compatible with Linux/macOS

Usage

Verifies config and paths before execution
Logs success, skipped files, and errors
Exit codes:
0 — Success
1 — Config error
2 — Backup failure

Requirements

Example backup.conf (place next to backup.sh at C:/Users/lenovo/OneDrive/Desktop/DevopsExample/DevOps-Practice-Test/backup-system/)
Bash 4+
rsync installed
Writable destination path

License

**MIT License — free to use and modify.**
