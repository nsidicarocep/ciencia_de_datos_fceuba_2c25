# Clase 4: Introducción a Tidyverse y Funciones Principales

**Curso**: Fundamentos del Análisis Programático de Datos  
**Fecha**: 29 de agosto de 2025  
**Modalidad**: Virtual asincrónica

## 📋 Objetivos de la clase

- Comprender la historia y filosofía del ecosistema tidyverse
- Configurar un entorno de trabajo organizado con gestión de carpetas
- Dominar la lectura de diferentes formatos de archivos
- Implementar las 6 operaciones fundamentales de manipulación de datos
- Comparar tidyverse con Base R y entender cuándo usar cada uno

---

## 🌟 ¿Qué es Tidyverse?

### Historia y creación

**Tidyverse** fue creado por **Hadley Wickham** y su equipo en RStudio (ahora Posit) a partir de 2014. Hadley, estadístico neozelandés y Chief Scientist de Posit, identificó que R tenía potencial enorme pero sufría de inconsistencias que dificultaban su aprendizaje y uso.

### La visión detrás de tidyverse

**Problema identificado**: R Base tenía funciones poderosas pero:
- Sintaxis inconsistente entre funciones
- Múltiples formas de hacer lo mismo
- Nombres de funciones poco intuitivos
- Estructuras de datos complejas para principiantes

**Solución propuesta**: Un ecosistema integrado con:
- **Filosofía consistente** basada en datos tidy
- **Sintaxis uniforme** entre todos los paquetes
- **Pipe operator** para código legible
- **Documentación excelente** y abundantes ejemplos

### Los principios de diseño

1. **Consistency**: todas las funciones siguen el mismo patrón
2. **Composability**: las funciones se combinan fácilmente 
3. **Readability**: el código debe ser legible como prosa
4. **Performance**: optimizado para casos de uso comunes

---

## 🤝 Base R vs Tidyverse: Comparación práctica

### Ejemplo 1: Filtrar y calcular promedios

```r
# BASE R
ventas_norte <- datos_ventas[datos_ventas$region == "Norte", ]
promedio_norte <- mean(ventas_norte$ventas)

# TIDYVERSE  
promedio_norte <- datos_ventas %>%
  filter(region == "Norte") %>%
  summarise(promedio = mean(ventas)) %>%
  pull(promedio)
```

### Ejemplo 2: Crear nueva variable y agrupar

```r
# BASE R
datos_ventas$comision <- datos_ventas$ventas * 0.02
resultado <- aggregate(datos_ventas$comision, 
                      by = list(region = datos_ventas$region), 
                      FUN = sum)
names(resultado)[2] <- "total_comision"

# TIDYVERSE
resultado <- datos_ventas %>%
  mutate(comision = ventas * 0.02) %>%
  group_by(region) %>%
  summarise(total_comision = sum(comision))
```

### Ejemplo 3: Operación compleja

```r
# BASE R (difícil de seguir)
datos_filtrados <- datos_ventas[datos_ventas$ventas > 40000, ]
datos_con_comision <- transform(datos_filtrados, 
                               comision = ventas * 0.02)
resultado_agregado <- aggregate(cbind(ventas, comision) ~ region, 
                               data = datos_con_comision, 
                               FUN = sum)
resultado_final <- resultado_agregado[order(-resultado_agregado$ventas), ]

# TIDYVERSE (fácil de leer)
resultado_final <- datos_ventas %>%
  filter(ventas > 40000) %>%
  mutate(comision = ventas * 0.02) %>%
  group_by(region) %>%
  summarise(ventas = sum(ventas), comision = sum(comision)) %>%
  arrange(desc(ventas))
```

### ¿Cuándo usar cada uno?

**Usar Tidyverse cuando:**
- Manipulación estándar de datos
- Código que otros van a leer
- Análisis exploratorio
- Aprendiendo R
- Trabajo en equipo

**Usar Base R cuando:**
- Performance crítico en loops
- Paquetes que no son compatible con tidyverse
- Operaciones matemáticas puras
- Desarrollo de paquetes (aunque cada vez menos)

---

## 📊 Tibbles vs Data Frames

### ¿Qué es un tibble?

Un **tibble** es la versión moderna del data.frame tradicional de R, diseñado para ser más user-friendly.

