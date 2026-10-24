# Fix BancoEstado UA599 — Guía definitiva (sin root)

Dispositivo: POCO (MIUI/HyperOS) · App: `net.veritran.becl.prod`
Actualizado: 2026-10-24

## Causa raíz

BancoEstado (plataforma Veritran) lanza **UA599** cuando detecta
**Modo Desarrollador / Depuración USB / Depuración inalámbrica activos**,
o **root/superusuario**. Confirmado por:
- bytepeaker.com · doncomo.com · notesread.com
- Reclamos.cl: "Banco Estado te Bloquea Rut Pay si tienes modo Desarrollador Activo"

En este equipo: **sin root**, pero se usa **Shizuku** (que requiere dev mode +
depuración inalámbrica). Al desactivar el Modo Desarrollador, **Shizuku se detiene**.

## Pasos definitivos (en orden)

### 1. Apagar todo lo de desarrollo
- Ajustes -> Sistema -> Opciones de desarrollador -> **switch superior OFF**.
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

## Estado final esperado

| Elemento | Estado |
|---|---|
| Modo desarrollador | OFF |
| Depuración USB / inalámbrica | OFF |
| Shizuku | detenido |
| Root | no tiene |
| BancoEstado | datos borrados / reinstalada |
| ReVanced/Morphe | intacto (no es la causa) |
