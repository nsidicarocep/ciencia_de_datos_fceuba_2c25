# =============================================================================
# INTERPOLACIÓN DE DATOS CENSALES: POBLACIÓN DE ARGENTINA
# Diferentes métodos para completar años intercensales
# =============================================================================

# Cargar librerías necesarias
library(tidyverse)
library(zoo)        # Para interpolación
library(scales)     # Para formateo de números

# =============================================================================
# 1. DATOS CENSALES REALES DE ARGENTINA (SIMULADOS REALISTAS)
# =============================================================================

# Crear datos censales cada 10 años (1970-2020)
# Basados en datos históricos aproximados de Argentina
censo_original <- tibble(
  año = seq(1970, 2020, by = 10),
  poblacion = c(
    23962000,   # 1970
    28094000,   # 1980
    32616000,   # 1990
    36260000,   # 2001
    40518000,   # 2010
    46044703    # 2020 (último censo real ajustado)
  ),
  fuente = "Censo Nacional"
)

print("=== DATOS CENSALES ORIGINALES (cada 10 años) ===")
print(censo_original)

# Calcular tasas de crecimiento intercensales reales
censo_original <- censo_original %>%
  mutate(
    tasa_crecimiento_decenal = ((poblacion / lag(poblacion))^(1/10) - 1) * 100,
    aumento_absoluto = poblacion - lag(poblacion),
    aumento_anual_promedio = aumento_absoluto / 10
  )

print("\n=== TASAS DE CRECIMIENTO INTERCENSALES ===")
print(censo_original %>% 
        dplyr::select(año, poblacion, tasa_crecimiento_decenal, aumento_anual_promedio) %>%
        mutate(across(where(is.numeric), ~round(.x, 2))))

# =============================================================================
# 2. MÉTODO 1: INTERPOLACIÓN LINEAL
# Asume aumento constante absoluto cada año
# =============================================================================

interpolacion_lineal <- censo_original %>%
  dplyr::select(año, poblacion) %>%
  # Crear serie completa de años
  complete(año = full_seq(año, 1)) %>%
  # Interpolación lineal: conexión recta entre censos
  mutate(
    poblacion_lineal = approx(año, poblacion, año, method = "linear")$y,
    metodo = "Lineal"
  )

print("\n=== MÉTODO 1: INTERPOLACIÓN LINEAL ===")
print("Asume incremento absoluto constante cada año")
print(interpolacion_lineal %>% 
        filter(año >= 2010, año <= 2020) %>%
        mutate(poblacion_lineal = round(poblacion_lineal, 0)))

# =============================================================================
# 3. MÉTODO 2: INTERPOLACIÓN EXPONENCIAL (GEOMÉTRICA)
# Asume tasa de crecimiento constante (más realista demográficamente)
# =============================================================================

interpolacion_exponencial <- censo_original %>%
  dplyr::select(año, poblacion) %>%
  mutate(log_poblacion = log(poblacion)) %>%
  complete(año = full_seq(año, 1)) %>%
  # Interpolar en escala logarítmica
  mutate(
    log_poblacion_interp = approx(año, log_poblacion, año, method = "linear")$y,
    poblacion_exponencial = exp(log_poblacion_interp),
    metodo = "Exponencial (tasa constante)"
  )

print("\n=== MÉTODO 2: INTERPOLACIÓN EXPONENCIAL ===")
print("Asume tasa de crecimiento porcentual constante")
print(interpolacion_exponencial %>% 
        filter(año >= 2010, año <= 2020) %>%
        dplyr::select(año, poblacion, poblacion_exponencial) %>%
        mutate(across(where(is.numeric), ~round(.x, 0))) %>% 
        mutate(diferencia = poblacion_exponencial - lag(poblacion_exponencial)))

# =============================================================================
# 4. MÉTODO 3: INTERPOLACIÓN LOGÍSTICA
# Tasa alta al principio, se desacelera hacia el final del período
# Simula el comportamiento demográfico más realista: transición demográfica
# =============================================================================

