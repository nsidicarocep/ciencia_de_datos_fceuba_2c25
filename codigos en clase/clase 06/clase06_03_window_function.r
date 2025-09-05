# ============================================================================
# WINDOW FUNCTIONS EN ANÁLISIS ECONÓMICO
# lag(), row_number(), rollmean(), cumsum() y funciones relacionadas
# ============================================================================

library(tidyverse)
library(zoo)  # Para rollmean()

# Datos de ejemplo: PIB trimestral de países latinoamericanos
pib_trimestral <- expand_grid(
  pais = c("Argentina", "Brasil", "Chile", "México"),
  año = 2020:2023,
  trimestre = 1:4
) %>%
  arrange(pais, año, trimestre) %>%
  mutate(
    fecha = as.Date(paste0(año, "-", (trimestre-1)*3 + 3, "-01")),
    # Simular PIB con tendencia y volatilidad realista
    pib_nominal = case_when(
      pais == "Argentina" ~ 150 + cumsum(rnorm(n(), 0.8, 3.2)),
      pais == "Brasil" ~ 2100 + cumsum(rnorm(n(), 1.2, 2.8)),
      pais == "Chile" ~ 75 + cumsum(rnorm(n(), 0.4, 1.5)),
      pais == "México" ~ 380 + cumsum(rnorm(n(), 0.6, 2.1))
    )
  )

print("Datos base de PIB trimestral:")
print(pib_trimestral %>% head(12))

# ============================================================================
# 1. LAG() y LEAD(): COMPARACIONES TEMPORALES
# ============================================================================

cat("\n=== LAG y LEAD: Análisis retrospectivo y prospectivo ===\n")

analisis_temporal <- pib_trimestral %>%
  group_by(pais) %>%
  arrange(año, trimestre) %>%
  mutate(
    # LAG: Comparación con períodos anteriores
    pib_trimestre_anterior = lag(pib_nominal, 1),
    pib_año_anterior = lag(pib_nominal, 4),  # 4 trimestres = 1 año
    pib_hace_2_años = lag(pib_nominal, 8),
    
    # LEAD: Análisis prospectivo  
    pib_proximo_trimestre = lead(pib_nominal, 1),
    pib_proximo_año = lead(pib_nominal, 4),
    
    # Cálculos económicos típicos
    crecimiento_trimestral = ((pib_nominal / pib_trimestre_anterior) - 1) * 100,
    crecimiento_interanual = ((pib_nominal / pib_año_anterior) - 1) * 100,
    crecimiento_bienal = ((pib_nominal / pib_hace_2_años) - 1) * 100,
    
    # Análisis de aceleración/desaceleración
    aceleracion = crecimiento_trimestral - lag(crecimiento_trimestral, 1),
    
    # Detectar recesiones (2 trimestres consecutivos de crecimiento negativo)
    trimestre_recesion = crecimiento_trimestral < 0,
    recesion_tecnica = trimestre_recesion & lag(trimestre_recesion, 1),
    
    # Análisis prospectivo: ¿mejorará la situación?
    mejorara_proximo_trim = pib_proximo_trimestre > pib_nominal,
    tendencia_futura = case_when(
      lead(crecimiento_trimestral, 1) > crecimiento_trimestral ~ "Mejorando",
      lead(crecimiento_trimestral, 1) < crecimiento_trimestral ~ "Empeorando", 
      TRUE ~ "Estable"
    )
  ) %>%
  ungroup()

print("Análisis temporal con LAG y LEAD:")
print(analisis_temporal %>% 
  filter(pais == "Argentina", año >= 2022) %>%
  select(pais, año, trimestre, crecimiento_trimestral, crecimiento_interanual, 
         aceleracion, recesion_tecnica, tendencia_futura))

# ============================================================================
# 2. ROW_NUMBER(), RANK(), DENSE_RANK(): RANKINGS Y POSICIONES
# ============================================================================

cat("\n=== RANKINGS: Posiciones relativas y competitividad ===\n")

