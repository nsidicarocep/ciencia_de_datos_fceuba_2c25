# =============================================================================
# RESPUESTAS - EJERCICIOS TIDYVERSE CON DATOS REALES
# Fundamentos del Analisis Programatico de Datos
# =============================================================================

# Carga de librerias necesarias
library(tidyverse)
library(lubridate)

# =============================================================================
# CARGA DE DATASETS
# =============================================================================

# Simulacion de bases ILOSTAT (en la practica vendrian de archivos reales)
# Base 1: Employment by demographics
set.seed(123)
empleo_demo <- tibble(
  pais = rep(c("Argentina", "Brasil", "Chile", "Mexico", "Colombia"), each = 40),
  anio = rep(2015:2022, times = 25),
  sexo = rep(c("Male", "Female"), each = 100),
  sector = sample(c("Agriculture", "Manufacturing", "Services", "Construction"), 200, replace = TRUE),
  empleo = round(runif(200, 100, 2000))
)

# Base 2: Average earnings
salarios <- tibble(
  pais = rep(c("Argentina", "Brasil", "Chile", "Mexico", "Colombia"), each = 40),
  anio = rep(2015:2022, times = 25),
  sexo = rep(c("Male", "Female"), each = 100),
  sector = sample(c("Agriculture", "Manufacturing", "Services", "Construction"), 200, replace = TRUE),
  salario = round(runif(200, 800, 3500), 2)
)

# Base 3: Empleo sectores Argentina - datos reales
empleo_argentina <- read_csv("https://raw.githubusercontent.com/argendatafundar/data/main/ESTPRO/empleo_sectores_ggdc_1950_2018.csv")

# Base 4: VAB sectorial provincia - datos reales
vab_provincial <- read_csv("https://raw.githubusercontent.com/argendatafundar/data/main/ESTPRO/vab_sectorial_provincia.csv")

# Base 5: Salarios SBC - datos reales
salarios_sbc <- read_csv("https://raw.githubusercontent.com/argendatafundar/data/main/SEBACO/12_salarios_sbc_y_desagregado.csv")

# =============================================================================
# EJERCICIOS BASICOS - ILOSTAT EMPLOYMENT
# =============================================================================

# EJERCICIO 1: Exploracion basica
# Objetivo: select() y arrange()

respuesta_1 <- empleo_demo %>%
  # Seleccionar columnas especificas
  select(pais, anio, sexo, empleo) %>%
  # Ordenar por pais y anio ascendente
  arrange(pais, anio) %>%
  # Mostrar primeras 15 filas
  head(15)

# Verificar paises unicos
paises_unicos <- empleo_demo %>%
  select(pais) %>%
  distinct() %>%
  nrow()

cat("Paises unicos en la base:", paises_unicos)

# EJERCICIO 2: Filtros basicos  
# Objetivo: filter() y select()

respuesta_2 <- empleo_demo %>%
  # Filtrar solo anio 2020 y mujeres
  filter(anio == 2020, sexo == "Female") %>%
  # Seleccionar variables de interes
  select(pais, sector, empleo) %>%
  # Ordenar para identificar top 3
  arrange(desc(empleo))

# Contar observaciones post-filtro
obs_filtradas <- nrow(respuesta_2)
cat("Observaciones despues del filtro:", obs_filtradas)

# Top 3 paises con mayor empleo femenino en 2020
top_3_empleo_fem <- respuesta_2 %>%
  head(3)

# EJERCICIO 3: Creacion de variables
# Objetivo: mutate() y filter()

respuesta_3 <- empleo_demo %>%
  # Crear variable de clasificacion de empleo
  mutate(
    nivel_empleo = case_when(
      empleo >= 1000 ~ "Alto",
      empleo >= 500 ~ "Medio",
      TRUE ~ "Bajo"
    )
  ) %>%
  # Filtrar solo empleo alto
  filter(nivel_empleo == "Alto") %>%
  # Analizar sectores con mayor frecuencia de empleo alto
  count(sector, sort = TRUE) %>%
  head(5)

# EJERCICIO 4: Analisis por grupos
# Objetivo: group_by(), summarise(), arrange()

