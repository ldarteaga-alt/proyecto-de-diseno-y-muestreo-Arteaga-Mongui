# ============================================================================
# analisis.R
# Analisis confirmatorio del experimento, tal como se preregistro:
#   log(error) ~ bloque + diseno * n
# Imprime la tabla ANOVA, las medias geometricas, las comparaciones y los
# diagnosticos de supuestos. El informe reproduce estos mismos numeros.
# ============================================================================

datos <- read.csv("datos/datos-experimento.csv", stringsAsFactors = FALSE)
datos$diseno <- factor(datos$diseno, levels = c("MAS", "Estr", "Congl"))
datos$n <- factor(datos$n_planeado)
datos$bloque <- factor(datos$bloque)
datos$log_error <- log(datos$error)

cat("=== Error medio aritmetico (puntos porcentuales) ===\n")
print(round(100 * tapply(datos$error, list(datos$diseno, datos$n, datos$bloque), mean), 2))

cat("\n=== Media geometrica del error (puntos porcentuales) ===\n")
print(round(100 * tapply(datos$log_error, list(datos$diseno, datos$n, datos$bloque),
                         function(z) exp(mean(z))), 2))

m <- aov(log_error ~ bloque + diseno * n, data = datos)
cat("\n=== ANOVA (log del error) ===\n")
print(summary(m))

cat("\n=== Supuestos ===\n")
cat("Shapiro-Wilk:\n"); print(shapiro.test(resid(m)))
cat("Fligner-Killeen (homocedasticidad):\n")
print(fligner.test(log_error ~ interaction(diseno, n), data = datos))

cat("\n=== Medias geometricas por diseno (pp) ===\n")
library(emmeans)
emm <- emmeans(m, ~ diseno)
print(summary(emm, type = "response"))

cat("\n=== Tukey: razon entre disenos (Congl/MAS > 1 = peor) ===\n")
print(summary(pairs(emm, reverse = TRUE), type = "response", infer = c(TRUE, TRUE)))

cat("\n=== Diseno x tamano ===\n")
print(summary(emmeans(m, ~ diseno | n), type = "response"))

cat("\n=== Efecto del tamano, dentro de cada diseno ===\n")
print(summary(pairs(emmeans(m, ~ n | diseno)), type = "response", infer = c(TRUE, TRUE)))

cat("\n=== Sensibilidad: ANOVA sobre el error sin transformar ===\n")
print(summary(aov(error ~ bloque + diseno * n, data = datos)))

cat("\n=== Bootstrap: razon Congl/MAS (medias geometricas) ===\n")
set.seed(7)
razon_boot <- replicate(2000, {
  idx <- split(seq_len(nrow(datos)), interaction(datos$diseno, datos$n))
  s <- unlist(lapply(idx, function(i) sample(i, length(i), replace = TRUE)))
  d <- datos[s, ]
  exp(mean(d$log_error[d$diseno == "Congl"]) - mean(d$log_error[d$diseno == "MAS"]))
})
print(round(quantile(razon_boot, c(0.025, 0.5, 0.975)), 2))