```r
# Crear un data.frame tradicional
df_tradicional <- data.frame(
  nombre = c("Ana", "Carlos", "Diana"),
  edad = c(25, 30, 28),
  ventas = c(5000, 7500, 6200)
)

# Crear un tibble
tb_moderno <- tibble(
  nombre = c("Ana", "Carlos", "Diana"), 
  edad = c(25, 30, 28),
  ventas = c(5000, 7500, 6200)
)

# También podés convertir
tb_convertido <- as_tibble(df_tradicional)
```

### Diferencias clave

| Aspecto | Data.frame | Tibble |
|---------|------------|--------|
| **Impresión** | Muestra todo | Solo primeras 10 filas |
| **Tipos de columna** | No siempre visible | Siempre visible |
| **Subsetting** | `df$col` o `df[["col"]]` | Mismo + warnings útiles |
| **Nombres de columna** | Acepta nombres problemáticos | Más estricto |
| **Conversión de tipos** | Automática (a veces problemática) | Más conservadora |

### Ejemplo práctico de las diferencias

```r
# Tibble muestra información útil
print(tb_moderno)
# A tibble: 3 × 3
#   nombre   edad ventas
#   <chr>   <dbl>  <dbl>
# 1 Ana        25   5000
# 2 Carlos     30   7500  
# 3 Diana      28   6200

# Data.frame tradicional es menos informativo
print(df_tradicional)
#    nombre edad ventas
# 1     Ana   25   5000
# 2  Carlos   30   7500
# 3   Diana   28   6200
```

---

## 🔧 El operador pipe (%>%): Filosofía y práctica

### La revolución del pipe

Antes de tidyverse, el código de R se leía "de adentro hacia afuera":

```r
# Código difícil de leer (anidado)
resultado <- arrange(
  summarise(
    group_by(
      filter(datos, ventas > 1000), 
      region
    ), 
    total = sum(ventas)
  ), 
  desc(total)
)

# Código con variables intermedias (verboso)
datos_filtrados <- filter(datos, ventas > 1000)
datos_agrupados <- group_by(datos_filtrados, region)  
datos_resumidos <- summarise(datos_agrupados, total = sum(ventas))
resultado <- arrange(datos_resumidos, desc(total))
```

### Con pipe: código que se lee como prosa

```r
# Código legible de izquierda a derecha, de arriba a abajo
resultado <- datos %>%
  filter(ventas > 1000) %>%      # "toma los datos Y DESPUÉS filtra ventas > 1000"
  group_by(region) %>%           # "Y DESPUÉS agrupa por región" 
  summarise(total = sum(ventas)) %>%  # "Y DESPUÉS suma las ventas"
  arrange(desc(total))           # "Y DESPUÉS ordena descendente"
```

### Beneficios del pipe

1. **Legibilidad**: se lee secuencialmente
2. **Debugging**: fácil comentar líneas para probar
3. **Modificabilidad**: agregar pasos es simple
4. **Menos variables intermedias**: código más limpio

---

## 📁 Gestión de proyectos y working directory

### Buenas prácticas de organización

Un proyecto bien organizado facilita la reproducibilidad y colaboración:

```
mi_proyecto/
├── instub/           # Datos de entrada (input)
├── outstub/          # Datos procesados y resultados
├── scripts/          # Códigos R
└── plots/            # Gráficos generados
```

### Configuración manual del working directory

```r
# Verificar directorio actual
getwd()

# Definir directorio de trabajo manualmente
setwd(r'(C:\Users\usuario\Documents\mi_proyecto)')

# Verificar que el cambio fue exitoso
getwd()
```

### Definición de carpetas y archivos

```r
# Definir carpetas de trabajo
instub <- 'instub'     # Carpeta de datos de entrada
outstub <- 'outstub'   # Carpeta de salida/resultados

# Definir nombre del archivo
archivo <- 'ventas.csv'

# Construir ruta completa
ruta_completa <- file.path(instub, archivo)

# Cargar archivo
datos <- read_csv(ruta_completa)
```

---

## 📂 Carga de archivos: Configuración práctica

### Configuración inicial del entorno

```r
# Cargar librerías necesarias
library(tidyverse)
library(readxl)      # Para archivos Excel
library(haven)       # Para SPSS, SAS, Stata

# Definir directorio de trabajo
setwd(r'(C:\Users\usuario\Documents\mi_proyecto)')

# Definir carpetas de trabajo
instub <- 'instub'     # Carpeta de datos de entrada
outstub <- 'outstub'   # Carpeta de resultados

# Crear carpetas si no existen
if (!dir.exists(instub)) {
  dir.create(instub, recursive = TRUE)
}

if (!dir.exists(outstub)) {
  dir.create(outstub, recursive = TRUE)
}

```

