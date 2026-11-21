# ============================================================================
# avance.R
# Primer grafico descriptivo del avance: lo recogido en la muestra (proporcion
# de hospitalizados por departamento) contra la poblacion de la cohorte, que se
# conoce porque el marco es la poblacion. Todavia sin pruebas.
# ============================================================================

library(ggplot2)

marco <- read.csv("datos/marco.csv", stringsAsFactors = FALSE)
pob   <- read.csv("datos/poblacion.csv")
muestra <- read.csv("datos/muestra.csv", stringsAsFactors = FALSE)

marco$y <- pob$y[match(marco$id, pob$id)]
base <- marco[marco$bloque == "2023-II", ]

# Lo recogido: la muestra. La referencia: la poblacion de la cohorte.
m <- merge(muestra, data.frame(id = base$id, y = base$y), by = "id")
dd <- aggregate(y ~ depto, data = m, FUN = mean)
names(dd)[2] <- "muestra"
dd$poblacion <- as.numeric(tapply(base$y, base$depto, mean)[dd$depto])
dd$n_h <- as.integer(table(m$depto)[dd$depto])
dd <- dd[order(dd$muestra), ]
dd$depto <- factor(dd$depto, levels = dd$depto)

p <- ggplot(dd, aes(x = depto)) +
  geom_col(aes(y = muestra), fill = "#2c7fb8", alpha = .85, width = .7) +
  geom_point(aes(y = poblacion), size = 2.6, colour = "#c0392b") +
  geom_text(aes(y = 0.01, label = paste0("n = ", n_h)), hjust = 0, size = 3,
            colour = "white") +
  coord_flip() +
  scale_y_continuous(labels = function(z) paste0(round(100 * z), " %"),
                     limits = c(0, 1.05)) +
  labs(x = NULL, y = "Proporción de hospitalizados",
       title = "Lo recogido, por departamento (cohorte 2023-II)",
       subtitle = "Barras: muestra de 341 casos. Puntos rojos: población de la cohorte.",
       caption = "La muestra reproduce la estructura por departamento de la población.") +
  theme_minimal(base_size = 11)

ggsave("figuras/avance-proporcion.png", p, width = 8, height = 4.2, dpi = 110)
cat("figura escrita en figuras/avance-proporcion.png\n")
print(dd)
