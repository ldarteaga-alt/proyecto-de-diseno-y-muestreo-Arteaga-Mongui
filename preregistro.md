# Preregistro conjunto: Diseño de Experimentos + Muestreo

**Integrantes:** Laura Arteaga y Faber Mongui
**Fecha de este documento:** 20 de noviembre de 2026
**Modalidad:** forma B (experimento computacional sobre el muestreo)

> **Estado del documento.** Este preregistro se publica junto con el informe, el
> 20 de noviembre, cuando los datos ya estaban descargados. No se publicó antes
> del cierre de su hito. Se deja escrito completo para que el plan sea
> verificable y para que las desviaciones se puedan leer contra algo; el informe
> lo declara en la sección de fidelidad y no se presenta como un análisis ciego.

## 1. Pregunta e hipótesis

**Pregunta de muestreo.** ¿Cuál es la proporción de casos de dengue notificados
en el segundo semestre de 2023 en los ocho departamentos del archivo que
terminaron hospitalizados?

**Pregunta del experimento.** ¿Cuánto cambia el error de esa estimación cuando
cambia el diseño muestral, cuánto cuando cambia el tamaño de la muestra, y el
efecto del tamaño depende del diseño?

**Hipótesis del experimento**, sobre el modelo
$\log(\text{error}) = \mu + \beta_j + \alpha_i + \gamma_k + (\alpha\gamma)_{ik} + \varepsilon_{ijk}$:

- $H_0$: $\alpha_i = 0$ para todo $i$ (el diseño no cambia el error).
- $H_0$: $\gamma_k = 0$ para todo $k$ (el tamaño no cambia el error).
- $H_0$: $(\alpha\gamma)_{ik} = 0$ para todo $i,k$ (no hay interacción).
- $H_1$: al menos un efecto es distinto de cero.

La dirección esperada es que los conglomerados aumenten el error y que el tamaño
lo reduzca; no se plantea una hipótesis direccional formal, solo la nula.

## 2. La respuesta

**En el experimento:** el error absoluto de la estimación,
$|\hat p - p|$, en puntos porcentuales, donde $p$ es la proporción de
hospitalizados de la población de esa corrida. Se analiza su logaritmo.

**En la muestra concreta:** la proporción de casos hospitalizados,
$\hat p = \sum_s y_k/\pi_k \big/ \sum_s 1/\pi_k$, con su error estándar y su
intervalo del 95 %.

**Instrumento:** ninguno: la respuesta es un campo del archivo (`PAC_HOS`).
Unidad: puntos porcentuales (proporción × 100). Resolución: la del archivo, que
es binaria.

## 3. Los factores

| Factor | Niveles | Tipo |
|---|---|---|
| Diseño muestral | aleatorio simple, estratificado por departamento, conglomerados en dos etapas | fijo |
| Tamaño de muestra | 100, 300 | fijo |
| Población (bloque) | cohorte 2023-I (2.040 casos), cohorte 2023-II (2.960 casos) | fijo |

Los factores se cruzan; la población es un bloque, no un factor de interés. No
hay factores anidados.

## 4. Unidad experimental y unidad de observación

**Unidad experimental:** una corrida, es decir, una selección nueva de una
muestra con su propia semilla. Dos corridas con la misma combinación de factores
son dos muestras distintas, no la misma muestra medida dos veces.

**Unidad de observación:** el caso notificado dentro de la muestra de esa
corrida.

**Submuestreo:** no hay. No se mide dos veces la misma unidad.

## 5. El diseño y por qué ese

**Muestreo.** Estratificado por departamento con asignación proporcional, porque
la proporción de hospitalizados varía mucho entre departamentos (de 35 % a 84 %)
y el estrato está en el marco. Se compara con el aleatorio simple, que es la
alternativa más simple y el punto de referencia del efecto de diseño.

**Experimento.** Factorial 3 × 2 en bloques. Se necesitan los dos factores
cruzados y no dos experimentos separados porque la pregunta incluye la
interacción: si el efecto del tamaño depende del diseño. El bloque es la
población, para que la comparación entre diseños no se contamine con las
diferencias entre cohortes.

## 6. La aleatorización

- La muestra concreta se selecciona con `set.seed(2026)` en `R/seleccion.R`.
  La semilla no se prueba: se usa la primera.
- La tabla de corridas se genera con `set.seed(2026)` en `R/tabla-corridas.R`:
  720 corridas en orden aleatorio, cada una con su semilla propia escrita en la
  tabla. La tabla completa va como anexo del informe.