### Ejemplos de carga por formato

```r
# Definir nombre del archivo
archivo_csv <- 'ventas.csv'
archivo_excel <- 'ventas.xlsx'
archivo_txt <- 'ventas.txt'
archivo_spss <- 'encuesta.sav'

# CSV
datos_csv <- read_csv(file.path(instub, archivo_csv))

# Excel (múltiples hojas)
datos_excel_hoja1 <- read_excel(file.path(instub, archivo_excel), sheet = 1)
datos_excel_hoja2 <- read_excel(file.path(instub, archivo_excel), sheet = "Resumen")

# Archivos de texto delimitado
datos_txt <- read_delim(file.path(instub, archivo_txt), delim = ";")

# SPSS
datos_spss <- read_spss(file.path(instub, archivo_spss))
```

### Verificación después de la carga

```r
# Verificar carga exitosa paso a paso
archivo <- 'ventas.csv'

# Cargar datos
datos_ventas <- read_csv(file.path(instub, archivo))

```

---

## 🚀 Introducción al ecosistema Tidyverse

### Los paquetes core

```r
# Al cargar tidyverse se cargan automáticamente:
library(tidyverse)

# ✅ readr    - Importación de datos rectangulares
# ✅ dplyr    - Manipulación de datos
# ✅ ggplot2  - Visualización (veremos más adelante)
# ✅ tibble   - Estructura de datos mejorada  
# ✅ tidyr    - Reorganización de datos
# ✅ stringr  - Manipulación de strings
# ✅ forcats  - Manejo de factores
# ✅ purrr    - Programación funcional
```

### ¿Por qué tidyverse es superior?

**1. Consistencia de API**
Todas las funciones siguen el mismo patrón:
- Primer argumento siempre es el dataset
- Return siempre un tibble (cuando corresponde)
- Nombres descriptivos y consistentes

**2. Composabilidad**
Las funciones están diseñadas para combinarse:

```r
# Cada función hace UNA cosa bien
datos %>%
  filter() %>%    # Solo filtra
  mutate() %>%    # Solo crea variables
  group_by() %>%  # Solo agrupa  
  summarise()     # Solo resume
```

**3. Filosofía tidy**
Todo está diseñado para trabajar con datos en formato tidy, lo que simplifica el 90% de las tareas analíticas.

---

## ⚡ Consideraciones de performance

### Cuándo usar tidyverse vs Base R

**Tidyverse es óptimo para:**
- Datasets medianos (< 10M filas)
- Análisis exploratorio
- Código que otros van a leer
- Prototipado rápido

```r
# Tidyverse - rápido y legible
datos %>%
  filter(ventas > 1000) %>%
  group_by(region) %>%
  summarise(total = sum(ventas))
```

**Base R puede ser mejor para:**
- Datasets muy grandes (>50M filas)
- Loops intensivos
- Operaciones matemáticas puras
- Cuando la memoria es limitada

```r
# Base R - más eficiente en memoria para loops grandes
for (i in 1:1000000) {
  # operaciones matemáticas intensivas
}
```

### Híbrido: lo mejor de ambos mundos

```r
# Usar tidyverse para manipulación + Base R para cálculos pesados
datos_prep <- datos %>%
  filter(fecha >= "2024-01-01") %>%
  select(vendedor, ventas, region)

# Convertir a matrix para cálculos rápidos si es necesario
matriz_ventas <- as.matrix(datos_prep[, "ventas"])
resultado_matematico <- colSums(matriz_ventas)
```

---

## 📊 Las 6 operaciones fundamentales implementadas

### Datos de ejemplo para trabajar

```r
# Crear dataset de ejemplo más rico
set.seed(123)
datos_ventas <- tibble(
  vendedor = rep(c("García", "López", "Martín", "Silva"), each = 4),
  region = rep(c("Norte", "Sur", "Centro", "Este"), 4),
  categoria = sample(c("Electrónicos", "Ropa", "Hogar"), 16, replace = TRUE),
  ventas = round(runif(16, 3000, 8000), 0),
  fecha = seq(from = as.Date("2024-01-01"), 
              to = as.Date("2024-04-15"), 
              length.out = 16),
  meta_alcanzada = sample(c(TRUE, FALSE), 16, replace = TRUE, prob = c(0.7, 0.3))
)

glimpse(datos_ventas)
```

