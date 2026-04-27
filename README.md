# 🌡️ Clasificación de Temperaturas Globales (1750–2015)

Proyecto de Machine Learning desarrollado en **R** para clasificar la temperatura promedio terrestre mensual en tres categorías —Frío, Moderado y Caliente— comparando el rendimiento de tres modelos de clasificación: Árbol base, Árbol ajustado y Random Forest.

---

## 📌 Descripción del problema

El cambio climático es uno de los desafíos más relevantes de nuestro tiempo. Este proyecto analiza registros históricos de temperatura global desde 1750 hasta 2015 con el objetivo de construir modelos capaces de **clasificar automáticamente** cada mes según su temperatura promedio terrestre.

**Variable objetivo:** `TemperatureCategory`

| Categoría  | Rango de temperatura |
|------------|----------------------|
| ❄️ Frío     | < 5 °C               |
| 🌤️ Moderado | 5 °C – 15 °C         |
| ☀️ Caliente | > 15 °C              |

---

## 📂 Estructura del repositorio

```
global-temperature-classification/
│
├── data/
│   └── GlobalTemperatures.csv       # Dataset (ver instrucciones abajo)
│
├── src/
│   ├── 00_setup.R                   # Instalación de paquetes necesarios
│   └── 01_analisis_temperatura.R    # Script principal de análisis y modelado
│
├── outputs/
│   └── figures/                     # Gráficos generados por el análisis
│
├── .gitignore
└── README.md
```

---

## 📊 Dataset

- **Nombre:** Global Land and Ocean-and-Land Temperatures
- **Fuente:** [Berkeley Earth — Kaggle](https://www.kaggle.com/datasets/berkeleyearth/climate-change-earth-surface-temperature-data)
- **Archivo a descargar:** `GlobalTemperatures.csv`
- **Período:** 1750 – 2015 (datos mensuales)

> ⚠️ El dataset no está incluido en el repositorio por su tamaño. Descargarlo desde el link de arriba y colocarlo en la carpeta `data/`.

### Variables utilizadas

| Variable                             | Descripción                                    |
|--------------------------------------|------------------------------------------------|
| `LandAverageTemperature`             | Temperatura promedio terrestre (variable base) |
| `LandMaxTemperature`                 | Temperatura máxima terrestre                   |
| `LandMinTemperature`                 | Temperatura mínima terrestre                   |
| `LandAndOceanAverageTemperature`     | Temperatura promedio tierra + océano           |

---

## ⚙️ Metodología

```
Datos crudos
    │
    ▼
Limpieza (imputación por mediana, conversión de fechas)
    │
    ▼
Ingeniería de features (creación de TemperatureCategory)
    │
    ▼
División train / test (80% / 20%, estratificada)
    │
    ├──► Árbol base (rpart)
    ├──► Árbol ajustado (rpart + hiperparámetros)
    └──► Random Forest (100 árboles, mtry = 3)
              │
              ▼
    Comparación de modelos (Accuracy + Matriz de Confusión)
```

---

## 🤖 Modelos entrenados

### 1. Árbol de Clasificación — Base
Modelo `rpart` sin ajuste de hiperparámetros, usando las variables `LandMaxTemperature`, `LandMinTemperature` y `LandAndOceanAverageTemperature`.

### 2. Árbol de Clasificación — Ajustado
Mismo modelo con control de hiperparámetros:
- `minsplit = 10`: mínimo de observaciones para intentar una división.
- `minbucket = 5`: mínimo de observaciones en un nodo hoja.
- `maxdepth = 30`: profundidad máxima del árbol.

### 3. Random Forest
Ensemble de 100 árboles con `mtry = 3`, usando todas las variables disponibles.

---

## 📈 Resultados

> Los valores de accuracy se obtienen al ejecutar el script con los datos originales.

| Modelo              | Accuracy  |
|---------------------|-----------|
| Árbol base          | —         |
| Árbol ajustado      | —         |
| **Random Forest**   | **—**     |


---

## 🚀 Cómo ejecutar el proyecto

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/global-temperature-classification.git
cd global-temperature-classification
```

### 2. Descargar el dataset
Descargá `GlobalTemperatures.csv` desde [Kaggle](https://www.kaggle.com/datasets/berkeleyearth/climate-change-earth-surface-temperature-data) y colocalo en la carpeta `data/`.

### 3. Instalar dependencias
Ejecutar en R o RStudio:
```r
source("src/00_setup.R")
```

### 4. Correr el análisis
```r
source("src/01_analisis_temperatura.R")
```

---

## 🛠️ Tecnologías y paquetes

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![RStudio](https://img.shields.io/badge/RStudio-75AADB?style=for-the-badge&logo=rstudio&logoColor=white)

| Paquete        | Uso                                        |
|----------------|--------------------------------------------|
| `rpart`        | Árboles de clasificación                   |
| `rpart.plot`   | Visualización de árboles                   |
| `randomForest` | Ensemble de Random Forest                  |
| `caret`        | Partición de datos y matrices de confusión |
| `dplyr`        | Manipulación de datos                      |
| `ggplot2`      | Visualizaciones                            |
| `readr`        | Lectura de archivos CSV                    |

---

## 👤 Autor

Nazarely Gomez Abularacn
T.S en Ciencia de Datos e Inteligencia Artificial

[![LinkedIn](www.linkedin.com/in/nazarely-gomez-abularach)
[![GitHub](https://github.com/Nazarely))

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.
