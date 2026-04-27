# =============================================================================
# 01_analisis_temperatura.R
#
# Clasificación de Temperaturas Globales (1750 - 2015)
#
# Objetivo: Clasificar la temperatura promedio terrestre mensual en tres
# categorías: Frío (< 5°C), Moderado (5°C - 15°C) y Caliente (> 15°C),
# utilizando árboles de clasificación (rpart) y Random Forest.
#
# Dataset: GlobalTemperatures.csv
# Fuente: Berkeley Earth / Kaggle
# https://www.kaggle.com/datasets/berkeleyearth/climate-change-earth-surface-temperature-data
#
# Autor: [Nazarely Gomez Abularach]
# Fecha: [junio 2024]
# =============================================================================


# -----------------------------------------------------------------------------
# 1. LIBRERÍAS
# -----------------------------------------------------------------------------
# Si algún paquete no está instalado, ejecutar primero: source("src/00_setup.R")

library(caret)
library(rpart)
library(rpart.plot)
library(readr)
library(dplyr)
library(caTools)
library(ggplot2)
library(randomForest)


# -----------------------------------------------------------------------------
# 2. CARGA DE DATOS
# -----------------------------------------------------------------------------

TemperaturaGlobal <- read.csv("data/GlobalTemperatures.csv")

# Estructura y resumen inicial
str(TemperaturaGlobal)
summary(TemperaturaGlobal)


# -----------------------------------------------------------------------------
# 3. LIMPIEZA Y TRANSFORMACIÓN DE DATOS
# -----------------------------------------------------------------------------

# Convertimos la columna 'dt' a tipo Date
TemperaturaGlobal$dt <- as.Date(TemperaturaGlobal$dt)

# Reemplazamos valores faltantes (NA) con la mediana de cada columna.
# Usamos la mediana en lugar de la media porque es más robusta frente a outliers.
TemperaturaGlobal <- TemperaturaGlobal %>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.), median(., na.rm = TRUE), .)))

# Verificamos que no queden NA
cat("Valores NA restantes:", sum(is.na(TemperaturaGlobal)), "\n")


# -----------------------------------------------------------------------------
# 4. INGENIERÍA DE FEATURES
# -----------------------------------------------------------------------------

# Creamos la variable objetivo: categoría de temperatura
# Frío: < 5°C | Moderado: 5°C a 15°C | Caliente: > 15°C
TemperaturaGlobal$TemperatureCategory <- cut(
  TemperaturaGlobal$LandAverageTemperature,
  breaks = c(-Inf, 5, 15, Inf),
  labels = c("Frío", "Moderado", "Caliente")
)

# Revisamos la distribución de categorías
table(TemperaturaGlobal$TemperatureCategory)


# -----------------------------------------------------------------------------
# 5. DIVISIÓN EN ENTRENAMIENTO Y PRUEBA (80/20)
# -----------------------------------------------------------------------------

set.seed(50)

Particion <- caret::createDataPartition(
  y    = TemperaturaGlobal$TemperatureCategory,
  p    = 0.8,
  list = FALSE
)

training <- TemperaturaGlobal[ Particion, ]
testing  <- TemperaturaGlobal[-Particion, ]

cat("Filas de entrenamiento:", nrow(training), "\n")
cat("Filas de prueba:       ", nrow(testing), "\n")


# -----------------------------------------------------------------------------
# 6. VISUALIZACIÓN EXPLORATORIA
# -----------------------------------------------------------------------------

# Histograma de temperaturas promedio terrestres
ggplot(TemperaturaGlobal, aes(x = LandAverageTemperature)) +
  geom_histogram(binwidth = 1, fill = "#2196F3", color = "white", alpha = 0.85) +
  labs(
    title    = "Distribución de Temperaturas Promedio Terrestres (1750-2015)",
    subtitle = "Datos mensuales — Berkeley Earth",
    x        = "Temperatura Promedio Terrestre (°C)",
    y        = "Frecuencia"
  ) +
  theme_minimal()

# Distribución de categorías de temperatura
ggplot(TemperaturaGlobal, aes(x = TemperatureCategory, fill = TemperatureCategory)) +
  geom_bar(color = "white", alpha = 0.85) +
  scale_fill_manual(values = c("Frío" = "#42A5F5", "Moderado" = "#FFA726", "Caliente" = "#EF5350")) +
  labs(
    title = "Distribución de Categorías de Temperatura",
    x     = "Categoría",
    y     = "Frecuencia"
  ) +
  theme_minimal() +
  theme(legend.position = "none")


# -----------------------------------------------------------------------------
# 7. MODELO 1: ÁRBOL DE CLASIFICACIÓN (rpart — sin ajuste)
# -----------------------------------------------------------------------------

