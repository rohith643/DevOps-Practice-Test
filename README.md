# backup.sh — Configurable Backup Automation Script

A reliable and portable Bash script for automated backups with flexible configuration, exclusion support, and output validation. Ideal for personal use, system maintenance, or portfolio demonstration.

Features

Configurable via backup.conf
Supports multiple source directories
Excludes files/folders using pattern matching
Validates output and logs errors
Timestamped backups and logs
Compatible with Linux/macOS
Usage

Make the script executable and run: chmod +x backup.sh ./backup.sh Logging & Validation

Verifies config and paths before execution
Logs success, skipped files, and errors
Exit codes:
0 — Success
1 — Config error
2 — Backup failure
Requirements

Bash 4+
rsync installed
Writable destination path
License

MIT License — free to use and modify.
