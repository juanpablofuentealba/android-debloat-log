# Xuper (IPTV pirata) en la malla — riesgo aceptado por el operador (2026-11-08)

> **Decisión del operador: dejar todo como está.** Este archivo documenta el
> estado real y el riesgo, **no** una tarea pendiente. **Ningún agente debe
> desinstalar estas apps por su cuenta.**

## Qué es

**Xuper** (también "XuperTV" / "Xuper Hidra") es una app de **IPTV pirata**:
películas, series y TV en vivo sin licencia. Se instala **fuera de Play Store**
y **no aparece en Ajustes** (sin actividad de lanzador).

**Requisito de funcionamiento:** usa **VPN propia**, porque el ISP chileno
bloquea el servicio. Eso implica que **todo el tráfico del teléfono pasa por
servidores de origen desconocido** mientras la VPN está activa.

## Dónde está instalada (verificado 2026-11-08)

| Nodo | Paquete | versionCode | Ubicación | Corre ahora |
|---|---|---|---|---|
| **a16** | `com.android.mgstxNF` | **43500** | `/data/app/` | ❌ no |
| **a13** | `com.lite.fczx` | **43404** | `/data/app/` | ❌ no |

> **Corrección:** `com.appfactory.tidytv` (**TidyTV: Clean Android TV**, en Play
> Store) **NO es IPTV**. Es una **app de limpieza de bloatware para Android TV**
> y no tiene relación con Xuper. Se retiró de este documento: no es un riesgo.

> **Nota:** `com.android.mgstxNF` y `com.lite.fczx` comparten el rango de
> `versionCode` (435xx / 434xx) y el patrón de nombre ofuscado → **mismo
> desarrollador, empaquetado distinto**. Es la misma app con dos nombres.
> Esta similitud vale **solo** entre esos dos; no aplica a `tidytv` (ver arriba).

## Verificado en a16 (08-nov-2026)

| Comprobación | Resultado |
|---|---|
| Instalada | ⚠️ sí |
| Proceso corriendo (uid 10564) | ✅ **no** |
| VPN activa (interfaz `tun`) | ✅ **no** |
| Administrador de dispositivos | ✅ **no** → desinstalable sin desactivar |
| Visible en Ajustes | ❌ **no** (ni con "mostrar apps del sistema") |
| En Play Store | ❌ **no (404)** |
| Documentada en la web | ❌ **no** (VirusTotal, urlscan, Kaspersky, Bing, Google: cero resultados) |

## Riesgo (según reportes externos, NO verificados aquí)

Un informe aportado por el operador atribuye a Xuper: **VPN oculta** que
intercepta el tráfico, **exfiltración de GPS** en tiempo real y **ransomware**
en versiones recientes.

> ⚠️ **Esos puntos NO se pudieron verificar** desde la malla: el paquete no
> aparece en ninguna base de datos pública. Se registran como **reporte
> externo**, no como hecho comprobado. Lo que **sí** está comprobado es el
> requisito de VPN y que la app se oculta de Ajustes.

## El conflicto real: dinero y VPN en el mismo teléfono

Android permite **una sola VPN activa**. Si Xuper la toma, **todas** las apps
salen por ella, incluidas las de banca.

| Nodo | Apps financieras | Xuper | Riesgo |
|---|---|---|---|
| **a16** | BancoEstado, BCI/MACH, MercadoPago, PayPal, Buda, XTB, Global66, Tenpo, OnePay | sí | ⚠️ comparten red |
| **a13** | **MercadoPago** (respaldo) | sí (`com.lite.fczx`) | ⚠️ comparten red |

**No hay forma técnica de aislar la VPN a una sola app en Android.** Cualquier
herramienta que lo prometa, no lo hace.

## Decisión del operador (2026-11-08)

**Dejar todo como está.** El operador usa Xuper a propósito para contenido y
asume el riesgo. Se evaluaron y descartaron por ahora:

- Desinstalarla de a16 (requiere ADB por cable; BancoEstado da UA599 con ADB).
- Desinstalarla de a13 (posible vía Shizuku, sin riesgo de banco).
- Aislarla con Shelter / perfil de trabajo.
- Moverla a un teléfono aparte.

## Regla operativa mientras siga instalada

1. **No abrir Xuper cuando se use la banca.** Cerrarla del todo (no minimizada).
2. **No desinstalarla sin pedir permiso al operador.** Está en uso.
3. Si algún día se desinstala: en **a16** requiere ADB por cable y luego
   **apagar Depuración USB** (ver `7-hallazgo-adbd-sin-shizuku.md`); en **a13**
   se puede vía Shizuku.

## Cómo desinstalarla (procedimiento listo, NO ejecutado)

**a13 (vía Shizuku, sin riesgo de banco):**
```bash
~/rish -c "pm uninstall --user 0 com.lite.fczx"
```
> `com.appfactory.tidytv` (TidyTV) **no se toca**: es una herramienta del
> operador para limpiar Android TV, no está relacionada con Xuper.

**a16 (requiere ADB por cable desde el MSI):**
```bash
adb uninstall com.android.mgstxNF
# después, en a16: Depuración USB = OFF
# verificar: getprop init.svc.adbd  -> stopped
```
