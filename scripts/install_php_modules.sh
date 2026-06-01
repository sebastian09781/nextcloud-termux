#!/data/data/com.termux/files/usr/bin/bash
# Instala módulos PHP para Nextcloud
MODULES="php-bcmath php-curl php-gd php-gmp php-igbinary php-imagick php-intl php-mbstring php-mysql php-redis php-xml php-zip php-apcu"

echo "Instalando módulos PHP..."
pkg install -y $MODULES
echo "Listo."
