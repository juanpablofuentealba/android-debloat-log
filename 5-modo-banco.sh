#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# modo-banco.sh  ->  Apaga la DEPURACION USB para usar BancoEstado
# ============================================================
# Requiere: Shizuku/rish ACTIVO (para poder ejecutar settings put).
# OJO: al terminar, la depuracion queda OFF, asi que Shizuku se
#      detendra. Este es el ultimo comando que podras lanzar con rish.
#
# Uso:  bash ~/debloat/5-modo-banco.sh
# ============================================================
set -e
RISH="$HOME/rish"

echo "==> Modo BANCO: apagando Depuracion USB / inalambrica..."
"$RISH" -c "settings put global adb_enabled 0; \
            settings put global adb_wifi_enabled 0; \
            settings put global development_settings_enabled 0" 2>&1 || true

sleep 1
echo "==> Verificando:"
"$RISH" -c "echo -n 'adb_enabled='; settings get global adb_enabled; \
            echo -n 'adb_wifi_enabled='; settings get global adb_wifi_enabled" 2>&1 || true

echo ""
echo "==> Hecho. Ahora:"
echo "    1. Borra los DATOS de BancoEstado (Ajustes > Apps > BancoEstado > Almacenamiento > Borrar datos)."
echo "    2. Reinicia el telefono."
echo "    3. Abre BancoEstado -> deberia entrar."
echo ""
echo "    (Shizuku se detendra al cortarse ADB. Es normal.)"
