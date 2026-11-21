# Avance

**Integrantes:** Laura Arteaga y Faber Mongui
**Fecha:** 20 de noviembre de 2026

## Qué hay hecho

- El marco (`datos/marco.csv`): 5.000 casos, sin la respuesta, con cohorte,
  departamento, municipio, área, sexo, edad y semana.
- La muestra (`datos/muestra.csv`): 341 casos del segundo semestre, con `pi_k` y
  peso, seleccionados con `set.seed(2026)`.
- Los datos (`datos/datos.csv`): la respuesta de los 341 casos.
- La bitácora (`datos/bitacora.md`): las sesiones y los incidentes.
- Las 720 corridas del experimento (`datos/datos-experimento.csv`).

## Desviaciones del preregistro y su consecuencia para el análisis

| # | Desviación | Consecuencia |
|---|---|---|
| 1 | El preregistro no se publicó antes de tener los datos; se publica el 20 de noviembre, con el informe. | El análisis no es ciego. Se documenta el plan completo y se reporta todo lo que se corrió; el informe lo declara en la sección de fidelidad. |
| 2 | La semilla del docente no se publicó porque el hito no se entregó. Se usó la primera semilla escrita en el guion, 2026, y no se probó ninguna otra. | La muestra no se eligió por conveniencia, pero tampoco está atada a una semilla externa. La comprobación Monte Carlo muestra que el guion sortea con las `pi_k` que dice. |
| 3 | El archivo trae una columna `respuesta` (Grave/Leve) que resultó ser `PAC_HOS` recodificada. | No se usa. La variable analizada es `PAC_HOS`, que es la del sistema de vigilancia. No cambia el diseño ni la estimación. |
| 4 | El diseño por conglomerados tenía que tomar 5 casos por municipio; hay municipios con menos de 5. | El número de municipios se calibró con el tamaño medio de municipio. El `n` efectivo medio quedó en 201,5 frente a 200 de los otros diseños (−0,7 %); se reporta en el informe. |
| 5 | La respuesta del experimento es el error absoluto, que es muy variable entre réplicas. | El piloto mostró un coeficiente de variación de 1,82; por eso se pasó de 10 a 60 réplicas por celda y se analiza el logaritmo del error. Queda documentado en `preregistro.md` y en el informe. |
| 6 | El informe se entrega sin las releases de los hitos anteriores. | Se publican todas juntas con la release `informe`. |

## El primer vistazo

La proporción de casos hospitalizados por departamento, en la cohorte 2023-II:

![Proporción de casos hospitalizados por departamento, cohorte 2023-II.](figuras/avance-proporcion.png)

Se lee directo: Cesar y Sucre están muy por encima del promedio y San Andrés y
Bolívar muy por debajo. La muestra reproduce razonablemente la estructura de la
población en los departamentos grandes; donde se separa es en los pequeños, que
tienen dos o tres casos y por eso su proporción es ruidosa (San Andrés, con dos
casos, da 50 % frente al 35 % de la población). Esa diferencia entre
departamentos es la que justifica estratificar, y es también la razón por la que
el promedio simple de la muestra no sirve: hay que usar los pesos.

Todavía no hay pruebas: eso va en el informe.
