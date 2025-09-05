# ============================================================================
# JOINS EN ANÁLISIS ECONÓMICO: INTEGRANDO FUENTES DE DATOS
# inner_join(), left_join(), full_join() y casos de uso reales
# ============================================================================

library(tidyverse)

# ============================================================================
# SIMULACIÓN DE DATOS DE DIFERENTES FUENTES INSTITUCIONALES
# ============================================================================

# DATOS DEL "INDEC" (de institutos de estadistica en realidad) : Información demográfica y PIB
indec <- tibble(
  codigo_pais = c("ARG", "BRA", "CHL", "COL", "MEX", "PER", "URY"),
  pais = c("Argentina", "Brasil", "Chile", "Colombia", "México", "Perú", "Uruguay"),
  poblacion_2023 = c(46.2, 216.4, 19.6, 52.1, 130.2, 33.7, 3.4),
  pib_percapita_usd = c(10423, 8897, 16265, 6131, 9926, 6692, 17278),
  superficie_km2 = c(2780400, 8514877, 756096, 1141748, 1964375, 1285216, 176215)
)

# DATOS DEL BANCO CENTRAL: Variables monetarias y financieras  
banco_central <- tibble(
  pais_codigo = c("ARG", "BRA", "CHL", "PER", "ECU"),  # ECU no está en INDEC
  tasa_politica = c(133.0, 11.75, 11.25, 7.75, 5.5),
  reservas_usd_mm = c(21500, 355000, 25800, 68500, 7200),
  inflacion_2023 = c(211.4, 4.6, 7.6, 8.5, 2.3),
  tipo_cambio = c(890.5, 4.9, 890.2, 3.7, 25000)
)

# DATOS DEL MINISTERIO DE TRABAJO: Empleo y salarios
trabajo <- tibble(
  iso_pais = c("ARG", "BRA", "CHL", "COL", "BOL"),  # BOL no está en otras fuentes
  desempleo_pct = c(5.7, 7.9, 7.6, 10.1, 4.1),
  salario_minimo_usd = c(280, 240, 420, 260, 310),
  empleo_formal_pct = c(48.5, 62.3, 69.8, 51.2, 28.9),
  horas_promedio = c(42, 44, 45, 48, 46)
)

# DATOS DE COMERCIO EXTERIOR: Exportaciones e importaciones
comercio <- tibble(
  pais_iso = c("ARG", "BRA", "CHL", "COL", "MEX", "PER"),
  exportaciones_usd_mm = c(89000, 334000, 95000, 56000, 593000, 63000),
  importaciones_usd_mm = c(76000, 248000, 87000, 73000, 505000, 55000),
  balanza_comercial = exportaciones_usd_mm - importaciones_usd_mm,
  exportaciones_pct_pib = c(16.9, 18.4, 31.4, 16.2, 39.3, 24.1)
)

print("=== FUENTES DE DATOS ORIGINALES ===")
print("INDEC (demográficos):")
print(indec)
print("\nBANCO CENTRAL (monetarios):")
print(banco_central)
print("\nTRABAJO (empleo):")
print(trabajo)
print("\nCOMERCIO EXTERIOR:")
print(comercio)

# ============================================================================
# 1. INNER_JOIN: SOLO COINCIDENCIAS COMPLETAS
# ============================================================================

cat("\n=== INNER_JOIN: Solo países con datos en ambas fuentes ===\n")

# Inner join entre INDEC y Banco Central
indec_bc_inner <- indec %>%
  inner_join(banco_central, by = c("codigo_pais" = "pais_codigo"))

print("INDEC + Banco Central (solo coincidencias):")
print(indec_bc_inner %>% 
  select(pais, poblacion_2023, pib_percapita_usd, tasa_politica, inflacion_2023))

cat("Países perdidos en inner join:")
paises_perdidos_inner <- setdiff(
  c(indec$pais, banco_central$pais_codigo), 
  indec_bc_inner$pais
)
print(paises_perdidos_inner)

# Triple inner join (solo países con datos en las 3 fuentes)
datos_completos <- indec %>%
  inner_join(banco_central, by = c("codigo_pais" = "pais_codigo")) %>%
  inner_join(trabajo, by = c("codigo_pais" = "iso_pais"))

print("\nTriple inner join (INDEC + BC + Trabajo):")
print(datos_completos %>% 
  select(pais, pib_percapita_usd, tasa_politica, desempleo_pct))

cat("Observaciones: Original INDEC =", nrow(indec), 
    "| Triple join =", nrow(datos_completos), "\n")

# ============================================================================
# 2. LEFT_JOIN: CONSERVAR BASE PRINCIPAL
# ============================================================================

cat("\n=== LEFT_JOIN: Conservar todos los países de INDEC ===\n")

# Left join conserva todos los países de INDEC
base_principal <- indec %>%
  left_join(banco_central, by = c("codigo_pais" = "pais_codigo")) %>%
  left_join(trabajo, by = c("codigo_pais" = "iso_pais")) %>%
  left_join(comercio, by = c("codigo_pais" = "pais_iso"))

