# Proyecto conjunto: muestreo y diseño de experimentos

**Integrantes:** Laura Arteaga y Faber Mongui
**Modalidad conjunta:** Diseño de Experimentos + Muestreo (forma B)
**Curso:** Muestreo — Corte III, 2026-II

## Qué se estima

La proporción de casos de dengue notificados en 2023 en ocho departamentos del
Caribe colombiano que terminaron hospitalizados (`PAC_HOS` = 1), y cuánto cambia
el error de esa estimación según el diseño muestral y el tamaño de la muestra.

La población son los 2.960 casos notificados en el segundo semestre de 2023 en
esos departamentos (la cohorte 2023-II). El marco es el archivo de vigilancia que
está en `datos/fuente/`. El parámetro se conoce porque el marco es la población
entera, y por eso al final se puede ver si el intervalo lo atrapa.

## Qué hay en cada carpeta

| Archivo o carpeta | Qué es |
|---|---|
| `ficha.md` | Hito 1: tema, población, marco y diseño previsto |
| `preregistro.md` | Hito 2: el plan completo, con la tabla de corridas |
| `avance.md` | Hito 3: las desviaciones y el primer gráfico |
| `informe.Rmd` | Hito 4: el informe, que se teje solo |
| `informe.html` | El informe ya renderizado |
| `R/00-prepara-datos.R` | Construye el marco y la tabla de la población |
| `R/seleccion.R` | Selecciona la muestra con la semilla del protocolo |
| `R/comprobacion.R` | Comprueba, unidad por unidad, las probabilidades de inclusión |
| `R/tabla-corridas.R` | Genera la tabla de corridas aleatorizada |
| `R/potencia.R` | Piloto y justificación de las réplicas |
| `R/experimento.R` | Corre las 720 corridas del experimento |
| `R/estimacion.R` | Estimación con `survey`, verificación por la segunda vía y `datos/datos.csv` |
| `R/analisis.R` | Análisis confirmatorio del experimento |
| `R/funciones.R` | Funciones de selección y estimación que comparten los guiones |
| `datos/fuente/` | El archivo original, sin tocar |
| `datos/marco.csv` | El marco: id, cohorte, departamento, municipio, área, sexo, edad, semana |
| `datos/poblacion.csv` | La respuesta de toda la población (para conocer el parámetro) |
| `datos/muestra.csv` | La muestra seleccionada, con `pi_k` y peso |
| `datos/datos.csv` | La respuesta de los casos de la muestra |
| `datos/tabla-corridas.csv` | Las 720 corridas, en orden aleatorio, con su semilla |
| `datos/datos-experimento.csv` | El resultado de cada corrida: `p_hat`, `n_efectivo`, error |
| `datos/comprobacion.csv` | El resumen de la comprobación Monte Carlo |
| `datos/potencia.csv` | El ruido del piloto y las réplicas que justifica |
| `datos/bitacora.md` | Cada sesión de trabajo y cada incidente |
| `figuras/` | Los gráficos que enlazan el informe y el avance |
| `sustentacion.md` | Guion y respuestas para la exposición |

## Cómo se reproduce

1. Abrir `proyecto-dde-arteaga-mongui.Rproj` en RStudio (todas las rutas son
   relativas a la raíz del proyecto).
2. En un R recién abierto, correr en este orden:

```r
source("R/00-prepara-datos.R")   # datos/marco.csv y datos/poblacion.csv
source("R/seleccion.R")          # datos/muestra.csv
source("R/comprobacion.R")       # datos/comprobacion.csv
source("R/tabla-corridas.R")     # datos/tabla-corridas.csv
source("R/potencia.R")           # datos/potencia.csv
source("R/experimento.R")        # datos/datos-experimento.csv
source("R/estimacion.R")         # datos/datos.csv y la estimación en consola
```

3. Tejer el informe: abrir `informe.Rmd` y pulsar **Knit** (o
   `rmarkdown::render("informe.Rmd")`). Sale `informe.html`.

Paquetes: `survey`, `emmeans`, `ggplot2`, `knitr`, `rmarkdown`. El pandoc que
trae RStudio sirve; no hay que instalar nada más.

Tiempo: el experimento corre en unos segundos; el tejido, en menos de un minuto.

## Datos y ética

- No hay datos personales: cada caso es un `id` numérico y el archivo no trae
  nombre, documento ni dirección.
- El archivo fuente no se edita a mano. Todo lo que se deriva de él sale de
  `R/00-prepara-datos.R`.
- La columna `respuesta` del archivo original es `PAC_HOS` recodificada; no se
  usa. La variable analizada es `PAC_HOS`.
- No hay consentimiento porque no hay personas: es un archivo administrativo
  público.

## Estado de las entregas

Este repositorio se armó el 20 de noviembre de 2026. Los hitos 1 (ficha) y 2
(preregistro) no se publicaron en sus fechas; el preregistro y el avance se
incluyen aquí con la fecha de hoy y el informe declara esa circunstancia en la
sección de fidelidad. Las releases se publican con las etiquetas `conjunto`,
`preregistro`, `avance` e `informe`.
