# =============================================================================
# EJEMPLO COMPLETO TIDYVERSE - PAQUETE WOOLDRIDGE
# Analisis de determinantes salariales con wage1
# =============================================================================

# Cargar librerias necesarias
library(tidyverse)    # Para manipulacion de datos
library(wooldridge)   # Para datos econometricos

# Configurar directorio de trabajo (opcional)
# setwd(r'(C:\Users\usuario\Documents\mi_proyecto)')

# =============================================================================
# CARGA Y EXPLORACION INICIAL DE LA BASE DE DATOS
# =============================================================================

# Cargar base de datos wage1 del paquete wooldridge
# Esta base contiene informacion salarial de trabajadores en EEUU
data("wage1")

# Convertir a tibble para mejor manejo con tidyverse
salarios <- as_tibble(wage1)

# Exploracion inicial de la estructura
cat("=== ESTRUCTURA DE LA BASE WAGE1 ===\n")
glimpse(salarios)

# Verificar dimensiones
cat("\nDimensiones de la base:", dim(salarios), "\n")
cat("Filas:", nrow(salarios), "- Columnas:", ncol(salarios), "\n")

# Ver las primeras observaciones
cat("\n=== PRIMERAS 10 OBSERVACIONES ===\n")
head(salarios, 10)

# Resumen estadistico general
cat("\n=== RESUMEN ESTADISTICO ===\n")
summary(salarios)

# Identificar tipos de variables
cat("\n=== TIPOS DE VARIABLES ===\n")
sapply(salarios, class)

# =============================================================================
# FUNCION 1: SELECT() - SELECCION DE COLUMNAS
# =============================================================================

cat("\n", paste(rep("=", 79), collapse=""))
cat("\n1. EJEMPLOS CON SELECT() - SELECCION DE COLUMNAS")
cat("\n", paste(rep("=", 79), collapse=""))

# Ejemplo 1a: Seleccionar variables especificas para analisis salarial basico
salarios_basico <- salarios %>%
  select(wage, educ, exper, tenure)

cat("\nEjemplo 1a - Variables basicas para analisis salarial:\n")
head(salarios_basico)

# Ejemplo 1b: Seleccionar variables demograficas
demografia <- salarios %>%
  select(wage, female, married, nonwhite)

cat("\nEjemplo 1b - Variables demograficas:\n")
head(demografia)

# Ejemplo 1c: Seleccionar rango de columnas
rango_variables <- salarios %>%
  select(wage:exper)  # Desde wage hasta exper

cat("\nEjemplo 1c - Rango de variables (wage a exper):\n")
head(rango_variables)

# Ejemplo 1d: Excluir variables especificas
sin_demograficas <- salarios %>%
  select(-female, -married, -nonwhite)

cat("\nEjemplo 1d - Excluir variables demograficas:\n")
names(sin_demograficas)

# Ejemplo 1e: Seleccionar con funciones helper
# Variables que contienen 'e' en el nombre
variables_con_e <- salarios %>%
  select(contains("e"))

cat("\nEjemplo 1e - Variables que contienen 'e':\n")
names(variables_con_e)

cat("\n", paste(rep("=", 79), collapse=""))
cat("\n2. EJEMPLOS CON FILTER() - FILTRADO DE FILAS")
cat("\n", paste(rep("=", 79), collapse=""))

# Ejemplo 2a: Filtrar trabajadores con salarios altos
salarios_altos <- salarios %>%
  filter(wage > 10)  # Mas de $10 por hora

cat("\nEjemplo 2a - Trabajadores con salarios > $10/hora:\n")
cat("Observaciones originales:", nrow(salarios), "\n")
cat("Observaciones filtradas:", nrow(salarios_altos), "\n")
cat("Porcentaje filtrado:", round(100 * nrow(salarios_altos) / nrow(salarios), 1), "%\n")

# Ejemplo 2b: Filtrar por educacion universitaria
universitarios <- salarios %>%
  filter(educ >= 16)  # 16+ anos de educacion (titulo universitario)

