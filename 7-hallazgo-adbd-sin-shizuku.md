# Hallazgo: el UA599 lo causa `adbd` vivo, NO Shizuku (2026-11-08)

> **Corrige y completa** `4-fix-bancoestado-UA599.md`. Ese archivo dice *"causa
> raíz: Depuración USB (ADB)"*, pero **no aclara que desinstalar Shizuku no
> alcanza**. Este caso lo demuestra.

## Qué pasó

El operador **ya no tiene Shizuku instalado** (`pm list packages` no lo
encuentra; los residuos `~/rish` y `rish_shizuku.dex` están en `~/.residuos/`).
**Y aun así BancoEstado daba `UA599 (D1)`.**

La causa no era Shizuku: era **`adbd` corriendo**.

## Evidencia (a16, Android 16 / HyperOS V816, 08-nov-2026)

### Con el error

```
$ getprop init.svc.adbd          -> running     ← el daemon de ADB VIVO
$ getprop sys.usb.config         -> adb
$ getprop persist.sys.usb.config -> adb         ← PERSISTENTE
```

En ese momento: **Shizuku desinstalado**, y el operador **no es developer**
(menú de Opciones de desarrollador apagado). BancoEstado → **UA599 (D1)**.

### Después de apagar "Depuración USB"

```
$ getprop init.svc.adbd          -> stopped     ✅
$ getprop sys.usb.config         -> mtp
$ getprop persist.sys.usb.config -> none        ← Android limpió la persistente
```

**BancoEstado entró.** Sin reinstalar nada.

## Por qué importa (lo que faltaba documentar)

1. **Shizuku ≠ ADB.** Shizuku **usaba** ADB para obtener privilegios; sacar
   Shizuku **no apaga ADB**. El daemon `adbd` queda vivo y Veritran lo detecta.
2. **`persist.sys.usb.config=adb` es persistente.** Sobrevive reinicios: Android
   vuelve a levantar `adbd` aunque el menú de developer esté apagado. Se limpia
   **solo** al apagar Depuración USB (`-> none`), no reinstalando ni reiniciando.
3. **Veritran mira ADB, no el Modo Desarrollador** (ya estaba en
   `4-fix-bancoestado-UA599.md`; aquí se confirma desde otro ángulo: no ser
   developer y tener `adbd` vivo da igual → UA599).
4. **Apagar Depuración USB SÍ mata `adbd`** y **SÍ limpia** la propiedad
   persistente. No hace falta `setprop` por ADB externo.

## Regla corregida

> **Para que BancoEstado funcione no basta con sacar Shizuku: hay que apagar la
> DEPURACIÓN USB para que muera `adbd`.**
> Y como `persist.sys.usb.config=adb` es persistente, mientras no se apague,
> `adbd` revive en cada arranque.

**Verificación rápida (desde Termux, sin permisos):**

```bash
getprop init.svc.adbd            # debe decir: stopped
getprop persist.sys.usb.config   # debe decir: none  (o mtp)
```

Si dice `running` / `adb` → BancoEstado dará UA599.

## Relación con el re-enrolamiento

Ya documentado en la práctica: tras apagar ADB, la app volvió a pedir
**re-enrolar** (perder sesión/dispositivo). Este archivo se limita a la causa
del UA599; el costo de alternar Shizuku ⟷ BancoEstado es aparte.
