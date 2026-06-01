#!/data/data/com.termux/files/usr/bin/bash
# Sync Nextcloud data between internal and external storage
SRC="/data/data/com.termux/files/home/nextcloud_data"
DST="/storage/emulated/0/Nextcloud/data"
LOG="/data/data/com.termux/files/home/logs/sync.log"

echo "[$(date)] Iniciando sync..." >> $LOG
rsync -av --delete "$SRC/" "$DST/" >> $LOG 2>&1
echo "[$(date)] Sync completado" >> $LOG