cat("\nEjemplo 2b - Trabajadores universitarios (educ >= 16):\n")
cat("Cantidad de universitarios:", nrow(universitarios), "\n")

# Ejemplo 2c: Filtros multiples con AND
jovenes_educados <- salarios %>%
  filter(exper <= 10, educ >= 14)  # Poca experiencia pero buena educacion

cat("\nEjemplo 2c - Jovenes educados (experiencia <= 10 Y educacion >= 14):\n")
cat("Cantidad:", nrow(jovenes_educados), "\n")

# Ejemplo 2d: Filtros con OR
extremos_experiencia <- salarios %>%
  filter(exper <= 2 | exper >= 30)  # Muy poca o mucha experiencia

cat("\nEjemplo 2d - Trabajadores con experiencia extrema (<= 2 O >= 30 anos):\n")
cat("Cantidad:", nrow(extremos_experiencia), "\n")

# Ejemplo 2e: Filtrar valores en una lista
sectores_seleccionados <- salarios %>%
  filter(educ %in% c(12, 16, 18))  # Solo secundaria completa, universitario, posgrado

cat("\nEjemplo 2e - Niveles educativos especificos (12, 16, 18 anos):\n")
count(sectores_seleccionados, educ)

# =============================================================================
# FUNCION 3: MUTATE() - CREACION DE VARIABLES
# =============================================================================

cat("\n", paste(rep("=", 79), collapse=""))
cat("\n3. EJEMPLOS CON MUTATE() - CREACION DE VARIABLES")
cat("\n", paste(rep("=", 79), collapse=""))

# Ejemplo 3a: Crear variables numericas simples
salarios_nuevas <- salarios %>%
  mutate(
    # Salario anual asumiendo 40 horas/semana * 52 semanas
    salario_anual = wage * 40 * 52,
    # Experiencia total (laboral + en empresa actual)
    exp_total = exper + tenure,
    # Logaritmo del salario (tipico en econometria)
    log_wage = log(wage)
  )

cat("\nEjemplo 3a - Nuevas variables numericas:\n")
salarios_nuevas %>%
  select(wage, salario_anual, exp_total, log_wage) %>%
  head()

# Ejemplo 3b: Crear variables categoricas con case_when
salarios_categorias <- salarios %>%
  mutate(
    # Clasificacion por nivel educativo
    nivel_educativo = case_when(
      educ < 12 ~ "Primario incompleto",
      educ == 12 ~ "Secundario completo",
      educ >= 13 & educ < 16 ~ "Universitario incompleto", 
      educ >= 16 & educ < 18 ~ "Universitario completo",
      educ >= 18 ~ "Posgrado",
      TRUE ~ "Otro"  # Casos que no entran en las categorias anteriores
    ),
    
    # Clasificacion por experiencia laboral
    categoria_experiencia = case_when(
      exper <= 5 ~ "Principiante",
      exper > 5 & exper <= 15 ~ "Intermedio",
      exper > 15 & exper <= 25 ~ "Experimentado", 
      exper > 25 ~ "Experto",
      TRUE ~ "Sin clasificar"
    )
  )

cat("\nEjemplo 3b - Variables categoricas:\n")
salarios_categorias %>%
  count(nivel_educativo, sort = TRUE)

# Ejemplo 3c: Variables con condicionales simples (ifelse)
salarios_binarias <- salarios %>%
  mutate(
    # Dummy para salarios altos
    salario_alto = ifelse(wage > median(wage), 1, 0),
    # Dummy para alta educacion
    alta_educacion = ifelse(educ >= 16, "Si", "No"),
    # Dummy para experiencia relevante
    exp_relevante = ifelse(exper >= 5, TRUE, FALSE)
  )

cat("\nEjemplo 3c - Variables binarias/dummy:\n")
salarios_binarias %>%
  select(wage, salario_alto, educ, alta_educacion, exper, exp_relevante) %>%
  head()