interpolacion_logistica <- function(t, P0, P1, k = 0.5) {
  # P0: población inicial
  # P1: población final
  # t: tiempo transcurrido (0 a 1)
  # k: parámetro de curvatura (mayor = más curvatura)
  
  # Función logística normalizada
  logistic <- function(x) 1 / (1 + exp(-k * (x - 0.5)))
  
  # Normalizar para que vaya de 0 a 1
  t_norm <- (logistic(t) - logistic(0)) / (logistic(1) - logistic(0))
  
  # Interpolar
  P0 + (P1 - P0) * t_norm
}

# Aplicar interpolación logística entre cada par de censos
crear_interpolacion_logistica <- function(df) {
  # Ordenar por año
  df <- df %>% arrange(año)
  
  resultado <- tibble()
  
  for (i in 1:(nrow(df) - 1)) {
    año_inicio <- df$año[i]
    año_fin <- df$año[i + 1]
    pob_inicio <- df$poblacion[i]
    pob_fin <- df$poblacion[i + 1]
    
    años_intermedios <- seq(año_inicio, año_fin, by = 1)
    t_valores <- (años_intermedios - año_inicio) / (año_fin - año_inicio)
    
    segmento <- tibble(
      año = años_intermedios,
      poblacion_logistica = interpolacion_logistica(t_valores, pob_inicio, pob_fin, k = 8)
    )
    
    resultado <- bind_rows(resultado, segmento)
  }
  
  # Eliminar duplicados (últimos de cada segmento)
  resultado %>% distinct(año, .keep_all = TRUE)
}

datos_logistica <- crear_interpolacion_logistica(censo_original %>% dplyr::select(año, poblacion))

print("\n=== MÉTODO 3: INTERPOLACIÓN LOGÍSTICA ===")
print("Crecimiento rápido al inicio, se desacelera al final")
print(datos_logistica %>% 
        filter(año >= 2010, año <= 2020) %>%
        mutate(poblacion_logistica = round(poblacion_logistica, 0)) %>% 
        mutate(diferencia = poblacion_logistica - lag(poblacion_logistica)))


# =============================================================================
# 5. MÉTODO 4: INTERPOLACIÓN SPLINE CÚBICA
# Curva suave que pasa por todos los puntos censales
# =============================================================================

interpolacion_spline <- censo_original %>%
  dplyr::select(año, poblacion) %>%
  complete(año = full_seq(año, 1)) %>%
  mutate(
    poblacion_spline = spline(censo_original$año, 
                              censo_original$poblacion, 
                              xout = año, 
                              method = "natural")$y,
    metodo = "Spline cúbica"
  )

print("\n=== MÉTODO 4: INTERPOLACIÓN SPLINE ===")
print("Curva suave entre censos")
print(interpolacion_spline %>% 
        filter(año >= 2010, año <= 2020) %>%
        dplyr::select(año, poblacion, poblacion_spline) %>%
        mutate(across(where(is.numeric), ~round(.x, 0)))%>% 
        mutate(diferencia = poblacion_spline - lag(poblacion_spline)))

# =============================================================================
# 6. MÉTODO 5: LAST OBSERVATION CARRIED FORWARD (LOCF)
# Mantiene valor del último censo hasta el próximo (no recomendado)
# =============================================================================

interpolacion_locf <- censo_original %>%
  dplyr::select(año, poblacion) %>%
  complete(año = full_seq(año, 1)) %>%
  mutate(
    poblacion_locf = na.locf(poblacion, na.rm = FALSE),
    metodo = "LOCF (Last Observation Carried Forward)"
  )

print("\n=== MÉTODO 5: LOCF (no recomendado para población) ===")
print(interpolacion_locf %>% 
        filter(año >= 2010, año <= 2020) %>%
        dplyr::select(año, poblacion, poblacion_locf))

# =============================================================================
# 7. MÉTODO 6: INTERPOLACIÓN CON TASA VARIABLE
# Usa información de cambios en tasas de crecimiento
# =============================================================================

# Calcular tasas de crecimiento entre censos
tasas_intercensales <- censo_original %>%
  filter(!is.na(tasa_crecimiento_decenal)) %>%
  dplyr::select(año, tasa_crecimiento_decenal)

# Interpolar las tasas de crecimiento
interpolacion_tasa_variable <- censo_original %>%
  dplyr::select(año, poblacion) %>%
  complete(año = full_seq(año, 1)) %>%
  left_join(tasas_intercensales, by = "año") %>%
  # Interpolar las tasas
  mutate(
    tasa_interpolada = approx(tasas_intercensales$año, 
                              tasas_intercensales$tasa_crecimiento_decenal, 
                              año, method = "linear")$y
  )

