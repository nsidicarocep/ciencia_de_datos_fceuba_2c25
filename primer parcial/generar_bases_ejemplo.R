# ==============================================================================
# SIMULACIÓN DE DATOS RELACIONALES: EMPLEADOS, EMPLEADORES Y ESTABLECIMIENTOS
# Sistema integrado de datos laborales y empresariales
# ==============================================================================

library(tidyverse)
library(lubridate)

set.seed(123)  # Para reproducibilidad

# ==============================================================================
# PARÁMETROS DE SIMULACIÓN
# ==============================================================================

n_empleadores <- 500      # Número de empresas
n_empleados <- 5000       # Número de empleados totales
n_meses <- 12             # Meses a simular

# ==============================================================================
# FUNCIONES AUXILIARES
# ==============================================================================

# Generar CUIT válido (simplificado)
generar_cuit <- function(n) {
  tipo <- sample(c("20", "27", "30", "33"), n, replace = TRUE, 
                 prob = c(0.4, 0.1, 0.4, 0.1))
  numero <- sprintf("%08d", sample(10000000:99999999, n))
  digito <- sample(0:9, n, replace = TRUE)
  paste0(tipo, "-", numero, "-", digito)
}

# Generar CUIL válido (simplificado)
generar_cuil <- function(n, sexo) {
  tipo <- ifelse(sexo == "Masculino", "20", "27")
  numero <- sprintf("%08d", sample(10000000:99999999, n))
  digito <- sample(0:9, n, replace = TRUE)
  paste0(tipo, "-", numero, "-", digito)
}

# ==============================================================================
# TABLA 2: EMPLEADORES
# ==============================================================================

cat("=== GENERANDO TABLA DE EMPLEADORES ===\n")

empleadores <- tibble(
  cuit_empleador = generar_cuit(n_empleadores),
  
  actividad_economica = sample(
    c("Agropecuaria", "Petróleo y Minería", "Industria liviana", 
      "Industria pesada", "Comercio", "Servicios intensivos en conocimiento", 
      "Otros servicios"), 
    n_empleadores, replace = TRUE,
    prob = c(0.1, 0.05, 0.15, 0.1, 0.25, 0.2, 0.15)
  ),
  
  tipo_sociedad = sample(
    c("S.A.", "S.R.L.", "S.A.S.", "Cooperativa", "Unipersonal", 
      "Sociedad Anónima Unipersonal"),
    n_empleadores, replace = TRUE
  ),
  
  provincia_sede = sample(
    c("Buenos Aires", "CABA", "Córdoba", "Santa Fe", "Mendoza", 
      "Tucumán", "Entre Ríos", "Salta", "Misiones", "Neuquén"),
    n_empleadores, replace = TRUE,
    prob = c(0.35, 0.25, 0.1, 0.08, 0.05, 0.04, 0.04, 0.03, 0.03, 0.03)
  ),
  
  obra_social = sample(
    c("OSDE", "Swiss Medical", "OSECAC", "OSPRERA", "OSPE", 
      "IOMA", "PAMI", "Otra"),
    n_empleadores, replace = TRUE
  )
) %>%
  mutate(
    # Finanzas según actividad económica
    ingreso_anual = case_when(
      actividad_economica == "Petróleo y Minería" ~ rnorm(n(), 50000000, 20000000),
      actividad_economica == "Industria pesada" ~ rnorm(n(), 30000000, 15000000),
      actividad_economica == "Servicios intensivos en conocimiento" ~ rnorm(n(), 20000000, 10000000),
      actividad_economica == "Industria liviana" ~ rnorm(n(), 15000000, 8000000),
      actividad_economica == "Comercio" ~ rnorm(n(), 10000000, 5000000),
      actividad_economica == "Agropecuaria" ~ rnorm(n(), 8000000, 4000000),
      TRUE ~ rnorm(n(), 5000000, 3000000)
    ),
    
    gasto_anual = ingreso_anual * runif(n(), 0.6, 0.95),
    
    utilidad = pmax(ingreso_anual - gasto_anual, 0),
    impuesto_pagado = utilidad * runif(n(), 0.25, 0.40),
    
    subsidios_recibidos = ifelse(
      runif(n()) < 0.15,
      runif(n(), 100000, 5000000),
      0
    )
  ) %>%
  select(-utilidad)

print(paste("Empleadores generados:", nrow(empleadores)))

# ==============================================================================
# TABLA 3: ESTABLECIMIENTOS
# ==============================================================================

cat("\n=== GENERANDO TABLA DE ESTABLECIMIENTOS ===\n")

