# ============================================================================
# comprobacion.R
# Comprueba, unidad por unidad, que el guion de seleccion sortea con las
# probabilidades de inclusion que dice el protocolo. Repite la seleccion 2000
# veces con semillas distintas y compara la frecuencia de cada caso con su
# pi_k. Escribe el resumen en datos/comprobacion.csv.
# ============================================================================

source("R/funciones.R")

marco <- read.csv("datos/marco.csv", stringsAsFactors = FALSE)
marco <- marco[marco$bloque == "2023-II", ]
N <- nrow(marco)

N_h <- table(marco$depto)
n   <- 341
n_h <- asignar(n, N_h)
names(n_h) <- names(N_h)

seleccionar <- function(semilla) {
  set.seed(semilla)
  unlist(lapply(names(n_h), function(h) {
    ids <- marco$id[marco$depto == h]
    ids[sample(length(ids), n_h[[h]])]
  }))
}

pos <- seq_len(N)
names(pos) <- marco$id
pi_teo <- as.numeric(n_h[marco$depto]) / as.numeric(N_h[marco$depto])

R <- 2000
veces <- integer(N)
for (r in seq_len(R)) {
  i <- pos[as.character(seleccionar(10000 + r))]
  stopifnot(!anyDuplicated(i))
  veces[i] <- veces[i] + 1
}
z <- (veces / R - pi_teo) / sqrt(pi_teo * (1 - pi_teo) / R)
res <- data.frame(guion = "protocolo", fuera_de_3 = sum(abs(z) > 3),
                  nunca = sum(veces == 0), siempre = sum(veces == R))

# Un guion roto a proposito: siempre los primeros ids de cada estrato. La media
# por estrato sale perfecta, pero unidad por unidad no pasa.
rotas <- unlist(lapply(names(n_h), function(h) head(marco$id[marco$depto == h], n_h[[h]])))
veces_rotas <- tabulate(match(rotas, marco$id), nbins = N)
z_rotas <- (veces_rotas - pi_teo) / sqrt(pi_teo * (1 - pi_teo))
res <- rbind(res, data.frame(guion = "roto", fuera_de_3 = sum(abs(z_rotas) > 3),
                             nunca = sum(veces_rotas == 0), siempre = sum(veces_rotas > 0)))

write.csv(res, "datos/comprobacion.csv", row.names = FALSE)
print(res)
