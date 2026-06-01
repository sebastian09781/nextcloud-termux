#!/data/data/com.termux/files/usr/bin/bash
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; N='\033[0m'
PREFIX=/data/data/com.termux/files/usr
export PATH=/usr/bin:/bin:/usr/sbin:$PREFIX/bin

# pgrep via /proc (compatible Android)
_pids() { for f in /proc/[0-9]*/cmdline; do [ -r "$f" ] && grep -aq "$1" "$f" 2>/dev/null && echo "${f#/proc/}"; done | sed 's|/cmdline||'; }
_running() { for f in /proc/[0-9]*/cmdline; do [ -r "$f" ] && grep -aq "$1" "$f" 2>/dev/null && return 0; done; return 1; }

echo -ne "  Redis      "; _running "[r]edis"          && echo -e "${G}✅ activo${N}"        || echo -e "${R}❌ inactivo${N}"
echo -ne "  MariaDB    "; mysqladmin ping --silent 2>/dev/null && echo -e "${G}✅ activo${N}"  || echo -e "${R}❌ inactivo${N}"
echo -ne "  PHP-FPM    "; p=$(_pids php-fpm | wc -l); [ "$p" -gt 0 ] && echo -e "${G}✅ ${p} proc${N}" || echo -e "${R}❌ inactivo${N}"
echo -ne "  Apache     "; p=$(_pids "[h]ttpd" | wc -l)
if [ "$p" -gt 0 ]; then
  code=$(curl -m 3 -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/core/img/favicon.png 2>/dev/null)
  [ "$code" = "200" ] && echo -e "${G}✅ ${p} proc (HTTP 200)${N}" || echo -e "${Y}⚠ ${p} proc (HTTP ${code})${N}"
else echo -e "${R}❌ inactivo${N}"; fi
echo -ne "  Cloudflare "; _running "[c]loudflared"    && echo -e "${G}✅ activo${N}"        || echo -e "${R}❌ inactivo${N}"
echo -ne "  Cron       "; _running "[c]ron_loop"      && echo -e "${G}✅ activo${N}"        || echo -e "${R}❌ inactivo${N}"
