# ============================================================================
# PIVOTS EN ANÁLISIS ECONÓMICO
# pivot_longer() y pivot_wider() para reestructuración de datos
# ============================================================================

library(tidyverse)

# ============================================================================
# DATOS DE EJEMPLO: FORMATOS TÍPICOS EN ECONOMÍA
# ============================================================================

# PROBLEMA TÍPICO 1: Datos "anchos" de inflación anual por país
inflacion_ancha <- tibble(
  pais = c("Argentina", "Brasil", "Chile", "Colombia", "México", "Perú"),
  `2020` = c(36.1, 3.2, 3.0, 2.5, 3.4, 1.8),
  `2021` = c(48.4, 8.3, 4.5, 5.6, 5.7, 4.0),
  `2022` = c(72.4, 9.3, 11.6, 10.2, 7.8, 7.9),
  `2023` = c(133.0, 4.6, 7.6, 13.1, 4.7, 1.3)
)

# PROBLEMA TÍPICO 2: PIB trimestral en formato ancho
pib_trimestral_ancho <- tibble(
  pais = c("Argentina", "Brasil", "Chile"),
  region = c("América del Sur", "América del Sur", "América del Sur"),
  `2023_Q1` = c(148.2, 525.8, 78.4),
  `2023_Q2` = c(151.7, 532.1, 79.8),
  `2023_Q3` = c(147.9, 529.3, 81.2),
  `2023_Q4` = c(152.4, 538.7, 82.1)
)

# DATOS YA EN FORMATO LARGO (para ejemplos de pivot_wider)
comercio_bilateral <- tibble(
  pais_exportador = rep(c("Argentina", "Brasil", "Chile"), each = 6),
  pais_importador = rep(c("Brasil", "Chile", "México", "Brasil", "Argentina", "México"), 3),
  año = rep(c(2022, 2022, 2022, 2023, 2023, 2023), 3),
  valor_millones_usd = c(
    # Argentina exports
    1250, 890, 450, 1180, 920, 480,
    # Brasil exports  
    2100, 1800, 2200, 2250, 1950, 2350,
    # Chile exports
    980, 750, 1100, 1020, 800, 1150
  )
)

print("=== DATOS ORIGINALES ===")
print("Inflación por país (formato ANCHO - problemático):")
print(inflacion_ancha)

print("\nPIB trimestral (formato ANCHO - problemático):")
print(pib_trimestral_ancho)

print("\nComercio bilateral (formato LARGO - ideal):")
print(comercio_bilateral %>% head(9))

# ============================================================================
# 1. PIVOT_LONGER(): DE ANCHO A LARGO
# ============================================================================

cat("\n=== PIVOT_LONGER: Convertir datos anchos a largos ===\n")

# CASO 1: Inflación - años como columnas → variable temporal
inflacion_larga <- inflacion_ancha %>%
  tidyr::pivot_longer(
    cols = `2020`:`2023`,           # Columnas a convertir
    # cols = -pais,                 # Columnas que no se convierten 
    names_to = "anio",               # Nombre de la nueva columna
    values_to = "inflacion",        # Nombre de la columna de valores
    names_transform = list(anio = as.numeric)  # Convertir años a numérico
  )

print("Inflación convertida a formato largo:")
print(inflacion_larga %>% head(12))

# Ahora podemos hacer análisis que antes eran imposibles
cat("\nAnálisis ahora posibles:\n")

# Inflación promedio por año
inflacion_por_año <- inflacion_larga %>%
  group_by(anio) %>%
  summarise(inflacion_regional = mean(inflacion), .groups = "drop") # ungroup()
print("Inflación promedio regional por año:")
print(inflacion_por_año)

# País con mayor volatilidad
volatilidad_por_pais <- inflacion_larga %>%
  group_by(pais) %>%
  summarise(
    volatilidad = sd(inflacion),
    inflacion_promedio = mean(inflacion),
    .groups = "drop"
  ) %>%
  arrange(desc(volatilidad))
print("Volatilidad inflacionaria por país:")
print(volatilidad_por_pais)

# CASO 2: PIB trimestral - columnas complejas con separador
pib_largo <- pib_trimestral_ancho %>%
  pivot_longer(
    cols = starts_with("2023_"),
    names_to = c("anio", "trimestre"),
    names_sep = "_",                # Separar por guión bajo
    values_to = "pib_nominal"
  ) %>%
  mutate(
    anio = as.numeric(anio),
    trimestre_num = as.numeric(str_extract(trimestre, "\\d"))
  )

print("PIB trimestral en formato largo:")
print(pib_largo)

# Análisis estacional ahora posible
estacionalidad_pib <- pib_largo %>%
  group_by(trimestre) %>%
  summarise(
    pib_promedio = mean(pib_nominal),
    n_paises = n(),
    .groups = "drop"
  )
print("Análisis estacional del PIB:")
print(estacionalidad_pib)

