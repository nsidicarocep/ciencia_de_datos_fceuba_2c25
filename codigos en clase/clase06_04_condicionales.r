# ============================================================================
# LÓGICA CONDICIONAL EN ANÁLISIS ECONÓMICO
# if_else() y case_when() con casos de uso reales
# ============================================================================

library(tidyverse)

# Datos de ejemplo: países latinoamericanos con indicadores económicos
datos_paises <- tibble(
  pais = c("Argentina", "Brasil", "Chile", "Colombia", "México", "Perú", "Uruguay"),
  pib_percapita = c(10423, 8897, 16265, 6131, 9926, 6692, 17278),
  inflacion_2023 = c(133.0, 4.6, 7.6, 13.1, 4.7, 1.3, 5.9),
  desempleo = c(5.7, 7.9, 7.6, 10.1, 2.8, 7.2, 8.3),
  gini = c(41.4, 48.9, 44.4, 51.3, 45.4, 42.8, 39.7),
  poblacion_millones = c(45.8, 215.3, 19.6, 51.9, 128.9, 33.7, 3.4),
  exportaciones_pct_pib = c(16.9, 18.4, 31.4, 16.2, 39.3, 24.1, 18.7)
)

print("Datos base:")
print(datos_paises)

# ============================================================================
# 1. IF_ELSE(): PARA DECISIONES BINARIAS SIMPLES
# ============================================================================

cat("\n=== IF_ELSE: Clasificaciones binarias ===\n")

# Casos ideales para if_else(): clasificaciones claras con dos opciones
clasificaciones_binarias <- datos_paises %>%
  mutate(
    # 1. Nivel de desarrollo (criterio simple)
    desarrollo = if_else(
      pib_percapita > 12000, 
      "Desarrollado", 
      "En desarrollo"
    ),
    
    # 2. Estabilidad de precios
    inflacion_controlada = if_else(
      inflacion_2023 <= 10, 
      "Estable", 
      "Alta inflación"
    ),
    
    # 3. Tamaño de economía
    economia_grande = if_else(
      poblacion_millones > 50, 
      "Grande", 
      "Pequeña/Mediana"
    ),
    
    # 4. Apertura comercial
    economia_abierta = if_else(
      exportaciones_pct_pib > 25, 
      "Abierta", 
      "Cerrada"
    ),
    
    # 5. Validación de datos (útil para limpieza)
    desempleo_valido = if_else(
      desempleo >= 0 & desempleo <= 30, 
      "Válido", 
      "Revisar"
    ),
    
    # 6. Aplicar políticas (subsidios, programas sociales)
    elegible_ayuda = if_else(
      pib_percapita < 8000 & desempleo > 8, 
      "Elegible", 
      "No elegible"
    )
  )

print("Clasificaciones con if_else():")
print(clasificaciones_binarias %>% 
  select(pais, pib_percapita, desarrollo, inflacion_controlada, economia_abierta))

# ============================================================================
# 2. CASE_WHEN(): PARA LÓGICA COMPLEJA Y JERÁRQUICA
# ============================================================================

cat("\n=== CASE_WHEN: Clasificaciones complejas ===\n")

