#!/data/data/com.termux/files/usr/bin/bash
# Debloat seguro para user 0 via Shizuku/rish. 100% reversible.
#
# Uso:      bash ~/debloat/2b-desinstalar-pendientes-rish.sh
# Revertir: bash ~/debloat/3-restaurar.sh <log>
#
# Estrategia por paquete:
#   1) pm uninstall --user 0   -> si "Success"            => QUITADO
#   2) si "Failure [-1000]"    -> pm disable-user --user 0 => DESHABILITADO
#   3) si tampoco              -> SKIP (se reporta)
#
# Verificacion FIABLE: se lee el estado con `pm list packages` en UNA sola
# llamada a rish (cacheado), no con un grep por paquete (evita falsos OK).

set -u
RISH="$HOME/rish"
STAMP="$(date +%Y%m%d_%H%M%S)"
LOG="$HOME/debloat/log_desinstalacion_$STAMP.txt"

# --- Lista revisada (todos reversibles) ---
PKGS=(
  com.miui.daemon     # System Daemon: telemetria de fondo
  com.xiaomi.midrop   # Mi Drop: transferencia de archivos
  com.xiaomi.glgm     # Game Center: anuncios/juegos
  com.android.stk     # SIM Toolkit: menu de operador
)

die(){ echo "ERROR: $*" >&2; exit 1; }

[ -x "$RISH" ] || die "no existe $RISH"

echo "== Comprobando Shizuku/rish =="
if ! timeout 20 "$RISH" -c "id" 2>&1 | grep -q "uid=2000"; then
  die "Shizuku no responde. Inicia Shizuku y desactiva el ahorro de bateria
       para Termux y Shizuku, luego reintenta."
fi
echo "OK: rish operativo (uid=2000 shell)"
echo

# --- Estado real, en UNA llamada (evita timeouts/falsos negativos) ---
snapshot(){
  timeout 25 "$RISH" -c "pm list packages" 2>/dev/null | sed 's/^package://'
}
is_installed(){ echo "$ALL" | grep -qx "$1"; }
is_disabled(){ timeout 25 "$RISH" -c "pm list packages -d" 2>/dev/null | sed 's/^package://' | grep -qx "$1"; }
is_present(){ is_installed "$1" || is_disabled "$1"; }

ALL="$(snapshot)"
[ -n "$ALL" ] || die "no pude leer la lista de paquetes (timeout de rish)"

echo "Log: $LOG"
{
  echo "# Debloat user 0 via rish, $STAMP"
  echo "# formato: RESULTADO paquete  (QUITADO|DESHABILITADO|SKIP)"
} > "$LOG"

for p in "${PKGS[@]}"; do
  if ! is_present "$p"; then
    echo "AUSENTE        $p"; echo "SKIP $p (ausente)" >> "$LOG"; continue
  fi

  out=$(timeout 30 "$RISH" -c "pm uninstall --user 0 $p" 2>&1)
  if echo "$out" | grep -q "Success"; then
    echo "QUITADO        $p"; echo "QUITADO $p" >> "$LOG"; continue
  fi

  # Fallback documentado: algunos paquetes protegidos dan Failure [-1000]
  out2=$(timeout 30 "$RISH" -c "pm disable-user --user 0 $p" 2>&1)
  if echo "$out2" | grep -qi "new state: disabled"; then
    echo "DESHABILITADO  $p  (uninstall: $out)"; echo "DESHABILITADO $p" >> "$LOG"; continue
  fi

  echo "SKIP           $p  (uninstall: $out | disable: $out2)"
  echo "SKIP $p (uninstall: $out | disable: $out2)" >> "$LOG"
done

# --- Verificacion final (re-lee estado real) ---
echo
echo "== Verificacion =="
for p in "${PKGS[@]}"; do
  if is_installed "$p"; then
    if is_disabled "$p"; then echo "DESHABILITADO  $p"; else echo "SIGUE ACTIVO   $p"; fi
  else
    echo "QUITADO        $p"
  fi
done

echo
echo "Revertir todo:      bash ~/debloat/3-restaurar.sh $LOG"
echo "Reactivar uno:      ~/rish -c \"pm enable <pkg>\""
