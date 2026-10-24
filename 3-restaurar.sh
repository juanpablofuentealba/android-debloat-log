#!/data/data/com.termux/files/usr/bin/bash
# Restaura paquetes tocados por el debloat (via Shizuku/rish).
#
# Uso:  bash ~/debloat/3-restaurar.sh [log]
# Sin argumento usa el log mas reciente.
#
# Entiende los formatos del log:
#   QUITADO <pkg>        -> cmd package install-existing <pkg>
#   DESHABILITADO <pkg>  -> pm enable <pkg>
#   OK <pkg>             -> (logs antiguos) install-existing

set -u
RISH="$HOME/rish"
LOG="${1:-$(ls -t ~/debloat/log_desinstalacion_*.txt 2>/dev/null | head -1)}"

if [ -z "${LOG:-}" ] || [ ! -f "$LOG" ]; then
  echo "No encontre log de debloat en ~/debloat/."; exit 1
fi

r(){ # ejecuta via rish si esta disponible, si no directo
  if [ -x "$RISH" ] && timeout 15 "$RISH" -c "id" >/dev/null 2>&1; then
    timeout 30 "$RISH" -c "$1" 2>&1
  else
    timeout 30 sh -c "$1" 2>&1
  fi
}

echo "Restaurando desde: $LOG"
n=0
while read -r state pkg _; do
  [ -n "${pkg:-}" ] || continue
  case "$state" in
    QUITADO|OK)
      if r "cmd package install-existing $pkg" | grep -qi "installed"; then
        echo "RESTAURADO     $pkg"
      else
        echo "FALLO          $pkg"
      fi
      n=$((n+1)) ;;
    DESHABILITADO)
      if r "pm enable $pkg" | grep -qiE "new state: enabled"; then
        echo "REACTIVADO     $pkg"
      else
        echo "FALLO          $pkg"
      fi
      n=$((n+1)) ;;
  esac
done < <(grep -E '^(QUITADO|DESHABILITADO|OK) ' "$LOG")

echo "Hecho. ($n paquetes procesados)"