# Casos que requieren case_when(): múltiples criterios y jerarquías
clasificaciones_complejas <- datos_paises %>%
  mutate(
    # 1. Clasificación de desarrollo (múltiples niveles)
    categoria_desarrollo = case_when(
      pib_percapita > 15000 ~ "Alto desarrollo",
      pib_percapita > 10000 ~ "Desarrollo medio-alto",
      pib_percapita > 6000 ~ "Desarrollo medio",
      pib_percapita > 3000 ~ "Desarrollo medio-bajo",
      TRUE ~ "Bajo desarrollo"
    ),
    
    # 2. Tipología macroeconómica (múltiples variables)
    perfil_macro = case_when(
      inflacion_2023 > 50 & desempleo > 8 ~ "Crisis severa",
      inflacion_2023 > 20 & desempleo > 10 ~ "Inestabilidad alta",
      inflacion_2023 > 10 & desempleo > 8 ~ "Inestabilidad moderada",
      inflacion_2023 <= 5 & desempleo <= 6 ~ "Muy estable",
      inflacion_2023 <= 10 & desempleo <= 8 ~ "Estable",
      TRUE ~ "Mixto"
    ),
    
    # 3. Clasificación de desigualdad (basada en Gini)
    nivel_desigualdad = case_when(
      gini > 50 ~ "Muy alta",
      gini > 45 ~ "Alta", 
      gini > 40 ~ "Moderada",
      gini > 35 ~ "Baja",
      TRUE ~ "Muy baja"
    ),
    
    # 4. Estrategia de integración comercial
    estrategia_comercial = case_when(
      exportaciones_pct_pib > 35 & poblacion_millones < 20 ~ "Economía pequeña abierta",
      exportaciones_pct_pib > 30 & poblacion_millones > 100 ~ "Potencia exportadora",
      exportaciones_pct_pib > 25 ~ "Orientada a exportación",
      exportaciones_pct_pib < 20 & poblacion_millones > 100 ~ "Mercado interno grande",
      TRUE ~ "Orientada al mercado interno"
    ),
    
    # 5. Prioridad de política económica (lógica jerárquica)
    prioridad_politica = case_when(
      inflacion_2023 > 50 ~ "Control inflacionario urgente",
      desempleo > 12 ~ "Creación de empleo",
      gini > 50 ~ "Reducción desigualdad",
      pib_percapita < 5000 ~ "Crecimiento económico",
      exportaciones_pct_pib < 15 ~ "Competitividad externa",
      TRUE ~ "Consolidación institucional"
    ),
    
    # 6. Clasificación de riesgo económico
    riesgo_economico = case_when(
      inflacion_2023 > 100 | desempleo > 15 ~ "Alto riesgo",
      inflacion_2023 > 20 | desempleo > 10 | gini > 50 ~ "Riesgo moderado",
      pib_percapita < 8000 ~ "Riesgo por desarrollo",
      TRUE ~ "Bajo riesgo"
    )
  )

print("Clasificaciones complejas con case_when():")
print(clasificaciones_complejas %>% 
  select(pais, categoria_desarrollo, perfil_macro, prioridad_politica))

# ============================================================================
# 3. COMPARACIÓN: CUÁNDO USAR CADA UNA
# ============================================================================

cat("\n=== COMPARACIÓN if_else vs case_when ===\n")

# Mismo problema resuelto con ambas funciones
comparacion <- datos_paises %>%
  mutate(
    # OPCIÓN 1: Con if_else anidados (NO recomendado para >2 categorías)
    desarrollo_if_else = if_else(
      pib_percapita > 15000, "Alto",
      if_else(pib_percapita > 10000, "Medio-Alto", "Medio-Bajo")
    ),
    
    # OPCIÓN 2: Con case_when (RECOMENDADO)
    desarrollo_case_when = case_when(
      pib_percapita > 15000 ~ "Alto",
      pib_percapita > 10000 ~ "Medio-Alto", 
      TRUE ~ "Medio-Bajo"
    ),
    
    # Mostrar diferencias
    son_iguales = desarrollo_if_else == desarrollo_case_when
  )

print("Comparación if_else vs case_when:")
print(comparacion %>% 
  select(pais, pib_percapita, desarrollo_if_else, desarrollo_case_when, son_iguales))

# ============================================================================
# 4. CASOS DE USO AVANZADOS
# ============================================================================

cat("\n=== Casos de uso avanzados ===\n")

# 4.1 Combinando múltiples condiciones lógicas
condiciones_complejas <- datos_paises %>%
  mutate(
    # AND: Todas las condiciones deben cumplirse
    pais_estable = case_when(
      inflacion_2023 <= 8 & desempleo <= 8 & gini <= 45 ~ "Muy estable",
      inflacion_2023 <= 15 & desempleo <= 10 ~ "Estable",
      TRUE ~ "Inestable"
    ),
    
    # OR: Al menos una condición debe cumplirse
    necesita_atencion = case_when(
      inflacion_2023 > 20 | desempleo > 12 | gini > 50 ~ "Atención prioritaria",
      inflacion_2023 > 10 | desempleo > 8 | gini > 45 ~ "Monitoreo",
      TRUE ~ "Situación normal"
    ),
    
    # Condiciones con rangos
    categoria_inflacion = case_when(
      inflacion_2023 < 0 ~ "Deflación",
      inflacion_2023 <= 3 ~ "Meta cumplida",
      inflacion_2023 <= 6 ~ "Cerca de meta",
      inflacion_2023 <= 15 ~ "Moderadamente alta",
      inflacion_2023 <= 50 ~ "Alta",
      TRUE ~ "Hiperinflación"
    )
  )