# Generar establecimientos por empleador
establecimientos <- empleadores %>%
  mutate(
    n_establecimientos = case_when(
      actividad_economica %in% c("Comercio", "Servicios intensivos en conocimiento") ~ 
        sample(1:5, n(), replace = TRUE, prob = c(0.5, 0.25, 0.15, 0.07, 0.03)),
      actividad_economica %in% c("Industria pesada", "Industria liviana") ~ 
        sample(1:3, n(), replace = TRUE, prob = c(0.6, 0.3, 0.1)),
      TRUE ~ sample(1:2, n(), replace = TRUE, prob = c(0.7, 0.3))
    )
  ) %>%
  uncount(n_establecimientos) %>%
  group_by(cuit_empleador) %>%
  mutate(
    id_establecimiento = paste0(cuit_empleador, "-EST-", row_number()),
    
    tipo_actividades = case_when(
      row_number() == 1 ~ "Administrativas",
      actividad_economica %in% c("Industria liviana", "Industria pesada") ~ 
        sample(c("Productivo", "Almacenamiento", "Todas"), 1, prob = c(0.6, 0.2, 0.2)),
      actividad_economica == "Comercio" ~ "Comercial",
      TRUE ~ sample(c("Administrativas", "Comercial", "Todas"), 1, prob = c(0.3, 0.5, 0.2))
    ),
    
    provincia_establecimiento = if_else(
      runif(n()) < 0.7,
      provincia_sede,
      sample(c("Buenos Aires", "CABA", "Córdoba", "Santa Fe", "Mendoza", 
               "Tucumán", "Entre Ríos", "Salta", "Misiones", "Neuquén"), 
             n(), replace = TRUE)
    ),
    
    departamento = paste("Departamento", sample(1:50, n(), replace = TRUE)),
    
    direccion = paste(
      sample(c("Av.", "Calle", "Ruta", "Camino"), n(), replace = TRUE),
      sample(c("San Martín", "Belgrano", "Rivadavia", "Mitre", "9 de Julio"), 
             n(), replace = TRUE),
      sample(100:9999, n(), replace = TRUE)
    ),
    
    parque_industrial = case_when(
      actividad_economica %in% c("Industria pesada", "Industria liviana") ~ 
        sample(c("Sí", "No"), n(), replace = TRUE, prob = c(0.4, 0.6)),
      TRUE ~ sample(c("Sí", "No"), n(), replace = TRUE, prob = c(0.1, 0.9))
    )
  ) %>%
  ungroup() %>%
  select(cuit_empleador, id_establecimiento, tipo_actividades, 
         provincia_establecimiento, departamento, direccion, parque_industrial)

print(paste("Establecimientos generados:", nrow(establecimientos)))

# ==============================================================================
# TABLA 1: EMPLEADOS
# ==============================================================================

cat("\n=== GENERANDO TABLA DE EMPLEADOS ===\n")

# Asignar empleados a establecimientos
empleados_base <- establecimientos %>%
  mutate(
    n_empleados = case_when(
      tipo_actividades == "Productivo" ~ sample(50:500, n(), replace = TRUE),
      tipo_actividades == "Almacenamiento" ~ sample(20:100, n(), replace = TRUE),
      tipo_actividades == "Comercial" ~ sample(5:50, n(), replace = TRUE),
      tipo_actividades == "Administrativas" ~ sample(10:100, n(), replace = TRUE),
      TRUE ~ sample(10:200, n(), replace = TRUE)
    )
  ) %>%
  uncount(n_empleados) %>%
  slice_sample(n = n_empleados) %>%
  mutate(
    sexo = sample(c("Masculino", "Femenino"), n(), replace = TRUE, 
                  prob = c(0.55, 0.45)),
    edad = sample(18:70, n(), replace = TRUE),
    
    nivel_educativo = sample(
      c("Secundario", "Universitario", "Posgrado"), 
      n(), replace = TRUE, prob = c(0.5, 0.4, 0.1)
    ),
    
    categoria_ocupacional = sample(
      c("Directivo", "Profesional", "Técnico", "Administrativo", "Operario"),
      n(), replace = TRUE, prob = c(0.05, 0.15, 0.2, 0.3, 0.3)
    ),
    
    tipo_contrato = sample(
      c("Permanente", "Temporal", "Pasantía"), 
      n(), replace = TRUE, prob = c(0.7, 0.25, 0.05)
    ),
    
    fecha_ingreso = as.Date("2020-01-01") + sample(0:1460, n(), replace = TRUE),
    antigüedad_meses = as.numeric(interval(fecha_ingreso, as.Date("2024-01-01")) %/% months(1)),
    
    cuil_empleado = generar_cuil(n(), sexo)
  )

# Crear panel mensual
empleados <- empleados_base %>%
  crossing(mes = 1:n_meses) %>%
  mutate(
    # Salario base según categoría
    salario_base = case_when(
      categoria_ocupacional == "Directivo" ~ rnorm(n(), 500000, 100000),
      categoria_ocupacional == "Profesional" ~ rnorm(n(), 350000, 80000),
      categoria_ocupacional == "Técnico" ~ rnorm(n(), 250000, 50000),
      categoria_ocupacional == "Administrativo" ~ rnorm(n(), 200000, 40000),
      categoria_ocupacional == "Operario" ~ rnorm(n(), 180000, 35000),
      TRUE ~ rnorm(n(), 200000, 50000)
    ),
    
    # Ajustes
    ajuste_educacion = case_when(
      nivel_educativo == "Posgrado" ~ 1.3,
      nivel_educativo == "Universitario" ~ 1.15,
      TRUE ~ 1.0
    ),
    
    ajuste_antiguedad = 1 + pmin(antigüedad_meses / 12 * 0.01, 0.10),
    
    salario_mensual = round(salario_base * ajuste_educacion * ajuste_antiguedad),
    
    horas_trabajadas = case_when(
      tipo_contrato == "Pasantía" ~ sample(80:120, n(), replace = TRUE),
      tipo_contrato == "Temporal" ~ sample(100:160, n(), replace = TRUE),
      TRUE ~ 160 + sample(-10:20, n(), replace = TRUE)
    ),
    
    remuneracion_total = round(salario_mensual * runif(n(), 1.0, 1.2))
  ) %>%
  select(mes, cuil_empleado, cuit_empleador, id_establecimiento,
         remuneracion_total, salario_mensual, horas_trabajadas,
         sexo, nivel_educativo, edad, antigüedad_meses, 
         tipo_contrato, categoria_ocupacional, fecha_ingreso)

print(paste("Registros de empleados generados:", nrow(empleados)))

