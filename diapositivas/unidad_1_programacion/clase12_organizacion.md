# Organización de Proyectos de Ciencia de Datos
**Guía práctica para estructura, nomenclatura y reproducibilidad**

---

## 📁 Estructura de Carpetas Estándar

### Organización básica recomendada

```
mi_proyecto_analisis_ventas/
│
├── data/
│   ├── raw/                    # Datos originales (NUNCA modificar)
│   ├── processed/              # Datos procesados/limpios
│   └── external/               # Datos de fuentes externas
│
├── scripts/
│   ├── 01_carga_datos.R
│   ├── 02_limpieza.R
│   ├── 03_exploracion.R
│   ├── 04_analisis_principal.R
│   └── 05_reportes.R
│
├── functions/
│   ├── limpieza_funciones.R
│   ├── visualizacion_funciones.R
│   └── analisis_funciones.R
│
├── outputs/
│   ├── figures/                # Gráficos generados
│   ├── tables/                 # Tablas exportadas
│   └── reports/                # Informes finales
│
├── config/
│   └── parametros.R            # Parámetros globales
│
└── README.md                   # Documentación del proyecto
```

---

## 📋 Principios Fundamentales

### 1. **Separación clara de datos originales y procesados**
- `data/raw/`: Datos originales, **NUNCA** modificar
- `data/processed/`: Resultados de limpieza y transformación
- `data/external/`: Referencias, catálogos, datos auxiliares

### 2. **Scripts numerados por orden de ejecución**
- Facilita entender el flujo del análisis
- Cada script tiene una responsabilidad específica
- Nombres descriptivos que explican el contenido

### 3. **Funciones separadas de scripts principales**
- Código reutilizable en archivos independientes
- Organizado por temática (limpieza, visualización, etc.)
- Facilita mantenimiento y testing

---

## 📝 Nomenclatura de Archivos y Scripts

### Convenciones para scripts principales

```r
# ✅ CORRECTO: Numeración + descripción clara
01_carga_datos_eph.R
02_limpieza_ingresos.R
03_exploracion_descriptiva.R
04_analisis_regresiones.R
05_graficos_principales.R
06_reporte_final.R

# ❌ EVITAR: Sin orden, nombres ambiguos
analisis.R
datos.R
final.R
script1.R
```

### Convenciones para archivos de datos

```r
# ✅ CORRECTO: Fecha + descripción + estado
# Datos originales
2024_eph_t3_microdatos.csv
2024_indec_pib_trimestral.xlsx

# Datos procesados
2024_eph_t3_limpio.csv
2024_pib_serie_completa.csv

# ❌ EVITAR: Nombres genéricos
datos.csv
base.xlsx
final.csv
```

---

## ⚙️ Configuración Reproducible

### Archivo de configuración (`config/parametros.R`)

```r
# =============================================================================
# CONFIGURACIÓN GLOBAL DEL PROYECTO
# =============================================================================

# Limpiar entorno
rm(list = ls())

# Configurar opciones globales
options(stringsAsFactors = FALSE)
options(scipen = 999)  # Evitar notación científica

# Librerías del proyecto
library(tidyverse)
library(readxl)
library(lubridate)
library(scales)

# Definir directorios de forma reproducible
if (!exists("proyecto_dir")) {
  proyecto_dir <- here::here()  # Usa el paquete 'here'
  # Alternativa manual:
  # proyecto_dir <- dirname(rstudioapi::getSourceEditorContext()$path)
}

# Rutas principales
dir_data_raw <- file.path(proyecto_dir, "data", "raw")
dir_data_processed <- file.path(proyecto_dir, "data", "processed")
dir_data_external <- file.path(proyecto_dir, "data", "external")
dir_outputs_figures <- file.path(proyecto_dir, "outputs", "figures")
dir_outputs_tables <- file.path(proyecto_dir, "outputs", "tables")

# Crear directorios si no existen
dirs_crear <- c(dir_data_raw, dir_data_processed, dir_data_external,
                dir_outputs_figures, dir_outputs_tables)

for (dir in dirs_crear) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }
}

# Parámetros del análisis
YEAR_ANALISIS <- 2024
TRIMESTRE_ANALISIS <- 3
UMBRAL_POBREZA <- 85000  # Ejemplo para análisis de pobreza

# Funciones para mensajes consistentes
mensaje_exito <- function(texto) {
  cat("✅", texto, "\n")
}

mensaje_proceso <- function(texto) {
  cat("🔄", texto, "...\n")
}

mensaje_exito("Configuración cargada correctamente")
```

### Carga de configuración en cada script

```r
# Inicio de cada script
source(here::here("config", "parametros.R"))

# O si no usas 'here'
source(file.path(dirname(rstudioapi::getSourceEditorContext()$path), 
                 "..", "config", "parametros.R"))
```

