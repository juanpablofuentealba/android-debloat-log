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

## 9. Sesión de recuperación (24-oct 07:3x) — intento paso 1

Contexto nuevo aportado por el usuario:
- **No tiene root**, solo **Shizuku** (moe.shizuku.privileged.api) + rish.
- Usa **ReVanced/Morphe**: `app.revanced.android.gms`, `app.morphe.android.apps.photos`,
  `app.morphe.android.youtube`, `app.morphe.android.apps.youtube.music`,
  `app.morphe.manager`, `com.revanced.net.revancedmanager`.
- **ReVanced ya estaba instalado ANTES del 1er debloat** => NO es causa raíz del UA599
  (la app funcionaba con ReVanced presente). Se mantiene como factor secundario posible.
- WebView: se detectó una **canary `157.0.8103.14`** y el usuario la **bajó a estable
  `140.0.7339.207`**. (Antes del incidente pudo estar la canary => candidato real.)
- `com.google.android.gms` oficial sigue instalado y habilitado; `app.revanced.android.gms`
  es ADICIONAL, no reemplaza al oficial.

Estado Shizuku/rish:
- Tras reiniciar el teléfono Shizuku se detiene. Se reactivó y `~/rish -c "echo OK"` => `OK`.
- rish: `~/rish` + `~/rish_shizuku.dex` ya desplegados en HOME (origen: `~/shz/`).
  NO hacen falta los archivos de Downloads.

### Intento paso 1: borrar SOLO caché de BancoEstado

```bash
~/rish -c "pm clear --cache-only net.veritran.becl.prod"
```

**RESULTADO: FALLA.** Salida real:

```
cmd: Failure calling service package: Failed transaction (2147483646)
```

**Causa:** Shizuku **sin root** no puede ejecutar `pm clear` (restricción de permisos
SELinux; `pm clear` requiere privilegios que Shizuku no otorga). NO es problema de la app.

**Alternativa (sin Shizuku):** borrar caché a mano:
Ajustes -> Apps -> BancoEstado -> Almacenamiento -> **Borrar caché** (NO borrar datos).

### Comandos preparados para los siguientes pasos (rish OK)

```bash
# Paso 2: restaurar SIM Toolkit quitado por el debloat
~/rish -c "cmd package install-existing com.android.stk"

# Paso 3: reactivar supervision de GMS
~/rish -c "pm enable com.google.android.gms.supervision"

# Paso 4 (si nada funciona): deshabilitar GMS de ReVanced temporalmente
~/rish -c "pm disable-user --user 0 app.revanced.android.gms"
# re-habilitar:
~/rish -c "pm enable app.revanced.android.gms"
```

### Nota entorno Shizuku (reencontrada)

- El timeout inicial de rish fue por: Shizuku detenido tras reinicio + optimización de
  batería. Solución: reiniciar Shizuku (depuración inalámbrica o ADB) y poner Termux y
  Shizuku en **Sin restricciones** de batería.

---

## 10. INVESTIGACIÓN WEB (24-oct) — causa raíz confirmada: MODO DESARROLLADOR

Se buscó en la web con el contexto real (sin root, solo Shizuku, developer mode).

### 10.1 Fuentes consultadas

| Fuente | URL |
|---|---|
| Bytepeaker | https://bytepeaker.com/android/solucion-error-ua599-en-la-aplicacion-banco-estado/ |
| Doncomo | https://doncomo.com/como-solucionar-el-error-ua599-en-la-aplicacion-del-banco-del-estado-en-android-guia-paso-a-paso/ |
| NotesRead | https://notesread.com/how-to-fix-the-ua599-error-in-the-banco-estado-app-on-android/ |
| Reclamos.cl | https://www.reclamos.cl/banco_estado/reclamo/2019/nov/bancoestado_error_ua599_r5 |
| Reclamos.cl | https://www.reclamos.cl/banco_estado/reclamo/2019/dec/bancoestado_error_ua599_r1 |

### 10.2 Qué dicen las fuentes (consenso)

Todas coinciden: **UA599 = la app detecta entorno de desarrollo / superusuario**.
Textual de Bytepeaker:
> "Usuarios que usan la aplicación Banco Estado se presentan con el error UA599,
> debido a que la aplicación detecta si en tu móvil descargaste una aplicación que
> otorga acceso de superusuario y tiene permisos para entrar al servicio Root."

