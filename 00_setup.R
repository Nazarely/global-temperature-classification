# =============================================================================
# 00_setup.R
# Instalación de paquetes necesarios para el proyecto.
# Ejecutar este script una sola vez antes de correr el análisis principal.
# =============================================================================

paquetes <- c("caTools", "dplyr", "rpart", "rpart.plot", "readr", "caret", "ggplot2", "randomForest")

paquetes_faltantes <- paquetes[!(paquetes %in% installed.packages()[, "Package"])]

if (length(paquetes_faltantes) > 0) {
  message("Instalando paquetes faltantes: ", paste(paquetes_faltantes, collapse = ", "))
  install.packages(paquetes_faltantes)
} else {
  message("Todos los paquetes ya están instalados.")
}
