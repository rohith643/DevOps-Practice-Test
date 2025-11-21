
**Automated Backup System**

**Project Overview**

This project provides a **Bash-based backup tool** that automatically saves copies of important files and folders.  
It works like a smart "copy and paste" system that:

- Creates compressed backups (`.tar.gz`)
- Verifies integrity with checksums
- Cleans up old backups using rotation rules
- Logs all actions for transparency
- Supports configuration, dry-run mode, and lock files to prevent multiple runs

This tool is useful for developers, system administrators, and anyone who wants **reliable, automated backups** without relying on heavy external software.

---

**How to Use It**

**1. Installation**

Clone the repository and make the script executable:

```bash
git clone https://github.com/your-username/backup-system.git
cd backup-system
chmod +x backup.sh
```

**2. Configuration**

Edit `backup.config` to set your preferences:

```bash
BACKUP_DESTINATION=/home/backups
EXCLUDE_PATTERNS=".git,node_modules,.cache"
DAILY_KEEP=7
WEEKLY_KEEP=4
MONTHLY_KEEP=3
```

**3. Basic Usage**

Run a backup:

```bash
./backup.sh /home/user/documents
```

Dry-run mode (simulate actions without executing):

```bash
./backup.sh --dry-run /home/user/documents
```

Restore a backup (bonus feature):

```bash
./backup.sh --restore backup-2024-11-03-1430.tar.gz --to /home/user/restored_files
```

List available backups:

```bash
./backup.sh --list
```

---

**How It Works**

**Backup Creation**

- Compresses the source folder into a `.tar.gz` file named with a timestamp (`backup-YYYY-MM-DD-HHMM.tar.gz`).
- Generates a checksum (`.md5` or `.sha256`) to verify file integrity.

**Rotation Algorithm**

- Keeps **7 daily backups** (last 7 days).
- Keeps **4 weekly backups** (last 4 Sundays).
- Keeps **3 monthly backups** (first day of last 3 months).
- Deletes anything older.

**Verification**

- Compares checksum with saved fingerprint.
- Extracts a test file from the archive to confirm integrity.
- Prints `SUCCESS` or `FAILED`.

**Logging**

All actions are logged in `backup.log`:

```
[2024-11-03 14:30:15] INFO: Starting backup of /home/user/documents
[2024-11-03 14:30:45] SUCCESS: Backup created: backup-2024-11-03-1430.tar.gz
[2024-11-03 14:30:46] INFO: Checksum verified successfully
[2024-11-03 14:30:50] INFO: Deleted old backup: backup-2024-10-05-0900.tar.gz
```

**Lock File**

Prevents multiple runs by creating `/tmp/backup.lock`.  
If the lock exists, the script exits safely.

---

**Design Decisions**

- **Config file**: Keeps script flexible and user-friendly.
- **Checksum verification**: Ensures backups are reliable.
- **Rotation rules**: Balance between safety and disk space.
- **Dry-run mode**: Lets users preview actions before execution.
- **Lock file**: Prevents race conditions when multiple backups run.

**Challenges faced:**

- Handling mixed environments (Linux/Windows paths).
- Ensuring robust error handling.
- Designing rotation logic without deleting valid backups.

**Solutions:**

- Modular functions (`create_backup`, `verify_backup`, `delete_old_backups`).
- Clear error messages.
- Extensive testing with fake dates and sample folders.

---

**Testing**

**Example 1: Creating a Backup**

```bash
./backup.sh /home/user/test_folder
```

Output:

```
SUCCESS: Backup created backup-2024-11-03-1430.tar.gz
Checksum verified successfully
```

 **Example 2: Multiple Backups Over Days**

Simulated backups on different dates show automatic deletion of old ones.

**Example 3: Dry Run**

```bash
./backup.sh --dry-run /home/user/test_folder
```

Output:

```
Would backup folder /home/user/test_folder
Would delete backup backup-2024-10-01-0900.tar.gz
```

**Example 4: Error Handling**

```bash
./backup.sh /home/user/missing_folder
```

Output:

```
Error: Source folder not found
```

---
**Known Limitations**

- Incremental backups (only changed files) are not yet implemented.
- Email notifications are simulated via `email.txt` instead of real SMTP.
- Rotation rules assume consistent timestamps; manual edits may break logic.
- Script tested on Linux; Windows compatibility may require adjustments.

---

**Folder Structure**

```
backup-system/
├── backup.sh              # Main script
├── backup.config          # Configuration file
├── README.md              # Documentation
├── backup.log             # Log file (auto-generated)
└── backups/               # Backup files stored here
```

---

**Example Outputs**

**Backup File**

```
backup-2024-11-03-1430.tar.gz
backup-2024-11-03-1430.tar.gz.md5
```

**Log File**

```
[2024-11-03 14:30:15] INFO: Starting backup of /home/user/documents
[2024-11-03 14:30:45] SUCCESS: Backup created
```

---

**Final Notes**

This project demonstrates **professional-grade Bash scripting** with:

- Automation
- Error handling
- Config-driven design
- Logging and verification

It’s a solid foundation for building more advanced backup systems with features like incremental backups, cloud sync, and real email notifications.
