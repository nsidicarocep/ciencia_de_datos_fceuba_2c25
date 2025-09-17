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
  ocupacion = sample(c("Administrativo", "Técnico", "Gerencial", "Operativo", "Profesional", "Comercial"), 
                     1200, replace = TRUE, prob = c(0.25, 0.2, 0.1, 0.25, 0.15, 0.05))
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
  rama_actividad = sample(c("Industria", "Servicios", "Comercio", "Construcción", "Agro", "Tecnología"), 
                          150, replace = TRUE, prob = c(0.2, 0.35, 0.2, 0.1, 0.05, 0.1)),
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
  id_trabajador = sample(trabajadores$id_trabajador, 400,replace=TRUE),
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


# =============================================================================
# EJERCICIO 1: ANÁLISIS DE DESIGUALDAD SALARIAL MULTI-DIMENSIONAL
# =============================================================================

cat("=== EJERCICIO 1: Desigualdad Salarial Multi-dimensional ===\n")

dataset_completo <- trabajadores %>%
  inner_join(empleos %>% filter(empleo_activo), by = "id_trabajador") %>%
  inner_join(empresas, by = "id_empresa") %>%
  inner_join(viviendas, by = "id_trabajador") %>%
  mutate(
    grupo_etario = case_when(
      edad <= 30 ~ "18-30",
      edad <= 45 ~ "31-45",
      edad <= 65 ~ "46-65"
    )
  )

cuartiles_genero_educacion <- dataset_completo %>%
  group_by(genero, nivel_educativo) %>%
  mutate(cuartil_salarial = ntile(salario_bruto, 4)) %>%
  ungroup()

analisis_proporciones <- cuartiles_genero_educacion %>%
  group_by(genero, nivel_educativo, cuartil_salarial) %>%
  summarise(trabajadores = n(), .groups = "drop") %>%
  group_by(genero, nivel_educativo) %>%
  mutate(
    total_grupo = sum(trabajadores),
    proporcion = trabajadores / total_grupo
  ) %>%
  ungroup()

tabla_cuartiles <- analisis_proporciones %>%
  select(genero, nivel_educativo, cuartil_salarial, proporcion) %>%
  pivot_wider(
    names_from = cuartil_salarial,
    values_from = proporcion,
    names_prefix = "Q",
    values_fill = 0
  )

brechas_genero <- tabla_cuartiles %>%
  select(genero, nivel_educativo, Q4) %>%
  pivot_wider(
    names_from = genero,
    values_from = Q4,
    values_fill = 0
  ) %>%
  mutate(brecha_Q4 = Hombre - Mujer) %>%
  arrange(desc(brecha_Q4))

print("Top 3 niveles educativos con mayor brecha de género en Q4:")
print(brechas_genero %>% head(3))

# =============================================================================
# EJERCICIO 2: MATRIZ DE TRANSICIÓN LABORAL TEMPORAL
# =============================================================================

cat("\n=== EJERCICIO 2: Matriz de Transición Laboral ===\n")

datos_movilidad <- movilidad %>%
  inner_join(empleos %>% select(id_empleo, sector), by = "id_empleo") %>%
  arrange(id_trabajador, año)

transiciones <- datos_movilidad %>%
  group_by(id_trabajador) %>%
  mutate(
    sector_anterior = lag(sector),
    año_anterior = lag(año)
  ) %>%
  filter(!is.na(sector_anterior)) %>%
  ungroup()

matriz_transicion <- transiciones %>%
  count(sector_anterior, sector, name = "transiciones") %>%
  group_by(sector_anterior) %>%
  mutate(
    total_salidas = sum(transiciones),
    proporcion = round(transiciones / total_salidas, 3)
  ) %>%
  ungroup()

matriz_cuadrada <- matriz_transicion %>%
  select(sector_anterior, sector, proporcion) %>%
  pivot_wider(
    names_from = sector,
    values_from = proporcion,
    values_fill = 0
  )

print("Matriz de transición entre sectores:")
print(matriz_cuadrada)

retencion_sectores <- matriz_transicion %>%
  filter(sector_anterior == sector) %>%
  select(sector = sector_anterior, prop_retencion = proporcion) %>%
  arrange(desc(prop_retencion))

