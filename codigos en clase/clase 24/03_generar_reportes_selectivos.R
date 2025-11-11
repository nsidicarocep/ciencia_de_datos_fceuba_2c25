################################################################################
# Script: 03_generar_reportes_selectivos.R
# Descripción: Genera reportes solo para provincias seleccionadas
# Autor: Ejemplo RMarkdown
# Fecha: 2025-11-10
################################################################################

library(rmarkdown)
library(tidyverse)

# ============================================================================
# CONFIGURACIÓN: Elegir provincias para generar reportes
# ============================================================================

# Opción 1: Provincias específicas
provincias_seleccionadas <- c(
  "Buenos Aires",
  "CABA",
  "Córdoba",
  "Santa Fe",
  "Mendoza"
)

# Opción 2: Por región (descomentar para usar)
# region_patagonia <- c("Neuquén", "Río Negro", "Chubut", "Santa Cruz", "Tierra del Fuego")
# region_noa <- c("Salta", "Jujuy", "Tucumán", "Catamarca", "La Rioja", "Santiago del Estero")
# region_cuyo <- c("Mendoza", "San Juan", "San Luis")

# provincias_seleccionadas <- region_patagonia

# ============================================================================

# Parámetros
año_reporte <- 2024

# Crear directorio si no existe
if (!dir.exists("reportes_provincias")) {
  dir.create("reportes_provincias")
}

# Mensaje inicial
cat("\n", rep("=", 70), "\n", sep = "")
cat("  GENERACIÓN SELECTIVA DE REPORTES\n")
cat(rep("=", 70), "\n\n", sep = "")
cat("Provincias seleccionadas:", length(provincias_seleccionadas), "\n")
cat("Lista:", paste(provincias_seleccionadas, collapse = ", "), "\n\n")

# Generar reportes
for (i in seq_along(provincias_seleccionadas)) {
  
  provincia <- provincias_seleccionadas[i]
  
  nombre_archivo <- paste0(
    "reportes_provincias/informe_",
    str_replace_all(tolower(provincia), " ", "_"),
    "_", año_reporte, ".pdf"
  )
  
  cat(sprintf("[%d/%d] Generando: %s... ",
              i, length(provincias_seleccionadas), provincia))
  
  tryCatch({
    rmarkdown::render(
      input = "template_provincia.Rmd",
      output_file = basename(nombre_archivo),
      output_dir = "reportes_provincias",
      params = list(provincia = provincia, año = año_reporte),
      quiet = TRUE
    )
    cat("✓\n")
  }, error = function(e) {
    cat("✗ ERROR:", conditionMessage(e), "\n")
  })
}

cat("\n✓ Proceso completado\n")
cat("Reportes guardados en: ./reportes_provincias/\n\n")