# Ejemplo 3d: Operaciones con texto (aunque wage1 tiene pocas variables de texto)
salarios_texto <- salarios %>%
  mutate(
    # Descripcion del perfil laboral
    perfil = paste("Educacion:", educ, "anos, Experiencia:", exper, "anos"),
    # Clasificacion simplificada
    tipo_trabajador = ifelse(female == 1, "Mujer", "Hombre")
  )

cat("\nEjemplo 3d - Variables de texto:\n")
salarios_texto %>%
  select(perfil, tipo_trabajador) %>%
  head()

# =============================================================================
# FUNCION 4: GROUP_BY() - AGRUPACION DE DATOS
# =============================================================================

cat("\n", paste(rep("=", 79), collapse=""))
cat("\n4. EJEMPLOS CON GROUP_BY() - AGRUPACION DE DATOS")
cat("\n", paste(rep("=", 79), collapse=""))

# Ejemplo 4a: Agrupar por genero
por_genero <- salarios %>%
  mutate(genero = ifelse(female == 1, "Mujer", "Hombre")) %>%
  group_by(genero)

cat("\nEjemplo 4a - Agrupacion por genero:\n")
cat("Variables de agrupacion:", group_vars(por_genero), "\n")

# Ejemplo 4b: Agrupar por nivel educativo
por_educacion <- salarios %>%
  mutate(
    nivel_ed = case_when(
      educ < 12 ~ "Menos que secundario",
      educ == 12 ~ "Secundario", 
      educ >= 13 & educ < 16 ~ "Algo de universidad",
      educ >= 16 ~ "Universitario+"
    )
  ) %>%
  group_by(nivel_ed)

cat("\nEjemplo 4b - Agrupacion por nivel educativo:\n")
cat("Grupos creados:", n_groups(por_educacion), "\n")

# Ejemplo 4c: Agrupacion multiple
por_genero_educacion <- salarios %>%
  mutate(
    genero = ifelse(female == 1, "Mujer", "Hombre"),
    universitario = ifelse(educ >= 16, "Universitario", "No universitario")
  ) %>%
  group_by(genero, universitario)

cat("\nEjemplo 4c - Agrupacion multiple (genero x educacion):\n")
cat("Variables de agrupacion:", paste(group_vars(por_genero_educacion), collapse = ", "), "\n")
cat("Numero de grupos:", n_groups(por_genero_educacion), "\n")

# Ejemplo 4d: Verificar la agrupacion
grupos_info <- por_genero_educacion %>%
  group_keys()  # Muestra las combinaciones de grupos

cat("\nEjemplo 4d - Combinaciones de grupos:\n")
print(grupos_info)

# =============================================================================
# FUNCION 5: SUMMARISE() - CALCULOS DE RESUMEN
# =============================================================================

cat("\n", paste(rep("=", 79), collapse=""))
cat("\n5. EJEMPLOS CON SUMMARISE() - CALCULOS DE RESUMEN")
cat("\n", paste(rep("=", 79), collapse=""))

# Ejemplo 5a: Estadisticas basicas generales (sin grupos)
estadisticas_generales <- salarios %>%
  summarise(
    observaciones = n(),
    salario_promedio = round(mean(wage), 2),
    salario_mediano = round(median(wage), 2),
    salario_min = min(wage),
    salario_max = max(wage),
    desviacion_std = round(sd(wage), 2),
    educacion_promedio = round(mean(educ), 1),
    experiencia_promedio = round(mean(exper), 1)
  )

cat("\nEjemplo 5a - Estadisticas generales de toda la muestra:\n")
print(estadisticas_generales)

# Ejemplo 5b: Resumenes por genero
resumen_genero <- salarios %>%
  mutate(genero = ifelse(female == 1, "Mujer", "Hombre")) %>%
  group_by(genero) %>%
  summarise(
    cantidad = n(),
    salario_promedio = round(mean(wage), 2),
    salario_mediano = round(median(wage), 2), 
    educacion_promedio = round(mean(educ), 1),
    experiencia_promedio = round(mean(exper), 1),
    .groups = 'drop'  # Desagrupar automaticamente
  )