---

## 🔧 Organización de Funciones

### Archivo de funciones de limpieza (`functions/limpieza_funciones.R`)

```r
# =============================================================================
# FUNCIONES PARA LIMPIEZA DE DATOS
# =============================================================================

#' Limpiar nombres de columnas según convenciones del proyecto
#' @param df data.frame con nombres a limpiar
#' @return data.frame con nombres en snake_case
limpiar_nombres <- function(df) {
  nombres_nuevos <- names(df) %>%
    str_to_lower() %>%                    # Todo minúsculas
    str_replace_all("[^a-zA-Z0-9_]", "_") %>%  # Solo letras, números y _
    str_replace_all("_{2,}", "_") %>%     # Eliminar _ múltiples
    str_remove("^_|_$")                   # Eliminar _ al inicio/final
  
  names(df) <- nombres_nuevos
  return(df)
}

#' Validar rangos de variables numéricas
#' @param vector vector numérico a validar
#' @param min_val valor mínimo esperado
#' @param max_val valor máximo esperado
#' @return logical vector indicando valores válidos
validar_rango <- function(vector, min_val = -Inf, max_val = Inf) {
  vector >= min_val & vector <= max_val & !is.na(vector)
}

#' Detectar y reportar datos atípicos usando IQR
#' @param df data.frame
#' @param columna nombre de la columna a analizar
#' @return lista con información sobre atípicos
detectar_atipicos <- function(df, columna) {
  vector_datos <- df[[columna]]
  
  Q1 <- quantile(vector_datos, 0.25, na.rm = TRUE)
  Q3 <- quantile(vector_datos, 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  
  limite_inferior <- Q1 - 1.5 * IQR
  limite_superior <- Q3 + 1.5 * IQR
  
  atipicos <- vector_datos < limite_inferior | vector_datos > limite_superior
  
  list(
    n_atipicos = sum(atipicos, na.rm = TRUE),
    porcentaje = round(100 * sum(atipicos, na.rm = TRUE) / length(vector_datos), 2),
    limite_inferior = limite_inferior,
    limite_superior = limite_superior,
    indices_atipicos = which(atipicos)
  )
}
```

### Archivo de funciones de visualización (`functions/visualizacion_funciones.R`)

```r
# =============================================================================
# FUNCIONES PARA VISUALIZACIÓN
# =============================================================================

#' Tema estándar para gráficos del proyecto
tema_proyecto <- function() {
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray60"),
    axis.title = element_text(size = 11),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    strip.text = element_text(size = 10, face = "bold"),
    panel.grid.minor = element_blank()
  )
}

#' Paleta de colores estándar del proyecto
colores_proyecto <- c(
  primario = "#2E86C1",
  secundario = "#E74C3C", 
  terciario = "#F39C12",
  gris_claro = "#BDC3C7",
  gris_oscuro = "#34495E"
)

#' Guardar gráfico con formato estándar
#' @param plot objeto ggplot
#' @param nombre_archivo nombre sin extensión
#' @param ancho ancho en pulgadas
#' @param alto alto en pulgadas
guardar_grafico <- function(plot, nombre_archivo, ancho = 10, alto = 6) {
  
  # Crear nombre con fecha
  fecha_actual <- format(Sys.Date(), "%Y%m%d")
  nombre_completo <- paste0(fecha_actual, "_", nombre_archivo)
  
  # Guardar en PNG (alta calidad)
  ggsave(
    filename = file.path(dir_outputs_figures, paste0(nombre_completo, ".png")),
    plot = plot,
    width = ancho, height = alto,
    dpi = 300, bg = "white"
  )
  
  # También en PDF (vectorial)
  ggsave(
    filename = file.path(dir_outputs_figures, paste0(nombre_completo, ".pdf")),
    plot = plot,
    width = ancho, height = alto
  )
  
  mensaje_exito(paste("Gráfico guardado:", nombre_completo))
}
```

### Cargar funciones en scripts principales

```r
# Al inicio del script, después de cargar configuración
source(file.path("functions", "limpieza_funciones.R"))
source(file.path("functions", "visualizacion_funciones.R"))

# O cargar todas las funciones de una vez
archivos_funciones <- list.files("functions", pattern = "\\.R$", full.names = TRUE)
sapply(archivos_funciones, source)
```

---

## 📊 Carga Reproducible de Datos

### Función estándar para cargar datos

