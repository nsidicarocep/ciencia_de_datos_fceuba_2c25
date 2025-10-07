# TRANSFORMACIONES DE VARIABLES PARA CIENCIA DE DATOS EN ECONOMÍA
# Ejemplo práctico: Análisis de cadena de retail

# Cargar librerías necesarias
library(tidyverse)
library(zoo)
library(DescTools)
library(MASS)
library(scales)

# Configuración para visualizaciones
theme_set(theme_minimal())

# 1. CREACIÓN DE DATASET SIMULADO #### 

set.seed(123)

# Dataset de sucursales y ventas mensuales (2 años)
n_sucursales <- 20
n_meses <- 24

datos_retail <- expand.grid(
  sucursal_id = 1:n_sucursales,
  mes = 1:n_meses
) %>%
  mutate(
    # Variables categóricas
    region = sample(c("Norte", "Sur", "Este", "Oeste"), n_sucursales, replace = TRUE)[sucursal_id],
    tamanio = sample(c("Pequeña", "Mediana", "Grande"), n_sucursales, replace = TRUE)[sucursal_id],
    
    # Fecha
    fecha = as.Date("2022-01-01") + months(mes - 1),
    
    # Ventas con tendencia, estacionalidad y ruido
    ventas_base = 50000 + (sucursal_id * 2000) + (mes * 500),
    estacionalidad = 10000 * sin(2 * pi * mes / 12),
    ventas_nominal = ventas_base + estacionalidad + rnorm(n(), 0, 5000),
    ventas_nominal = pmax(ventas_nominal, 10000), # Mínimo realista
    
    # Costos (70-80% de ventas)
    costos = ventas_nominal * runif(n(), 0.70, 0.80),
    
    # Número de empleados (correlacionado con tamaño)
    n_empleados = case_when(
      tamanio == "Pequeña" ~ rpois(n(), 8),
      tamanio == "Mediana" ~ rpois(n(), 15),
      tamanio == "Grande" ~ rpois(n(), 25)
    ),
    
    # Salarios promedio (con asimetría positiva)
    salario_promedio = case_when(
      tamanio == "Pequeña" ~ rlnorm(n(), log(35000), 0.3),
      tamanio == "Mediana" ~ rlnorm(n(), log(42000), 0.3),
      tamanio == "Grande" ~ rlnorm(n(), log(50000), 0.3)
    )
  )

# Crear índice de precios (IPC) simulado - inflación creciente
ipc_data <- data.frame(
  mes = 1:n_meses,
  fecha = seq(as.Date("2022-01-01"), by = "month", length.out = n_meses),
  ipc = 100 * (1.02)^((1:n_meses)/12) # 2% anual aproximado
)

# Unir con IPC
datos_retail <- datos_retail %>%
  left_join(ipc_data, by = c("mes", "fecha"))

# Introducir datos faltantes (5% aleatorio)
set.seed(456)
indices_faltantes <- sample(1:nrow(datos_retail), size = round(0.05 * nrow(datos_retail)))
datos_retail$ventas_nominal[indices_faltantes] <- NA

# Introducir algunos outliers (errores de datos + eventos reales)
set.seed(789)
# Outliers por error (ventas muy bajas)
datos_retail$ventas_nominal[sample(1:nrow(datos_retail), 3)] <-
  datos_retail$ventas_nominal[sample(1:nrow(datos_retail), 3)] * 0.1

# Outliers reales (campaña exitosa)
datos_retail$ventas_nominal[sample(1:nrow(datos_retail), 2)] <-
  datos_retail$ventas_nominal[sample(1:nrow(datos_retail), 2)] * 2.5

print("=== DATASET CREADO ===")
print(head(datos_retail))
print(paste("Dimensiones:", nrow(datos_retail), "filas x", ncol(datos_retail), "columnas"))
print(paste("Datos faltantes en ventas:", sum(is.na(datos_retail$ventas_nominal))))

# 2. ESTANDARIZACIÓN (Z-SCORE) #### 

cat("\n\n=== 2. ESTANDARIZACIÓN (Z-SCORE) ===\n")

