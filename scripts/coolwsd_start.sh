#!/data/data/com.termux/files/usr/bin/bash
# Inicia LibreOffice Online (CoolWS) para edición de documentos
PREFIX=/data/data/com.termux/files/usr
LOG=/data/data/com.termux/files/home/logs/coolwsd.log

echo "Iniciando LibreOffice Online..."
nohup coolwsd --o:sys_template_path=/data/data/com.termux/files/home/cool/template \
  --o:child_root_path=/data/data/com.termux/files/home/cool/child \
  --o:server_name=localhost \
  >> $LOG 2>&1 &
disown
echo "coolwsd PID: $!"
