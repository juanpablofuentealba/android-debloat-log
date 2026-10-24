#!/data/data/com.termux/files/usr/bin/bash
# Muestra que paquetes de la lista existen y su estado. NO borra nada.

PKGS=(
  # --- Anuncios / telemetria (maxima prioridad) ---
  com.miui.msa.global
  com.miui.analytics
  com.miui.misightservice
  com.miui.bugreport

  # --- Tiendas / apps MIUI prescindibles ---
  com.xiaomi.mipicks
  com.miui.player
  com.miui.videoplayer
  com.miui.virtualsim
  com.miui.vsimcore
  com.miui.cleaner
  com.miui.yellowpage
  com.mi.globalbrowser
  com.mi.appfinder
  com.miui.fm
  com.miui.fmservice
  com.miui.miservice
  com.xiaomi.midrop
  com.xiaomi.discover
  com.mi.globalminusscreen

  # --- Preinstalados de terceros (bloat de fabricante) ---
  com.facebook.system
  com.facebook.appmanager
  com.facebook.services
  com.facebook.katana
  com.facebook.orca
  com.facebook.adsmanager
  com.facebook.stella
  com.amazon.appmanager
  com.bilibili.app.in

  # --- Google prescindible (solo si usas alternativas) ---
  com.google.android.apps.bard
  com.google.android.videos
  com.google.android.apps.subscriptions.red
  com.android.chrome
)

echo "=== ESTADO DE OBJETIVOS ==="
for p in "${PKGS[@]}"; do
  if pm list packages 2>/dev/null | grep -q "package:$p$"; then
    if pm list packages -d 2>/dev/null | grep -q "package:$p$"; then
      echo "[DESHABILITADO] $p"
    else
      echo "[instalado]    $p"
    fi
  else
    echo "[no existe]    $p"
  fi
done