# Visualización previo a estandarizar
datos_retail %>%
  dplyr::select(sucursal_id, mes, ventas_nominal, costos) %>%
  pivot_longer(cols = c(ventas_nominal, costos), names_to = "variable", values_to = "valor") %>%
  filter(!is.na(valor)) %>%
  ggplot(aes(x = valor, fill = variable)) +
  geom_density(alpha = 0.5) +
  labs(title = "Distribución No Estandarizada",
       subtitle = "Ventas y Costos en la misma escala",
       x = "Valor", y = "Densidad") +
  scale_fill_manual(values = c("blue", "red"),
                    labels = c("Costos", "Ventas"))

# Estandarizar ventas y costos para comparar
datos_retail <- datos_retail %>%
  mutate(
    ventas_std = scale(ventas_nominal)[,1],
    costos_std = scale(costos)[,1],
    salario_std = scale(salario_promedio)[,1]
  )

# Visualización
datos_retail %>%
  dplyr::select(sucursal_id, mes, ventas_std, costos_std) %>%
  pivot_longer(cols = c(ventas_std, costos_std), names_to = "variable", values_to = "valor") %>%
  filter(!is.na(valor)) %>%
  ggplot(aes(x = valor, fill = variable)) +
  geom_density(alpha = 0.5) +
  labs(title = "Distribución Estandarizada (Z-score)",
       subtitle = "Ventas y Costos en la misma escala",
       x = "Z-score", y = "Densidad") +
  scale_fill_manual(values = c("blue", "red"),
                    labels = c("Costos", "Ventas"))

# 3. MIN-MAX SCALING (NORMALIZACIÓN) ####

# Normalizar a rango [0,1]
minmax_fun <- function(x){
  (x - min(x,na.rm=T)) / (max(x,na.rm=T)-min(x,na.rm=T))
}
datos_retail <- datos_retail %>%
  mutate(
    ventas_minmax = (ventas_nominal - min(ventas_nominal, na.rm = TRUE)) /
      (max(ventas_nominal, na.rm = TRUE) - min(ventas_nominal, na.rm = TRUE)),
    salario_minmax = (salario_promedio - min(salario_promedio)) /
      (max(salario_promedio) - min(salario_promedio)),
    ventas_minmax_con_f = minmax_fun(ventas_nominal),
    salario_minmax_con_f = minmax_fun(salario_promedio)
  )

print(head(datos_retail,20))

cat("Rango ventas normalizadas: [",
    round(min(datos_retail$ventas_minmax, na.rm = TRUE), 3), ",",
    round(max(datos_retail$ventas_minmax, na.rm = TRUE), 3), "]\n")

# 4. DETECCIÓN DE OUTLIERS ####

cat("\n\n=== 4. DETECCIÓN DE OUTLIERS ===\n")

# A) Método IQR (Rango Intercuartílico)
Q1 <- quantile(datos_retail$ventas_nominal, 0.25, na.rm = TRUE)
Q3 <- quantile(datos_retail$ventas_nominal, 0.75, na.rm = TRUE)
IQR_val <- Q3 - Q1

limite_inferior <- Q1 - 1.5 * IQR_val
limite_superior <- Q3 + 1.5 * IQR_val

datos_retail <- datos_retail %>%
  mutate(
    outlier_iqr = !is.na(ventas_nominal) &
      (ventas_nominal < limite_inferior | ventas_nominal > limite_superior)
  )

cat("Método IQR:\n")
cat("  Q1:", round(Q1), "| Q3:", round(Q3), "| IQR:", round(IQR_val), "\n")
cat("  Límites: [", round(limite_inferior), ",", round(limite_superior), "]\n")
cat("  Outliers detectados:", sum(datos_retail$outlier_iqr, na.rm = TRUE), "\n")

# B) Método Z-score
datos_retail <- datos_retail %>%
  mutate(
    z_ventas = scale(ventas_nominal)[,1],
    outlier_zscore = !is.na(z_ventas) & abs(z_ventas) > 3
  )

cat("\nMétodo Z-score (|Z| > 3):\n")
cat("  Outliers detectados:", sum(datos_retail$outlier_zscore, na.rm = TRUE), "\n")