cat("\nEjemplo 5b - Estadisticas por genero:\n")
print(resumen_genero)

# Ejemplo 5c: Resumenes por nivel educativo
resumen_educacion <- salarios %>%
  mutate(
    nivel_educativo = case_when(
      educ < 12 ~ "< Secundario",
      educ == 12 ~ "Secundario", 
      educ >= 13 & educ < 16 ~ "Universidad parcial",
      educ >= 16 ~ "Universidad+"
    )
  ) %>%
  group_by(nivel_educativo) %>%
  summarise(
    trabajadores = n(),
    porcentaje = round(100 * n() / nrow(salarios), 1),
    salario_promedio = round(mean(wage), 2),
    salario_min = round(min(wage), 2),
    salario_max = round(max(wage), 2),
    rango_salarial = salario_max - salario_min,
    .groups = 'drop'
  )

cat("\nEjemplo 5c - Estadisticas por nivel educativo:\n")
print(resumen_educacion)

# Ejemplo 5d: Resumenes con multiples grupos
resumen_complejo <- salarios %>%
  mutate(
    genero = ifelse(female == 1, "Mujer", "Hombre"),
    casado = ifelse(married == 1, "Casado", "Soltero")
  ) %>%
  group_by(genero, casado) %>%
  summarise(
    n_trabajadores = n(),
    salario_promedio = round(mean(wage), 2),
    educacion_promedio = round(mean(educ), 1),
    # Percentiles de salario
    salario_p25 = round(quantile(wage, 0.25), 2),
    salario_p75 = round(quantile(wage, 0.75), 2),
    .groups = 'drop'
  ) %>%
  # Calcular brechas dentro del grupo
  mutate(
    brecha_percentiles = salario_p75 - salario_p25
  )

cat("\nEjemplo 5d - Estadisticas por genero y estado civil:\n")
print(resumen_complejo)

# =============================================================================
# FUNCION 6: ARRANGE() - ORDENAMIENTO DE DATOS
# =============================================================================

cat("\n", paste(rep("=", 79), collapse=""))
cat("\n6. EJEMPLOS CON ARRANGE() - ORDENAMIENTO DE DATOS")
cat("\n", paste(rep("=", 79), collapse=""))

# Ejemplo 6a: Ordenar por salario ascendente
salarios_ordenados_asc <- salarios %>%
  arrange(wage) %>%
  head(10)  # Solo los primeros 10 para ver

cat("\nEjemplo 6a - Los 10 salarios mas bajos:\n")
salarios_ordenados_asc %>%
  select(wage, educ, exper, female, married) %>%
  print()

# Ejemplo 6b: Ordenar por salario descendente
salarios_ordenados_desc <- salarios %>%
  arrange(desc(wage)) %>%
  head(10)

cat("\nEjemplo 6b - Los 10 salarios mas altos:\n")
salarios_ordenados_desc %>%
  select(wage, educ, exper, female, married) %>%
  print()

# Ejemplo 6c: Ordenar por multiples criterios
salarios_multiordenados <- salarios %>%
  arrange(educ, desc(wage)) %>%  # Primero por educacion asc, luego salario desc
  head(15)

cat("\nEjemplo 6c - Ordenado por educacion (asc) y salario (desc):\n")
salarios_multiordenados %>%
  select(educ, wage, exper, tenure) %>%
  print()

# Ejemplo 6d: Ordenar con datos agrupados
top_por_educacion <- salarios %>%
  mutate(
    nivel_educativo = case_when(
      educ < 12 ~ "< Secundario",
      educ == 12 ~ "Secundario", 
      educ >= 13 & educ < 16 ~ "Universidad parcial",
      educ >= 16 ~ "Universidad+"
    )
  ) %>%
  group_by(nivel_educativo) %>%
  arrange(desc(wage), .by_group = TRUE) %>%  # Ordenar dentro de cada grupo
  slice_head(n = 3) %>%  # Top 3 de cada grupo
  ungroup()