```r
# En functions/carga_funciones.R
#' Cargar datos con validación y logging
#' @param nombre_archivo nombre del archivo
#' @param carpeta carpeta donde buscar ('raw', 'processed', 'external')
#' @param encoding codificación del archivo
cargar_datos <- function(nombre_archivo, carpeta = "raw", encoding = "UTF-8") {
  
  # Construir ruta completa
  ruta_carpeta <- switch(carpeta,
    "raw" = dir_data_raw,
    "processed" = dir_data_processed, 
    "external" = dir_data_external,
    stop("Carpeta debe ser 'raw', 'processed' o 'external'")
  )
  
  ruta_completa <- file.path(ruta_carpeta, nombre_archivo)
  
  # Verificar que el archivo existe
  if (!file.exists(ruta_completa)) {
    stop("Archivo no encontrado: ", ruta_completa)
  }
  
  mensaje_proceso(paste("Cargando", nombre_archivo))
  
  # Detectar tipo de archivo y cargar apropiadamente
  extension <- tools::file_ext(nombre_archivo)
  
  datos <- switch(extension,
    "csv" = read_csv(ruta_completa, locale = locale(encoding = encoding)),
    "xlsx" = read_excel(ruta_completa),
    "rds" = readRDS(ruta_completa),
    "txt" = read_delim(ruta_completa, locale = locale(encoding = encoding)),
    stop("Formato no soportado: ", extension)
  )
  
  # Información sobre los datos cargados
  mensaje_exito(paste("Cargado:", nrow(datos), "filas,", ncol(datos), "columnas"))
  
  return(datos)
}

#' Guardar datos procesados con validación
#' @param datos data.frame a guardar
#' @param nombre_archivo nombre sin extensión
guardar_datos_procesados <- function(datos, nombre_archivo) {
  
  # Agregar timestamp
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M")
  nombre_completo <- paste0(timestamp, "_", nombre_archivo)
  
  # Guardar en múltiples formatos
  ruta_csv <- file.path(dir_data_processed, paste0(nombre_completo, ".csv"))
  ruta_rds <- file.path(dir_data_processed, paste0(nombre_completo, ".rds"))
  
  write_csv(datos, ruta_csv)
  saveRDS(datos, ruta_rds)
  
  mensaje_exito(paste("Datos guardados:", nombre_completo))
  
  # Log de metadatos
  metadatos <- list(
    fecha_creacion = Sys.time(),
    filas = nrow(datos),
    columnas = ncol(datos),
    columnas_nombres = names(datos),
    archivo_origen = nombre_archivo
  )
  
  saveRDS(metadatos, file.path(dir_data_processed, paste0(nombre_completo, "_metadata.rds")))
}
```

---

## 🔄 Flujo de Trabajo Estándar

### Script principal de análisis (`scripts/01_carga_datos.R`)

```r
# =============================================================================
# SCRIPT 01: CARGA Y VALIDACIÓN INICIAL DE DATOS
# Proyecto: Análisis de EPH T3 2024
# Autor: [Tu nombre]
# Fecha: 2024-09-26
# =============================================================================

# Configuración inicial
source(here::here("config", "parametros.R"))
source(here::here("functions", "carga_funciones.R"))
source(here::here("functions", "limpieza_funciones.R"))

mensaje_proceso("Iniciando carga de datos")

# Cargar datos principales
eph_individual <- cargar_datos("usu_individual_T324.txt", "raw")
eph_hogar <- cargar_datos("usu_hogar_T324.txt", "raw")

# Validaciones iniciales
stopifnot("Datos individuales vacíos" = nrow(eph_individual) > 0)
stopifnot("Datos hogares vacíos" = nrow(eph_hogar) > 0)

# Verificar estructura esperada
columnas_esperadas_ind <- c("CODUSU", "NRO_HOGAR", "COMPONENTE", "P21")
columnas_faltantes <- setdiff(columnas_esperadas_ind, names(eph_individual))
if (length(columnas_faltantes) > 0) {
  warning("Columnas faltantes: ", paste(columnas_faltantes, collapse = ", "))
}

# Estadísticas básicas de carga
cat("\n" , "="*50, "\n")
cat("RESUMEN DE CARGA\n")
cat("="*50, "\n")
cat("EPH Individual:", nrow(eph_individual), "registros\n")
cat("EPH Hogar:", nrow(eph_hogar), "registros\n")
cat("Período:", unique(eph_individual$ANO4), "T", unique(eph_individual$TRIMESTRE), "\n")

mensaje_exito("Carga completada exitosamente")

# Limpiar variables temporales
rm(columnas_esperadas_ind, columnas_faltantes)
```

### Script de limpieza (`scripts/02_limpieza.R`)