### 1. **select()** - Seleccionar columnas

```r
# Básico: seleccionar por nombre
datos_ventas %>%
  select(vendedor, ventas)

# Seleccionar rango
datos_ventas %>%
  select(vendedor:categoria)

# Excluir columnas
datos_ventas %>%
  select(-fecha, -meta_alcanzada)

# Funciones helper
datos_ventas %>%
  select(starts_with("v"))        # Empieza con "v"
  
datos_ventas %>%
  select(ends_with("s"))          # Termina con "s"
  
datos_ventas %>%
  select(contains("vent"))        # Contiene "vent"

datos_ventas %>%
  select(where(is.numeric))       # Solo columnas numéricas

# Reordenar columnas
datos_ventas %>%
  select(ventas, everything())    # ventas primero, resto después
```

### 2. **filter()** - Filtrar filas

```r
# Filtros numéricos
datos_ventas %>%
  filter(ventas > 5000)

datos_ventas %>%
  filter(between(ventas, 4000, 6000))  # Entre valores

# Filtros de texto
datos_ventas %>%
  filter(vendedor == "García")

datos_ventas %>%
  filter(vendedor %in% c("García", "López"))

datos_ventas %>%
  filter(str_detect(vendedor, "^G"))   # Empieza con G

# Filtros lógicos
datos_ventas %>%
  filter(meta_alcanzada == TRUE)

# Combinar condiciones
datos_ventas %>%
  filter(ventas > 5000 & region %in% c("Norte", "Sur"))

datos_ventas %>%
  filter(ventas > 6000 | meta_alcanzada == TRUE)

# Filtros de fechas
datos_ventas %>%
  filter(fecha >= as.Date("2024-02-01"))

datos_ventas %>%
  filter(year(fecha) == 2024, month(fecha) %in% c(1, 2))
```

### 3. **mutate()** - Crear nuevas variables

```r
# Variables simples
datos_ventas %>%
  mutate(
    comision = ventas * 0.02,
    ventas_usd = ventas / 1000,  # Asumiendo tipo de cambio simplificado
    vendedor_codigo = str_sub(vendedor, 1, 3)
  )

# Variables con condicionales
datos_ventas %>%
  mutate(
    performance = ifelse(ventas >= 5000, "Alto", "Bajo"),
    
    categoria_detallada = case_when(
      ventas >= 7000 ~ "Excelente",
      ventas >= 5500 ~ "Muy bueno",
      ventas >= 4000 ~ "Bueno", 
      ventas >= 2500 ~ "Regular",
      TRUE ~ "Bajo"
    ),
    
    cumple_meta = ifelse(meta_alcanzada, "Sí", "No")
  )

# Variables de fecha
datos_ventas %>%
  mutate(
    año = year(fecha),
    mes = month(fecha, label = TRUE),
    dia_semana = wday(fecha, label = TRUE),
    trimestre = paste0("Q", quarter(fecha))
  )

# Variables de texto
datos_ventas %>%
  mutate(
    vendedor_upper = str_to_upper(vendedor),
    iniciales = paste0(str_sub(vendedor, 1, 1), str_sub(str_extract(vendedor, " \\w"), 2, 2)),
    descripcion = paste(vendedor, "vendió", ventas, "en", region)
  )
```

### 4. **group_by()** - Agrupar datos

```r
# Agrupar por una variable
datos_ventas %>%
  group_by(region) %>%
  glimpse()  # Nota la línea "Groups: region [4]"

# Agrupar por múltiples variables
datos_agrupados <- datos_ventas %>%
  group_by(region, categoria)

# Verificar agrupación
group_vars(datos_agrupados)
groups(datos_agrupados)

# Desagrupar
datos_agrupados %>%
  ungroup()
```

### 5. **summarise()** - Calcular estadísticas

```r
# Resumen básico
datos_ventas %>%
  summarise(
    total_ventas = sum(ventas),
    promedio_ventas = mean(ventas),
    mediana_ventas = median(ventas),
    num_observaciones = n()
  )

# Resumen por grupos
datos_ventas %>%
  group_by(region) %>%
  summarise(
    ventas_totales = sum(ventas),
    ventas_promedio = round(mean(ventas)),
    vendedores_unicos = n_distinct(vendedor),
    mejor_venta = max(ventas),
    peor_venta = min(ventas),
    rango_ventas = max(ventas) - min(ventas),
    .groups = 'drop'  # Desagrupar automáticamente
  )

# Múltiples agrupaciones
datos_ventas %>%
  group_by(region, categoria) %>%
  summarise(
    ventas_segmento = sum(ventas),
    transacciones = n(),
    .groups = 'keep'    # Mantener agrupación por region
  ) %>%
  mutate(
    participacion = round(100 * ventas_segmento / sum(ventas_segmento), 1)
  )
```

