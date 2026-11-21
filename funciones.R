# ============================================================================
# funciones.R
# Funciones de seleccion y de estimacion que comparten el experimento, el
# piloto y el informe. Cada funcion recibe un data.frame con las columnas
# id, depto, municipio, bloque e y (la respuesta).
# ============================================================================

# --- Muestreo aleatorio simple ---------------------------------------------
sel_mas <- function(d, n, semilla) {
  set.seed(semilla)
  i <- sample(nrow(d), n)
  list(id = d$id[i], pi = rep(n / nrow(d), n), n_efectivo = n)
}

# --- Asignacion por estrato: proporcional, minimo 2 y sin pasar de N_h ------
asignar <- function(n, Nh) {
  nm <- names(Nh)
  Nh <- as.numeric(Nh); names(Nh) <- nm
  nh <- n * Nh / sum(Nh)
  nh <- pmin(pmax(round(nh), pmin(2, Nh)), Nh)
  for (k in 1:1000) {
    if (sum(nh) >= n) break
    cap <- Nh - nh
    if (all(cap <= 0)) break
    i <- which.max(cap * Nh)
    nh[i] <- nh[i] + 1
  }
  for (k in 1:1000) {
    if (sum(nh) <= n) break
    i <- which.max(nh - pmin(2, Nh))
    nh[i] <- nh[i] - 1
  }
  nh
}

# --- Estratificado por departamento, asignacion proporcional ---------------
sel_estrat <- function(d, n, semilla) {
  set.seed(semilla)
  Nh <- table(d$depto)
  nh <- asignar(n, Nh)
  names(nh) <- names(Nh)
  ids <- unlist(lapply(names(nh), function(h) {
    v <- d$id[d$depto == h]
    v[sample(length(v), nh[[h]])]
  }))
  est <- d$depto[match(ids, d$id)]
  list(id = ids, pi = as.numeric(nh[est]) / as.numeric(Nh[est]),
       n_efectivo = length(ids))
}

# --- Conglomerados en dos etapas: municipios y luego casos ------------------
# Se toman k casos por municipio. El numero de municipios se calibra con el
# tamano medio de municipio para que el n efectivo ronde el n planeado: hay
# municipios con menos de k casos y esos aportan menos.
sel_congl <- function(d, n, semilla, k = 5) {
  set.seed(semilla)
  mun <- unique(d$municipio)
  M   <- length(mun)
  Ni_all <- table(d$municipio)
  m   <- max(2, round(n / mean(pmin(k, as.numeric(Ni_all)))))
  m   <- min(m, M)
  elegidos <- sample(mun, m)
  ids <- c(); pis <- c()
  for (u in elegidos) {
    idx <- which(d$municipio == u)
    Ni  <- length(idx)
    ki  <- min(k, Ni)
    ids <- c(ids, d$id[idx][sample(Ni, ki)])
    pis <- c(pis, rep((m / M) * (ki / Ni), ki))
  }
  list(id = ids, pi = pis, n_efectivo = length(ids))
}

# --- Una corrida ------------------------------------------------------------
# Selecciona segun el diseno y estima la proporcion con el estimador de razon
# de Horvitz-Thompson: suma(y/pi) / suma(1/pi).
una_corrida <- function(d, diseno, n, semilla) {
  s <- switch(diseno,
    MAS   = sel_mas(d, n, semilla),
    Estr  = sel_estrat(d, n, semilla),
    Congl = sel_congl(d, n, semilla)
  )
  y <- d$y[match(s$id, d$id)]
  p_hat <- sum(y / s$pi) / sum(1 / s$pi)
  data.frame(p_hat = p_hat, n_efectivo = s$n_efectivo)
}

# --- Cargar el marco con la respuesta --------------------------------------
cargar_marco <- function(ruta_marco = "datos/marco.csv",
                         ruta_pob = "datos/poblacion.csv") {
  d <- read.csv(ruta_marco, stringsAsFactors = FALSE)
  pob <- read.csv(ruta_pob)
  d$y <- pob$y[match(d$id, pob$id)]
  stopifnot(!anyNA(d$y))
  d
}
