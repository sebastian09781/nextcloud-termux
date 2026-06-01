#!/data/data/com.termux/files/usr/bin/bash
# Prueba conexión a MariaDB
echo "Probando conexión MariaDB..."
mysqladmin ping --silent && echo "✅ MariaDB responde" || echo "❌ MariaDB no responde"
echo ""
echo "Base de datos Nextcloud:"
mysql -e "USE nextcloud; SELECT COUNT(*) AS tablas FROM information_schema.tables WHERE table_schema='nextcloud';" 2>/dev/null || echo "  No se pudo acceder"