rankings_economia <- pib_trimestral %>%
  filter(año == 2023, trimestre == 4) %>%  # Último trimestre disponible
  mutate(
    # Diferentes tipos de ranking
    posicion_unica = row_number(desc(pib_nominal)),          # Sin empates
    ranking_con_empates = rank(desc(pib_nominal)),           # Con empates, deja huecos  
    ranking_denso = dense_rank(desc(pib_nominal)),           # Sin huecos tras empates
    
    # Percentiles (útil para comparaciones regionales)
    percentil_pib = round(percent_rank(pib_nominal) * 100, 1),
    
    # Rankings dentro de grupos (por año, por región, etc.)
    rank_anual = row_number(desc(pib_nominal)),
    
    # Clasificaciones basadas en ranking
    categoria_economia = case_when(
      posicion_unica == 1 ~ "Líder regional",
      posicion_unica <= 2 ~ "Economía grande", 
      posicion_unica <= 3 ~ "Economía mediana",
      TRUE ~ "Economía pequeña"
    ),
    
    # Top performers (útil para análisis comparativo)
    top_3 = posicion_unica <= 3,
    top_50_pct = percentil_pib >= 50
  )

print("Rankings económicos:")
print(rankings_economia %>% 
  select(pais, pib_nominal, posicion_unica, ranking_denso, percentil_pib, categoria_economia))

# Ranking temporal: mejor performance por país
mejor_trimestre_por_pais <- pib_trimestral %>%
  group_by(pais) %>%
  mutate(
    rank_historico = row_number(desc(pib_nominal)),
    es_mejor_trimestre = rank_historico == 1,
    es_peor_trimestre = rank_historico == max(rank_historico)
  ) %>%
  filter(es_mejor_trimestre | es_peor_trimestre) %>%
  select(pais, año, trimestre, pib_nominal, es_mejor_trimestre, es_peor_trimestre)

print("Mejores y peores trimestres por país:")
print(mejor_trimestre_por_pais)

# ============================================================================
# 3. ROLLMEAN(): PROMEDIOS MÓVILES PARA SUAVIZAR TENDENCIAS
# ============================================================================

cat("\n=== PROMEDIOS MÓVILES: Suavizar volatilidad y detectar tendencias ===\n")

promedios_moviles <- pib_trimestral %>%
  group_by(pais) %>%
  arrange(año, trimestre) %>%
  mutate(
    # Promedios móviles de diferentes ventanas
    pib_ma2 = rollmean(pib_nominal, k = 2, fill = NA, align = "right"),  # 2 trimestres
    pib_ma4 = rollmean(pib_nominal, k = 4, fill = NA, align = "right"),  # 1 año
    pib_ma8 = rollmean(pib_nominal, k = 8, fill = NA, align = "right"),  # 2 años
    
    # Calcular volatilidad con ventanas móviles
    volatilidad_4t = rollapply(pib_nominal, width = 4, FUN = sd, fill = NA, align = "right"),
    
    # Detectar tendencias usando promedios móviles
    tendencia_corto = case_when(
      pib_nominal > pib_ma2 ~ "Por encima promedio 2T",
      pib_nominal < pib_ma2 ~ "Por debajo promedio 2T",
      TRUE ~ "En promedio"
    ),
    
    tendencia_largo = case_when(
      pib_ma4 > lag(pib_ma4, 2) ~ "Tendencia ascendente",
      pib_ma4 < lag(pib_ma4, 2) ~ "Tendencia descendente", 
      TRUE ~ "Tendencia lateral"
    ),
    
    # Señales de cambio de tendencia
    cambio_tendencia = case_when(
      pib_nominal > pib_ma8 & lag(pib_nominal, 1) <= lag(pib_ma8, 1) ~ "Ruptura alcista",
      pib_nominal < pib_ma8 & lag(pib_nominal, 1) >= lag(pib_ma8, 1) ~ "Ruptura bajista",
      TRUE ~ "Sin cambio"
    )
  ) %>%
  ungroup()

print("Promedios móviles y análisis de tendencias:")
print(promedios_moviles %>% 
  filter(pais == "Brasil", año >= 2022) %>%
  select(pais, año, trimestre, pib_nominal, pib_ma4, tendencia_largo, cambio_tendencia))

# ============================================================================
# 4. CUMSUM() y FUNCIONES ACUMULATIVAS
# ============================================================================

cat("\n=== FUNCIONES ACUMULATIVAS: Totales y extremos históricos ===\n")