print("Base principal con left joins:")
print(base_principal %>% 
  select(pais, pib_percapita_usd, tasa_politica, desempleo_pct, 
         exportaciones_usd_mm, everything()) %>%
  mutate(across(where(is.numeric), ~round(.x, 1))))

# Análisis de completitud
completitud <- base_principal %>%
  summarise(
    total_paises = n(),
    con_datos_bc = sum(!is.na(tasa_politica)),
    con_datos_trabajo = sum(!is.na(desempleo_pct)),
    con_datos_comercio = sum(!is.na(exportaciones_usd_mm)),
    datos_completos = sum(!is.na(tasa_politica) & !is.na(desempleo_pct) & 
                         !is.na(exportaciones_usd_mm))
  )

print("Análisis de completitud:")
print(completitud)

# ============================================================================
# 3. FULL_JOIN: CONSERVAR TODA LA INFORMACIÓN
# ============================================================================

cat("\n=== FULL_JOIN: Conservar información de todas las fuentes ===\n")

# Full join para conservar todos los países de todas las fuentes
union_completa <- indec %>%
  full_join(banco_central, by = c("codigo_pais" = "pais_codigo")) %>%
  full_join(trabajo, by = c("codigo_pais" = "iso_pais")) %>%
  full_join(comercio, by = c("codigo_pais" = "pais_iso")) %>%
  # Limpiar nombres de países
  mutate(
    pais_final = case_when(
      !is.na(pais) ~ pais,
      codigo_pais == "ECU" ~ "Ecuador", 
      codigo_pais == "BOL" ~ "Bolivia",
      TRUE ~ codigo_pais
    )
  ) %>%
  select(-pais) %>%
  rename(pais = pais_final) %>%
  relocate(pais, .after = codigo_pais)

print("Unión completa de todas las fuentes:")
print(union_completa %>% 
  select(pais, poblacion_2023, tasa_politica, desempleo_pct, exportaciones_usd_mm) %>%
  arrange(pais))

# Identificar qué países vienen de qué fuentes
origen_datos <- union_completa %>%
  mutate(
    en_indec = !is.na(poblacion_2023),
    en_bc = !is.na(tasa_politica), 
    en_trabajo = !is.na(desempleo_pct),
    en_comercio = !is.na(exportaciones_usd_mm),
    n_fuentes = en_indec + en_bc + en_trabajo + en_comercio
  ) %>%
  select(pais, en_indec, en_bc, en_trabajo, en_comercio, n_fuentes)

print("Origen de datos por país:")
print(origen_datos)

# ============================================================================
# 4. RIGHT_JOIN: CONSERVAR BASE SECUNDARIA
# ============================================================================

cat("\n=== RIGHT_JOIN: Conservar base del Banco Central ===\n")

# Right join (menos común, pero útil en casos específicos)
enfoque_monetario <- indec %>%
  right_join(banco_central, by = c("codigo_pais" = "pais_codigo"))

print("Enfoque monetario (right join con BC):")
print(enfoque_monetario %>% 
  select(pais, poblacion_2023, tasa_politica, inflacion_2023, reservas_usd_mm))

# ============================================================================
# 5. SEMI_JOIN y ANTI_JOIN: JOINS DE FILTRADO
# ============================================================================

cat("\n=== SEMI_JOIN y ANTI_JOIN: Filtrado de observaciones ===\n")

# Semi join: países de INDEC que TIENEN datos en BC
paises_con_datos_bc <- indec %>%
  semi_join(banco_central, by = c("codigo_pais" = "pais_codigo"))
idem <- indec %>% 
  filter(codigo_pais %in% banco_central$pais_codigo)

print("Países de INDEC que SÍ tienen datos en BC (semi_join):")
print(paises_con_datos_bc$pais)

# Anti join: países de INDEC que NO tienen datos en BC  
paises_sin_datos_bc <- indec %>%
  anti_join(banco_central, by = c("codigo_pais" = "pais_codigo"))
idem <- indec %>% 
  filter(! codigo_pais %in% banco_central$pais_codigo)

print("Países de INDEC que NO tienen datos en BC (anti_join):")
print(paises_sin_datos_bc$pais)

# Anti join inverso: países en BC que no están en INDEC
paises_solo_bc <- banco_central %>%
  anti_join(indec, by = c("pais_codigo" = "codigo_pais"))

print("Países solo en BC (anti_join inverso):")
print(paises_solo_bc$pais_codigo)

# ============================================================================
# 6. JOINS CON CLAVES MÚLTIPLES: DATOS PANEL
# ============================================================================

cat("\n=== JOINS CON CLAVES MÚLTIPLES: Datos panel ===\n")