respuesta_4 <- empleo_demo %>%
  # Crear variable decada
  mutate(decada = paste0(10 * (anio %/% 10), "s")) %>%
  # Agrupar por decada
  group_by(decada) %>%
  # Calcular estadisticas por grupo
  summarise(
    empleo_promedio = round(mean(empleo)),
    empleo_maximo = max(empleo),
    empleo_minimo = min(empleo),
    .groups = 'drop'
  ) %>%
  # Ordenar por empleo promedio descendente
  arrange(desc(empleo_promedio))

# =============================================================================
# EJERCICIOS INTERMEDIOS - SALARIOS
# =============================================================================

# EJERCICIO 5: Brecha salarial por genero
# Objetivo: filter(), group_by(), summarise()

respuesta_5 <- salarios %>%
  # Filtrar periodo 2015-2020
  filter(anio >= 2015, anio <= 2020) %>%
  # Agrupar por sexo y sector
  group_by(sexo, sector) %>%
  # Calcular estadisticas salariales
  summarise(
    salario_promedio = round(mean(salario), 2),
    salario_mediano = round(median(salario), 2),
    .groups = 'drop'
  ) %>%
  # Ordenar para facilitar comparacion
  arrange(sector, desc(salario_promedio))

# Analisis de brecha por sector
brecha_salarial <- salarios %>%
  filter(anio >= 2015, anio <= 2020) %>%
  group_by(sector) %>%
  summarise(
    salario_hombres = mean(salario[sexo == "Male"]),
    salario_mujeres = mean(salario[sexo == "Female"]),
    .groups = 'drop'
  ) %>%
  mutate(
    diferencia_absoluta = salario_hombres - salario_mujeres,
    diferencia_porcentual = round(100 * diferencia_absoluta / salario_mujeres, 1)
  ) %>%
  arrange(desc(diferencia_absoluta))

# EJERCICIO 6: Ranking de sectores por salarios
# Objetivo: group_by(), summarise(), arrange(), mutate()

respuesta_6 <- salarios %>%
  # Agrupar por sector (ignorando sexo)
  group_by(sector) %>%
  # Calcular salario promedio por sector
  summarise(
    salario_promedio = round(mean(salario), 2),
    .groups = 'drop'
  ) %>%
  # Crear ranking
  mutate(ranking = row_number(desc(salario_promedio))) %>%
  # Ordenar por ranking
  arrange(ranking) %>%
  # Mostrar top 10
  head(10)

# Calcular diferencia entre sector #1 y #10
diferencia_top_10 <- respuesta_6$salario_promedio[1] - respuesta_6$salario_promedio[10]
cat("Diferencia salarial entre sector #1 y #10:", diferencia_top_10)

# EJERCICIO 7: Crecimiento salarial por decadas (sin lag/lead)
# Objetivo: mutate(), filter(), group_by(), summarise()

respuesta_7 <- salarios %>%
  # Filtrar un pais especifico para el analisis
  filter(pais == "Argentina") %>%
  # Crear variable decada
  mutate(decada = paste0(10 * (anio %/% 10), "s")) %>%
  # Agrupar por decada
  group_by(decada) %>%
  # Estrategia: usar min y max de cada decada para calcular crecimiento
  summarise(
    salario_inicial = min(salario),
    salario_final = max(salario),
    anio_inicial = min(anio),
    anio_final = max(anio),
    .groups = 'drop'
  ) %>%
  # Calcular crecimiento porcentual por decada
  mutate(
    crecimiento_pct = round(100 * (salario_final - salario_inicial) / salario_inicial, 1),
    anios_periodo = anio_final - anio_inicial + 1
  ) %>%
  # Ordenar por crecimiento
  arrange(desc(crecimiento_pct))

# =============================================================================
# EJERCICIOS ARGENTINA - DATOS HISTORICOS
# =============================================================================

# EJERCICIO 8: Transformacion productiva argentina
# Objetivo: filter(), mutate(), arrange()

# Primero explorar la estructura de la base
glimpse(empleo_argentina)