print("Condiciones complejas:")
print(condiciones_complejas %>% 
  select(pais, inflacion_2023, categoria_inflacion, pais_estable, necesita_atencion))

# 4.2 Usando valores de otras variables en las condiciones
referencias_relativas <- datos_paises %>%
  mutate(
    # Comparar con promedios
    inflacion_media = mean(inflacion_2023, na.rm = TRUE),
    pib_mediano = median(pib_percapita, na.rm = TRUE),
    
    # Clasificación relativa
    posicion_inflacion = case_when(
      inflacion_2023 > 2 * inflacion_media ~ "Muy por encima",
      inflacion_2023 > inflacion_media ~ "Por encima del promedio",
      inflacion_2023 > 0.5 * inflacion_media ~ "Por debajo del promedio",
      TRUE ~ "Muy por debajo"
    ),
    
    # Quintiles de desarrollo
    posicion_desarrollo = case_when(
      pib_percapita >= quantile(pib_percapita, 0.8) ~ "Quintil superior",
      pib_percapita >= quantile(pib_percapita, 0.6) ~ "Cuarto quintil",
      pib_percapita >= quantile(pib_percapita, 0.4) ~ "Tercer quintil", 
      pib_percapita >= quantile(pib_percapita, 0.2) ~ "Segundo quintil",
      TRUE ~ "Quintil inferior"
    )
  )

print("Referencias relativas:")
print(referencias_relativas %>% 
  select(pais, posicion_inflacion, posicion_desarrollo))

# ============================================================================
# 5. ERRORES COMUNES Y MEJORES PRÁCTICAS
# ============================================================================

cat("\n=== Errores comunes y mejores prácticas ===\n")

# Simulación de errores típicos y sus correcciones
errores_y_soluciones <- datos_paises %>%
  mutate(
    # ERROR 1: No usar TRUE para el último caso en case_when
    # clasificacion_mala = case_when(
    #   pib_percapita > 15000 ~ "Alto",
    #   pib_percapita > 10000 ~ "Medio"
    #   # Falta: TRUE ~ "Bajo" - esto genera NA para valores no cubiertos
    # ),
    
    # CORRECTO: Siempre incluir TRUE para casos no cubiertos
    clasificacion_buena = case_when(
      pib_percapita > 15000 ~ "Alto",
      pib_percapita > 10000 ~ "Medio",
      TRUE ~ "Bajo"  # Captura todos los casos restantes
    ),
    
    # ERROR 2: Orden incorrecto en case_when (evalúa en orden)
    # categoria_mala = case_when(
    #   pib_percapita > 5000 ~ "Medio",    # Esto capturaría valores >15000 también
    #   pib_percapita > 15000 ~ "Alto",    # Este nunca se ejecutaría
    #   TRUE ~ "Bajo"
    # ),
    
    # CORRECTO: Orden de más específico a más general
    categoria_buena = case_when(
      pib_percapita > 15000 ~ "Alto",     # Más específico primero
      pib_percapita > 5000 ~ "Medio",
      TRUE ~ "Bajo"
    ),
    
    # MEJOR PRÁCTICA: Condiciones mutuamente excluyentes y exhaustivas
    desarrollo_completo = case_when(
      pib_percapita >= 15000 ~ "Desarrollado",
      pib_percapita >= 10000 & pib_percapita < 15000 ~ "Desarrollo medio-alto",
      pib_percapita >= 6000 & pib_percapita < 10000 ~ "Desarrollo medio",
      pib_percapita < 6000 ~ "En desarrollo",
      TRUE ~ "Sin clasificar"  # Para casos NA o inesperados
    )
  )

print("Mejores prácticas:")
print(errores_y_soluciones %>% 
  select(pais, pib_percapita, clasificacion_buena, categoria_buena, desarrollo_completo))

# ============================================================================
# 6. CASO DE USO INTEGRADO: ANÁLISIS DE TRABAJADORES
# ============================================================================

cat("\n=== Caso integrado: Clasificación de trabajadores ===\n")

