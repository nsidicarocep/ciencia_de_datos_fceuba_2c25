# ============================================================================
# MANEJO DE FECHAS EN ANÁLISIS ECONÓMICO CON LUBRIDATE
# Basado en el cheatsheet de lubridate aplicado a datos económicos
# ============================================================================

library(tidyverse)
library(lubridate)

# ============================================================================
# 1. PARSING: Convertir strings a fechas (funciones más comunes)
# ============================================================================

# Datos típicos de fuentes económicas con diferentes formatos
datos_economicos <- tibble(
  fuente = c("BCRA", "INDEC", "FMI", "BM", "CEPAL", "OECD"),
  fecha_str = c("2023-12-15", "15/12/2023", "Dec 15, 2023", 
                "2023-12", "2023Q4", "2023-W50"),
  valor = c(150.2, 8.5, 2.1, 45.8, 67.3, 12.4)
)

# Parsing con funciones ymd family
datos_parseados <- datos_economicos %>%
  mutate(
    # ymd() para formato ISO (YYYY-MM-DD) - más común en APIs
    fecha_iso = case_when(
      str_detect(fecha_str, "^\\d{4}-\\d{2}-\\d{2}$") ~ ymd(fecha_str),
      TRUE ~ as.Date(NA)
    ),
    
    # dmy() para formato europeo/argentino (DD/MM/YYYY)
    fecha_dmy = case_when(
      str_detect(fecha_str, "^\\d{2}/\\d{2}/\\d{4}$") ~ dmy(fecha_str),
      TRUE ~ as.Date(NA)
    ),
    
    # mdy() para formato estadounidense con texto
    fecha_mdy = case_when(
      str_detect(fecha_str, "^[A-Za-z]{3} \\d{2}, \\d{4}$") ~ mdy(fecha_str),
      TRUE ~ as.Date(NA)
    ),
    
    # ym() para datos mensuales (común en inflación)
    fecha_mensual = case_when(
      str_detect(fecha_str, "^\\d{4}-\\d{2}$") ~ ym(fecha_str),
      TRUE ~ as.Date(NA)
    ),
    
    # Parsing manual para trimestres (común en PIB)
    fecha_trimestral = case_when(
      str_detect(fecha_str, "Q1") ~ ymd(paste0(str_extract(fecha_str, "\\d{4}"), "-03-31")),
      str_detect(fecha_str, "Q2") ~ ymd(paste0(str_extract(fecha_str, "\\d{4}"), "-06-30")),
      str_detect(fecha_str, "Q3") ~ ymd(paste0(str_extract(fecha_str, "\\d{4}"), "-09-30")),
      str_detect(fecha_str, "Q4") ~ ymd(paste0(str_extract(fecha_str, "\\d{4}"), "-12-31")),
      TRUE ~ as.Date(NA)
    ),
    
    # Consolidar en una sola fecha
    fecha_final = coalesce(fecha_iso, fecha_dmy, fecha_mdy, fecha_mensual, fecha_trimestral)
  )

print("Parsing de diferentes formatos:")
print(datos_parseados %>% select(fuente, fecha_str, fecha_final))

# ============================================================================
# 2. EXTRACCIÓN DE COMPONENTES: Obtener partes de fechas
# ============================================================================

componentes <- datos_parseados %>%
  filter(!is.na(fecha_final)) %>%
  mutate(
    # Componentes básicos
    año = year(fecha_final),
    mes = month(fecha_final),
    dia = day(fecha_final),
    
    # Componentes útiles en economía
    trimestre = quarter(fecha_final),
    semestre = semester(fecha_final),
    semana = week(fecha_final),
    dia_año = yday(fecha_final),
    
    # Etiquetas textuales
    mes_nombre = month(fecha_final, label = TRUE, abbr = FALSE),
    mes_abrev = month(fecha_final, label = TRUE, abbr = TRUE),
    dia_semana = wday(fecha_final, label = TRUE, abbr = FALSE),
    
    # Variables dummy útiles para análisis
    es_enero = mes == 1,
    es_q1 = trimestre == 1,
    es_primer_semestre = semestre == 1,
    es_fin_año = mes == 12,
    
    # Períodos fiscales (ejemplo: año fiscal argentino)
    año_fiscal = if_else(mes >= 1, año, año - 1),
    
    # Estacionalidad (Hemisferio Sur)
    estacion = case_when(
      mes %in% c(12, 1, 2) ~ "Verano",
      mes %in% 3:5 ~ "Otoño", 
      mes %in% 6:8 ~ "Invierno",
      mes %in% 9:11 ~ "Primavera"
    )
  )

print("\nComponentes extraídos:")
print(componentes %>% 
  select(fuente, fecha_final, año, trimestre, mes_nombre, estacion, es_q1))

# ============================================================================
# 3. ARITMÉTICA DE FECHAS: Cálculos con períodos
# ============================================================================

