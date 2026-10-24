# Propuesta de solución UA599 (respuesta de Qwen) — y su resultado real

Fecha de registro: 2026-10-24
Origen: respuesta generada por **Qwen**, que se basó en este mismo repositorio
(`android-debloat-log`). Se guarda aquí como registro histórico y didáctico.

> ⚠️ **ESTADO: NO RESOLVIÓ EL ERROR.**
> Los pasos que propone **ya se ejecutaron** y el error **`UA599 (D1)` persistió**.
> Ver `INCIDENTE-bancoestado-UA599.md` sección 12 (descarte definitivo).
> Se conserva este texto porque es útil entender por qué la hipótesis no se sostiene.

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
| 1. Apagar Modo Desarrollador + Depuración | ✅ Sí | ❌ `UA599 (D1)` siguió |
| 2. Reiniciar el teléfono | ✅ Sí | ❌ siguió |
| 3. Borrar DATOS de BancoEstado | ✅ Sí | ❌ siguió |
| 4. Abrir la app | ✅ Sí | ❌ siguió |
| 5. Desinstalar + reiniciar + reinstalar | ✅ Sí | ❌ siguió |

## 3. Por qué la hipótesis de Qwen NO se sostiene

1. **Ya se ejecutó completa** y el error persistió (tabla arriba).
2. **Argumento decisivo:** en el MISMO equipo funcionan apps que también exigen
   integridad fuerte:
   - **SumUp con Tap to Pay (NFC)** ✅
   - **Mercado Pago** ✅
   - **Mach BCI**, **Banco Falabella**, **Global66**, **OnePay** ✅
   Si Veritran bloqueara por "entorno de desarrollo", esas apps también fallarían.
3. El equipo está **limpio a nivel de sistema**:
   - `ro.boot.verifiedbootstate = green`
   - `ro.boot.flash.locked = 1`
   - sin `magisk`, sin `su`, firmware oficial `release-keys`.
4. **Shizuku/F-Droid/Termux/ReVanced ya estaban ANTES** del primer debloat y los
   otros bancos no se quejan.

## 4. Conclusión vigente

El `UA599 (D1)` es **específico de la app de BancoEstado / Veritran** en este
dispositivo/cuenta (falso positivo, incompatibilidad con Android 16 / HyperOS 3,
o bloqueo del lado del banco). **No es el debloat, ni el dev mode, ni Shizuku.**

Pasos vigentes: probar la cuenta en otro teléfono y escalar el caso al área
técnica del banco con el código exacto **`UA599 (D1)`**.

Ver `4-fix-bancoestado-UA599.md` e `INCIDENTE-bancoestado-UA599.md` (sección 12).

---

## 5. Lección aprendida

Qwen se basó en las **secciones antiguas** del informe (hipótesis del dev mode,
secciones 5-10) y **no consideró la sección 12**, donde esa hipótesis ya estaba
**descartada con evidencia**. Este archivo queda como registro para que ninguna
IA ni persona vuelva a repetir pasos ya probados.

**Regla:** leer SIEMPRE la conclusión vigente del incidente antes de proponer
un fix.