```r
# =============================================================================
# SCRIPT 02: LIMPIEZA Y PREPARACIÓN DE DATOS
# =============================================================================

# Cargar script anterior (si es necesario)
if (!exists("eph_individual")) {
  source(here::here("scripts", "01_carga_datos.R"))
}

mensaje_proceso("Iniciando limpieza de datos")

# Limpiar nombres de columnas
eph_individual <- limpiar_nombres(eph_individual)
eph_hogar <- limpiar_nombres(eph_hogar)

# Filtros de calidad básicos
eph_clean <- eph_individual %>%
  # Mantener solo casos válidos
  filter(
    estado %in% 1,  # Solo entrevistas completas
    !is.na(componente),
    ch04 %in% 1:2  # Solo hombres y mujeres declarados
  ) %>%
  # Crear variables derivadas básicas
  mutate(
    genero = if_else(ch04 == 1, "Varon", "Mujer"),
    edad_grupos = case_when(
      ch06 < 18 ~ "Menor 18",
      ch06 >= 18 & ch06 < 65 ~ "18-64",
      ch06 >= 65 ~ "65 y más",
      TRUE ~ "Sin dato"
    )
  )

# Validar limpieza
cat("Registros antes limpieza:", nrow(eph_individual), "\n")
cat("Registros después limpieza:", nrow(eph_clean), "\n")
cat("Porcentaje conservado:", 
    round(100 * nrow(eph_clean) / nrow(eph_individual), 1), "%\n")

# Guardar datos limpios
guardar_datos_procesados(eph_clean, "eph_individual_limpio")

mensaje_exito("Limpieza completada")
```

---

## 📈 Buenas Prácticas Adicionales

### 1. **Logging y documentación automática**

```r
# Función para crear log de ejecución
crear_log_ejecucion <- function(script_nombre) {
  log_info <- list(
    script = script_nombre,
    fecha_ejecucion = Sys.time(),
    usuario = Sys.info()["user"],
    version_r = R.version.string,
    paquetes = sessionInfo()$otherPkgs
  )
  
  nombre_log <- paste0("log_", format(Sys.Date(), "%Y%m%d"), "_", script_nombre, ".rds")
  saveRDS(log_info, file.path("outputs", nombre_log))
}

# Al final de cada script
crear_log_ejecucion("01_carga_datos")
```

### 2. **Validaciones automáticas**

```r
# Función para validar integridad de datos
validar_datos <- function(df, nombre_dataset) {
  
  validaciones <- list(
    filas_vacias = sum(apply(df, 1, function(x) all(is.na(x)))),
    columnas_vacias = sum(apply(df, 2, function(x) all(is.na(x)))),
    duplicados_completos = sum(duplicated(df)),
    porcentaje_faltantes = round(100 * sum(is.na(df)) / (nrow(df) * ncol(df)), 2)
  )
  
  cat("\n", "VALIDACIÓN:", nombre_dataset, "\n")
  cat("Filas completamente vacías:", validaciones$filas_vacias, "\n")
  cat("Columnas completamente vacías:", validaciones$columnas_vacias, "\n") 
  cat("Filas duplicadas:", validaciones$duplicados_completos, "\n")
  cat("% datos faltantes:", validaciones$porcentaje_faltantes, "%\n")
  
  return(validaciones)
}
```

### 3. **Templates para nuevos análisis**

```r
# Template estándar al inicio de cada script
# =============================================================================
# SCRIPT XX: [DESCRIPCIÓN DEL SCRIPT]
# Proyecto: [Nombre del proyecto]
# Autor: [Tu nombre]
# Fecha creación: [Fecha]
# Última modificación: [Fecha]
# Descripción: [Explicación detallada del propósito]
# Inputs: [Archivos que requiere]
# Outputs: [Archivos que genera]
# =============================================================================

# TODO: [Lista de tareas pendientes]
# FIXME: [Problemas conocidos por resolver]
# NOTE: [Observaciones importantes]
```

---

## ⚠️ Errores Comunes a Evitar

### ❌ Problemas típicos
- Usar `setwd()` con rutas absolutas
- No documentar fuentes de datos
- Mezclar datos originales con procesados
- Scripts que dependen de objetos en memoria
- No versionar archivos de salida importantes

### ✅ Soluciones
- Usar rutas relativas y paquete `here`
- Documentar metadatos en cada carga
- Separación estricta raw/processed
- Cada script autocontenido
- Timestamping automático de outputs

---

## 🎯 Checklist de Proyecto Bien Organizado

- [ ] Estructura de carpetas clara y consistente
- [ ] Scripts numerados y con propósito específico
- [ ] Configuración centralizada reproducible
- [ ] Funciones organizadas por tema
- [ ] Datos originales protegidos (solo lectura)
- [ ] Nomenclatura consistente en todo el proyecto
- [ ] Validaciones automáticas implementadas
- [ ] Logging de ejecuciones activado
- [ ] README actualizado con instrucciones
- [ ] Outputs timestampeados automáticamente