acumulativas <- pib_trimestral %>%
  group_by(pais) %>%
  arrange(año, trimestre) %>%
  mutate(
    # Sumas acumuladas (útil para PIB anual acumulado)
    pib_acumulado_año = case_when(
      trimestre == 1 ~ pib_nominal,
      TRUE ~ cumsum(ifelse(trimestre == 1, pib_nominal, 
                           pib_nominal - lag(pib_nominal, 1)))
    ),
    
    # Promedios acumulados (performance histórica)
    pib_promedio_historico = cummean(pib_nominal),
    
    # Extremos acumulados (récords históricos)
    pib_maximo_historico = cummax(pib_nominal),
    pib_minimo_historico = cummin(pib_nominal),
    
    # Análisis de récords
    es_record_maximo = pib_nominal == pib_maximo_historico & 
                       pib_nominal > lag(pib_maximo_historico, 1),
    es_record_minimo = pib_nominal == pib_minimo_historico & 
                       pib_nominal < lag(pib_minimo_historico, 1),
    
    # Distancia a extremos históricos
    distancia_a_maximo = ((pib_nominal / pib_maximo_historico) - 1) * 100,
    distancia_a_minimo = ((pib_nominal / pib_minimo_historico) - 1) * 100,
    
    # Análisis de recuperación
    trimestres_desde_maximo = ifelse(es_record_maximo, 0, 
                                    row_number() - which.max(cummax(pib_nominal) == pib_nominal)),
    
    # Contador acumulado de eventos
    recesiones_acumuladas = cumsum(ifelse(is.na(lag(pib_nominal, 1)), FALSE,
                                         pib_nominal < lag(pib_nominal, 1))),
    
    # Performance acumulada vs inicial
    crecimiento_desde_inicio = ((pib_nominal / first(pib_nominal)) - 1) * 100
  ) %>%
  ungroup()

print("Funciones acumulativas:")
print(acumulativas %>% 
  filter(pais == "Chile", año >= 2022) %>%
  select(pais, año, trimestre, pib_nominal, pib_maximo_historico, 
         distancia_a_maximo, es_record_maximo, crecimiento_desde_inicio))

# ============================================================================
# 5. ANÁLISIS INTEGRADO: COMBINANDO TODAS LAS WINDOW FUNCTIONS
# ============================================================================

cat("\n=== ANÁLISIS INTEGRADO: Dashboard económico completo ===\n")

dashboard_economico <- pib_trimestral %>%
  group_by(pais) %>%
  arrange(año, trimestre) %>%
  mutate(
    # Análisis temporal (LAG/LEAD)
    crecimiento_trimestral = ((pib_nominal / lag(pib_nominal, 1)) - 1) * 100,
    crecimiento_interanual = ((pib_nominal / lag(pib_nominal, 4)) - 1) * 100,
    
    # Tendencias (ROLLMEAN)
    pib_tendencia = rollmean(pib_nominal, k = 4, fill = NA, align = "right"),
    
    # Posición relativa (RANK)
    percentil_historico = percent_rank(pib_nominal) * 100,
    
    # Récords (CUMMAX/CUMMIN)
    pib_maximo = cummax(pib_nominal),
    desde_maximo = ((pib_nominal / pib_maximo) - 1) * 100,
    
    # Análisis integral
    situacion_economica = case_when(
      desde_maximo >= -2 & crecimiento_interanual > 2 ~ "Expansión fuerte",
      desde_maximo >= -5 & crecimiento_interanual > 0 ~ "Crecimiento moderado",
      desde_maximo >= -10 & crecimiento_interanual > -2 ~ "Desaceleración",
      crecimiento_interanual <= -2 ~ "Contracción",
      TRUE ~ "Estancamiento"
    ),
    
    # Momentum (combinando lag y lead)
    momentum = case_when(
      crecimiento_trimestral > lag(crecimiento_trimestral, 1) & 
      lead(crecimiento_trimestral, 1) > crecimiento_trimestral ~ "Acelerando",
      crecimiento_trimestral < lag(crecimiento_trimestral, 1) & 
      lead(crecimiento_trimestral, 1) < crecimiento_trimestral ~ "Desacelerando",
      TRUE ~ "Estable"
    )
  ) %>%
  ungroup()