# Visualización de outliers
datos_retail %>%
  filter(!is.na(ventas_nominal)) %>%
  ggplot(aes(x = mes, y = ventas_nominal, color = outlier_iqr)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = c(limite_inferior, limite_superior),
             linetype = "dashed", color = "red") +
  labs(title = "Detección de Outliers - Método IQR",
       subtitle = "Ventas mensuales por sucursal",
       x = "Mes", y = "Ventas Nominales",
       color = "Outlier") +
  scale_color_manual(values = c("FALSE" = "steelblue", "TRUE" = "red"))

# 5. TRATAMIENTO DE OUTLIERS ####

cat("\n\n=== 5. TRATAMIENTO DE OUTLIERS ===\n")

# A) Winsorización (recomendado)
datos_retail <- datos_retail %>%
  dplyr::mutate(
    ventas_winsorized = Winsorize(ventas_nominal, quantile(ventas_nominal,probs = c(0.01, 0.99), na.rm = TRUE))
  )

cat("Winsorización (percentiles 1% y 99%):\n")
cat("  Ventas originales - Rango: [", round(min(datos_retail$ventas_nominal, na.rm = TRUE)), ",",
    round(max(datos_retail$ventas_nominal, na.rm = TRUE)), "]\n")
cat("  Ventas winsorized - Rango: [", round(min(datos_retail$ventas_winsorized, na.rm = TRUE)), ",",
    round(max(datos_retail$ventas_winsorized, na.rm = TRUE)), "]\n")

# B) Crear dummy para outliers (mantener información)
datos_retail <- datos_retail %>%
  mutate(
    dummy_outlier = as.numeric(outlier_iqr)
  )

cat("\nDummy para outliers creada (para usar en regresiones)\n")

# Veamos como cambia el promedio luego de la winsorizacion
t1 <- datos_retail %>% 
  group_by(sucursal_id) %>% 
  summarize(promedio_ventas = mean(ventas_nominal,na.rm=T),
            promedio_ventas_win = mean(ventas_winsorized,na.rm=T),
            desvio_ventas = sd(ventas_nominal,na.rm=T),
            desvio_ventas_win = sd(ventas_winsorized,na.rm=T),
            coeficiente_dispersion = sd(ventas_nominal,na.rm=T) / mean(ventas_nominal,na.rm=T),
            coeficiente_dispersion_win = sd(ventas_winsorized,na.rm=T) / mean(ventas_winsorized,na.rm=T))
View(t1)

# Veamos que hay sucursales que no se vieron afectadas. 
# ¿Deberiamos hacer el recorte por sucursal o en general? Depende


################################################################################
# 7. TRANSFORMACIÓN LOGARÍTMICA Y TASAS DE CRECIMIENTO
################################################################################

cat("\n\n=== 7. TRANSFORMACIÓN LOGARÍTMICA ===\n")

# Logaritmo de ventas y salarios
datos_retail <- datos_retail %>%
  mutate(
    log_ventas = log(ventas_nominal),
    log_salario = log(salario_promedio),
    log_costos = log(costos)
  )

# Calcular tasa de crecimiento (diferencia de logs)
datos_retail <- datos_retail %>%
  group_by(sucursal_id) %>%
  arrange(mes) %>%
  mutate(
    tasa_crecimiento_ventas = (log_ventas - lag(log_ventas)) * 100, # En porcentaje
    # Comparar con método directo
    tasa_crecimiento_directa = ((ventas_nominal - lag(ventas_nominal)) /
                                  lag(ventas_nominal)) * 100
  ) %>%
  ungroup()

cat("Tasa de crecimiento promedio (método log):",
    round(mean(datos_retail$tasa_crecimiento_ventas, na.rm = TRUE), 2), "%\n")
cat("Tasa de crecimiento promedio (método directo):",
    round(mean(datos_retail$tasa_crecimiento_directa, na.rm = TRUE), 2), "%\n")

# Visualización: Original vs Log
par(mfrow = c(1, 2))
hist(datos_retail$ventas_interpolada, main = "Ventas Originales",
     xlab = "Ventas", col = "steelblue", breaks = 30)
hist(datos_retail$log_ventas, main = "Log(Ventas)",
     xlab = "Log(Ventas)", col = "coral", breaks = 30)
par(mfrow = c(1, 1))