NotesRead aclara que el disparador real suele ser:
> "Hay dos casos comunes: **la depuración USB está habilitada**, o la configuración
> de orígenes desconocidos. [...] presione 'USB debugging' para deshabilitarlo;
> después se recomienda **reinstalar la aplicación**. Así el sistema ya no pensará
> que está rooted."

En Reclamos.cl hay un caso titulado:
> **"Banco Estado - DICTADURA DIGITAL Te Bloquea Rut Pay si tienes modo Desarrollador Activo"**

Esto **confirma** lo que el usuario dijo por experiencia propia:
**la app de BancoEstado NO funciona con Modo Desarrollador activo.**

### 10.3 Soluciones que listan las fuentes (en orden)

1. **Desactivar Depuración USB** (Ajustes -> Opciones de desarrollador).
2. **Desactivar Modo Desarrollador** (el switch superior).
3. **Reinstalar la app** o al menos **borrar caché Y DATOS** (la app cachea la detección).
4. Root real: eliminarlo (SuperSU -> Full unroot). No aplica aquí (sin root).

### 10.4 IMPORTANTE — Shizuku también dispara la detección

Aunque se apague el Modo Desarrollador, **Shizuku** (moe.shizuku.privileged.api)
se inicia vía **ADB / depuración inalámbrica**. Veritran puede detectar el entorno
elevado. Por eso hay que:

- Detener **Shizuku** por completo.
- Desactivar **Depuración inalámbrica** (adb_wifi_enabled) y **Depuración USB** (adb_enabled).
- Desactivar el **Modo Desarrollador**.
- Recién entonces **borrar DATOS** de BancoEstado (no solo caché) o reinstalar.

### 10.5 Estado verificado tras apagar el modo desarrollador

```
~/rish -c "settings get global development_settings_enabled"  -> "Server is not running"
ps -A | grep shizuku                                            -> (vacío)
```

=> Al desactivar el Modo Desarrollador, **Shizuku se detuvo** (comportamiento esperado).
No hay procesos shizuku/rish activos. Esto es BUENO para pasar la validación del banco.

### 10.6 Plan definitivo recomendado (con lo que tenemos)

Todo SIN Shizuku (Shizuku ya está detenido y no se puede usar sin re-activar dev mode):

1. Confirmar en Ajustes que **Modo Desarrollador = OFF** y **Depuración USB = OFF**.
2. Ajustes -> Apps -> BancoEstado -> Almacenamiento -> **Borrar DATOS** (no solo caché).
   - Esto borra la sesión y la detección cacheada; habrá que volver a loguearse.
3. Abrir BancoEstado y probar.
4. Si sigue fallando: **desinstalar BancoEstado** y reinstalarla desde Play Store.
5. Si AÚN falla: probar la cuenta en otro teléfono (descarta bloqueo del banco).

**Nota:** el usuario probó borrar SOLO caché + apagar dev mode y NO funcionó. Falta el
paso crítico: **borrar DATOS / reinstalar** (la app guarda el resultado de la detección).

### 10.7 Conclusión de causa raíz

- **Causa principal confirmada por fuentes y por la experiencia del usuario:
  Modo Desarrollador / Depuración activos => UA599.**
- El debloat NO fue la causa (ni `stk` ni telemetría). Shizuku tampoco es instalable
  sin activar dev mode, así que su sola presencia no basta; pero el dev mode SI.
- Morphe/ReVanced GMS: descartado como causa raíz (estaba antes del 1er debloat).

---

## 12. SESIÓN 24-oct (tarde) — DESCARTE DEFINITIVO DEL DEBLOAT Y DE SHIZUKU

El usuario ejecutó **todo** el plan y el UA599 **persiste**:

| Acción ejecutada | Resultado |
|---|---|
| Apagar Modo Desarrollador | UA599 sigue |
| Detener Shizuku (0 procesos) | UA599 sigue |
| Borrar DATOS de BancoEstado | UA599 sigue |
| Desinstalar la app | OK |
| Reiniciar el equipo | OK |
| Reinstalar desde Play Store | **UA599 sigue** |