print("Sectores ordenados por capacidad de retención:")
print(retencion_sectores)

# =============================================================================
# EJERCICIO 3: ANÁLISIS GEOESPACIAL DE PRODUCTIVIDAD
# =============================================================================

cat("\n=== EJERCICIO 3: Análisis Geoespacial de Productividad ===\n")

productividad_provincial <- dataset_completo %>%
  group_by(provincia_vivienda) %>%
  summarise(
    salario_promedio = mean(salario_bruto, na.rm = TRUE),
    costo_vida_estimado = mean(valor_estimado / m2_superficie, na.rm = TRUE),
    prop_universitarios = mean(nivel_educativo == "Universitario"),
    prop_empresas_grandes = mean(tamaño_empresa == "Grande"),
    trabajadores_total = n(),
    .groups = "drop"
  ) %>%
  mutate(
    indice_productividad = round(
      (salario_promedio / costo_vida_estimado) * 
        (1 + prop_universitarios) * 
        (1 + prop_empresas_grandes), 2
    ),
    cuartil_productividad = ntile(indice_productividad, 4)
  ) %>%
  arrange(desc(indice_productividad))

flujos_laborales <- dataset_completo %>%
  mutate(trabajo_fuera_provincia = provincia_nacimiento != provincia_vivienda) %>%
  group_by(provincia_nacimiento) %>%
  summarise(
    trabajadores_totales = n(),
    trabajadores_exporta = sum(trabajo_fuera_provincia),
    prop_exportacion = round(mean(trabajo_fuera_provincia) * 100, 1),
    .groups = "drop"
  ) %>%
  arrange(desc(prop_exportacion))

matriz_flujos <- dataset_completo %>%
  count(provincia_nacimiento, provincia_vivienda, name = "trabajadores") %>%
  pivot_wider(
    names_from = provincia_vivienda,
    values_from = trabajadores,
    values_fill = 0
  )

print("Top provincias por índice de productividad:")
print(productividad_provincial %>% head())

print("\nTop provincias que 'exportan' trabajadores:")
print(flujos_laborales %>% head())

# =============================================================================
# EJERCICIO 4: SEGMENTACIÓN EMPRESARIAL AVANZADA
# =============================================================================

cat("\n=== EJERCICIO 4: Segmentación Empresarial Avanzada ===\n")

estadisticas_empresas <- empleos %>%
  inner_join(trabajadores %>% select(id_trabajador, genero, nivel_educativo), by = "id_trabajador") %>%
  group_by(id_empresa) %>%
  summarise(
    empleos_totales = n(),
    empleos_terminados = sum(!is.na(fecha_fin)),
    salario_promedio = mean(salario_bruto, na.rm = TRUE),
    prop_mujeres = mean(genero == "Mujer"),
    nivel_educativo_num = mean(case_when(
      nivel_educativo == "Primario" ~ 1,
      nivel_educativo == "Secundario" ~ 2,
      nivel_educativo == "Terciario" ~ 3,
      nivel_educativo == "Universitario" ~ 4
    )),
    .groups = "drop"
  ) %>%
  mutate(
    rotacion_laboral = round(empleos_terminados / empleos_totales, 3),
    diversidad_genero = round(1 - abs(prop_mujeres - 0.5) * 2, 3)
  )

empresas_completas <- empresas %>%
  inner_join(estadisticas_empresas, by = "id_empresa") %>%
  filter(empleos_totales >= 3) %>%
  mutate(
    cuartil_salario = ntile(salario_promedio, 4),
    cuartil_diversidad = ntile(diversidad_genero, 4),
    cuartil_educacion = ntile(nivel_educativo_num, 4),
    cuartil_rotacion = ntile(desc(rotacion_laboral), 4)
  )

empresas_tipologia <- empresas_completas %>%
  mutate(
    tipologia = case_when(
      cuartil_salario == 4 & cuartil_diversidad == 4 ~ "Elite",
      cuartil_salario == 4 & cuartil_diversidad <= 2 ~ "Tradicional",
      cuartil_salario <= 2 & cuartil_diversidad == 4 ~ "Emergente",
      TRUE ~ "Básica"
    )
  )

