# ============================================================================
# experimento.R
# Corre el experimento factorial del proyecto: 3 disenos de muestreo x 2
# tamanos de muestra x 2 poblaciones (bloques) x 10 replicas = 120 corridas.
# Lee datos/tabla-corridas.csv (la tabla aleatorizada) y escribe
# datos/datos-experimento.csv con el n efectivo, la estimacion y el error.
# Se corre despues de tabla-corridas.R.
# ============================================================================

source("R/funciones.R")

marco <- cargar_marco()

# Parametro de cada poblacion: se conoce porque el marco ES la poblacion.
p_real <- tapply(marco$y, marco$bloque, mean)

plan <- read.csv("datos/tabla-corridas.csv", stringsAsFactors = FALSE)
stopifnot(nrow(plan) == 720)

resultado <- vector("list", nrow(plan))
for (i in seq_len(nrow(plan))) {
  d <- marco[marco$bloque == plan$bloque[i], ]
  r <- una_corrida(d, plan$diseno[i], plan$n_planeado[i], plan$semilla[i])
  pr <- p_real[[plan$bloque[i]]]
  resultado[[i]] <- data.frame(plan[i, ], r, p_real = pr, error = abs(r$p_hat - pr))
  if (i %% 20 == 0) cat("corridas:", i, "de", nrow(plan), "\n")
}

datos <- do.call(rbind, resultado)
datos <- datos[order(datos$orden), ]
write.csv(datos, "datos/datos-experimento.csv", row.names = FALSE)

cat("\nfilas:", nrow(datos), "\n")
cat("\nn efectivo por diseno:\n"); print(tapply(datos$n_efectivo, datos$diseno, summary))
cat("\nerror medio (puntos porcentuales) por celda:\n")
print(round(100 * tapply(datos$error, list(datos$diseno, datos$n_planeado, datos$bloque), mean), 2))
