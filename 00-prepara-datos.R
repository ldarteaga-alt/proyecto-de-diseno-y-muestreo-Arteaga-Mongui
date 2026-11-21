# ============================================================================
# 00-prepara-datos.R
# Construye el marco muestral y la tabla de la poblacion a partir del archivo
# fuente, sin editarlo a mano. Se corre desde la raiz del proyecto.
# ============================================================================

dir.create("datos", showWarnings = FALSE)

fuente <- read.csv("datos/fuente/casos-dengue-caribe-2023.csv",
                   stringsAsFactors = FALSE, check.names = FALSE)

stopifnot(nrow(fuente) == 5000, !anyDuplicated(fuente$id))
stopifnot(all(fuente$PAC_HOS %in% c(1, 2)))

# El marco: una fila por caso notificado, con lo que se sabe ANTES de medir.
# No lleva la respuesta: la respuesta es lo que se mide.
marco <- data.frame(
  id       = fuente$id,
  bloque   = ifelse(fuente$SEMANA <= 26, "2023-I", "2023-II"),
  depto    = fuente$Departamento_ocurrencia,
  municipio = paste0(sprintf("%02d", fuente$COD_DPTO_O), "-",
                     sprintf("%03d", fuente$COD_MUN_O)),
  area     = factor(fuente$AREA, levels = 1:3,
                    labels = c("Cabecera", "Centro poblado", "Rural disperso")),
  sexo     = factor(fuente$SEXO, levels = c("M", "F")),
  edad     = fuente$EDAD_ANOS,
  semana   = fuente$SEMANA
)

# La respuesta: 1 si el caso fue hospitalizado. PAC_HOS es la variable original
# del archivo (1 = si, 2 = no). La columna "respuesta" del archivo fuente es
# exactamente esta misma variable recodificada como Grave/Leve: no se usa.
poblacion <- data.frame(id = fuente$id,
                        y  = as.integer(fuente$PAC_HOS == 1))

write.csv(marco, "datos/marco.csv", row.names = FALSE)
write.csv(poblacion, "datos/poblacion.csv", row.names = FALSE)

cat("marco:", nrow(marco), "filas x", ncol(marco), "columnas\n")
print(table(marco$bloque))
print(round(tapply(poblacion$y, marco$bloque, mean), 4))
