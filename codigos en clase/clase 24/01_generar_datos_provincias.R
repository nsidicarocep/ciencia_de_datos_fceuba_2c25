################################################################################
# Script: 01_generar_datos_provincias.R
# Descripción: Genera datos ficticios de indicadores económicos y sociales 
#              por provincia para demostrar reportes automáticos en RMarkdown
# Autor: Ejemplo RMarkdown
# Fecha: 2025-11-10
################################################################################

library(tidyverse)

# Establecer semilla para reproducibilidad
set.seed(42)

# Lista de provincias argentinas
provincias <- c(
  "Buenos Aires", "CABA", "Catamarca", "Chaco", "Chubut",
  "Córdoba", "Corrientes", "Entre Ríos", "Formosa", "Jujuy",
  "La Pampa", "La Rioja", "Mendoza", "Misiones", "Neuquén",
  "Río Negro", "Salta", "San Juan", "San Luis", "Santa Cruz",
  "Santa Fe", "Santiago del Estero", "Tierra del Fuego", "Tucumán"
)

# Generar datos para 2023 y 2024
años <- 2023:2024

# Crear dataset con indicadores económicos y sociales
datos_provincias <- expand_grid(
  provincia = provincias,
  año = años
) %>%
  mutate(
    # Población (en miles de habitantes)
    poblacion = case_when(
      provincia == "Buenos Aires" ~ runif(n(), 17000, 17500),
      provincia == "CABA" ~ runif(n(), 3000, 3100),
      provincia == "Córdoba" ~ runif(n(), 3700, 3800),
      provincia == "Santa Fe" ~ runif(n(), 3400, 3500),
      provincia == "Mendoza" ~ runif(n(), 1900, 2000),
      provincia == "Tucumán" ~ runif(n(), 1600, 1700),
      TRUE ~ runif(n(), 300, 1500)
    ),
    
    # Tasa de desempleo (%)
    tasa_desempleo = runif(n(), 5, 12),
    
    # Tasa de empleo informal (%)
    tasa_informalidad = runif(n(), 25, 45),
    
    # PBG per cápita (en miles de pesos)
    pbg_per_capita = case_when(
      provincia %in% c("CABA", "Santa Cruz", "Neuquén", "Tierra del Fuego") ~ 
        runif(n(), 800, 1200),
      provincia %in% c("Buenos Aires", "Córdoba", "Santa Fe", "Mendoza") ~ 
        runif(n(), 500, 700),
      TRUE ~ runif(n(), 300, 500)
    ),
    
    # Tasa de crecimiento del PBG (%)
    crecimiento_pbg = rnorm(n(), mean = 2.5, sd = 3),
    
    # Índice de pobreza (%)
    pobreza = runif(n(), 20, 40),
    
    # Inversión pública (millones de pesos)
    inversion_publica = poblacion * runif(n(), 0.5, 2),
    
    # Exportaciones (millones de USD)
    exportaciones = case_when(
      provincia %in% c("Buenos Aires", "Santa Fe", "Córdoba") ~ 
        runif(n(), 3000, 8000),
      provincia %in% c("Mendoza", "San Juan", "Neuquén", "Chubut") ~ 
        runif(n(), 1000, 3000),
      TRUE ~ runif(n(), 100, 1000)
    ),
    
    # Sector principal (ficticio para ejemplificar)
    sector_principal = case_when(
      provincia %in% c("Buenos Aires", "CABA", "Córdoba", "Santa Fe") ~ "Servicios",
      provincia %in% c("Neuquén", "Santa Cruz", "Chubut") ~ "Hidrocarburos",
      provincia %in% c("Mendoza", "San Juan", "La Rioja") ~ "Agroindustria",
      provincia %in% c("Salta", "Tucumán", "Jujuy") ~ "Agrícola",
      TRUE ~ "Primario"
    )
  ) %>%
  # Agregar variación interanual
  group_by(provincia) %>%
  mutate(
    variacion_desempleo = if_else(año == 2024, 
                                   tasa_desempleo - lag(tasa_desempleo), 
                                   NA_real_),
    variacion_pbg_pc = if_else(año == 2024,
                                ((pbg_per_capita - lag(pbg_per_capita)) / 
                                   lag(pbg_per_capita)) * 100,
                                NA_real_)
  ) %>%
  ungroup()

# Guardar datos
write_csv(datos_provincias, "datos_provincias.csv")

# Mostrar resumen
cat("\n=== DATOS GENERADOS ===\n")
cat("Total de registros:", nrow(datos_provincias), "\n")
cat("Provincias:", length(unique(datos_provincias$provincia)), "\n")
cat("Años:", paste(unique(datos_provincias$año), collapse = ", "), "\n\n")

# Mostrar primeras filas
print(head(datos_provincias, 10))

cat("\n✓ Datos guardados en: datos_provincias.csv\n")