# Calcular población aplicando tasas interpoladas
interpolacion_tasa_variable$poblacion_tasa_variable <- NA
interpolacion_tasa_variable$poblacion_tasa_variable[1] <- censo_original$poblacion[1]

for (i in 2:nrow(interpolacion_tasa_variable)) {
  if (!is.na(interpolacion_tasa_variable$poblacion[i])) {
    # Si es año censal, usar dato real
    interpolacion_tasa_variable$poblacion_tasa_variable[i] <- 
      interpolacion_tasa_variable$poblacion[i]
  } else {
    # Aplicar tasa de crecimiento interpolada
    interpolacion_tasa_variable$poblacion_tasa_variable[i] <- 
      interpolacion_tasa_variable$poblacion_tasa_variable[i-1] * 
      (1 + interpolacion_tasa_variable$tasa_interpolada[i]/100)
  }
}

print("\n=== MÉTODO 6: INTERPOLACIÓN CON TASA VARIABLE ===")
print("Usa interpolación de tasas de crecimiento entre censos")
print(interpolacion_tasa_variable %>% 
        filter(año >= 2010, año <= 2020) %>%
        dplyr::select(año, poblacion, tasa_interpolada, poblacion_tasa_variable) %>%
        mutate(across(where(is.numeric), ~round(.x, 2))))

# =============================================================================
# 8. CONSOLIDAR TODOS LOS MÉTODOS EN UN DATASET
# =============================================================================

comparacion_completa <- censo_original %>%
  dplyr::select(año, poblacion) %>%
  complete(año = full_seq(año, 1)) %>%
  left_join(interpolacion_lineal %>% dplyr::select(año, poblacion_lineal), by = "año") %>%
  left_join(interpolacion_exponencial %>% dplyr::select(año, poblacion_exponencial), by = "año") %>%
  left_join(datos_logistica, by = "año") %>%
  left_join(interpolacion_spline %>% dplyr::select(año, poblacion_spline), by = "año") %>%
  left_join(interpolacion_locf %>% dplyr::select(año, poblacion_locf), by = "año") %>%
  left_join(interpolacion_tasa_variable %>% dplyr::select(año, poblacion_tasa_variable), by = "año") %>%
  # Renombrar para clarity
  rename(
    censo_real = poblacion,
    `1_Lineal` = poblacion_lineal,
    `2_Exponencial` = poblacion_exponencial,
    `3_Logística` = poblacion_logistica,
    `4_Spline` = poblacion_spline,
    `5_LOCF` = poblacion_locf,
    `6_Tasa_Variable` = poblacion_tasa_variable
  )

# =============================================================================
# 9. ANÁLISIS COMPARATIVO: PERÍODO 2010-2020
# =============================================================================

print("\n=== COMPARACIÓN DETALLADA: PERÍODO 2010-2020 ===")
comparacion_2010_2020 <- comparacion_completa %>%
  filter(año >= 2010, año <= 2020) %>%
  mutate(across(where(is.numeric), ~round(.x, 0)))

print(comparacion_2010_2020)

# Calcular diferencias respecto al método exponencial (más usado demográficamente)
diferencias <- comparacion_2010_2020 %>%
  filter(año == 2015) %>%  # Año medio del período
  pivot_longer(cols = starts_with(c("1_", "2_", "3_", "4_", "5_", "6_")), 
               names_to = "metodo", 
               values_to = "poblacion_2015") %>%
  mutate(
    diferencia_vs_exponencial = poblacion_2015 - first(poblacion_2015[metodo == "2_Exponencial"]),
    diferencia_porcentual = (diferencia_vs_exponencial / first(poblacion_2015[metodo == "2_Exponencial"])) * 100
  )

print("\n=== DIFERENCIAS EN 2015 (año medio) vs Método Exponencial ===")
print(diferencias %>% 
        dplyr::select(metodo, poblacion_2015, diferencia_vs_exponencial, diferencia_porcentual) %>%
        mutate(across(where(is.numeric), ~round(.x, 2))))

