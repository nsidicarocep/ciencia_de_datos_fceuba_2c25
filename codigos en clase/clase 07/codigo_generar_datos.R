# =============================================================================
# CONFIGURACIÓN Y GENERACIÓN DE DATOS
# =============================================================================

library(tidyverse)
library(lubridate)

set.seed(2024)

# TABLA 1: Trabajadores (base principal)
trabajadores <- tibble(
  id_trabajador = 1:800,
  dni = sample(20000000:45000000, 800),
  edad = sample(18:65, 800, replace = TRUE),
  genero = sample(c("Mujer", "Hombre"), 800, replace = TRUE, prob = c(0.52, 0.48)),
  nivel_educativo = sample(c("Primario", "Secundario", "Terciario", "Universitario"), 
                           800, replace = TRUE, prob = c(0.15, 0.45, 0.2, 0.2)),
  provincia_nacimiento = sample(c("Buenos Aires", "CABA", "Córdoba", "Santa Fe", "Mendoza", "Tucumán"), 
                                800, replace = TRUE, prob = c(0.35, 0.15, 0.15, 0.15, 0.1, 0.1)),
  fecha_nacimiento = as.Date("2024-01-01") - years(edad) - days(sample(0:364, 800, replace = TRUE)),
  estado_civil = sample(c("Soltero", "Casado", "Divorciado", "Viudo"), 800, replace = TRUE, prob = c(0.4, 0.45, 0.1, 0.05))
)

# TABLA 2: Empleos
empleos <- tibble(
  id_empleo = 1:1200,
  id_trabajador = sample(trabajadores$id_trabajador, 1200, replace = TRUE),
  id_empresa = sample(1:150, 1200, replace = TRUE),
  fecha_inicio = sample(seq(as.Date("2020-01-01"), as.Date("2024-01-01"), by = "day"), 1200, replace = TRUE),
  fecha_fin = ifelse(runif(1200) < 0.3, 
                     sample(seq(as.Date("2021-01-01"), as.Date("2024-12-31"), by = "day"), 1200, replace = TRUE),
                     NA),
  salario_bruto = round(rnorm(1200, mean = 180000, sd = 60000)),
  horas_semanales = sample(c(20, 35, 40, 48), 1200, replace = TRUE, prob = c(0.1, 0.2, 0.6, 0.1)),
  sector = sample(c("Público", "Privado", "Cuenta Propia"), 1200, replace = TRUE, prob = c(0.25, 0.65, 0.1)),
  rama_actividad = sample(c("Industria", "Servicios", "Comercio", "Construcción", "Agro", "Tecnología"), 
                          1200, replace = TRUE, prob = c(0.2, 0.35, 0.2, 0.1, 0.05, 0.1))
) %>%
  mutate(
    fecha_fin = as.Date(fecha_fin, origin = "1970-01-01"),
    salario_bruto = pmax(salario_bruto, 80000),
    empleo_activo = is.na(fecha_fin) | fecha_fin > as.Date("2024-01-01")
  )

# TABLA 3: Empresas
empresas <- tibble(
  id_empresa = 1:150,
  razon_social = paste("Empresa", 1:150, "SA"),
  cuit = paste0("30-", sample(10000000:99999999, 150), "-", sample(0:9, 150,replace=TRUE)),
  provincia_sede = sample(c("Buenos Aires", "CABA", "Córdoba", "Santa Fe", "Mendoza"), 
                          150, replace = TRUE, prob = c(0.4, 0.3, 0.15, 0.1, 0.05)),
  tamaño_empresa = sample(c("Micro", "Pequeña", "Mediana", "Grande"), 150, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1)),
  año_fundacion = sample(1950:2020, 150, replace = TRUE),
  facturacion_anual = case_when(
    tamaño_empresa == "Micro" ~ round(runif(150, 1, 50) * 1000000),
    tamaño_empresa == "Pequeña" ~ round(runif(150, 50, 200) * 1000000),
    tamaño_empresa == "Mediana" ~ round(runif(150, 200, 1000) * 1000000),
    tamaño_empresa == "Grande" ~ round(runif(150, 1000, 5000) * 1000000)
  ),
  certificacion_iso = sample(c(TRUE, FALSE), 150, replace = TRUE, prob = c(0.3, 0.7))
)

# TABLA 4: Viviendas
viviendas <- tibble(
  id_trabajador = trabajadores$id_trabajador,
  tipo_vivienda = sample(c("Casa", "Departamento", "Inquilinato", "Villa"), 800, replace = TRUE, prob = c(0.6, 0.25, 0.1, 0.05)),
  provincia_vivienda = sample(c("Buenos Aires", "CABA", "Córdoba", "Santa Fe", "Mendoza", "Tucumán"), 
                              800, replace = TRUE, prob = c(0.4, 0.2, 0.15, 0.15, 0.05, 0.05)),
  tenencia = sample(c("Propietario", "Inquilino", "Ocupante", "Familiar"), 800, replace = TRUE, prob = c(0.5, 0.3, 0.1, 0.1)),
  ambientes = sample(1:6, 800, replace = TRUE, prob = c(0.1, 0.2, 0.3, 0.25, 0.1, 0.05)),
  m2_superficie = round(20 + ambientes * 15 + rnorm(800, 0, 10)),
  valor_estimado = case_when(
    provincia_vivienda == "CABA" ~ m2_superficie * runif(800, 3000, 5000),
    provincia_vivienda == "Buenos Aires" ~ m2_superficie * runif(800, 1500, 3000),
    TRUE ~ m2_superficie * runif(800, 800, 2000)
  ),
  distancia_trabajo_km = round(runif(800, 0.5, 50), 1),
  tiempo_traslado_min = round(distancia_trabajo_km * runif(800, 1.5, 3) + rnorm(800, 0, 5))
) %>%
  mutate(
    m2_superficie = pmax(m2_superficie, 15),
    tiempo_traslado_min = pmax(tiempo_traslado_min, 5)
  )

# TABLA 5: Movilidad laboral
movilidad <- expand_grid(
  id_trabajador = sample(trabajadores$id_trabajador, 400,replace = TRUE),
  año = 2020:2024
) %>%
  group_by(id_trabajador) %>%
  slice_sample(n = sample(1:4, 1)) %>%
  ungroup() %>%
  mutate(
    id_empleo = sample(empleos$id_empleo, n()),
    tipo_cambio = sample(c("Promoción", "Cambio empresa", "Cambio sector", "Despido", "Renuncia"), 
                         n(), replace = TRUE),
    variacion_salarial = case_when(
      tipo_cambio == "Promoción" ~ runif(n(), 0.1, 0.4),
      tipo_cambio == "Cambio empresa" ~ runif(n(), -0.1, 0.3),
      tipo_cambio == "Cambio sector" ~ runif(n(), -0.2, 0.2),
      tipo_cambio == "Despido" ~ runif(n(), -0.3, 0),
      tipo_cambio == "Renuncia" ~ runif(n(), -0.1, 0.2)
    )
  )
