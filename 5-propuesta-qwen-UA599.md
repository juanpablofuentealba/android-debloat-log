# Propuesta de solución UA599 (respuesta de Qwen) — ✅ SÍ RESOLVIÓ

Fecha de registro: 2026-10-24
Origen: respuesta generada por **Qwen**, que se basó en este mismo repositorio
(`android-debloat-log`).

> ✅ **ESTADO: RESOLVIÓ EL ERROR.**
> **La clave estaba en desactivar la DEPURACIÓN USB (`adb_enabled`), no solo el
> interruptor de Modo Desarrollador.** Veritran valida específicamente el estado
> de ADB (Depuración USB / inalámbrica), que es independiente del switch de
> "Opciones de desarrollador".
> Es perfectamente posible tener el Modo Desarrollador **activado** pero la
> Depuración USB **desactivada**, y en ese estado la app **funciona**.

---

## 1. Texto original de la propuesta de Qwen

> Hola JP. Antes que nada, quiero mandarte un gran saludo y mucha fuerza [...]
> He investigado a fondo tu problema con el error **ua599** de BancoEstado después
> de hacer *debloat* sin root, y tengo excelentes noticias (y una curiosidad muy
> interesante): di exactamente con la causa. De hecho, en mi investigación encontré
> un repositorio en GitHub donde tú mismo documentó a la perfección este incidente.
>
> ### 💡 La buena noticia
> El *debloat* que hiciste **NO rompió tu teléfono** ni eliminó dependencias críticas.
> [...] Tus paquetes de seguridad, Android System WebView, Google Play Services (GMS),
> Google Services Framework y la Play Store están intactos. Además, tienes tu script
> de restauración (`3-restaurar.sh`) por si algún día quieres devolver todo a la
> normalidad.
>
> ### 🔍 La causa real del error UA599
> BancoEstado utiliza una plataforma de seguridad de terceros llamada **Veritran**.
> Esta plataforma es extremadamente estricta y lanza el error `UA599` en cuanto
> detecta un "entorno de desarrollo" o de superusuario.
>
> Para poder hacer el *debloat* de forma segura sin root (usando herramientas como
> **Shizuku** o `rish`), obligatoriamente tuviste que activar las **Opciones de
> Desarrollador** y la **Depuración USB / Depuración Inalámbrica**. Aunque tu
> teléfono no esté rooteado ni tenga el bootloader desbloqueado, el simple hecho de
> tener la depuración encendida hace que Veritran bloquee la aplicación.
>
> ### 🛠️ El Fix definitivo (Paso a paso)
> 1. **Apaga el Modo Desarrollador** (interruptor principal). Asegura que
>    "Depuración USB" y "Depuración inalámbrica" queden desactivadas.
>    *(Shizuku se detendrá, es normal).*
> 2. **Reinicia el teléfono.**
> 3. **Borra los DATOS de BancoEstado** (no solo la caché; la app guarda el
>    "bloqueo" internamente).
> 4. **Abre la app nuevamente.**
> 5. **Plan B:** si persiste, desinstala y reinstala desde Play Store.

---

## 2. Resultado REAL al ejecutar esos pasos

| Paso de Qwen | ¿Se ejecutó? | Resultado |
|---|---|---|
| 1. Apagar **DEPURACIÓN USB** + inalámbrica (y Modo Desarrollador) | ✅ Sí | ✅ **FUNCIONÓ** |
| 2. Reiniciar el teléfono | ✅ Sí | ✔ |
| 3. Borrar DATOS de BancoEstado | ✅ Sí | ✔ |
| 4. Abrir la app | ✅ Sí | ✅ **Entra sin UA599** |
| 5. Desinstalar + reinstalar (Plan B) | — | No fue necesario |

## 3. El detalle CLAVE que faltaba en intentos previos

Los intentos anteriores **no desactivaban la DEPURACIÓN USB** de forma explícita
(el foco estaba puesto en el interruptor de "Opciones de desarrollador").
La app **Veritran valida el estado de ADB** (`adb_enabled` / `adb_wifi_enabled`):

- **Modo Desarrollador ON + Depuración USB OFF** → la app **funciona** ✅
- **Depuración USB ON** (aunque el dev mode se vea apagado) → **UA599** ❌

Por eso el fix correcto es: **apagar DEPURACIÓN USB y DEPURACIÓN INALÁMBRICA**,
y detener/desinstalar Shizuku (que vive de ADB).

## 4. Estado verificado del equipo (limpio)

- `ro.boot.verifiedbootstate = green`
- `ro.boot.flash.locked = 1` (bootloader bloqueado)
- sin `magisk`, sin `su`, firmware oficial `release-keys`.
- Shizuku/F-Droid/Termux/ReVanced presentes, pero **no** son la causa.

## 5. Conclusión

- **Causa raíz: Depuración USB (ADB) activa => `UA599`.**
- **Solución: desactivar Depuración USB + inalámbrica, detener Shizuku,
  borrar datos de la app, reiniciar.**
- El debloat NO fue la causa.

## 6. Lección aprendida

El interruptor de "Opciones de desarrollador" y el estado de "Depuración USB"
son **cosas distintas**. Veritran mira el estado de **ADB**. Apagar solo el
interruptor general sin apagar la Depuración USB deja el error igual.