# Simular datos panel (país + año)
pib_anual <- expand_grid(
  codigo_pais = c("ARG", "BRA", "CHL"),
  año = 2020:2023
) %>%
  mutate(
    pib_nominal = case_when(
      codigo_pais == "ARG" ~ 450 + (año - 2020) * 20 + rnorm(n(), 0, 15),
      codigo_pais == "BRA" ~ 2100 + (año - 2020) * 50 + rnorm(n(), 0, 30),
      codigo_pais == "CHL" ~ 320 + (año - 2020) * 8 + rnorm(n(), 0, 10)
    )
  )

# Datos de inflación (mismos países, algunos años faltantes)
inflacion_anual <- tibble(
  pais_codigo = c("ARG", "ARG", "ARG", "BRA", "BRA", "CHL", "CHL", "CHL"),
  año = c(2020, 2022, 2023, 2021, 2022, 2020, 2021, 2023),
  inflacion = c(36.1, 94.8, 211.4, 8.3, 9.3, 3.0, 4.5, 7.6)
)

# Join con claves múltiples
panel_completo <- pib_anual %>%
  left_join(inflacion_anual, by = c("codigo_pais" = "pais_codigo", "año"))

print("Panel con claves múltiples (país + año):")
print(panel_completo %>% 
  arrange(codigo_pais, año) %>%
  mutate(pib_nominal = round(pib_nominal, 0)))

# ============================================================================
# 7. PROBLEMAS COMUNES Y VALIDACIONES
# ============================================================================

cat("\n=== PROBLEMAS COMUNES Y VALIDACIONES ===\n")

# 7.1 Datos duplicados (problema frecuente)
datos_con_duplicados <- tibble(
  codigo = c("ARG", "ARG", "BRA", "CHL"),  # Argentina duplicada
  indicador = c("PIB", "PIB_alternativo", "PIB", "PIB"),
  valor = c(450, 465, 2100, 320)
)

# Mostrar el problema
problema_duplicados <- indec %>%
  select(codigo_pais, pais) %>%
  left_join(datos_con_duplicados, by = c("codigo_pais" = "codigo"))

print("Problema: datos duplicados generan filas extra")
print(problema_duplicados)
cat("Filas originales:", nrow(indec), "| Con join problemático:", nrow(problema_duplicados), "\n")

# Solución: limpiar duplicados antes del join
datos_limpios <- datos_con_duplicados %>%
  filter(indicador == "PIB")  # Conservar solo una versión

join_corregido <- indec %>%
  select(codigo_pais, pais) %>%
  left_join(datos_limpios, by = c("codigo_pais" = "codigo"))

print("Solución: limpiar duplicados antes del join")
print(join_corregido)

# 7.2 Claves que no coinciden (diferencias de formato)
codigos_inconsistentes <- tibble(
  pais_nombre = c("Argentina", "Brasil", "Chile"),
  variable = c(100, 200, 300)
)

# Problema: nombres vs códigos
print("Problema: claves con diferentes formatos")
problema_claves <- indec %>%
  left_join(codigos_inconsistentes, by = c("pais" = "pais_nombre"))
print(problema_claves %>% select(pais, variable))


# ============================================================================
# 7. CASO DE USO INTEGRADO: ANÁLISIS ECONÓMICO COMPLETO
# ============================================================================

cat("\n=== ANÁLISIS ECONÓMICO INTEGRADO ===\n")

# Crear dataset final para análisis
dataset_final <- indec %>%
  left_join(banco_central, by = c("codigo_pais" = "pais_codigo")) %>%
  left_join(trabajo, by = c("codigo_pais" = "iso_pais")) %>%
  left_join(comercio, by = c("codigo_pais" = "pais_iso")) %>%
  mutate(
    # Indicadores calculados que requieren múltiples fuentes
    pib_total_usd_mm = (pib_percapita_usd * poblacion_2023) / 1000,
    apertura_comercial = ((exportaciones_usd_mm + importaciones_usd_mm) / (pib_total_usd_mm * 1000)) * 100,
    densidad_poblacional = poblacion_2023 / (superficie_km2 / 1000000),
    
    # Tipología económica integrando múltiples variables
    tipologia = case_when(
      pib_percapita_usd > 15000 & inflacion_2023 <= 10 ~ "Desarrollado estable",
      pib_percapita_usd > 10000 & inflacion_2023 <= 20 ~ "Desarrollo medio estable",
      inflacion_2023 > 50 ~ "Alta inflación",
      desempleo_pct > 8 ~ "Alto desempleo",
      TRUE ~ "Economía estándar"
    ),
    
    # Índice compuesto (requiere datos de múltiples fuentes)
    indice_competitividad = case_when(
      is.na(pib_percapita_usd) | is.na(inflacion_2023) | is.na(desempleo_pct) ~ NA_real_,
      TRUE ~ (pib_percapita_usd / 1000) - (inflacion_2023 / 10) - (desempleo_pct / 2)
    )
  ) %>%
  # Solo países con datos suficientes para análisis
  filter(!is.na(pib_percapita_usd), !is.na(inflacion_2023)) %>%
  arrange(desc(indice_competitividad))