# CASO 3: Datos con múltiples variables
indicadores_multiples <- tibble(
  pais = c("Argentina", "Brasil", "Chile"),
  pib_2022 = c(487.2, 2126.8, 317.1),
  pib_2023 = c(487.0, 2174.0, 335.5),
  inflacion_2022 = c(72.4, 9.3, 11.6),
  inflacion_2023 = c(133.0, 4.6, 7.6),
  desempleo_2022 = c(6.9, 9.3, 7.9),
  desempleo_2023 = c(5.7, 7.9, 7.6)
)

# Pivot con múltiples variables
indicadores_largos <- indicadores_multiples %>%
  pivot_longer(
    cols = -pais, # Dejar fija 
    names_to = c("indicador", "anio"),
    names_sep = "_",
    values_to = "valor"
  ) %>%
  mutate(anio = as.numeric(anio))

print("Múltiples indicadores en formato largo:")
print(indicadores_largos %>% arrange(pais, anio, indicador))

# ============================================================================
# 2. PIVOT_WIDER(): DE LARGO A ANCHO
# ============================================================================

cat("\n=== PIVOT_WIDER: Convertir datos largos a anchos ===\n")

# CASO 1: Crear matriz de comercio bilateral
matriz_comercio_2023 <- comercio_bilateral %>%
  filter(año == 2023) %>%
  pivot_wider(
    names_from = pais_importador,
    values_from = valor_millones_usd,
    values_fill = 0  # Llenar con 0 donde no hay comercio
  )

print("Matriz de comercio bilateral 2023:")
print(matriz_comercio_2023)

# CASO 2: Comparación año a año (antes vs después)
comparacion_anual <- comercio_bilateral %>%
  group_by(pais_exportador, pais_importador) %>%
  summarise(
    total_comercio = sum(valor_millones_usd),
    .groups = "drop"
  ) %>%
  # Agregar datos históricos para comparación
  bind_rows(
    tibble(
      pais_exportador = rep(c("Argentina", "Brasil", "Chile"), each = 3),
      pais_importador = rep(c("Brasil", "Chile", "México"), 3),
      total_comercio = c(1890, 1650, 720, 3200, 2850, 3400, 1480, 1100, 1680)
    ) %>%
    mutate(periodo = "2021-2022")
  ) %>%
  mutate(periodo = if_else(is.na(periodo), "2022-2023", periodo)) %>%
  pivot_wider(
    names_from = periodo,
    values_from = total_comercio
  ) %>%
  mutate(
    crecimiento_comercio = ((`2022-2023` / `2021-2022`) - 1) * 100
  )

print("Comparación de comercio bilateral:")
print(comparacion_anual %>% 
  mutate(crecimiento_comercio = round(crecimiento_comercio, 1)))

# CASO 3: Dashboard de indicadores por país
dashboard_paises <- inflacion_larga %>%
  group_by(pais) %>%
  summarise(
    inflacion_promedio = mean(inflacion),
    inflacion_2023 = inflacion[anio == 2023],
    .groups = "drop"
  ) %>%
  # Agregar otros indicadores
  left_join(
    tibble(
      pais = c("Argentina", "Brasil", "Chile", "Colombia", "México", "Perú"),
      pib_percapita = c(10423, 8897, 16265, 6131, 9926, 6692),
      desempleo = c(5.7, 7.9, 7.6, 10.1, 2.8, 7.2)
    ),
    by = "pais"
  ) %>%
  # Crear formato largo primero
  pivot_longer(
    cols = c(inflacion_promedio, inflacion_2023, pib_percapita, desempleo),
    names_to = "indicador",
    values_to = "valor"
  ) %>%
  # Luego a formato ancho por país
  pivot_wider(
    names_from = pais,
    values_from = valor
  )

print("Dashboard de indicadores (países como columnas):")
print(dashboard_paises %>% 
  mutate(across(where(is.numeric), ~round(.x, 1))))

# ============================================================================
# 3. CASOS AVANZADOS: PIVOTS COMPLEJOS
# ============================================================================

cat("\n=== CASOS AVANZADOS: Pivots complejos ===\n")

# CASO 1: Múltiples columnas de valores
datos_complejos <- tibble(
  pais = rep(c("Argentina", "Brasil"), each = 4),
  año = rep(2020:2023, 2),
  pib_nominal = c(450, 420, 487, 487, 1800, 1910, 2127, 2174),
  pib_real = c(380, 350, 365, 368, 1650, 1680, 1720, 1750),
  poblacion = c(45.2, 45.4, 45.8, 46.2, 212, 214, 215, 216)
)

# Pivot con múltiples columnas de valores
datos_anchos_multiples <- datos_complejos %>%
  pivot_wider(
    names_from = año,
    values_from = c(pib_nominal, pib_real, poblacion),
    names_sep = "_"
  )