# Simular datos de trabajadores (típico en EPH)
trabajadores <- tibble(
  id = 1:20,
  edad = sample(18:65, 20, replace = TRUE),
  ingresos = sample(c(NA, runif(19, 200, 2000)), 20),
  horas_semanales = sample(c(0, 20, 35, 40, 48), 20, replace = TRUE),
  tiene_obra_social = sample(c(TRUE, FALSE), 20, replace = TRUE),
  sector = sample(c("Formal", "Informal", "Público"), 20, replace = TRUE),
  educacion = sample(c("Primaria", "Secundaria", "Terciaria", "Universitaria"), 20, replace = TRUE)
) %>%
  mutate(
    # Clasificación compleja usando ambas funciones
    
    # 1. Situación laboral (binaria simple)
    tiene_empleo = if_else(horas_semanales > 0, "Ocupado", "Desocupado"),
    
    # 2. Tipo de empleo (múltiples criterios)
    tipo_empleo = case_when(
      horas_semanales == 0 ~ "Desocupado",
      horas_semanales < 35 ~ "Subocupado",
      horas_semanales >= 35 & tiene_obra_social & sector == "Formal" ~ "Empleo pleno formal",
      horas_semanales >= 35 & sector == "Formal" ~ "Formal sin cobertura",
      horas_semanales >= 35 ~ "Informal pleno",
      TRUE ~ "Otros"
    ),
    
    # 3. Nivel socioeconómico (jerárquico)
    nivel_socioeconomico = case_when(
      is.na(ingresos) | ingresos == 0 ~ "Sin ingresos",
      ingresos > 1500 & educacion == "Universitaria" ~ "Clase alta",
      ingresos > 1000 & educacion %in% c("Terciaria", "Universitaria") ~ "Clase media alta",
      ingresos > 600 & horas_semanales >= 35 ~ "Clase media",
      ingresos > 300 ~ "Clase media baja",
      TRUE ~ "Clase baja"
    ),
    
    # 4. Prioridad para política social
    prioridad_social = case_when(
      horas_semanales == 0 & edad > 45 ~ "Prioridad alta - Desempleo adulto",
      is.na(ingresos) | ingresos < 400 ~ "Prioridad alta - Pobreza",
      tipo_empleo == "Subocupado" & edad < 30 ~ "Prioridad media - Joven subocupado",
      !tiene_obra_social & ingresos < 800 ~ "Prioridad media - Sin cobertura",
      TRUE ~ "Prioridad baja"
    ),
    
    # 5. Elegibilidad para programas (condiciones múltiples)
    programa_capacitacion = if_else(
      edad <= 35 & educacion %in% c("Primaria", "Secundaria") & 
      (horas_semanales == 0 | tipo_empleo == "Informal pleno"),
      "Elegible",
      "No elegible"
    )
  )

print("Clasificación compleja de trabajadores:")
print(trabajadores %>% 
  select(id, edad, ingresos, horas_semanales, tipo_empleo, nivel_socioeconomico, prioridad_social) %>%
  slice_head(n = 10))

# ============================================================================
# RESUMEN DE MEJORES PRÁCTICAS
# ============================================================================

cat("\n=== RESUMEN DE MEJORES PRÁCTICAS ===\n")
cat("✓ if_else(): Para clasificaciones binarias simples y claras\n")
cat("✓ case_when(): Para múltiples categorías y lógica compleja\n")
cat("✓ Siempre usar TRUE como última condición en case_when()\n")
cat("✓ Ordenar condiciones de más específica a más general\n")
cat("✓ Hacer condiciones mutuamente excluyentes y exhaustivas\n")
cat("✓ Usar & para AND lógico, | para OR lógico\n")
cat("✓ Considerar valores NA en las condiciones\n")
cat("✓ Validar que todas las observaciones queden clasificadas\n")

# Verificación final
verificacion <- trabajadores %>%
  summarise(
    total_casos = n(),
    casos_sin_tipo_empleo = sum(is.na(tipo_empleo)),
    casos_sin_nivel_socio = sum(is.na(nivel_socioeconomico)),
    casos_sin_prioridad = sum(is.na(prioridad_social))
  )

cat("\nVerificación de clasificaciones completas:\n")
print(verificacion)