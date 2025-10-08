#!/bin/bash

SOURCE_DIR="/d/_Astrica/UNI/4_курс/devops-portfolio-/source"
BACKUP_DIR="/d/_Astrica/UNI/4_курс/devops-portfolio-/backup"
LOG_FILE="$BACKUP_DIR/backup.log"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

echo "[$(date)] Starting backup of $SOURCE_DIR" >> "$LOG_FILE"
tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"
if [ $? -eq 0 ]; then
    echo "[$(date)] Backup successful: $BACKUP_FILE" >> "$LOG_FILE"
else
    echo "[$(date)] Backup failed" >> "$LOG_FILE"
    exit 1
fi

# keeping only tail 5
cd "$BACKUP_DIR" || exit
BACKUP_COUNT=$(ls -1 backup_*.tar.gz 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt 5 ]; then
    echo "[$(date)] Cleaning up old backups..." >> "$LOG_FILE"
    ls -1tr backup_*.tar.gz | head -n -5 | xargs -r rm -f
    echo "[$(date)] Cleanup done." >> "$LOG_FILE"
fi

echo "[$(date)] Backup finished" >> "$LOG_FILE"