### 6. **arrange()** - Ordenar datos

```r
# Ordenar ascendente (por defecto)
datos_ventas %>%
  arrange(ventas)

# Ordenar descendente
datos_ventas %>%
  arrange(desc(ventas))

# Múltiples criterios
datos_ventas %>%
  arrange(region, desc(ventas))

# Dentro de grupos
datos_ventas %>%
  group_by(region) %>%
  arrange(desc(ventas), .by_group = TRUE)
```

---

## 🔄 Combinando las 6 operaciones

### Análisis completo paso a paso

```r
# Pipeline completo de análisis
analisis_completo <- datos_ventas %>%
  # 1. Filtrar datos relevantes
  filter(fecha >= as.Date("2024-01-01")) %>%
  
  # 2. Seleccionar variables necesarias  
  select(vendedor, region, categoria, ventas, meta_alcanzada) %>%
  
  # 3. Crear variables derivadas
  mutate(
    comision = ventas * 0.025,
    performance = case_when(
      ventas >= 6500 ~ "Excelente",
      ventas >= 5000 ~ "Bueno",
      TRUE ~ "Regular"
    ),
    meta_texto = ifelse(meta_alcanzada, "Alcanzó", "No alcanzó")
  ) %>%
  
  # 4. Agrupar por características
  group_by(region, performance) %>%
  
  # 5. Calcular estadísticas de grupo
  summarise(
    vendedores = n_distinct(vendedor),
    ventas_totales = sum(ventas),
    comision_total = sum(comision),
    proporcion_meta = round(100 * sum(meta_alcanzada) / n(), 1),
    .groups = 'drop'
  ) %>%
  
  # 6. Ordenar resultado final
  arrange(region, desc(ventas_totales))

print(analisis_completo)
```

---

## 🆚 Comparación detallada: Tidyverse vs Base R

### Ejemplo complejo: Análisis de ventas por trimestre

```r
# BASE R (verboso y complejo)
datos_ventas$trimestre <- paste0("Q", quarters(datos_ventas$fecha))
datos_ventas$comision <- datos_ventas$ventas * 0.02

# Filtrar y agrupar en Base R
datos_filtrados <- datos_ventas[datos_ventas$ventas > 4000, ]
resultado_base <- aggregate(
  cbind(ventas = datos_filtrados$ventas, comision = datos_filtrados$comision),
  by = list(region = datos_filtrados$region, 
            trimestre = datos_filtrados$trimestre),
  FUN = function(x) c(suma = sum(x), promedio = mean(x))
)

# TIDYVERSE (claro y conciso)
resultado_tidy <- datos_ventas %>%
  mutate(
    trimestre = paste0("Q", quarter(fecha)),
    comision = ventas * 0.02
  ) %>%
  filter(ventas > 4000) %>%
  group_by(region, trimestre) %>%
  summarise(
    ventas_suma = sum(ventas),
    ventas_promedio = mean(ventas),
    comision_suma = sum(comision),
    comision_promedio = mean(comision),
    .groups = 'drop'
  ) %>%
  arrange(trimestre, desc(ventas_suma))
```

### Velocidad de desarrollo: Tidyverse vs Base R

**Tidyverse ventajas:**
- ✅ 70% menos líneas de código en promedio
- ✅ Errores más claros y descriptivos
- ✅ Autocompletado mejor en IDEs
- ✅ Menos consultas a documentación
- ✅ Código self-documenting

**Base R ventajas:**
- ✅ Parte del R core (no dependencias externas)
- ✅ Más rápido para operaciones específicas
- ✅ Mayor control de memoria
- ✅ Estable en el tiempo (menos breaking changes)

---

## 📋 Tibbles: La evolución del data.frame

### Creación de tibbles

