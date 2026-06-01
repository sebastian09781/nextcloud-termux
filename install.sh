#!/data/data/com.termux/files/usr/bin/bash
# ──────────────────────────────────────────────────────
# nextcloud-termux — Instalación guiada paso a paso
# Repo: https://github.com/sebastian09781/nextcloud-termux
# ──────────────────────────────────────────────────────

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; N='\033[0m'
step=0

next() { step=$((step+1)); echo -e "\n${B}[${step}/${total}]${N} $1"; }
ok()   { echo -e "  ${G}✅${N} $1"; }
info() { echo -e "  ${Y}ℹ${N}  $1"; }

total=5

clear
echo -e "${B}╔════════════════════════════════════════╗${N}"
echo -e "${B}║   nextcloud-termux — Instalación guiada ${N}"
echo -e "${B}╚════════════════════════════════════════╝${N}"
echo -e "${Y}Este script prepara tu Termux para correr${N}"
echo -e "${Y}un servidor Nextcloud 24/7 en Android.${N}"
sleep 1

# ── Paso 1: core-termux ──────────────────────────────
next "core-termux — Framework base para Termux"
echo ""
echo "  core-termux instala herramientas esenciales"
echo "  (gh, fzf, bat, lsd, nodejs, python, etc.)"
echo "  y un sistema modular para gestionar paquetes."
echo ""
echo -e "  ${Y}¿Quieres continuar con la instalación?${N}"
echo -n "  Presiona ENTER para continuar (o Ctrl+C para salir)... "
read -r _

echo ""
echo -e "  ${B}Ejecutando:${N}"
echo "  curl -fsSL https://raw.githubusercontent.com/DevCoreXOfficial/core-termux/main/install.sh | bash"
echo ""
curl -fsSL https://raw.githubusercontent.com/DevCoreXOfficial/core-termux/main/install.sh | bash
if [ $? -eq 0 ]; then
  ok "core-termux instalado"
else
  echo -e "  ${R}❌ Error instalando core-termux${N}"
  echo "  Revisa tu conexión e intenta de nuevo."
  exit 1
fi
sleep 1

# ── Paso 2: opencode ─────────────────────────────────
next "opencode — Asistente AI para desarrollo"
echo ""
echo "  opencode es el asistente AI con el que fue"
echo "  construido este proyecto. Te guiará en la"
echo "  configuración del servidor Nextcloud."
echo ""
echo -e "  ${B}Ejecutando:${N}"
echo "  core install ai --opencode"
echo ""
core install ai --opencode
if [ $? -eq 0 ]; then
  ok "opencode instalado"
else
  echo -e "  ${Y}⚠ opencode ya está instalado o hubo un error${N}"
fi
sleep 1

# ── Paso 3: nextcloud-termux repo ────────────────────
next "Clonar nextcloud-termux"
echo ""
echo "  Este repositorio contiene scripts, configuraciones"
echo "  y documentación para el servidor Nextcloud."
echo ""
if [ -d "$HOME/nextcloud-termux" ]; then
  info "nextcloud-termux ya existe, actualizando..."
  cd "$HOME/nextcloud-termux" && git pull
else
  cd "$HOME"
  git clone https://github.com/sebastian09781/nextcloud-termux.git
fi
if [ $? -eq 0 ]; then
  ok "Repositorio listo en ~/nextcloud-termux"
else
  echo -e "  ${R}❌ Error clonando el repositorio${N}"
  exit 1
fi
sleep 1

# ── Paso 4: permisos ─────────────────────────────────
next "Dar permisos a los scripts"
chmod +x "$HOME/nextcloud-termux/scripts/"*.sh
chmod +x "$HOME/nextcloud-termux/boot/"*.sh
chmod +x "$HOME/nextcloud-termux/shortcuts/"*
ok "Scripts ejecutables"

# ── Paso 5: guía ─────────────────────────────────────
next "¡Instalación completada! ¿Cómo seguir?"
echo ""
echo -e "  ${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo -e "  ${G}  Todo listo para configurar tu servidor${N}"
echo -e "  ${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
echo ""
echo -e "  ${B}Para continuar, ejecuta opencode:${N}"
echo ""
echo -e "    ${Y}opencode${N}"
echo ""
echo -e "  Luego dentro de opencode, pídele que te guíe:${N}"
echo ""
echo -e "    ${B}>${N} quiero instalar y configurar el servidor Nextcloud paso a paso"
echo ""
echo -e "  ${B}O puedes leer la documentación:${N}"
echo ""
echo -e "    ${Y}cat ~/nextcloud-termux/README.md${N}"
echo ""
echo -e "  ${B}Scripts disponibles:${N}"
echo ""
echo "    scripts/start_nextcloud.sh    Iniciar servidor"
echo "    scripts/stop_nextcloud.sh     Detener servidor"
echo "    scripts/status_nextcloud.sh   Ver estado"
echo "    scripts/backup_nextcloud.sh   Backup completo"
echo "    scripts/install_php_modules.sh  Módulos PHP"
echo ""
echo -e "  ${B}Shortcuts para Tasker/Widget:${N}"
echo ""
echo "    shortcuts/Iniciar Nextcloud"
echo "    shortcuts/Detener Nextcloud"
echo "    shortcuts/Estado Nextcloud"
echo "    shortcuts/Reiniciar Nextcloud"
echo ""
echo -e "  ${B}Configuraciones de ejemplo:${N}"
echo ""
echo "    config/config.php.example"
echo "    config/my.cnf"
echo "    config/nextcloud.conf"
echo "    config/nc_vars.env.example"
echo ""
echo -e "  ${B}Battery Smart Charger (control de batería):${N}"
echo ""
echo "    https://github.com/sebastian09781/battery-smart-charger"
echo ""
echo -e "${G}╔════════════════════════════════════════╗${N}"
echo -e "${G}║  ¡Gracias por usar nextcloud-termux!   ║${N}"
echo -e "${G}║  opencode te guiará en lo que sigue.   ║${N}"
echo -e "${G}╚════════════════════════════════════════╝${N}"