analisis_sectorial <- empresas_tipologia %>%
  count(rama_actividad, tipologia) %>%
  group_by(rama_actividad) %>%
  mutate(
    total_sector = sum(n),
    proporcion = round(n / total_sector, 3)
  ) %>%
  ungroup()

tipologia_pivot <- analisis_sectorial %>%
  select(rama_actividad, tipologia, proporcion) %>%
  pivot_wider(
    names_from = tipologia,
    values_from = proporcion,
    values_fill = 0
  ) %>%
  arrange(desc(Elite))

print("Distribución de tipologías empresariales por sector:")
print(tipologia_pivot)

# =============================================================================
# EJERCICIO INTEGRADOR: DASHBOARD DE INEQUIDAD LABORAL
# =============================================================================

cat("\n=== EJERCICIO INTEGRADOR: Dashboard de Inequidad Laboral ===\n")

dashboard_inequidad <- trabajadores %>%
  inner_join(empleos %>% filter(empleo_activo), by = "id_trabajador") %>%
  inner_join(empresas, by = "id_empresa") %>%
  inner_join(viviendas, by = "id_trabajador") %>%
  
  mutate(
    indice_socioeconomico = case_when(
      valor_estimado >= quantile(valor_estimado, 0.8, na.rm = TRUE) ~ "Alto",
      valor_estimado >= quantile(valor_estimado, 0.4, na.rm = TRUE) ~ "Medio",
      TRUE ~ "Bajo"
    ),
    movilidad_geografica = provincia_nacimiento != provincia_vivienda,
    eficiencia_traslado = salario_bruto / (tiempo_traslado_min * 22 * 2)
  ) %>%
  
  group_by(provincia_vivienda, genero) %>%
  mutate(cuartil_salarial_provincial = ntile(salario_bruto, 4)) %>%
  ungroup() %>%
  
  group_by(rama_actividad) %>%
  mutate(cuartil_salarial_sectorial = ntile(salario_bruto, 4)) %>%
  ungroup() %>%
  
  group_by(provincia_vivienda, genero, nivel_educativo) %>%
  summarise(
    trabajadores = n(),
    salario_mediano = median(salario_bruto),
    prop_q4_provincial = mean(cuartil_salarial_provincial == 4),
    prop_movilidad_geo = mean(movilidad_geografica),
    .groups = 'drop'
  ) %>%
  
  pivot_wider(
    names_from = genero,
    values_from = c(trabajadores, salario_mediano, prop_q4_provincial),
    names_sep = "_"
  ) %>%
  
  mutate(
    brecha_salarial = round((salario_mediano_Hombre - salario_mediano_Mujer) / salario_mediano_Hombre * 100, 1),
    brecha_q4 = round(prop_q4_provincial_Hombre - prop_q4_provincial_Mujer, 3)
  ) %>%
  
  filter(!is.na(brecha_salarial), !is.infinite(brecha_salarial))

top_brechas_provinciales <- dashboard_inequidad %>%
  arrange(desc(brecha_salarial)) %>%
  head(3) %>%
  select(provincia_vivienda, nivel_educativo, brecha_salarial)

print("1. Top 3 combinaciones provincia-educación con mayor brecha salarial de género:")
print(top_brechas_provinciales)

menor_brecha_q4 <- dashboard_inequidad %>%
  group_by(nivel_educativo) %>%
  summarise(brecha_q4_promedio = mean(brecha_q4, na.rm = TRUE)) %>%
  arrange(brecha_q4_promedio)

print("\n2. Niveles educativos por brecha promedio en Q4 (menor = más equitativo):")
print(menor_brecha_q4)

ranking_equidad <- dashboard_inequidad %>%
  group_by(provincia_vivienda) %>%
  summarise(
    brecha_salarial_promedio = mean(brecha_salarial, na.rm = TRUE),
    brecha_q4_promedio = mean(abs(brecha_q4), na.rm = TRUE),
    casos_analizados = n()
  ) %>%
  mutate(
    indice_equidad = round(100 - (brecha_salarial_promedio + brecha_q4_promedio * 100) / 2, 1)
  ) %>%
  arrange(desc(indice_equidad))

print("\n3. Ranking de equidad laboral por provincia (mayor = más equitativo):")
print(ranking_equidad)