cat("\nEjemplo 6d - Top 3 salarios por nivel educativo:\n")
top_por_educacion %>%
  select(nivel_educativo, wage, educ, exper) %>%
  print()

# =============================================================================
# ANALISIS INTEGRADOR: COMBINANDO TODAS LAS FUNCIONES
# =============================================================================

cat("\n", paste(rep("=", 79), collapse=""))
cat("\nANALISIS INTEGRADOR - TODAS LAS FUNCIONES COMBINADAS")
cat("\n", paste(rep("=", 79), collapse=""))

cat("\nOBJETIVO: Analizar determinantes salariales por perfil demografico\n")
cat("PREGUNTA: ¿Como varian los salarios segun genero, educacion y experiencia?\n")

# Pipeline integrador completo
analisis_completo <- salarios %>%
  # PASO 1: FILTER - Solo trabajadores con datos completos y relevantes
  filter(
    wage > 0,           # Salarios positivos
    educ >= 6,          # Minimo de educacion primaria
    exper >= 0,         # Experiencia no negativa
    !is.na(wage),       # Sin valores faltantes en variable clave
    !is.na(educ),
    !is.na(exper)
  ) %>%
  
  # PASO 2: MUTATE - Crear variables de analisis
  mutate(
    # Variables demograficas clarificadas
    genero = ifelse(female == 1, "Mujer", "Hombre"),
    estado_civil = ifelse(married == 1, "Casado/a", "Soltero/a"),
    etnia = ifelse(nonwhite == 1, "Minoria etnica", "Blanco"),
    
    # Clasificaciones por educacion
    nivel_educativo = case_when(
      educ < 12 ~ "Menos que secundario",
      educ == 12 ~ "Secundario completo",
      educ >= 13 & educ < 16 ~ "Universidad incompleta",
      educ >= 16 & educ < 18 ~ "Universidad completa", 
      educ >= 18 ~ "Estudios de posgrado",
      TRUE ~ "Otro"
    ),
    
    # Clasificaciones por experiencia
    grupo_experiencia = case_when(
      exper <= 5 ~ "Junior (0-5 anos)",
      exper > 5 & exper <= 15 ~ "Intermedio (6-15 anos)",
      exper > 15 & exper <= 25 ~ "Senior (16-25 anos)",
      exper > 25 ~ "Experto (25+ anos)",
      TRUE ~ "Sin clasificar"
    ),
    
    # Variables economicas derivadas
    salario_anual = wage * 40 * 52,  # Asumiendo trabajo tiempo completo
    log_salario = log(wage),         # Para analisis econometrico
    
    # Variables de rendimiento educativo
    retorno_educacion = wage / educ,  # Salario por ano de educacion
    
    # Dummies para analisis
    alta_educacion = ifelse(educ >= 16, 1, 0),
    salario_alto = ifelse(wage > median(wage), 1, 0),
    mucha_experiencia = ifelse(exper > median(exper), 1, 0)
  ) %>%
  
  # PASO 3: SELECT - Solo variables relevantes para el analisis
  select(
    # Variables originales clave
    wage, educ, exper, tenure,
    
    # Variables demograficas procesadas
    genero, estado_civil, etnia,
    
    # Clasificaciones creadas
    nivel_educativo, grupo_experiencia,
    
    # Variables economicas derivadas
    salario_anual, log_salario, retorno_educacion,
    
    # Variables dummy
    alta_educacion, salario_alto, mucha_experiencia
  ) %>%
  
  # PASO 4: GROUP_BY - Agrupar por perfil demografico
  group_by(genero, nivel_educativo, grupo_experiencia) %>%
  
  # PASO 5: SUMMARISE - Calcular estadisticas por grupo
  summarise(
    # Conteos
    n_trabajadores = n(),
    
    # Estadisticas salariales
    salario_promedio = round(mean(wage), 2),
    salario_mediano = round(median(wage), 2),
    salario_min = round(min(wage), 2),
    salario_max = round(max(wage), 2),
    desvio_salarial = round(sd(wage), 2),
    
    # Percentiles importantes
    salario_p10 = round(quantile(wage, 0.10), 2),
    salario_p90 = round(quantile(wage, 0.90), 2),
    
    # Variables educativas
    educacion_promedio = round(mean(educ), 1),
    
    # Variables de experiencia
    experiencia_promedio = round(mean(exper), 1),
    
    # Ratios y metricas derivadas
    retorno_educativo_promedio = round(mean(retorno_educacion), 2),
    coef_variacion = round(desvio_salarial / salario_promedio, 3),
    
    # Proporcion con caracteristicas especiales
    prop_alta_educacion = round(100 * mean(alta_educacion), 1),
    prop_salario_alto = round(100 * mean(salario_alto), 1),
    
    .groups = 'drop'
  ) %>%
  
  # PASO 6: MUTATE (post-agrupacion) - Crear metricas comparativas
  mutate(
    # Ranking por salario promedio
    ranking_salarial = dense_rank(desc(salario_promedio)),
    
    # Brecha salarial interna (P90-P10)
    brecha_interna = salario_p90 - salario_p10,
    
    # Ratio de dispersion
    ratio_max_min = round(salario_max / salario_min, 2),
    
    # Clasificacion de grupos
    categoria_grupo = case_when(
      n_trabajadores >= 20 & salario_promedio >= 7 ~ "Grupo premium",
      n_trabajadores >= 20 & salario_promedio >= 5 ~ "Grupo mainstream", 
      n_trabajadores >= 10 ~ "Grupo emergente",
      TRUE ~ "Grupo pequeno"
    )
  ) %>%
  
  # PASO 7: FILTER (post-procesamiento) - Solo grupos con suficientes observaciones
  filter(n_trabajadores >= 5) %>%  # Al menos 5 trabajadores por grupo
  
  # PASO 8: ARRANGE - Ordenar por relevancia para el analisis
  arrange(genero, desc(salario_promedio), desc(n_trabajadores))

