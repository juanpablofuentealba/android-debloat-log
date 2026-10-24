#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# modo-shizuku.sh  ->  Enciende la DEPURACION USB para usar Shizuku
# ============================================================
# OJO: este script NO puede ejecutarse solo. Para activar la
# depuracion USB se necesita ADB (PC) o hacerlo a mano en Ajustes.
# Aqui se dejan los pasos claros y, si Shizuku ya esta activo, se
# puede usar para ENCENDERLA. Si Shizuku esta detenido, hazlo manual.
#
# Uso:  bash ~/debloat/6-modo-shizuku.sh
# ============================================================
RISH="$HOME/rish"

echo "==> Modo SHIZUKU: se necesita Depuracion USB ENCENDIDA."
echo ""

if "$RISH" -c "echo OK" >/dev/null 2>&1; then
  echo "==> Shizuku/rish disponible. Encendiendo depuracion..."
  "$RISH" -c "settings put global development_settings_enabled 1; \
              settings put global adb_enabled 1; \
              settings put global adb_wifi_enabled 1" 2>&1 || true
  sleep 1
  "$RISH" -c "echo -n 'adb_enabled='; settings get global adb_enabled" 2>&1 || true
  echo ""
  echo "==> Depuracion ENCENDIDA. Reinicia Shizuku desde su app."
  echo "    AVISO: BancoEstado se bloqueara (UA599) mientras ADB este ON."
else
  echo "==> Shizuku/rish NO responde (esta detenido, porque ADB esta OFF)."
  echo "    Para volver a activarlo, hazlo MANUALMENTE:"
  echo ""
  echo "    A. Ajustes > Sistema > Opciones de desarrollador"
  echo "       -> Depuracion USB = ON"
  echo "       -> Depuracion inalambrica = ON"
  echo "    B. Abre la app Shizuku e iniciala"
  echo "       (via depuracion inalambrica o con PC/ADB:"
  echo "        adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh )"
  echo "    C. Cuando Shizuku arranque, vuelve a correr este script si quieres."
fi

echo ""
echo "    Recuerda: mientras ADB este ON, BancoEstado dara UA599."
