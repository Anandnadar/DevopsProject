# 🗄️ backup-and-cleanup-script

A production-grade Linux shell script that automates **timestamped backups** and **disk cleanup** of old/unnecessary files — with structured logging, dry-run support, and safe concurrency control.

---

## 📁 Repository Structure

```
backup-and-cleanup-script/
├── backup_cleanup.sh      # Main script
├── README.md              # This file
└── logs/                  # Auto-created at runtime
```

---

## ✨ Features

| Feature | Details |
|---|---|
| **Timestamped backups** | Archives named `backup_YYYYMMDD_HHMMSS.tar.gz` |
| **Compression** | GNU `tar` with gzip — excludes `.git`, `node_modules`, `*.log`, etc. |
| **SHA-256 checksum** | Every archive gets a `.sha256` sidecar file |
| **Backup retention** | Auto-purges archives older than `--days` (default: 7) |
| **Disk cleanup** | Removes files older than `--cleanup-days` matching: `.tmp`, `.log`, `core`, `.swp`, `.pyc`, `.cache`, and more |
| **Empty dir removal** | Prunes empty subdirectories after cleanup |
| **Structured log** | `[YYYY-MM-DD HH:MM:SS] [LEVEL] message` with monthly rotation |
| **Dry-run mode** | `--dry-run` previews all actions without touching files |
| **Lock file** | Prevents concurrent runs via `/tmp/backup_cleanup.lock` |
| **Disk space check** | Validates free space before attempting a backup |

---

## 🚀 Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/<your-username>/backup-and-cleanup-script.git
cd backup-and-cleanup-script
```

### 2. Make the script executable

```bash
chmod +x backup_cleanup.sh
```

### 3. Run it

```bash
# Full run (backup + cleanup) with defaults
sudo ./backup_cleanup.sh --verbose

# Custom source and backup destination
./backup_cleanup.sh \
  --source /var/www/html \
  --backup-dir /mnt/nas/backups \
  --verbose

# Preview everything without changing any files
./backup_cleanup.sh --dry-run --verbose

# Backup only — skip cleanup
./backup_cleanup.sh --backup-only --source /home/user/projects

# Cleanup only — delete files older than 14 days
./backup_cleanup.sh --cleanup-only --cleanup-days 14
```

---

## ⚙️ Options Reference

```
--source       <dir>   Directory to back up          (default: /var/www/html)
--backup-dir   <dir>   Where archives are stored     (default: /var/backups/myapp)
--cleanup-dir  <dir>   Directory to scan for junk    (default: /tmp/old_files)
--log-dir      <dir>   Where logs are written        (default: /var/log/backup_cleanup)
--days         <n>     Retain backups for N days     (default: 7)
--cleanup-days <n>     Delete files older than N days(default: 30)
--dry-run              Simulate — no files touched
--backup-only          Skip cleanup step
--cleanup-only         Skip backup step
--verbose              Print INFO messages to console
-h, --help             Show help
```

You can also set any option via **environment variable**:

```bash
export SOURCE_DIR=/opt/myapp
export RETENTION_DAYS=14
./backup_cleanup.sh
```

---

## 📋 Log Format

Logs are written to `/var/log/backup_cleanup/backup_cleanup_YYYYMM.log`:

```
[2025-05-04 02:00:01] [SECTION] ══════════  STARTING BACKUP & CLEANUP SCRIPT  ══════════
[2025-05-04 02:00:01] [INFO]    PID        : 12345
[2025-05-04 02:00:01] [INFO]    Dry-run    : false
[2025-05-04 02:00:02] [INFO]    Disk space OK — 45.30 GB available in /var/backups/myapp
[2025-05-04 02:00:05] [SUCCESS] Backup created: backup_20250504_020002.tar.gz (128.50 MB)
[2025-05-04 02:00:05] [INFO]    Checksum written → /var/backups/myapp/backup_20250504_020002.tar.gz.sha256
[2025-05-04 02:00:06] [INFO]    Deleted old backup: backup_20250427_020001.tar.gz (121.30 MB)
[2025-05-04 02:00:07] [INFO]    Deleted (Temp files): /tmp/old_files/session.tmp (4.00 KB)
[2025-05-04 02:00:07] [SUCCESS] Cleanup complete: 12 item(s) removed, ~8.40 MB freed.
[2025-05-04 02:00:07] [SUCCESS] All tasks completed successfully.
```

Log files are **auto-rotated** (gzip-compressed) when they exceed `MAX_LOG_SIZE_MB` (default: 10 MB).

---

## 🕐 Schedule with Cron

Run the script daily at 2 AM:

```bash
sudo crontab -e
```

Add:

```cron
# Daily backup & cleanup at 02:00
0 2 * * * /path/to/backup_cleanup.sh \
    --source /var/www/html \
    --backup-dir /mnt/backups \
    --days 7 \
    --cleanup-days 30 \
    >> /var/log/backup_cleanup/cron.log 2>&1
```

---

## 🔒 Security Notes

- Run as a user with **read access** to `--source` and **write access** to `--backup-dir`.
- Use `sudo` only if backing up root-owned directories.
- The lock file at `/tmp/backup_cleanup.lock` prevents overlapping cron runs.
- SHA-256 checksums let you verify archive integrity before a restore.

---

## 🛠️ Requirements

| Tool | Purpose |
|---|---|
| `bash` ≥ 4.0 | Script interpreter |
| `tar` | Archive creation |
| `gzip` | Compression / log rotation |
| `sha256sum` | Checksum generation |
| `find` | Old-file detection |
| `df`, `du`, `stat` | Disk / file size queries |
| `bc` | Human-readable size math |

All tools ship with standard Ubuntu / Debian / RHEL distributions.

---

## 📜 License

MIT — free to use, modify, and distribute.