print("Pivot con múltiples columnas de valores:")
print(datos_anchos_multiples)

# CASO 2: Pivot con funciones de agregación
comercio_agregado <- comercio_bilateral %>%
  # Agregar totales por región
  mutate(
    region_exportador = case_when(
      pais_exportador %in% c("Argentina", "Brasil", "Chile") ~ "Cono Sur",
      TRUE ~ "Otros"
    )
  ) %>%
  group_by(region_exportador,pais_exportador, pais_importador, año) %>%
  summarise(total_exportaciones = sum(valor_millones_usd), .groups = "drop") %>%
  select(-pais_exportador) %>% 
  pivot_wider(
    names_from = año,
    values_from = total_exportaciones,
    values_fn = sum,  # Función de agregación en caso de duplicados
    values_fill = 0
  )

print("Exportaciones agregadas por región:")
print(comercio_agregado)

# ============================================================================
# 4. FLUJO COMPLETO: LARGO → ANCHO → LARGO
# ============================================================================

cat("\n=== FLUJO COMPLETO: Transformaciones múltiples ===\n")

# Partir de datos largos, crear reporte ancho, volver a formato largo
flujo_completo <- inflacion_larga %>%
  # 1. De largo a ancho (para reporte)
  pivot_wider(
    names_from = año,
    values_from = inflacion,
    names_prefix = "año_"
  ) %>%
  # Agregar estadísticas de resumen
  mutate(
    promedio_periodo = (`año_2020` + `año_2021` + `año_2022` + `año_2023`) / 4,
    variacion_total = `año_2023` - `año_2020`,
    categoria = case_when(
      `año_2023` > 50 ~ "Alta inflación",
      `año_2023` > 10 ~ "Inflación moderada",
      TRUE ~ "Baja inflación"
    )
  ) %>%
  # 2. Volver a formato largo para análisis
  pivot_longer(
    cols = starts_with("año_"),
    names_to = "año",
    values_to = "inflacion",
    names_prefix = "año_"
  ) %>%
  mutate(año = as.numeric(año))

print("Flujo completo (largo → ancho → largo):")
print(flujo_completo %>% 
  select(pais, año, inflacion, promedio_periodo, categoria) %>%
  head(12))

# ============================================================================
# 5. PROBLEMAS COMUNES Y SOLUCIONES
# ============================================================================

cat("\n=== PROBLEMAS COMUNES Y SOLUCIONES ===\n")

# PROBLEMA 1: Datos faltantes en pivot_wider
datos_con_na <- tibble(
  pais = c("Argentina", "Argentina", "Brasil", "Chile", "Chile"),
  año = c(2022, 2023, 2022, 2022, 2023),
  inflacion = c(72.4, 133.0, 9.3, 11.6, 7.6)  # Brasil 2023 faltante
)

# Sin valores_fill (genera NA)
pivot_con_na <- datos_con_na %>%
  pivot_wider(names_from = año, values_from = inflacion)

print("Problema: NAs en pivot_wider")
print(pivot_con_na)

# Solución: usar values_fill
pivot_sin_na <- datos_con_na %>%
  pivot_wider(
    names_from = año, 
    values_from = inflacion,
    values_fill = 0  # O el valor apropiado
  )

print("Solución: values_fill para llenar NAs")
print(pivot_sin_na)

# PROBLEMA 2: Nombres de columnas problemáticos
datos_nombres_problematicos <- tibble(
  pais = c("Argentina", "Brasil"),
  `2023-Q1` = c(30.1, 1.2),  # Nombres con caracteres especiales
  `2023-Q2` = c(35.4, 1.8)
)

# datos_nombres_problematicos <- janitor::clean_names(datos_nombres_problematicos)

# Solución: usar names_repair o limpiar nombres
pivot_nombres_limpios <- datos_nombres_problematicos %>%
  pivot_longer(
    cols = -pais,
    names_to = "periodo",
    values_to = "inflacion"
  ) %>%
  mutate(
    # Limpiar nombres de períodos
    año = as.numeric(str_extract(periodo, "\\d{4}")),
    trimestre = str_extract(periodo, "Q\\d")
  )

print("Solución: limpiar nombres problemáticos")
print(pivot_nombres_limpios)

# PROBLEMA 3: Múltiples observaciones por celda
datos_duplicados <- tibble(
  pais = c("Argentina", "Argentina", "Brasil"),
  año = c(2023, 2023, 2023),  # Argentina duplicada
  inflacion = c(130.0, 136.0, 4.6)
)

# Solución: agregación explícita antes del pivot
pivot_con_agregacion <- datos_duplicados %>%
  group_by(pais, año) %>%
  summarise(inflacion = mean(inflacion), .groups = "drop") %>%  # Promedio
  pivot_wider(names_from = año, values_from = inflacion)

print("Solución: agregación antes de pivot")
print(pivot_con_agregacion)