respuesta_8 <- empleo_argentina %>%
  # Filtrar anos cada 10 anos (ajustar segun variables reales de la base)
  filter(anio %in% c(1950, 1960, 1970, 1980, 1990, 2000, 2010, 2018)) %>%
  # Crear clasificacion por periodos historicos
  mutate(
    periodo_historico = case_when(
      anio >= 1950 & anio <= 1970 ~ "Industrializacion",
      anio >= 1980 & anio <= 2000 ~ "Crisis y ajuste", 
      anio >= 2001 ~ "Siglo XXI"
    )
  ) %>%
  # Ordenar por ano y sector para analizar cambios
  arrange(anio, sector) %>%
  # Analizar participacion por periodo (asumiendo que hay variable de participacion)
  group_by(periodo_historico, sector) %>%
  summarise(
    participacion_promedio = mean(participacion, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(periodo_historico, desc(participacion_promedio))

# EJERCICIO 9: Estabilidad sectorial
# Objetivo: group_by(), summarise(), mutate(), arrange()

respuesta_9 <- empleo_argentina %>%
  # Agrupar por sector productivo
  group_by(sector) %>%
  # Calcular estadisticas de estabilidad
  summarise(
    empleo_promedio = mean(empleo, na.rm = TRUE),
    participacion_promedio = mean(participacion, na.rm = TRUE),
    desvio_std = sd(participacion, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  # Calcular coeficiente de variacion (medida de volatilidad)
  mutate(
    coef_variacion = round(desvio_std / participacion_promedio, 3),
    ranking_participacion = dense_rank(desc(participacion_promedio)),
    ranking_estabilidad = dense_rank(coef_variacion)  # menor CV = mas estable
  ) %>%
  # Identificar sectores con alta participacion y baja volatilidad
  filter(ranking_participacion <= 5 | ranking_estabilidad <= 5) %>%
  arrange(ranking_participacion)

# =============================================================================
# EJERCICIOS INTEGRADORES - NUEVAS BASES
# =============================================================================

# EJERCICIO 10: Especializacion provincial
# Objetivo: Todas las funciones principales

# Primero explorar la base VAB provincial
glimpse(vab_provincial)

respuesta_10 <- vab_provincial %>%
  # Paso 1: Filtrar anos de interes cada 6 anos
  filter(anio %in% c(2004, 2010, 2016, 2022)) %>%
  # Paso 2: Calcular participacion de cada actividad por provincia y ano
  group_by(provincia_nombre, anio) %>%
  mutate(
    vab_total_provincial = sum(vab_pb, na.rm = TRUE),
    participacion_actividad = round(100 * vab_pb / vab_total_provincial, 2)
  ) %>%
  ungroup() %>%
  # Paso 3: Identificar actividad principal por provincia y ano
  group_by(provincia_nombre, anio) %>%
  mutate(actividad_principal = actividad_desc[which.max(participacion_actividad)]) %>%
  ungroup() %>%
  # Paso 4: Clasificar provincias segun especializacion
  group_by(provincia_nombre, anio) %>%
  summarise(
    actividad_principal = first(actividad_principal),
    max_participacion = max(participacion_actividad, na.rm = TRUE),
    # Obtener participacion de sectores clave (ajustar nombres segun base real)
    part_primario = sum(participacion_actividad[str_detect(actividad_desc, 
                       "Agricultura|Ganaderia|Pesca|Mineria")], na.rm = TRUE),
    part_industria = sum(participacion_actividad[str_detect(actividad_desc, 
                        "Industria|Manufactur")], na.rm = TRUE),
    part_servicios = sum(participacion_actividad[str_detect(actividad_desc, 
                        "Comercio|Servicio|Financ|Transporte")], na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  # Crear clasificacion de especializacion
  mutate(
    tipo_especializacion = case_when(
      part_primario > 30 ~ "Primario",
      part_industria > 25 ~ "Industrial", 
      part_servicios > 60 ~ "Servicios",
      TRUE ~ "Diversificado"
    )
  )

# Paso 5: Contar provincias por tipo y ano
resumen_especializacion <- respuesta_10 %>%
  group_by(anio, tipo_especializacion) %>%
  summarise(cantidad_provincias = n(), .groups = 'drop') %>%
  arrange(anio, desc(cantidad_provincias))

# Paso 6: Analizar cambios de especializacion 2004-2022
cambios_especializacion <- respuesta_10 %>%
  filter(anio %in% c(2004, 2022)) %>%
  select(provincia_nombre, anio, tipo_especializacion) %>%
  pivot_wider(names_from = anio, values_from = tipo_especializacion,
              names_prefix = "anio_") %>%
  mutate(cambio_especializacion = anio_2004 != anio_2022) %>%
  filter(cambio_especializacion == TRUE)

# EJERCICIO 11: Evolucion salarial por sectores SBC
# Objetivo: Todas las funciones principales

# Explorar estructura de salarios SBC
glimpse(salarios_sbc)

respuesta_11 <- salarios_sbc %>%
  # Paso 1: Crear variables temporales (ajustar segun formato fecha real)
  mutate(
    # Asumir que fecha esta en formato adecuado
    anio = year(fecha),
    decada = case_when(
      anio >= 2000 & anio <= 2009 ~ "2000s",
      anio >= 2010 & anio <= 2019 ~ "2010s", 
      anio >= 2020 ~ "2020s"
    )
  ) %>%
  # Paso 2: Filtrar decadas de interes
  filter(!is.na(decada)) %>%
  # Paso 3: Calcular salario promedio por sector y decada
  group_by(sector, decada) %>%
  summarise(
    salario_promedio = mean(salario, na.rm = TRUE),
    salario_inicial = min(salario, na.rm = TRUE),
    salario_final = max(salario, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  # Paso 4: Calcular crecimiento por sector y decada
  group_by(sector) %>%
  arrange(sector, decada) %>%
  mutate(
    # Crecimiento respecto a decada anterior (metodo simplificado)
    crecimiento_decada = round(100 * (salario_final - salario_inicial) / salario_inicial, 1)
  ) %>%
  ungroup()

# Paso 5: Top 5 sectores por crecimiento en cada decada
top_sectores_crecimiento <- respuesta_11 %>%
  group_by(decada) %>%
  arrange(desc(crecimiento_decada)) %>%
  slice_head(n = 5) %>%
  ungroup()

# Paso 6: Calcular brecha salarial por decada
brecha_intersectorial <- respuesta_11 %>%
  group_by(decada) %>%
  summarise(
    salario_max = max(salario_promedio, na.rm = TRUE),
    salario_min = min(salario_promedio, na.rm = TRUE),
    ratio_brecha = round(salario_max / salario_min, 2),
    .groups = 'drop'
  )

# Paso 7: Sectores consistentemente bien remunerados
sectores_top_consistentes <- respuesta_11 %>%
  group_by(sector) %>%
  summarise(
    ranking_promedio = mean(dense_rank(desc(salario_promedio))),
    apariciones_top25 = sum(dense_rank(desc(salario_promedio)) <= quantile(dense_rank(desc(salario_promedio)), 0.25)),
    .groups = 'drop'
  ) %>%
  filter(apariciones_top25 >= 2) %>%  # Presente en top 25% al menos 2 decadas
  arrange(ranking_promedio)

# EJERCICIO 12: Convergencia regional (INTEGRADOR AVANZADO)
# Objetivo: Analisis complejo con todas las funciones

respuesta_12 <- vab_provincial %>%
  # Paso 1: Calcular VAB per capita aproximado (simplificado)
  group_by(provincia_nombre, anio) %>%
  summarise(
    vab_total = sum(vab_pb, na.rm = TRUE),
    # Asumir poblacion aproximada basada en VAB (proxy muy simplificado)
    vab_per_capita_aprox = vab_total / 1000,  # Dividir por constante como proxy
    .groups = 'drop'
  ) %>%
  # Paso 2: Crear variables sectoriales
  left_join(
    vab_provincial %>%
      group_by(provincia_nombre, anio) %>%
      summarise(
        vab_industria = sum(vab_pb[str_detect(actividad_desc, "Industria|Manufactur")], na.rm = TRUE),
        vab_servicios = sum(vab_pb[str_detect(actividad_desc, "Comercio|Servicio|Financ")], na.rm = TRUE),
        .groups = 'drop'
      ),
    by = c("provincia_nombre", "anio")
  ) %>%
  # Paso 3: Calcular concentracion industrial por provincia
  group_by(provincia_nombre) %>%
  mutate(
    concentracion_industrial = vab_industria / vab_total,
    coef_var_industrial = sd(concentracion_industrial, na.rm = TRUE) / mean(concentracion_industrial, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  # Paso 4: Calcular distancia al promedio nacional
  group_by(anio) %>%
  mutate(
    vab_nacional_promedio = mean(vab_per_capita_aprox, na.rm = TRUE),
    distancia_promedio_nacional = abs(vab_per_capita_aprox - vab_nacional_promedio),
    distancia_relativa = distancia_promedio_nacional / vab_nacional_promedio
  ) %>%
  ungroup() %>%
  # Paso 5: Analizar convergencia (provincias pobres crecen mas rapido?)
  group_by(provincia_nombre) %>%
  arrange(anio) %>%
  mutate(
    vab_inicial = first(vab_per_capita_aprox),
    vab_final = last(vab_per_capita_aprox),
    tasa_crecimiento = (vab_final - vab_inicial) / vab_inicial
  ) %>%
  ungroup() %>%
  # Paso 6: Identificar outliers
  mutate(
    es_outlier_crecimiento = abs(tasa_crecimiento) > 2 * sd(tasa_crecimiento, na.rm = TRUE),
    tipo_outlier = case_when(
      tasa_crecimiento > 2 * sd(tasa_crecimiento, na.rm = TRUE) ~ "Crecimiento excepcional",
      tasa_crecimiento < -2 * sd(tasa_crecimiento, na.rm = TRUE) ~ "Declive marcado", 
      TRUE ~ "Normal"
    )
  ) %>%
  # Paso 7: Crear tipologia final
  mutate(
    tipologia_provincial = case_when(
      vab_per_capita_aprox > quantile(vab_per_capita_aprox, 0.75, na.rm = TRUE) ~ "Desarrollada",
      tasa_crecimiento > quantile(tasa_crecimiento, 0.75, na.rm = TRUE) ~ "En crecimiento",
      tasa_crecimiento < quantile(tasa_crecimiento, 0.25, na.rm = TRUE) ~ "En declive",
      TRUE ~ "Estancada"
    )
  )

# Resumen final de convergencia
convergencia_resumen <- respuesta_12 %>%
  group_by(anio) %>%
  summarise(
    coef_variacion_regional = sd(vab_per_capita_aprox, na.rm = TRUE) / mean(vab_per_capita_aprox, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    tendencia_convergencia = case_when(
      coef_variacion_regional < lag(coef_variacion_regional) ~ "Convergiendo",
      coef_variacion_regional > lag(coef_variacion_regional) ~ "Divergiendo", 
      TRUE ~ "Estable"
    )
  )

# =============================================================================
# VERIFICACIONES Y OUTPUTS FINALES
# =============================================================================

cat("=====================================")
cat("RESUMEN DE EJERCICIOS COMPLETADOS")
cat("=====================================")

cat("\nEJERCICIO 1 - Exploracion basica:")
print(respuesta_1)

cat("\nEJERCICIO 2 - Filtros basicos:")
print(head(respuesta_2))

cat("\nEJERCICIO 3 - Creacion de variables:")
print(respuesta_3)

cat("\nEJERCICIO 4 - Analisis por grupos:")
print(respuesta_4)

cat("\nEJERCICIO 5 - Brecha salarial:")
print(head(respuesta_5))

cat("\nBRECHA SALARIAL POR SECTOR:")
print(head(brecha_salarial))

cat("\nEJERCICIO 6 - Ranking sectores:")
print(respuesta_6)

cat("\nEJERCICIO 7 - Crecimiento salarial:")
print(respuesta_7)

# Para ejercicios con datos reales, verificar primero si las bases se cargaron correctamente
if(exists("empleo_argentina") && nrow(empleo_argentina) > 0) {
  cat("\nEJERCICIO 8 - Transformacion Argentina:")
  print(head(respuesta_8))
  
  cat("\nEJERCICIO 9 - Estabilidad sectorial:")
  print(head(respuesta_9))
}

if(exists("vab_provincial") && nrow(vab_provincial) > 0) {
  cat("\nEJERCICIO 10 - Especializacion provincial:")
  print(head(resumen_especializacion))
  
  cat("\nCAMBIOS DE ESPECIALIZACION 2004-2022:")
  print(cambios_especializacion)
}

if(exists("salarios_sbc") && nrow(salarios_sbc) > 0) {
  cat("\nEJERCICIO 11 - Salarios SBC:")
  print(head(top_sectores_crecimiento))
  
  cat("\nBRECHA INTERSECTORIAL POR DECADA:")
  print(brecha_intersectorial)
}

if(exists("vab_provincial") && nrow(vab_provincial) > 0) {
  cat("\nEJERCICIO 12 - Convergencia regional:")
  print(head(convergencia_resumen))
}

cat("\n=====================================")
cat("ANALISIS COMPLETADO")
cat("=====================================")