### 12.1 PRUEBA LÓGICA DECISIVA (aportada por el usuario)

El usuario tiene **otras apps financieras que funcionan perfectamente**:
- **Mercado Pago** (`com.mercadopago.wallet`) → OK
- **Mach BCI** (`cl.bci.sismo.mach`) → OK
- **Banco Falabella** → OK
- **SumUp con Tap to Pay / NFC** → OK (esta exige Play Integrity fuerte)
- **Global66** (`com.global66.cards`), **OnePay** (`cl.transbank.onepay`) → OK
- **ReVanced/Morphe, Shizuku, F-Droid, APK Extractor, Termux** ya estaban **ANTES**
  del primer debloat, y esos bancos NO los detectan como peligrosos.

**Conclusión:** si una app que exige **Play Integrity fuerte** (SumUp Tap to Pay)
funciona, y otras fintech funcionan, entonces **NO es detección de root/Shizuku/
debloat**. Es un problema **ESPECÍFICO de la app de BancoEstado / su plataforma
Veritran**, no del dispositivo.

### 12.2 Sistema verificado LIMPIO (a nivel Android)

```
ro.boot.verifiedbootstate = green     # bootloader íntegro
ro.boot.flash.locked      = 1         # bootloader BLOQUEADO
ro.boot.veritymode        = enforcing # dm-verity activo
ro.build.tags             = release-keys
ro.build.type             = user      # firmware oficial
ro.crypto.state           = encrypted
/sbin/magisk              -> no existe
su en PATH                -> no existe
```

=> A nivel de sistema operativo el equipo **NO está rooteado ni modificado**.

### 12.2b Subcódigo exacto: UA599 (D1)

El usuario confirmó que su error es **`UA599 (D1)`** (no `R:5`, que era el de los
reclamos web). Búsqueda web de `"UA599" "D1"` => **Bing: "No hay resultados"**.
Es un **código interno propietario de Veritran**, no documentado públicamente.

- El subcódigo (`D1`, `R:5`, etc.) indica el punto exacto del fallo dentro del
  microsite Veritran, pero **la familia UA599 es la misma**: entorno/validación
  no válida.
- No cambia el diagnóstico: problema específico de la app + este dispositivo/cuenta.

### 12.3 Causas probables restantes (NO relacionadas con el debloat)

1. **Falso positivo propio de la app de BancoEstado / Veritran** sobre este modelo
   (POCO `2410FPCC5G`, HyperOS 3.0, Android 16, build `OS3.0.307.0.WGTMIXM`).
2. **Versión de la app incompatible** con Android 16 / HyperOS 3 (build muy nuevo).
3. **Bloqueo del lado del banco** para esta cuenta/dispositivo (token, intentos
   fallidos, o el canal rechaza el device fingerprint).
4. **Play Integrity / atestación de hardware** que Veritran exige y que falla
   específicamente con la huella de este dispositivo (aunque el SO esté limpio).

### 12.4 Siguientes pasos recomendados (fuera del ámbito de Termux/Shizuku)

1. **Probar la cuenta en OTRO teléfono** (de un familiar/amigo).
   - Si funciona ahí → el problema es la combinación app+este dispositivo.
   - Si falla en otro teléfono también → el problema es **la cuenta/bloqueo del banco**.
2. **Llamar a BancoEstado** (600 200 7000 / app) y pedir **desbloqueo del canal
   digital** y reportar el código **UA599 (R:5)**. Mencionar que el equipo NO tiene
   root y el modo desarrollador está desactivado.
3. **Comparar versión de la app** con la Play Store; reportar si es build reciente.
4. **Reportar el modelo** (POCO 2410FPCC5G, Android 16 / HyperOS 3) para descartar
   incompatibilidad conocida.
5. **Usar la banca web** (bancoestado.cl) mientras se resuelve, o el sitio en
   navegador del teléfono.

### 12.5 Qué NO vale la pena seguir probando

- Restaurar apps del debloat (no es la causa).
- Desinstalar Shizuku/F-Droid/Termux/Morphe (no es la causa; ya estaban antes y
  otros bancos funcionan).
- Seguir borrando datos/reinstalando (ya se hizo y no cambia).

---

## 13. Archivos relacionados (todos en ~/debloat/)

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
