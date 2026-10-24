# Incidente: BancoEstado error UA599 tras segundo debloat

Fecha del incidente: 2026-10-23
Dispositivo: POCO (MIUI/HyperOS)
App afectada: `net.veritran.becl.prod` (BancoEstado, plataforma Veritran/Microsite)

---

## 1. Resumen

Tras el **segundo debloat** (23-oct 19:17) la app de BancoEstado falla con
**UA599**. Se investigó si alguna app desinstalada por el debloat causó el error.

**Conclusión:** ninguna de las apps quitadas es dependencia directa de la banca.
El único candidato plausible de la lista es `com.android.stk` (SIM Toolkit).
El UA599 apunta más a WebView / integridad / fecha-hora que al debloat.

---

## 2. Cronología de los debloat

| Fecha/hora | Log | Acción |
|---|---|---|
| 2026-10-23 10:50 | `backup_pkgs_20261023.txt` | Backup de paquetes ANTES de tocar nada |
| 2026-10-23 10:56 | `log_desinstalacion_20261023_105604.txt` | 1er intento (sin rish) → TODO FALLO |
| 2026-10-23 11:15 | `log_desinstalacion_20261023_111500.txt` | 1er debloat real vía rish → OK |
| 2026-10-23 19:17 | `log_desinstalacion_20261023_191726.txt` | 2do debloat (pendientes) → OK |
| 2026-10-23 19:21 | `log_desinstalacion_20261023_192145.txt` | Verificación/reintento del 2do |

---

## 3. Apps quitadas en el 1er debloat (11:15, vía rish)

Formato: `OK <pkg>` = desinstalado para user 0 (reversible con `install-existing`).

```
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
com.miui.fm
com.miui.fmservice
com.miui.miservice
com.xiaomi.discover
com.mi.globalminusscreen
com.miui.vsimcore
com.miui.msa.global        (ya hecho antes)
com.xiaomi.midrop          (SKIP en este log)
```

## 4. Apps quitadas en el 2do debloat (19:17)

```
OK   com.miui.daemon        # telemetria de fondo
OK   com.xiaomi.glgm        # Game Center
OK   com.android.stk        # <-- SIM TOOLKIT  (unico sospechoso de banca)
SKIP com.xiaomi.midrop      # Failure [-1000], luego DESHABILITADO
```

Verificación 19:21: `com.miui.daemon` y `com.xiaomi.glgm` y `com.android.stk`
ya aparecen ausentes; `com.xiaomi.midrop` quedó DESHABILITADO.

---

## 5. Estado verificado (post-debloat, lectura con `pm list packages`)

### Dependencias críticas que SIGUEN presentes (NO se tocaron)
```
com.android.webview                 # motor del microsite Veritran
com.google.android.gms              # GMS
com.google.android.gsf
com.android.vending                 # Play Store
com.miui.securitycenter
com.lbe.security.miui
com.android.nfc
com.fido.asm
```

### Deshabilitados detectados (`pm list packages -d`)
```
com.android.virtualization.terminal
com.boundax.koreapreloadappinstaller
com.google.android.apps.photos
com.google.android.apps.youtube.music
com.google.android.devicelockcontroller   # <-- enrolamiento del dispositivo
com.google.android.gms.supervision        # <-- supervision GMS
com.google.android.ims                    # <-- IMS/RCS de Google (SMS/RCS)
com.google.android.youtube
com.miui.virtualsim
com.xiaomi.midrop                         # deshabilitado por el debloat
```

> **Nota:** `com.google.android.ims` (IMS/RCS) y
> `com.google.android.devicelockcontroller` tambien estan deshabilitados.
> Si aparecen problemas de SMS/RCS o de enrolamiento del dispositivo,
> son candidatos a revisar/reactivar.

### App del banco
```
net.veritran.becl.prod   # instalada desde 2026-09-13, NO tocada por debloat
pm path: /data/app/~~lTWwvxW26ZD-OWjBRJ4IVQ==/net.veritran.becl.prod-S_zCxmKirPZd6AGCxCJ13g==/base.apk
```

---

## 6. Análisis

- **UA599** es un código **interno de la plataforma Veritran** (no de Android ni de red).
  Suele indicar fallo al inicializar/validar el entorno seguro (microsite/WebView/atestación).
- Ninguna app quitada provee WebView, red, seguridad ni GMS → no explican el fallo.
- Único sospechoso real de la lista: **`com.android.stk`** (SIM Toolkit), usado por el
  operador para SMS OTA / banca por SIM.
- `com.google.android.gms.supervision` quedó **deshabilitado** (revisar si es intencional).

Causas probables del UA599 (en orden):
1. WebView desactualizado/roto (coincide en fecha con el 2do debloat).
2. `com.google.android.gms.supervision` deshabilitado.
3. Fecha/hora del sistema mal (Veritran valida TLS → certificado → UA599).
4. Restricciones de batería/red de fondo tras debloat.
5. Bloqueo del lado del banco (intentos fallidos / mantenimiento).

---

## 7. Plan de recuperación (orden recomendado, sin riesgo)

1. **Reiniciar y probar** la app. (no destructivo)
2. **Fecha/hora**: Ajustes → Sistema → Fecha y hora → automática ON
   (si ya estaba, off 5s y on para forzar resync). Zona: Chile / GMT-3.
3. **WebView**: Play Store → "Android System WebView" y "Chrome" → actualizar.
   Verificar que WebView no esté deshabilitado.
4. **Reiniciar de nuevo y probar**.
5. Si sigue (requiere Shizuku/rish activo):
   ```bash
   ~/rish -c "cmd package install-existing com.android.stk"
   ~/rish -c "pm enable com.google.android.gms.supervision"
   ```
6. **Borrar caché** (no datos) de BancoEstado.
7. Solo como último recurso: **borrar datos** (re-enrolar) y/o desinstalar + reinstalar.
8. Si nada funciona: probar la cuenta en **otro teléfono** (descarta fallo del banco).

### Restauración total del debloat
```bash
bash ~/debloat/3-restaurar.sh                       # usa el log mas reciente
bash ~/debloat/3-restaurar.sh <ruta-log-concreto>   # un log especifico
```
El script entiende: `QUITADO`/`OK` -> `cmd package install-existing`;
`DESHABILITADO` -> `pm enable`.

---

## 8. Notas de entorno

- Shizuku/rish dio **"Request timeout"**: desactivar optimización de batería
  para Termux y para Shizuku, luego reintentar.
- `pm` directo (sin rish) SÍ funciona para lectura de lista de paquetes.
- `dumpsys` NO está disponible en PATH de Termux.
- El APK no es legible directamente (permisos de sistema); usar rish si se
  necesita inspeccionar.

---

## 9. Archivos relacionados (todos en ~/debloat/)

```
1-lista-objetivos.sh                      # inventario (solo lectura)
2-desinstalar.sh                          # 1er intento sin rish
2-desinstalar-rish.sh                     # debloat conservador via rish
2b-desinstalar-pendientes-rish.sh         # 2do debloat (pendientes)
3-restaurar.sh                            # restauracion reversible
backup_pkgs_20261023.txt                  # backup de paquetes pre-debloat
log_desinstalacion_20261023_105604.txt
log_desinstalacion_20261023_111500.txt
log_desinstalacion_20261023_191726.txt
log_desinstalacion_20261023_192145.txt
INCIDENTE-bancoestado-UA599.md            # este archivo
```