# Crear serie temporal para análisis
serie_mensual <- tibble(
  fecha = seq(ymd("2020-01-01"), ymd("2023-12-01"), by = "month"),
  pib_mensual = 100 + cumsum(rnorm(48, 0.2, 1.5))
) %>%
  mutate(
    # Aritmética básica con fechas
    hace_un_año = fecha - years(1),
    hace_un_trimestre = fecha - months(3),
    hace_un_mes = fecha - months(1),
    
    # Próximos períodos
    proximo_trimestre = fecha + months(3),
    fin_año = ceiling_date(fecha, "year") - days(1),
    inicio_año = floor_date(fecha, "year"),
    
    # Cálculos de diferencias temporales
    meses_desde_inicio = interval(ymd("2020-01-01"), fecha) %/% months(1),
    años_transcurridos = interval(ymd("2020-01-01"), fecha) %/% years(1),
    
    # Variables para análisis económico
    es_mismo_mes_año_anterior = month(fecha) == month(hace_un_año),
    trimestre_actual = quarter(fecha),
    trimestre_anterior = quarter(hace_un_trimestre)
  )

print("\nAritmética de fechas:")
print(serie_mensual %>% 
  filter(year(fecha) == 2023, month(fecha) <= 3) %>%
  select(fecha, hace_un_año, hace_un_trimestre, meses_desde_inicio))

# ============================================================================
# 4. ANÁLISIS TEMPORAL ECONÓMICO: Casos de uso prácticos
# ============================================================================

# Simular datos trimestrales de PIB
pib_trimestral <- tibble(
  fecha = seq(ymd("2020-03-31"), ymd("2023-12-31"), by = "quarter"),
  pib_nominal = 100 * (1.02)^(0:(length(seq(ymd("2020-03-31"), ymd("2023-12-31"), by = "quarter"))-1)) + 
                rnorm(length(seq(ymd("2020-03-31"), ymd("2023-12-31"), by = "quarter")), 0, 2)
) %>%
  mutate(
    # Componentes temporales
    año = year(fecha),
    trimestre = quarter(fecha),
    
    # Fechas de comparación
    mismo_trim_año_anterior = fecha - years(1),
    trimestre_anterior = fecha - months(3),
    
    # Cálculos intertemporales (lag manual para este ejemplo)
    pib_año_anterior = lag(pib_nominal, 4),
    pib_trim_anterior = lag(pib_nominal, 1),
    
    # Variaciones porcentuales
    var_interanual = ((pib_nominal / pib_año_anterior) - 1) * 100,
    var_trimestral = ((pib_nominal / pib_trim_anterior) - 1) * 100,
    
    # Análisis de ciclos
    ciclo_covid = case_when(
      fecha >= ymd("2020-03-31") & fecha <= ymd("2021-12-31") ~ "Pandemia",
      fecha >= ymd("2022-03-31") ~ "Recuperación",
      TRUE ~ "Pre-pandemia"
    ),
    
    # Estacionalidad
    trimestre_etiqueta = paste0("Q", trimestre),
    es_trimestre_fuerte = trimestre %in% c(2, 4)  # Ejemplo: Q2 y Q4 suelen ser más fuertes
  )

print("\nAnálisis temporal del PIB:")
print(pib_trimestral %>% 
  filter(año >= 2022) %>%
  select(fecha, trimestre_etiqueta, var_interanual, var_trimestral, ciclo_covid))

# ============================================================================
# 5. TRABAJANDO CON INTERVALOS: Análisis de períodos
# ============================================================================

# Definir períodos importantes
crisis_2001 <- interval(ymd("2001-01-01"), ymd("2002-12-31"))
crisis_2008 <- interval(ymd("2008-09-01"), ymd("2009-06-30"))
pandemia <- interval(ymd("2020-03-01"), ymd("2021-12-31"))

# Análisis de eventos
eventos_economicos <- tibble(
  evento = c("Devaluación 2002", "Crisis Subprime", "Pandemia COVID", 
             "Recuperación", "Elecciones 2023"),
  fecha_evento = ymd(c("2002-01-01", "2008-09-15", "2020-03-20", 
                       "2021-06-01", "2023-10-22")),
  impacto_pib = c(-10.9, -5.9, -9.9, 8.5, 2.1)
) %>%
  mutate(
    # Clasificar eventos por período
    durante_crisis_2001 = fecha_evento %within% crisis_2001,
    durante_crisis_2008 = fecha_evento %within% crisis_2008,
    durante_pandemia = fecha_evento %within% pandemia,
    
    # Calcular tiempo transcurrido
    años_desde_evento = interval(fecha_evento, today()) %/% years(1),
    meses_desde_evento = interval(fecha_evento, today()) %/% months(1),
    
    # Clasificar por antigüedad
    categoria_temporal = case_when(
      años_desde_evento >= 20 ~ "Histórico",
      años_desde_evento >= 10 ~ "Mediano plazo",
      años_desde_evento >= 5 ~ "Reciente",
      TRUE ~ "Muy reciente"
    )
  )