# Resumen del último trimestre por país
resumen_actual <- dashboard_economico %>%
  filter(año == 2023, trimestre == 4) %>%
  select(pais, pib_nominal, crecimiento_trimestral, crecimiento_interanual, 
         desde_maximo, situacion_economica, momentum) %>%
  arrange(desc(pib_nominal))

print("Dashboard económico - Situación actual:")
print(resumen_actual)

# ============================================================================
# 6. CASOS DE USO ESPECÍFICOS POR FUNCIÓN
# ============================================================================

cat("\n=== CASOS DE USO ESPECÍFICOS ===\n")

# LAG: Análisis de políticas económicas
efectos_politica <- pib_trimestral %>%
  filter(pais == "Argentina") %>%
  mutate(
    # Simular implementación de política en 2022-Q2
    politica_implementada = año >= 2022 & trimestre >= 2,
    crecimiento = ((pib_nominal / lag(pib_nominal, 1)) - 1) * 100,
    crecimiento_pre_politica = lag(crecimiento, 2),
    efecto_politica = crecimiento - crecimiento_pre_politica
  ) %>%
  filter(politica_implementada) %>%
  select(año, trimestre, crecimiento, efecto_politica)

print("Análisis de efectos de política (LAG):")
print(efectos_politica)

# ROW_NUMBER: Top performers por período
top_trimestres <- pib_trimestral %>%
  group_by(año, trimestre) %>%
  mutate(
    ranking_trimestral = row_number(desc(pib_nominal)),
    es_lider = ranking_trimestral == 1
  ) %>%
  filter(es_lider) %>%
  select(año, trimestre, pais, pib_nominal)

print("Líderes por trimestre (ROW_NUMBER):")
print(top_trimestres %>% tail(8))

# ROLLMEAN: Detección de ciclos económicos
ciclos <- pib_trimestral %>%
  filter(pais == "México") %>%
  mutate(
    tendencia_8t = rollmean(pib_nominal, k = 8, fill = NA, align = "center"),
    ciclo = pib_nominal - tendencia_8t,
    fase_ciclo = case_when(
      ciclo > 2 ~ "Expansión",
      ciclo < -2 ~ "Contracción", 
      TRUE ~ "Estabilidad"
    )
  ) %>%
  filter(!is.na(tendencia_8t)) %>%
  select(año, trimestre, pib_nominal, tendencia_8t, ciclo, fase_ciclo)

print("Análisis de ciclos económicos (ROLLMEAN):")
print(ciclos %>% tail(8))

# CUMSUM: Crecimiento acumulado por década
crecimiento_decada <- pib_trimestral %>%
  group_by(pais) %>%
  arrange(año, trimestre) %>%
  mutate(
    crecimiento_trim = ((pib_nominal / lag(pib_nominal, 1)) - 1) * 100,
    crecimiento_acum_2020s = cumsum(ifelse(año >= 2020, crecimiento_trim, 0))
  ) %>%
  filter(año == 2023, trimestre == 4) %>%
  select(pais, crecimiento_acum_2020s) %>%
  arrange(desc(crecimiento_acum_2020s))

print("Crecimiento acumulado década 2020s (CUMSUM):")
print(crecimiento_decada)

# ============================================================================
# RESUMEN DE WINDOW FUNCTIONS UTILIZADAS
# ============================================================================

cat("\n=== RESUMEN DE WINDOW FUNCTIONS ===\n")
cat("✓ lag() / lead(): Comparaciones temporales y análisis de políticas\n")
cat("✓ row_number(): Rankings únicos y identificación de líderes\n")
cat("✓ rank() / dense_rank(): Rankings con empates y clasificaciones\n")
cat("✓ percent_rank(): Percentiles y posición relativa histórica\n")
cat("✓ rollmean(): Promedios móviles y detección de tendencias\n")
cat("✓ cumsum(): Totales acumulados y efectos agregados\n")
cat("✓ cummean(): Promedios históricos y performance acumulada\n")
cat("✓ cummax() / cummin(): Récords históricos y análisis de extremos\n")
cat("\nTodas aplicadas a análisis macroeconómico real.\n")