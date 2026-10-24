# android-debloat-log

Registro y respaldo del debloat de un dispositivo POCO (MIUI/HyperOS) vía
Shizuku/`rish`, incluyendo el incidente del error **UA599** de BancoEstado.

## Contenido

| Archivo | Descripción |
|---|---|
| `INCIDENTE-bancoestado-UA599.md` | Informe completo: cronología, apps quitadas, estado verificado, análisis, **investigación web** y plan de recuperación. **La conclusión vigente está en la sección 12.** |
| `4-fix-bancoestado-UA599.md` | Guía del fix. **Actualizada**: la hipótesis del Modo Desarrollador quedó **DESCARTADA**. |
| `5-propuesta-qwen-UA599.md` | Propuesta de solución dada por **Qwen** (basada en este repo) + **su resultado real: NO resolvió**. Registro didáctico. |
| `backup_pkgs_20261023.txt` | Backup de paquetes **pre-debloat** |
| `estado_pkgs_20261023_post-debloat.txt` | Estado de paquetes **post-debloat** |
| `estado_pkgs_deshabilitados_20261023.txt` | Paquetes deshabilitados |
| `log_desinstalacion_*.txt` | Logs originales de cada corrida de debloat |
| `1-lista-objetivos.sh` | Inventario (solo lectura) |
| `2-desinstalar.sh` | Primer intento (sin rish) |
| `2-desinstalar-rish.sh` | Debloat conservador vía rish |
| `2b-desinstalar-pendientes-rish.sh` | Segundo debloat (pendientes) |
| `3-restaurar.sh` | Restauración reversible |

## TL;DR del incidente (conclusión VIGENTE)

- App afectada: `net.veritran.becl.prod` (BancoEstado, plataforma Veritran/Microsite).
- Error exacto: **`UA599 (D1)`** (subcódigo interno de Veritran, no documentado).
- **El debloat NO fue la causa.** Ninguna app quitada es dependencia de la banca.
- **El Modo Desarrollador/Shizuku NO fue la causa** (hipótesis DESCARTADA):
  - Se apagó dev mode + depuración, se detuvo Shizuku, se borraron DATOS,
    se desinstaló, reinició y reinstaló => **el error siguió**.
- **Prueba decisiva:** en el MISMO equipo funcionan apps que exigen integridad
  fuerte: **SumUp Tap to Pay (NFC)**, **Mercado Pago**, **Mach**, **Banco Falabella**,
  **Global66**, **OnePay**. Si fuera detección de entorno, también fallarían.
- Sistema **limpio**: bootloader bloqueado, verified boot `green`, sin magisk/su,
  firmware oficial `release-keys`.
- Shizuku/F-Droid/Termux/ReVanced ya estaban ANTES del 1er debloat (no es la causa).
- WebView canary `157.0.8103.14` -> bajada a estable `140.0.7339.207`.

**Conclusión:** `UA599 (D1)` es **específico de la app de BancoEstado/Veritran**
(falso positivo, incompatibilidad con Android 16 / HyperOS 3, o bloqueo del lado
del banco). **No es el dispositivo.**

## Qué hacer (vigente)

1. **Probar la cuenta en OTRO teléfono** (define si es la cuenta o el equipo).
2. **Escalar el caso al área técnica del banco** con el código exacto `UA599 (D1)`,
   indicando que el equipo no tiene root y el dev mode está OFF.
3. Mientras tanto: usar la **banca web** (bancoestado.cl).

> Detalle completo en `4-fix-bancoestado-UA599.md` y sección 12 de
> `INCIDENTE-bancoestado-UA599.md`.

## Propuestas ya probadas que NO funcionaron

- Hipótesis "Modo Desarrollador" (ver `5-propuesta-qwen-UA599.md`).
- `pm clear` / `pm enable` / `install-existing` vía Shizuku sin root
  (dan `Failed transaction (2147483646)`).

## Restauración total

```bash
bash ~/debloat/3-restaurar.sh
```

> Nota: los comandos asumen Shizuku/`rish` activo. `pm uninstall --user 0` es
> reversible con `cmd package install-existing`.
