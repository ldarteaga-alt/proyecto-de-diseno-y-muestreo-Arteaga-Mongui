# ============================================================================
# seleccion.R
# Selecciona la muestra concreta que se analiza en el informe (parte de
# muestreo). Poblacion: los casos notificados en el segundo semestre de 2023
# (bloque 2023-II), N = 2960. Diseno: estratificado por departamento con
# asignacion proporcional. Escribe datos/muestra.csv con pi_k y peso.
# Se corre con R recien abierto: Session -> Restart R.
# ============================================================================

source("R/funciones.R")

marco <- read.csv("datos/marco.csv", stringsAsFactors = FALSE)

# Poblacion del ejercicio de muestreo: una de las dos poblaciones del proyecto.
marco <- marco[marco$bloque == "2023-II", ]
N <- nrow(marco)

# --- Tamano: margen de 5 puntos porcentuales, 95 %, p = 0.5 (el mas exigente)
z  <- qnorm(0.975)
n0 <- z^2 * 0.25 / 0.05^2
n  <- ceiling(n0 / (1 + n0 / N))

# --- Asignacion proporcional por departamento, minimo 2 y suma exacta
N_h <- table(marco$depto)
n_h <- asignar(n, N_h)
names(n_h) <- names(N_h)
stopifnot(sum(n_h) == n, all(n_h >= pmin(2, as.numeric(N_h))),
          all(n_h <= as.numeric(N_h)))

# --- Seleccion: la semilla del protocolo. No se prueba otra.
set.seed(2026)

sel <- unlist(lapply(names(n_h), function(h) {
  ids <- marco$id[marco$depto == h]
  ids[sample(length(ids), n_h[[h]])]
}))

muestra <- marco[match(sel, marco$id), ]
muestra$N_h  <- as.numeric(N_h[muestra$depto])
muestra$n_h  <- as.numeric(n_h[muestra$depto])
muestra$pi_k <- muestra$n_h / muestra$N_h
muestra$peso <- 1 / muestra$pi_k

stopifnot(sum(duplicated(muestra$id)) == 0, nrow(muestra) == n)
stopifnot(abs(sum(muestra$peso) - N) < 1e-8)   # asignacion proporcional: suman N

write.csv(muestra, "datos/muestra.csv", row.names = FALSE)

cat("N =", N, " n0 =", round(n0, 2), " n =", n, "\n")
print(table(muestra$depto))
cat("pesos suman:", sum(muestra$peso), "\n")