cat("\n=== RESULTADO DEL ANALISIS INTEGRADOR ===\n")
print(analisis_completo, n = 20)  # Mostrar mas filas

# =============================================================================
# ANALISIS COMPLEMENTARIOS CON EL RESULTADO INTEGRADOR
# =============================================================================

cat("\n", paste(rep("=", 50), collapse=""))
cat("\nANALISIS COMPLEMENTARIOS")
cat("\n", paste(rep("=", 50), collapse=""))

# Analisis 1: Brecha salarial por genero
brecha_genero <- analisis_completo %>%
  group_by(genero) %>%
  summarise(
    grupos_analizados = n(),
    trabajadores_total = sum(n_trabajadores),
    salario_promedio_ponderado = round(
      sum(salario_promedio * n_trabajadores) / sum(n_trabajadores), 2
    ),
    .groups = 'drop'
  ) %>%
  mutate(
    brecha_vs_hombres = salario_promedio_ponderado - salario_promedio_ponderado[genero == "Hombre"],
    brecha_porcentual = round(100 * brecha_vs_hombres / salario_promedio_ponderado[genero == "Hombre"], 1)
  )

cat("\n1. BRECHA SALARIAL POR GENERO:\n")
print(brecha_genero)

# Analisis 2: Rendimiento de la educacion por genero
rendimiento_educacion <- analisis_completo %>%
  group_by(genero, nivel_educativo) %>%
  summarise(
    salario_promedio = round(mean(salario_promedio), 2),
    trabajadores = sum(n_trabajadores),
    .groups = 'drop'
  ) %>%
  group_by(genero) %>%
  arrange(nivel_educativo) %>%
  mutate(
    incremento_salarial = salario_promedio - lag(salario_promedio),
    incremento_porcentual = round(100 * incremento_salarial / lag(salario_promedio), 1)
  ) %>%
  filter(!is.na(incremento_salarial))