modelo_base <- rpart::rpart(
  TemperatureCategory ~ LandMaxTemperature + LandMinTemperature + LandAndOceanAverageTemperature,
  data   = training,
  method = "class"
)

# Visualizamos el árbol
rpart.plot::rpart.plot(modelo_base, main = "Árbol de Clasificación — Base")

# Importancia de variables
poder_prediccion_base <- varImp(modelo_base)
poder_prediccion_base %>% arrange(desc(Overall))

# Predicciones y evaluación
predicciones_base <- predict(modelo_base, newdata = testing, type = "class")

matriz_confusion_base <- confusionMatrix(
  data      = predicciones_base,
  reference = testing$TemperatureCategory
)
print(matriz_confusion_base)


# -----------------------------------------------------------------------------
# 8. MODELO 2: ÁRBOL CON HIPERPARÁMETROS AJUSTADOS
# -----------------------------------------------------------------------------

# minsplit: mínimo de observaciones para intentar una división
# minbucket: mínimo de observaciones en un nodo hoja
# maxdepth: profundidad máxima del árbol
control <- rpart.control(minsplit = 10, minbucket = 5, maxdepth = 30)

modelo_ajustado <- rpart(
  TemperatureCategory ~ .,
  data    = training,
  method  = "class",
  control = control
)

# Visualizamos el árbol ajustado
rpart.plot::rpart.plot(modelo_ajustado, main = "Árbol de Clasificación — Ajustado")

# Importancia de variables
poder_prediccion_ajustado <- caret::varImp(modelo_ajustado)
poder_prediccion_ajustado %>% arrange(desc(Overall))

# Predicciones y evaluación
predicciones_ajustadas <- predict(modelo_ajustado, newdata = testing, type = "class")

matriz_confusion_ajustada <- confusionMatrix(
  data      = predicciones_ajustadas,
  reference = testing$TemperatureCategory
)
print(matriz_confusion_ajustada)


# -----------------------------------------------------------------------------
# 9. MODELO 3: RANDOM FOREST (100 árboles)
# -----------------------------------------------------------------------------

modelo_rf <- randomForest(
  TemperatureCategory ~ .,
  data   = training,
  ntree  = 100,
  mtry   = 3
)

print(modelo_rf)

# Predicciones y evaluación
predicciones_rf <- predict(modelo_rf, newdata = testing)

matriz_confusion_rf <- caret::confusionMatrix(
  as.factor(testing$TemperatureCategory),
  as.factor(predicciones_rf)
)
print(matriz_confusion_rf)


# -----------------------------------------------------------------------------
# 10. COMPARACIÓN DE MODELOS — MATRICES DE CONFUSIÓN
# -----------------------------------------------------------------------------

# Función auxiliar para convertir una confusion matrix a dataframe
convertir_a_df <- function(cm, nombre_modelo) {
  as.data.frame(cm$table) %>%
    mutate(
      Modelo     = nombre_modelo,
      Reference  = factor(Reference,  levels = c("Frío", "Moderado", "Caliente")),
      Prediction = factor(Prediction, levels = c("Frío", "Moderado", "Caliente"))
    )
}

df_base     <- convertir_a_df(matriz_confusion_base,     "Base")
df_ajustado <- convertir_a_df(matriz_confusion_ajustada, "Ajustado")
df_rf       <- convertir_a_df(matriz_confusion_rf,       "Random Forest")

df_combined <- rbind(df_base, df_ajustado, df_rf)

# Gráfico de matrices de confusión comparadas
ggplot(df_combined, aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq), size = 4, fontface = "bold") +
  facet_wrap(~ Modelo) +
  scale_fill_gradient(low = "white", high = "#EF5350") +
  labs(
    title    = "Comparación de Matrices de Confusión",
    subtitle = "Base vs. Ajustado vs. Random Forest",
    x        = "Valor Verdadero",
    y        = "Predicción",
    fill     = "Frecuencia"
  ) +
  theme_minimal() +
  theme(
    strip.text  = element_text(face = "bold", size = 11),
    axis.text   = element_text(size = 10)
  )


# -----------------------------------------------------------------------------
# 11. RESUMEN DE ACCURACY POR MODELO
# -----------------------------------------------------------------------------

resumen <- data.frame(
  Modelo   = c("Base", "Ajustado", "Random Forest"),
  Accuracy = c(
    matriz_confusion_base$overall["Accuracy"],
    matriz_confusion_ajustada$overall["Accuracy"],
    matriz_confusion_rf$overall["Accuracy"]
  )
)

resumen <- resumen %>% arrange(desc(Accuracy))
print(resumen)