```r
# Desde vectors
mi_tibble <- tibble(
  id = 1:5,
  nombre = c("Ana", "Bruno", "Carla", "Diego", "Elena"),
  activo = c(TRUE, TRUE, FALSE, TRUE, FALSE)
)

# Desde data.frame existente
df_viejo <- data.frame(x = 1:3, y = 4:6)
tb_nuevo <- as_tibble(df_viejo)

# Con tribble (por filas)
datos_tribble <- tribble(
  ~vendedor, ~region, ~ventas,
  "García",  "Norte", 5000,
  "López",   "Sur",   6500,
  "Martín",  "Centro", 4800
)
```

### Ventajas específicas de tibbles

```r
# 1. Impresión inteligente
print(datos_ventas)  # Solo muestra lo necesario

# 2. Subsetting más estricto (evita errores)
# data.frame permite esto (puede causar problemas):
df_traditional <- data.frame(nombre = "Ana", edad = 25)
df_traditional$nom  # Devuelve "Ana" (partial matching)

# tibble es más estricto:
tb_moderno <- tibble(nombre = "Ana", edad = 25)
tb_moderno$nom  # Devuelve NULL y warning

# 3. No convierte strings automáticamente
tb_seguro <- tibble(
  texto = c("Hola", "Mundo"),
  numero = c(1, 2)
)
str(tb_seguro)  # texto se mantiene como character

# 4. Permite nombres de columna complejos
tb_flexible <- tibble(
  `nombre completo` = "Ana García",
  `año de nacimiento` = 1990,
  `salario en $` = 50000
)
```

---

## 🔍 Funciones de exploración avanzada

### Exploración estructural

```r
# Información completa del dataset
glimpse(datos_ventas)           # Estructura compacta
str(datos_ventas)               # Estructura detallada
summary(datos_ventas)           # Estadísticas por variable

# Dimensiones y nombres
dim(datos_ventas)               # [filas, columnas]
nrow(datos_ventas)              # Número de filas
ncol(datos_ventas)              # Número de columnas  
names(datos_ventas)             # Nombres de columnas
length(datos_ventas)            # Número de variables
```

### Exploración de contenido

```r
# Primeras y últimas observaciones
head(datos_ventas)              # Primeras 6 filas (default)
head(datos_ventas, 10)          # Primeras 10 filas
tail(datos_ventas, 3)           # Últimas 3 filas

# Muestra aleatoria
slice_sample(datos_ventas, n = 5)           # 5 filas aleatorias
slice_sample(datos_ventas, prop = 0.1)      # 10% aleatorio

# Valores únicos
datos_ventas %>% 
  distinct(vendedor)            # Valores únicos de vendedor

datos_ventas %>%
  count(region, sort = TRUE)    # Frecuencias ordenadas

# Verificar completitud
datos_ventas %>%
  summarise(across(everything(), ~ sum(is.na(.))))  # NAs por columna
```

### Exploración estadística

```r
# Estadísticas por variable numérica
datos_ventas %>%
  select(where(is.numeric)) %>%
  summary()

# Estadísticas personalizadas
datos_ventas %>%
  summarise(
    ventas_min = min(ventas),
    ventas_q1 = quantile(ventas, 0.25),
    ventas_mediana = median(ventas),
    ventas_promedio = mean(ventas),
    ventas_q3 = quantile(ventas, 0.75),
    ventas_max = max(ventas),
    ventas_sd = sd(ventas),
    ventas_cv = sd(ventas) / mean(ventas)  # Coeficiente de variación
  )

# Por grupos
datos_ventas %>%
  group_by(region) %>%
  summarise(across(where(is.numeric), 
                   list(promedio = mean, mediana = median, sd = sd),
                   .names = "{.col}_{.fn}"))
```

---

## 🎮 Casos de uso avanzados - Lo vamos a ver en otra clase 

### Trabajando con fechas

```r
# Extraer componentes de fecha
datos_ventas %>%
  mutate(
    año = year(fecha),
    mes = month(fecha, label = TRUE, abbr = FALSE),
    dia = day(fecha),
    dia_semana = wday(fecha, label = TRUE),
    semana = week(fecha),
    trimestre = quarter(fecha),
    es_fin_de_semana = wday(fecha) %in% c(1, 7)
  )

# Operaciones con fechas
datos_ventas %>%
  mutate(
    dias_desde_primera_venta = as.numeric(fecha - min(fecha)),
    es_venta_reciente = fecha >= (max(fecha) - days(30))
  )
```

### Manejo de texto