print("\nAnálisis de eventos económicos:")
print(eventos_economicos %>% 
  select(evento, fecha_evento, durante_pandemia, años_desde_evento, categoria_temporal))

# ============================================================================
# 6. REDONDEO Y AGRUPACIÓN DE FECHAS: floor_date, ceiling_date
# ============================================================================

# Datos de alta frecuencia (diarios) agregados a menor frecuencia
datos_diarios <- tibble(
  fecha = seq(ymd("2023-01-01"), ymd("2023-12-31"), by = "day"),
  tipo_cambio = 300 + cumsum(rnorm(365, 0, 2))
) %>%
  mutate(
    # Redondear a diferentes períodos
    inicio_mes = floor_date(fecha, "month"),
    fin_mes = ceiling_date(fecha, "month") - days(1),
    inicio_trimestre = floor_date(fecha, "quarter"),
    inicio_semana = floor_date(fecha, "week"),
    
    # Para agregaciones
    año_mes = floor_date(fecha, "month"),
    año_trimestre = floor_date(fecha, "quarter")
  )

# Agregación mensual
tipo_cambio_mensual <- datos_diarios %>%
  group_by(año_mes) %>%
  summarise(
    tc_promedio = mean(tipo_cambio),
    tc_maximo = max(tipo_cambio),
    tc_minimo = min(tipo_cambio),
    tc_fin_mes = last(tipo_cambio),
    volatilidad = sd(tipo_cambio),
    dias_datos = n(),
    .groups = "drop"
  ) %>%
  mutate(
    mes_nombre = month(año_mes, label = TRUE),
    trimestre = quarter(año_mes)
  )

print("\nAgregación de datos diarios a mensuales:")
print(tipo_cambio_mensual %>% 
  filter(month(año_mes) <= 3) %>%
  select(año_mes, mes_nombre, tc_promedio, tc_fin_mes, volatilidad))

# ============================================================================
# 7. CASOS DE USO AVANZADOS: Análisis de estacionalidad
# ============================================================================

# Análisis estacional de empleo
empleo_mensual <- tibble(
  fecha = seq(ymd("2020-01-01"), ymd("2023-12-01"), by = "month"),
  tasa_desempleo = 8 + 2*sin(2*pi*(1:48)/12) + rnorm(48, 0, 0.5)  # Patrón estacional
) %>%
  mutate(
    año = year(fecha),
    mes = month(fecha),
    trimestre = quarter(fecha),
    
    # Análisis estacional
    mes_nombre = month(fecha, label = TRUE),
    estacion = case_when(
      mes %in% c(12, 1, 2) ~ "Verano",
      mes %in% 3:5 ~ "Otoño",
      mes %in% 6:8 ~ "Invierno", 
      mes %in% 9:11 ~ "Primavera"
    ),
    
    # Comparaciones temporales
    mismo_mes_año_ant = fecha - years(1),
    hace_12_meses = lag(tasa_desempleo, 12),
    variacion_interanual = tasa_desempleo - hace_12_meses,
    
    # Detectar patrones
    es_enero = mes == 1,  # Enero suele tener mayor desempleo estacional
    es_diciembre = mes == 12,  # Diciembre suele tener menor desempleo
    temporada_alta_empleo = mes %in% c(10, 11, 12)  # Temporada navideña
  )

# Resumen estacional
resumen_estacional <- empleo_mensual %>%
  group_by(estacion) %>%
  summarise(
    desempleo_promedio = mean(tasa_desempleo, na.rm = TRUE),
    desempleo_min = min(tasa_desempleo, na.rm = TRUE),
    desempleo_max = max(tasa_desempleo, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desempleo_promedio)

print("\nAnálisis estacional del desempleo:")
print(resumen_estacional)

# ============================================================================
# RESUMEN DE FUNCIONES LUBRIDATE UTILIZADAS
# ============================================================================

cat("\n=== FUNCIONES LUBRIDATE CUBIERTAS ===\n")
cat("PARSING: ymd(), dmy(), mdy(), ym()\n")
cat("COMPONENTES: year(), month(), quarter(), day(), week(), semester()\n") 
cat("ETIQUETAS: month(label=TRUE), wday(label=TRUE)\n")
cat("ARITMÉTICA: +/- years(), months(), days(), weeks()\n")
cat("REDONDEO: floor_date(), ceiling_date()\n")
cat("INTERVALOS: interval(), %within%, %/%\n")
cat("UTILIDADES: today(), now(), leap_year()\n")
cat("\nTodas aplicadas a casos reales de análisis económico.\n")