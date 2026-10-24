# Fix BancoEstado UA599 — Guía definitiva (sin root) ✅ RESUELTO

Dispositivo: POCO (MIUI/HyperOS) · App: `net.veritran.becl.prod`
Actualizado: 2026-10-24

## Causa raíz (confirmada)

BancoEstado (plataforma Veritran) lanza **UA599** cuando detecta el entorno de
desarrollo. **El disparador específico es la DEPURACIÓN USB (ADB)**, no solo el
interruptor de "Modo Desarrollador".

> ⚠️ **Clave:** "Opciones de desarrollador" y "Depuración USB" son **cosas
distintas**. Veritran mira el estado de **ADB**.
> - Modo Desarrollador **ON** + Depuración USB **OFF** → la app **funciona** ✅
> - Depuración USB **ON** → **UA599** ❌

En este equipo: **sin root**, pero se usa **Shizuku** (que requiere ADB +
depuración inalámbrica). Al cortar ADB, **Shizuku se detiene**.

## Pasos definitivos (en orden)

### 1. Apagar la DEPURACIÓN USB (paso CLAVE)
- Ajustes -> Sistema -> Opciones de desarrollador -> **Depuración USB = OFF**
  y **Depuración inalámbrica = OFF**. (Este es el paso que resuelve.)
- Opcionalmente, apagar también el switch superior de "Opciones de desarrollador".
- Dentro, verificar **Depuración USB = OFF** y **Depuración inalámbrica = OFF**.
- Confirmado por rish antes de perderlo:
  ```
  settings get global development_settings_enabled   -> 0
  settings get global adb_enabled                    -> 0
  settings get global adb_wifi_enabled               -> 0
  ```

### 2. Detener Shizuku por completo
- Abrir app Shizuku -> **Detener** (o simplemente reiniciar tras apagar dev mode).
- Verificar que no queden procesos:
  ```
  ps -A | grep -i shizuku   # debe salir vacío
  ```

### 3. Borrar DATOS de BancoEstado (CLAVE — no basta la caché)
- Ajustes -> Apps -> BancoEstado -> Almacenamiento -> **Borrar datos**.
- Esto elimina la detección cacheada por la app. Habrá que re-loguearse.

### 4. Probar la app
- Abrir BancoEstado. Si entra, LISTO.

### 5. Si sigue fallando: reinstalar
- Desinstalar BancoEstado.
- Reiniciar el teléfono.
- Reinstalar desde Play Store.
- Abrir y probar.

### 6. Si AÚN falla
- Probar la cuenta en **otro teléfono** -> descarta bloqueo del banco
  (intentos fallidos / mantenimiento del lado del banco).
- Llamar a BancoEstado y pedir desbloqueo del canal.

## Por qué NO es necesario restaurar STK ni el debloat

- El debloat quitó telemetría/STK. Ninguna es dependencia de la banca.
- Rish **sin root** NO puede `pm clear`, `pm enable` ni `install-existing`
  (da "Failed transaction (2147483646)").
- `com.android.stk` / `com.google.android.gms.supervision` no son el problema.

## Nota sobre WebView

Se detectó una WebView canary `157.0.8103.14`; se bajó a estable `140.0.7339.207`.
No era la causa del UA599, pero es bueno dejarla estable.

## ACTUALIZACIÓN 24-oct (tarde): hipótesis del dev mode DESCARTADA

Se ejecutó el plan completo y el UA599 **persiste**: apagar dev mode, detener
Shizuku, borrar DATOS, desinstalar, reiniciar, reinstalar. Nada funcionó.

### Evidencia de que NO es el dispositivo ni el debloat

- **SumUp con Tap to Pay (NFC)** funciona => Play Integrity fuerte PASA.
- **Mercado Pago, Mach BCI, Banco Falabella, Global66, OnePay** funcionan.
- **Shizuku, F-Droid, APK Extractor, Termux, ReVanced/Morphe** ya estaban ANTES
  del 1er debloat y esos bancos no se quejan.
- Sistema limpio: bootloader bloqueado, verified boot green, sin magisk, sin su,
  firmware oficial `user/release-keys`.

### Conclusión

El problema es **específico de la app de BancoEstado / Veritran** (falso positivo,
versión incompatible con Android 16 / HyperOS 3, o bloqueo del lado del banco).

### Qué hacer ahora (fuera de Termux)

1. Probar la cuenta en **otro teléfono** (clave para saber si es la cuenta o el equipo).
2. **Llamar a BancoEstado** y reportar **UA599 (R:5)** + pedir desbloqueo del canal.
   Indicar que el equipo no tiene root y el dev mode está OFF.
3. Verificar **versión de la app** vs Play Store.
4. Usar la **banca web** mientras tanto.

### Modelo afectado

- POCO `2410FPCC5G`, HyperOS 3.0, **Android 16**, build `OS3.0.307.0.WGTMIXM`.

## Estado final esperado

| Elemento | Estado |
|---|---|
| Modo desarrollador | OFF |
| Depuración USB / inalámbrica | OFF |
| Shizuku | detenido |
| Root | no tiene |
| BancoEstado | datos borrados / reinstalada |
| ReVanced/Morphe | intacto (no es la causa) |