```r
# Operaciones de string
datos_ventas %>%
  mutate(
    vendedor_limpio = str_trim(vendedor),          # Quitar espacios
    vendedor_lower = str_to_lower(vendedor),       # Minúsculas
    primera_letra = str_sub(vendedor, 1, 1),       # Primera letra
    longitud_nombre = str_length(vendedor),        # Largo del string
    contiene_r = str_detect(vendedor, "r")         # Detectar patrón
  )
```

### Operaciones across múltiples columnas

```r
# Aplicar la misma función a varias columnas
datos_ventas %>%
  summarise(across(where(is.character), n_distinct))  # Valores únicos de texto

datos_ventas %>%
  group_by(region) %>%
  summarise(across(where(is.numeric), mean))          # Promedio de numéricas

# Múltiples funciones a la vez
datos_ventas %>%
  group_by(region) %>%
  summarise(
    across(ventas, 
           list(suma = sum, promedio = mean, maximo = max),
           .names = "ventas_{.fn}")
  )
```

---

### Guardado de resultados

```r
# Guardar dataset procesado
resultado_final <- datos_ventas %>%
  group_by(region) %>%
  summarise(total = sum(ventas))

# Definir archivo de salida
archivo_salida <- "ventas_por_region_2024.csv"
ruta_salida <- file.path(outstub, archivo_salida)

# Guardar
write_csv(resultado_final, ruta_salida)
```

---

## ⚠️ Errores comunes y cómo evitarlos

### 1. Olvidar el pipe
```r
# ❌ Error común
datos_ventas
filter(ventas > 5000)  # No funciona, filter no sabe qué datos usar

# ✅ Correcto
datos_ventas %>%
  filter(ventas > 5000)
```

### 2. No desagrupar
```r
# ❌ Problemático
datos_agrupados <- datos_ventas %>%
  group_by(region) %>%
  summarise(total = sum(ventas))
# datos_agrupados sigue agrupado!

# ✅ Mejor práctica
datos_resumidos <- datos_ventas %>%
  group_by(region) %>%
  summarise(total = sum(ventas), .groups = 'drop')
```

### 3. Sobreescribir datos originales
```r
# ❌ Peligroso
datos_ventas <- datos_ventas %>%
  filter(ventas > 1000)  # Se perdieron las ventas <= 1000

# ✅ Recomendado  
datos_ventas_filtrados <- datos_ventas %>%
  filter(ventas > 1000)  # Original intacto
```

---

## 🏗️ Mejores prácticas de código

### Estilo de código legible

```r
# ✅ Código bien estructurado
resultado_final <- datos_ventas %>%
  # Paso 1: Filtrar período de interés
  filter(fecha >= as.Date("2024-01-01")) %>%
  
  # Paso 2: Crear variables necesarias
  mutate(
    trimestre = paste0("Q", quarter(fecha)),
    comision = ventas * 0.02
  ) %>%
  
  # Paso 3: Agrupar y resumir
  group_by(region, trimestre) %>%
  summarise(
    ventas_totales = sum(ventas),
    comision_total = sum(comision),
    num_ventas = n(),
    .groups = 'drop'
  ) %>%
  
  # Paso 4: Ordenar resultado
  arrange(trimestre, desc(ventas_totales))
```

### Nomenclatura consistente

```r
# ✅ Nombres descriptivos y consistentes
datos_ventas_q1 <- datos_ventas %>%
  filter(quarter(fecha) == 1)

resumen_por_vendedor <- datos_ventas %>%
  group_by(vendedor) %>%
  summarise(total_ventas = sum(ventas))

top_3_regiones <- datos_ventas %>%
  group_by(region) %>%
  summarise(ventas = sum(ventas)) %>%
  arrange(desc(ventas)) %>%
  slice_head(n = 3)
```

---

## 💻 Configuración específica por formato

### CSV y delimitados

```r
# Configuración específica para archivos CSV argentinos
archivo <- 'ventas_argentina.csv'

datos_csv_arg <- read_csv(
  file.path(instub, archivo),
  locale = locale(
    encoding = "UTF-8",           # Para caracteres especiales
    decimal_mark = ",",           # Coma decimal (Argentina)
    grouping_mark = "."           # Punto de miles
  ),
  na = c("", "NA", "NULL", "-", "n/a"),  # Valores que representan NA
  trim_ws = TRUE,                        # Quitar espacios extra
  show_col_types = FALSE                 # No mostrar tipos en consola
)

# Para archivos con problemas de encoding
archivo_latin <- 'datos_legacy.csv'
datos_latin <- read_csv(
  file.path(instub, archivo_latin),
  locale = locale(encoding = "latin1"),
  show_col_types = FALSE
)
```

