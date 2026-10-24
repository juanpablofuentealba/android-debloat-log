#!/data/data/com.termux/files/usr/bin/bash
# MODO CONSERVADOR via Shizuku/rish - desinstala para user 0 (reversible).
# Ejecutar:  bash ~/debloat/2-desinstalar-rish.sh

set -u
RISH=~/rish
LOG=~/debloat/log_desinstalacion_$(date +%Y%m%d_%H%M%S).txt

PKGS=(
  com.miui.analytics
  com.miui.misightservice
  com.miui.bugreport
  com.xiaomi.mipicks
  com.miui.player
  com.miui.videoplayer
  com.miui.cleaner
  com.miui.yellowpage
  com.mi.globalbrowser
  com.mi.appfinder
  com.miui.miservice
  com.xiaomi.midrop
  com.xiaomi.discover
  com.mi.globalminusscreen
  com.miui.vsimcore
)

echo "Log: $LOG"
echo "# Desinstalados (user 0) modo conservador via rish, $(date)" > "$LOG"
echo "com.miui.msa.global  (ya hecho antes)" >> "$LOG"

for p in "${PKGS[@]}"; do
  out=$(timeout 30 "$RISH" -c "pm uninstall --user 0 $p" 2>&1)
  case "$out" in
    *Success*)     echo "OK    $p"; echo "OK $p" >> "$LOG" ;;
    *Failure*|*Exception*|*"not installed"*) echo "SKIP  $p ($out)"; echo "SKIP $p" >> "$LOG" ;;
    *)             echo "??    $p -> $out"; echo "SKIP $p" >> "$LOG" ;;
  esac
done
echo
echo "Listo. Revertir:  bash ~/debloat/3-restaurar.sh"
