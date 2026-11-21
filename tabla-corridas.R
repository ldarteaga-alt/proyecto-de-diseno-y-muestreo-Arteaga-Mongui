# ============================================================================
# tabla-corridas.R
# Genera la tabla de corridas del experimento, aleatorizada con una semilla.
# 3 disenos x 2 tamanos x 2 poblaciones (bloques) x 60 replicas = 720 corridas.
# La semilla de cada corrida es fija y esta en la tabla: cualquiera puede
# repetir una corrida suelta y obtener la misma muestra.
# ============================================================================

dir.create("datos", showWarnings = FALSE)

disenos <- c("MAS", "Estr", "Congl")
tamanos <- c(100, 300)
bloques <- c("2023-I", "2023-II")
replicas <- 60

plan <- expand.grid(diseno = disenos, n_planeado = tamanos,
                    bloque = bloques, replica = seq_len(replicas),
                    stringsAsFactors = FALSE)
plan <- plan[order(plan$bloque, plan$diseno, plan$n_planeado, plan$replica), ]

# Una semilla distinta y reproducible por corrida.
plan$semilla <- 2026000 + 10 * seq_len(nrow(plan)) + plan$replica

# El orden de las corridas se sortea: la asignacion es aleatoria de verdad.
set.seed(2026)
plan <- plan[sample(nrow(plan)), ]
plan$orden <- seq_len(nrow(plan))
plan <- plan[, c("orden", "bloque", "diseno", "n_planeado", "replica", "semilla")]

write.csv(plan, "datos/tabla-corridas.csv", row.names = FALSE)

cat("corridas:", nrow(plan), "\n")
print(table(plan$diseno, plan$n_planeado, plan$bloque))
cat("\nprimeras 8 filas:\n"); print(head(plan, 8))
