#!/data/data/com.termux/files/usr/bin/bash
# MODO CONSERVADOR - desinstala SOLO para el usuario 0 (reversible). Guarda log.
# NO toca: Facebook, Chrome, Google Bard/TV/One, Amazon, launcher, Seguridad Xiaomi.
# Ejecutar:  bash ~/debloat/2-desinstalar.sh

set -u
LOG=~/debloat/log_desinstalacion_$(date +%Y%m%d_%H%M%S).txt

PKGS=(
  # --- Anuncios / telemetria (la peor fuente de ads y rastreo) ---
  com.miui.msa.global
  com.miui.analytics
  com.miui.misightservice
  com.miui.bugreport

  # --- Tiendas de apps MIUI ---
  com.xiaomi.mipicks

  # --- Apps MIUI prescindibles (multimedia/limpieza/navegador) ---
  com.miui.player
  com.miui.videoplayer
  com.miui.cleaner
  com.miui.yellowpage
  com.mi.globalbrowser
  com.mi.appfinder
  com.miui.fm
  com.miui.fmservice

  # --- Servicios MIUI de relleno ---
  com.miui.miservice
  com.xiaomi.midrop
  com.xiaomi.discover
  com.mi.globalminusscreen

  # --- SIM virtual (no aplica en Chile) ---
  com.miui.vsimcore
)

echo "Log: $LOG"
echo "# Desinstalados (user 0), modo conservador, $(date)" > "$LOG"
for p in "${PKGS[@]}"; do
  if pm list packages 2>/dev/null | grep -q "package:$p$"; then
    if pm uninstall --user 0 "$p" >/dev/null 2>&1; then
      echo "OK    $p" | tee -a "$LOG"
    else
      echo "FALLO $p" | tee -a "$LOG"
    fi
  else
    echo "SKIP  $p (no instalado)" | tee -a "$LOG"
  fi
done
echo
echo "Listo. Revertir:  bash ~/debloat/3-restaurar.sh"