## 7. Las réplicas

60 réplicas por celda (720 corridas). Se justifican con un piloto de 4 réplicas
por celda, con semillas propias y datos que no entran en el análisis, que dio una
desviación estándar del log del error de 1,21. Con esa estimación, 60 réplicas
por celda detectan, con potencia 0,80, una razón de 2,1 entre las medias de dos
tratamientos. El efecto esperado del diseño por conglomerados es de 2,9 y el del
tamaño de 2,0: el primero se detecta con holgura y el segundo queda en el límite,
y así se reportará.

## 8. El modelo y la tabla ANOVA esperada

$$\log(\text{error}_{ijk}) = \mu + \beta_j + \alpha_i + \gamma_k + (\alpha\gamma)_{ik} + \varepsilon_{ijk}, \qquad \varepsilon_{ijk} \sim N(0,\sigma^2)$$

| Fuente | gl |
|---|---|
| Bloque | 1 |
| Diseño | 2 |
| Tamaño | 1 |
| Diseño × tamaño | 2 |
| Error | 713 |
| Total | 719 |

El denominador de todos los $F$ es el cuadrado medio del error (713 gl): es un
factorial en bloques con réplicas, no un parcelas divididas.

## 9. El plan de análisis

1. Descriptivo: media geométrica del error por celda y por bloque.
2. ANOVA sobre el log del error con bloque, diseño, tamaño e interacción.
3. Si la interacción no es significativa, se leen los efectos principales; si lo
   es, se leen las celdas y no los efectos principales.
4. Comparaciones múltiples de Tukey entre diseños, reportadas como razones de
   error (escala original), no como diferencias de logaritmos.
5. Supuestos: residuos frente a ajustados, gráfico de normalidad,
   Fligner–Killeen para homocedasticidad y Shapiro–Wilk. Si la
   homocedasticidad falla, se reporta el ANOVA sobre el logaritmo (que es el
   principal) y el de la escala original como sensibilidad.
6. Verificación sin supuestos: bootstrap de la razón conglomerados/MAS.
7. Estimación de la muestra concreta: `survey` con estratos, pesos y corrección
   por población finita; verificación del error estándar con la fórmula del
   estratificado calculada a mano.
8. Efecto de diseño de la muestra concreta frente a un aleatorio simple del
   mismo tamaño.

**Qué no se hará después de ver los datos:** no se cambiará la respuesta, ni el
modelo, ni el número de réplicas, ni se quitarán corridas. Si algo cambia, va
como desviación en `avance.md`.

## 10. Ética y riesgos

No hay personas: el archivo es administrativo y público, y no trae nombres,
documentos ni direcciones. No hay consentimiento que pedir y no hay riesgo para
nadie. El único riesgo es de interpretación: el archivo solo contiene casos
notificados, así que la estimación no se puede presentar como la de todos los
casos de dengue del país.

## Campos del protocolo de muestreo (versión breve)

**Población objetivo.** Casos de dengue notificados en 2023 en los ocho
departamentos del archivo (Atlántico, Bolívar, Cesar, Córdoba, Guajira,
Magdalena, San Andrés y Sucre), partidos en dos cohortes por semana
epidemiológica.

**Marco y cobertura.** El archivo de 5.000 registros. Quedan fuera los casos no
notificados —si los leves se notifican menos, la proporción de hospitalizados se
sobreestima—, los demás departamentos y los demás años.

**Unidad de muestreo y de observación.** El caso notificado en los dos casos.

**Probabilidad de inclusión.** Estratificado proporcional: $\pi_k = n_h/N_h$,
peso $1/\pi_k$. Conglomerados: $\pi_k = (m/M)(k_i/N_i)$.

**Tamaño.** $n_0 = 1{,}96^2(0{,}25)/0{,}05^2 = 384{,}15$ y $n = 341$ con
corrección por población finita ($N = 2.960$).

**Selección y comprobación.** `R/seleccion.R` y `R/comprobacion.R`: 2000
repeticiones, frecuencia de cada caso contra su $\pi_k$, unidad por unidad.

**Plan de estimación.** `svydesign(ids = ~1, strata = ~depto, weights = ~peso,
fpc = ~N_h)`, `svymean` con intervalo y efecto de diseño; verificación con la
fórmula del estratificado a mano.

**No respuesta.** No hay: el archivo tiene la variable completa en los 2.960
casos. El análogo es la cobertura del marco, que se reporta.