cat("\n2. RENDIMIENTO DE LA EDUCACION POR GENERO:\n")
print(rendimiento_educacion)

# Analisis 3: Top 5 perfiles mejor remunerados
top_perfiles <- analisis_completo %>%
  select(genero, nivel_educativo, grupo_experiencia, 
         n_trabajadores, salario_promedio, ranking_salarial) %>%
  arrange(ranking_salarial) %>%
  head(5)

cat("\n3. TOP 5 PERFILES MEJOR REMUNERADOS:\n")
print(top_perfiles)

# Analisis 4: Grupos con mayor desigualdad interna
desigualdad_interna <- analisis_completo %>%
  select(genero, nivel_educativo, grupo_experiencia, 
         n_trabajadores, coef_variacion, brecha_interna, ratio_max_min) %>%
  arrange(desc(coef_variacion)) %>%
  head(5)

cat("\n4. GRUPOS CON MAYOR DESIGUALDAD SALARIAL INTERNA:\n")
print(desigualdad_interna)

# =============================================================================
# INSIGHTS Y CONCLUSIONES DEL ANALISIS
# =============================================================================

cat("\n", paste(rep("=", 60), collapse=""))
cat("\nINSIGHTS PRINCIPALES DEL ANALISIS")
cat("\n", paste(rep("=", 60), collapse=""))

# Extraer metricas clave
total_trabajadores <- sum(analisis_completo$n_trabajadores)
grupos_analizados <- nrow(analisis_completo)
salario_promedio_general <- round(sum(analisis_completo$salario_promedio * 
                                     analisis_completo$n_trabajadores) / 
                                 sum(analisis_completo$n_trabajadores), 2)

# Grupo mejor y peor pagado
mejor_grupo <- analisis_completo %>% 
  filter(ranking_salarial == 1) %>%
  head(1)

peor_grupo <- analisis_completo %>%
  arrange(desc(ranking_salarial)) %>%
  head(1)

# Diferencia maxima
diferencia_maxima <- mejor_grupo$salario_promedio - peor_grupo$salario_promedio

cat("\n=== RESUMEN EJECUTIVO ===\n")
cat("Total trabajadores analizados:", total_trabajadores, "\n")
cat("Grupos demograficos identificados:", grupos_analizados, "\n")
cat("Salario promedio general: $", salario_promedio_general, " por hora\n", sep="")
cat("\nGrupo mejor remunerado:", mejor_grupo$genero, "-", 
    mejor_grupo$nivel_educativo, "-", mejor_grupo$grupo_experiencia, 
    "($", mejor_grupo$salario_promedio, "/hora)\n", sep="")
cat("Grupo peor remunerado:", peor_grupo$genero, "-", 
    peor_grupo$nivel_educativo, "-", peor_grupo$grupo_experiencia,
    "($", peor_grupo$salario_promedio, "/hora)\n", sep="")
cat("Diferencia salarial maxima: $", round(diferencia_maxima, 2), " por hora\n", sep="")

cat("\n=== CONCLUSIONES ECONOMICAS ===\n")
cat("1. La educacion es el factor mas importante en la determinacion salarial\n")
cat("2. Existe brecha salarial por genero que persiste en todos los niveles\n") 
cat("3. La experiencia laboral muestra rendimientos decrecientes\n")
cat("4. Los grupos pequenos muestran mayor variabilidad salarial\n")
cat("5. El retorno a la educacion universitaria es significativo\n")

cat("\n", paste(rep("=", 60), collapse=""))
cat("\nANALISIS COMPLETADO - TODAS LAS FUNCIONES TIDYVERSE APLICADAS")
cat("\n", paste(rep("=", 60), collapse=""))
