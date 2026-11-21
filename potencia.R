# ============================================================================
# potencia.R
# Piloto para justificar las replicas. Corre 4 replicas por celda con semillas
# propias (distintas de las del experimento), estima el ruido en la escala del
# analisis (log del error) y calcula cuantas replicas hacen falta para detectar
# una razon de 2 entre dos tratamientos con potencia 0.80, y que razon se
# alcanza a detectar con 60 replicas.
# Los datos del piloto NO entran en el analisis confirmatorio.
# Escribe datos/potencia.csv.
# ============================================================================

source("R/funciones.R")

marco <- cargar_marco()

celdas <- expand.grid(diseno = c("MAS", "Estr", "Congl"),
                      n_planeado = c(100, 300),
                      bloque = c("2023-I", "2023-II"),
                      replica = 1:4, stringsAsFactors = FALSE)

piloto <- vector("list", nrow(celdas))
for (i in seq_len(nrow(celdas))) {
  d <- marco[marco$bloque == celdas$bloque[i], ]
  r <- una_corrida(d, celdas$diseno[i], celdas$n_planeado[i], 900000 + i)
  piloto[[i]] <- data.frame(celdas[i, ], error = abs(r$p_hat - mean(d$y)))
}
piloto <- do.call(rbind, piloto)
piloto$log_error <- log(piloto$error)

m <- aov(log_error ~ bloque + diseno * factor(n_planeado), data = piloto)
sigma <- sqrt(sum(resid(m)^2) / df.residual(m))

grupos <- 6
potencia <- function(n, razon) {
  power.anova.test(groups = grupos, between.var = log(razon)^2 * 7 / 60,
                   within.var = sigma^2, n = n)$power
}
reps_2 <- NA
for (k in 2:600) if (potencia(k, 2) >= 0.80) { reps_2 <- k; break }
razon_min <- NA
for (r in seq(1.2, 5, by = 0.01)) if (potencia(60, r) >= 0.80) { razon_min <- r; break }

write.csv(data.frame(sigma = sigma, reps_para_2 = reps_2, razon_min_60 = razon_min),
          "datos/potencia.csv", row.names = FALSE)

cat("sigma del log del error:", round(sigma, 3), "\n")
cat("replicas para detectar razon 2:", reps_2, "\n")
cat("razon minima detectable con 60 replicas:", razon_min, "\n")