### Excel avanzado

```r
# Explorar archivo Excel antes de cargar
archivo_excel <- 'ventas.xlsx'
ruta_excel <- file.path(instub, archivo_excel)

# Listar hojas disponibles
hojas <- excel_sheets(ruta_excel)
cat("Hojas disponibles:", paste(hojas, collapse = ", "), "\n")

# Información de cada hoja
for (hoja in hojas) {
  cat("\n=== HOJA:", hoja, "===\n")
  datos_estructura <- read_excel(ruta_excel, sheet = hoja, n_max = 0)  # Solo estructura
  cat("Columnas:", paste(names(datos_estructura), collapse = ", "), "\n")
}

# Cargar hoja específica con configuración
hoja_objetivo <- "Datos_2024"
datos_excel <- read_excel(
  ruta_excel,
  sheet = hoja_objetivo,
  skip = 2,                     # Saltar primeras 2 filas
  na = c("", "NA", "N/A", "-"),
  trim_ws = TRUE,
  guess_max = 1000             # Analizar más filas para determinar tipos
)
```

---

## 📈 Ejemplo integrado completo

```r
# === ANÁLISIS COMPLETO CON TIDYVERSE ===

# 1. CONFIGURACIÓN Y CARGA
library(tidyverse)

# Simular carga desde archivo (en la práctica sería read_csv)
datos_completos <- tibble(
  id_venta = 1:50,
  fecha_venta = seq(as.Date("2024-01-01"), as.Date("2024-03-15"), length.out = 50),
  vendedor = sample(c("García", "López", "Martín", "Silva", "Rodríguez"), 50, replace = TRUE),
  sucursal = sample(c("Centro", "Norte", "Sur", "Este"), 50, replace = TRUE),
  categoria = sample(c("Electrónicos", "Ropa", "Hogar", "Deportes"), 50, replace = TRUE),
  cantidad = sample(1:10, 50, replace = TRUE),
  precio_unitario = round(runif(50, 50, 500), 2),
  descuento_pct = sample(c(0, 5, 10, 15), 50, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
) %>%
  mutate(
    subtotal = cantidad * precio_unitario,
    descuento_monto = subtotal * (descuento_pct / 100),
    total_venta = subtotal - descuento_monto
  )

# 2. EXPLORACIÓN INICIAL
cat("=== EXPLORACIÓN DEL DATASET ===\n")
glimpse(datos_completos)

# Verificar calidad de datos
datos_completos %>%
  summarise(
    filas_totales = n(),
    across(everything(), ~ sum(is.na(.))),
    .names = "na_{.col}"
  )

# 3. ANÁLISIS MULTIDIMENSIONAL
analisis_ejecutivo <- datos_completos %>%
  # Crear variables de análisis
  mutate(
    mes = month(fecha_venta, label = TRUE),
    trimestre = paste0("Q", quarter(fecha_venta)),
    ticket_promedio = total_venta / cantidad,
    categoria_descuento = case_when(
      descuento_pct == 0 ~ "Sin descuento",
      descuento_pct <= 10 ~ "Descuento moderado", 
      TRUE ~ "Descuento alto"
    )
  ) %>%
  
  # Análisis por vendedor y sucursal
  group_by(vendedor, sucursal) %>%
  summarise(
    ventas_brutas = sum(subtotal),
    descuentos_otorgados = sum(descuento_monto),
    ventas_netas = sum(total_venta),
    transacciones = n(),
    ticket_promedio = round(mean(total_venta)),
    margen_descuento = round(100 * sum(descuento_monto) / sum(subtotal), 1),
    .groups = 'drop'
  ) %>%
  
  # Ranking y categorización
  mutate(
    eficiencia = round(ventas_netas / transacciones),
    ranking_ventas = dense_rank(desc(ventas_netas)),
    performance = case_when(
      ventas_netas >= quantile(ventas_netas, 0.8) ~ "Top 20%",
      ventas_netas >= quantile(ventas_netas, 0.6) ~ "Bueno", 
      ventas_netas >= quantile(ventas_netas, 0.4) ~ "Promedio",
      TRUE ~ "Bajo rendimiento"
    )
  ) %>%
  
  arrange(ranking_ventas)

print(analisis_ejecutivo)
```
