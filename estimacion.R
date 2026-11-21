# ============================================================================
# estimacion.R
# Estimacion de la proporcion de casos hospitalizados con la muestra concreta
# (341 casos del segundo semestre), con el diseno que se corrio: estratificado
# por departamento, pesos 1/pi_k y correccion por poblacion finita.
# Verifica el error estandar por una segunda via y calcula el efecto de diseno.
# ============================================================================

library(survey)

marco <- read.csv("datos/marco.csv", stringsAsFactors = FALSE)
pob   <- read.csv("datos/poblacion.csv")
marco$y <- pob$y[match(marco$id, pob$id)]
marco <- marco[marco$bloque == "2023-II", ]
N <- nrow(marco)

muestra <- read.csv("datos/muestra.csv", stringsAsFactors = FALSE)
resp <- merge(muestra, data.frame(id = marco$id, y = marco$y), by = "id")
stopifnot(nrow(resp) == nrow(muestra))

# Los datos recogidos: una fila por caso seleccionado, con su respuesta.
# En un archivo administrativo la "recogida" es el cruce con el archivo fuente;
# si hubiera habido no respuesta, aqui iria respondio = FALSE.
datos <- data.frame(id = resp$id, respondio = TRUE, y = resp$y)
datos <- datos[order(datos$id), ]
write.csv(datos, "datos/datos.csv", row.names = FALSE)

dis <- svydesign(ids = ~1, strata = ~depto, weights = ~peso, fpc = ~N_h, data = resp)
est <- svymean(~y, dis, deff = TRUE)
print(est)
print(confint(est))

# Segunda via: la formula del estratificado, a mano.
N_h <- table(marco$depto)
n_h <- table(resp$depto)[names(N_h)]
p_h <- tapply(resp$y, resp$depto, mean)
var_h <- tapply(resp$y, resp$depto, function(z) mean(z) * (1 - mean(z)))
W <- as.numeric(N_h) / N
V_manual <- sum(W^2 * (1 - n_h / as.numeric(N_h)) * var_h / n_h)
cat("\nEE manual:", sqrt(V_manual), " EE survey:", SE(est), "\n")

# Efecto de diseno frente a un aleatorio simple del mismo tamano.
n <- nrow(resp)
V_mas <- mean(marco$y) * (1 - mean(marco$y)) / n * (1 - n / N)
cat("V_mas:", V_mas, " deff:", V_manual / V_mas, "\n")

# El parametro, que solo se conoce porque el marco es la poblacion.
p_real <- mean(marco$y)
ic <- confint(est)
cat("p_real:", p_real, " IC:", ic[1], ic[2],
    " contiene:", ic[1] <= p_real && p_real <= ic[2], "\n")
cat("margen de error (pp):", round(100 * (ic[2] - ic[1]) / 2, 2), "\n")
