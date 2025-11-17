# ============================================================================
# PRÁCTICA: Series de Tiempo con Datos Reales Argentinos
# Datos: Salarios, Empleo y PIB por sectores (2004-2025)
# ============================================================================
# 
# DECISIÓN METODOLÓGICA GENERAL:
# Utilizaremos datos económicos reales de Argentina para ilustrar todos los
# conceptos de series de tiempo. Los datos son trimestrales, lo cual es ideal
# para mostrar estacionalidad en variables económicas.
#
# FUENTES DE DATOS:
# - Salarios por sector económico (CIIU)
# - Salarios por tipo de empleo (registrados, no registrados, público)
# - Variables económicas (AUH, impuesto a las ganancias, jubilación mínima)
# - Empleo por categoría ocupacional
# - PIB por sectores económicos
#
# ============================================================================

# Cargar paquetes necesarios ----------------------------------------------

library(tidyverse)      # Manipulación y visualización de datos
library(forecast)       # Análisis y predicción de series de tiempo
library(tseries)        # Tests estadísticos para series
library(scales)         # Formateo de ejes
library(lubridate)      # Manejo de fechas

# Configuración de gráficos
theme_set(theme_minimal(base_size = 12))

# Configuración para evitar notación científica
options(scipen = 999)


# =============================================================================
# PARTE 1: Carga y Exploración de Datos
# =============================================================================

# DECISIÓN 1.1: Rutas de archivos
# Asumimos que los archivos están en el directorio de trabajo o especificamos
# la ruta completa. Para este ejercicio, están en /mnt/user-data/uploads/

ruta_base <- r'(ciencia_de_datos_fceuba_2c25\codigos en clase\clase 24\)'

# DECISIÓN 1.2: Cargar todos los archivos
# Cargamos cada archivo con read_csv para aprovechar la detección automática
# de tipos de datos

salarios_ciiu <- read_csv(paste0(ruta_base, "01_salario_ciiu.csv"))
salarios_tipo <- read_csv(paste0(ruta_base, "02_salarios_x_tipo.csv"))
tabla_economica <- read_csv(paste0(ruta_base, "03_tabla.csv"))
empleo_desagregado <- read_csv(paste0(ruta_base, "04_empleo_x_desagregacion.csv"))
pib_sectores <- read_csv(paste0(ruta_base, "06_pib_x_sectores.csv"))

# Transformar en fechas las variables de fecha 
salarios_ciiu <- salarios_ciiu %>% mutate(fecha_trimestre = lubridate::ymd(fecha_trimestre))
salarios_tipo <- salarios_tipo %>% mutate(fecha_trimestre = lubridate::ymd(fecha_trimestre))
tabla_economica <- tabla_economica %>% mutate(fecha_trimestre = lubridate::ymd(fecha_trimestre))
empleo_desagregado <- empleo_desagregado %>% mutate(fecha_trimestre = lubridate::ymd(fecha_trimestre))
pib_sectores <- pib_sectores %>% filter(!str_detect(periodo,'Total')) %>% mutate(periodo = lubridate::ymd(periodo))
# DECISIÓN 1.3: Exploración inicial
# Verificamos la estructura de cada dataset para entender qué tenemos

cat("=== ESTRUCTURA DE LOS DATOS ===\n\n")

cat("1. Salarios por CIIU:\n")
glimpse(salarios_ciiu)
cat("\nPrimeras filas:\n")
print(head(salarios_ciiu, 3))

cat("\n2. Salarios por tipo:\n")
glimpse(salarios_tipo)

cat("\n3. Tabla económica:\n")
glimpse(tabla_economica)

cat("\n4. Empleo desagregado:\n")
glimpse(empleo_desagregado)

cat("\n5. PIB por sectores:\n")
glimpse(pib_sectores)

# DECISIÓN 1.4: Verificar cobertura temporal
# Es crucial saber el rango de fechas para decidir qué análisis hacer

cat("\n=== COBERTURA TEMPORAL ===\n")
min(salarios_ciiu$fecha_trimestre)
max(salarios_ciiu$fecha_trimestre)
min(salarios_tipo$fecha_trimestre) 
max(salarios_tipo$fecha_trimestre)
min(pib_sectores$periodo)
max(pib_sectores$periodo)


# =============================================================================
# PARTE 2: Preparación de Datos para Análisis de Series de Tiempo
# =============================================================================

# DECISIÓN 2.1: Trabajar con agregados nacionales
# Para comenzar, trabajaremos con los totales generales de cada serie
# Esto simplifica el análisis y permite enfocarnos en los conceptos de ST

# 2.1.1 Salarios totales
# DECISIÓN: Usar "TOTAL GENERAL" que incluye todo el mercado laboral
salarios_totales <- salarios_ciiu %>%
  filter(sector_economico == "TOTAL GENERAL") %>%
  select(fecha = fecha_trimestre, salario_mensual) %>%
  arrange(fecha)

cat("\n=== SALARIOS TOTALES ===\n")
cat("Observaciones:", nrow(salarios_totales), "\n")
print(paste("Período:", min(salarios_totales$fecha), "a", max(salarios_totales$fecha)))

# 2.1.2 PIB total
# DECISIÓN: Sumar todos los sectores para obtener PIB total por trimestre
pib_total <- pib_sectores %>%
  filter(sector_agregado == "Total economía") %>%
  select(fecha = periodo, pib = valor) %>%
  arrange(fecha)

cat("\n=== PIB TOTAL ===\n")
cat("Observaciones:", nrow(pib_total), "\n")
print(paste("Período:", min(pib_total$fecha), "a", max(pib_total$fecha)))

# 2.1.3 Empleo total
empleo_total <- empleo_desagregado %>%
  select(fecha = fecha_trimestre, empleo_total = puestos_totales) %>%
  arrange(fecha)

# DECISIÓN 2.2: Calcular tasas de crecimiento
# Las tasas de crecimiento son más estacionarias que los niveles
# Esto es importante para análisis econométrico posterior

salarios_totales <- salarios_totales %>%
  mutate(
    salario_lag = lag(salario_mensual),
    crecimiento_salario = (salario_mensual - salario_lag) / salario_lag * 100
  )

pib_total <- pib_total %>%
  mutate(
    pib_lag = lag(pib),
    crecimiento_pib = (pib - pib_lag) / pib_lag * 100
  )


# =============================================================================
# PARTE 3: Visualización Inicial de Series
# =============================================================================

# DECISIÓN 3.1: Visualizar niveles primero
# Siempre comenzamos graficando para detectar patrones visualmente

# 3.1.1 Salario mensual promedio
p1 <- ggplot(salarios_totales, aes(x = fecha, y = salario_mensual)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(color = "steelblue", size = 2, alpha = 0.6) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Evolución del salario mensual promedio en Argentina",
    subtitle = "Valores en pesos constantes - Total economía",
    x = "Trimestre",
    y = "Salario mensual promedio ($)",
    caption = "Fuente: Elaboración propia con datos de SIPA"
  ) +
  theme(plot.title = element_text(face = "bold"))

print(p1)

# INTERPRETACIÓN:
# - Vemos una tendencia decreciente clara (pérdida de poder adquisitivo)
# - No parece haber estacionalidad muy marcada a simple vista

# 3.1.2 PIB total
p2 <- ggplot(pib_total, aes(x = fecha, y = pib)) +
  geom_line(color = "darkgreen", linewidth = 1) +
  geom_point(color = "darkgreen", size = 1.5, alpha = 0.4) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "PIB de Argentina a precios constantes",
    subtitle = "Total economía - Base 2004",
    x = "Trimestre",
    y = "PIB (millones de pesos de 2004)",
    caption = "Fuente: INDEC"
  ) +
  theme(plot.title = element_text(face = "bold"))

print(p2)

# INTERPRETACIÓN:
# - Tendencia de largo plazo relativamente estable con fluctuaciones
# - Caídas visibles (crisis 2008-2009, 2018-2019, 2020 pandemia)
# - Posible estacionalidad (picos y valles regulares)

# 3.1.3 Comparar ambas series (estandarizadas)
# DECISIÓN: Estandarizar para poder compararlas en un mismo gráfico

comparacion <- salarios_totales %>%
  select(fecha, salario_mensual) %>%
  left_join(pib_total %>% select(fecha, pib), by = "fecha") %>%
  filter(!is.na(pib) & !is.na(salario_mensual)) %>%
  mutate(
    salario_std = scale(salario_mensual)[,1],
    pib_std = scale(pib)[,1]
  )

p3 <- comparacion %>%
  pivot_longer(cols = c(salario_std, pib_std), 
               names_to = "variable", 
               values_to = "valor") %>%
  mutate(variable = recode(variable,
                          salario_std = "Salario real",
                          pib_std = "PIB")) %>%
  ggplot(aes(x = fecha, y = valor, color = variable)) +
  geom_line(linewidth = 1) +
  labs(
    title = "Salario Real y PIB: Evolución Comparada",
    subtitle = "Series estandarizadas (media=0, sd=1)",
    x = "Trimestre",
    y = "Valores estandarizados",
    color = "Serie"
  ) +
  theme(legend.position = "bottom")

print(p3)

# INTERPRETACIÓN:
# - Ambas series no muestran co-movimiento en el período analizado
# - El PIB muestra más volatilidad (ciclos económicos)
# - ¿Hay correlación?


# =============================================================================
# PARTE 4: Creación de Objetos de Serie Temporal (ts)
# =============================================================================

# DECISIÓN 4.1: Convertir a objetos ts
# Los objetos ts son necesarios para usar funciones de forecast y análisis ST
# IMPORTANTE: frequency = 4 porque son datos TRIMESTRALES

# 4.1.1 Salario mensual (desde 2016 Q1)
# DECISIÓN: Usar el período más largo disponible
ts_salario <- ts(salarios_totales$salario_mensual,
                start = c(2016, 1),  # Año 2016, trimestre 1
                frequency = 4)       # 4 trimestres por año

# 4.1.2 PIB (desde 2004 Q1)
ts_pib <- ts(pib_total$pib,
            start = c(2004, 1),
            frequency = 4)

# 4.1.3 Empleo total (desde 2016 Q1)
ts_empleo <- ts(empleo_total$empleo_total,
               start = c(2016, 1),
               frequency = 4)

# Verificar la creación correcta
cat("\n=== SERIES TEMPORALES CREADAS ===\n")
cat("Salario: de", start(ts_salario), "a", end(ts_salario), 
    "- Observaciones:", length(ts_salario), "\n")
cat("PIB: de", start(ts_pib), "a", end(ts_pib), 
    "- Observaciones:", length(ts_pib), "\n")
cat("Empleo: de", start(ts_empleo), "a", end(ts_empleo), 
    "- Observaciones:", length(ts_empleo), "\n")

# 4.1.4 Visualizar con autoplot (del paquete forecast)
# DECISIÓN: autoplot da formato automático apropiado para series temporales

autoplot(ts_salario) +
  labs(title = "Serie Temporal: Salario Mensual Promedio",
       y = "Salario ($)", x = "Año")

autoplot(ts_pib) +
  labs(title = "Serie Temporal: PIB Argentina",
       y = "PIB (millones $2004)", x = "Año")


# =============================================================================
# PARTE 5: Detección Visual de Estacionalidad
# =============================================================================

# DECISIÓN 5.1: Usar gráficos estacionales
# Los "seasonal plots" muestran el patrón estacional claramente

# 5.1.1 Gráfico estacional del PIB
# DECISIÓN: Usar el PIB porque tiene más años de datos (2004-2025)
ggseasonplot(ts_pib, year.labels = FALSE, continuous = TRUE) +
  labs(title = "Patrón Estacional del PIB Argentino",
       subtitle = "Cada línea representa un año",
       y = "PIB", x = "Trimestre") +
  theme_minimal()

# INTERPRETACIÓN:
# - Q2 (abr-jun) tiende a ser el trimestre más alto (¿cosecha?)
# - Q1 (ene-mar) tiende a ser más bajo (¿vacaciones?)
# - Esto indica estacionalidad MULTIPLICATIVA (amplitud crece con nivel)

# 5.1.2 Gráfico de subseries por trimestre
ggsubseriesplot(ts_pib) +
  labs(title = "Subseries del PIB por Trimestre",
       y = "PIB") +
  theme_minimal()

# INTERPRETACIÓN:
# - Las líneas azules muestran la media de cada trimestre
# - Q2 claramente más alto en promedio
# - Q1 relativamente bajo

# 5.1.3 Estacionalidad en salarios
# DECISIÓN: Aunque tiene menos años, también lo analizamos
ggseasonplot(ts_salario, year.labels = TRUE) +
  labs(title = "Patrón Estacional del Salario Mensual",
       y = "Salario ($)", x = "Trimestre")

# INTERPRETACIÓN:
# - Menos clara la estacionalidad en salarios
# - Posible pico en Q4 (aguinaldo de diciembre)


# =============================================================================
# PARTE 6: Descomposición de Series
# =============================================================================

# DECISIÓN 6.1: Usar descomposición multiplicativa
# RAZÓN: Las series económicas suelen tener varianza que crece con el nivel
# (heterocedasticidad), por lo que el modelo multiplicativo es más apropiado

# 6.1.1 Descomposición clásica del PIB
decomp_pib_mult <- decompose(ts_pib, type = "multiplicative")

autoplot(decomp_pib_mult) +
  labs(title = "Descomposición Multiplicativa del PIB",
       subtitle = "Método clásico") +
  theme_minimal()

# INTERPRETACIÓN DE COMPONENTES:
# - TENDENCIA: Crecimiento hasta aprox 2018, luego estancamiento/caída,
# aunque ya desde 2011 se nota desaceleración 
# - ESTACIONALIDAD: Patrón regular, Q2 alto, Q1 bajo
# - RESIDUOS (remainder): Relativamente pequeños, indica buen ajuste

# 6.1.2 Extraer componentes específicos
tendencia_pib <- decomp_pib_mult$trend
estacional_pib <- decomp_pib_mult$seasonal
irregular_pib <- decomp_pib_mult$random

# Visualizar solo la tendencia
autoplot(tendencia_pib) +
  labs(title = "Tendencia del PIB (sin estacionalidad)",
       y = "PIB tendencial") +
  geom_line(color = "darkgreen", linewidth = 1.2)

# DECISIÓN 6.2: Descomposición STL (más robusta)
# RAZÓN: STL es más flexible y robusto a outliers que decompose()

decomp_pib_stl <- stl(ts_pib, s.window = "periodic")

autoplot(decomp_pib_stl) +
  labs(title = "Descomposición STL del PIB",
       subtitle = "Método STL (más robusto)") +
  theme_minimal()

# COMPARACIÓN STL vs Clásico:
# - STL maneja mejor los outliers (ej: pandemia 2020)
# - La tendencia de STL es más suave
# - El componente estacional es similar en ambos

# 6.1.3 Descomposición del salario
# DECISIÓN: Usar modelo aditivo porque la variación estacional es más constante
decomp_salario <- decompose(ts_salario, type = "additive")

autoplot(decomp_salario) +
  labs(title = "Descomposición Aditiva del Salario Mensual") +
  theme_minimal()

# INTERPRETACIÓN:
# - TENDENCIA: Fuertemente creciente (inflación)
# - ESTACIONALIDAD: Pico en Q4 (aguinaldo)
# - RESIDUOS: Algunos outliers grandes (shocks económicos)


# =============================================================================
# PARTE 7: Desestacionalización
# =============================================================================

# DECISIÓN 7.1: Comparar múltiples métodos de desestacionalización
# OBJETIVO: Mostrar que diferentes métodos pueden dar resultados similares
# pero con matices importantes

cat("\n=== DESESTACIONALIZACIÓN ===\n")

# 7.1.1 Método Clásico
pib_desest_clasico <- seasadj(decomp_pib_mult)

# 7.1.2 Método STL
pib_desest_stl <- seasadj(decomp_pib_stl)

# 7.1.3 Método ARIMA automático
# DECISIÓN: Dejar que auto.arima() elija el mejor modelo
cat("Ajustando modelo ARIMA automático...\n")
modelo_pib_arima <- auto.arima(ts_pib, 
                               seasonal = TRUE,
                               stepwise = FALSE,  # Búsqueda exhaustiva
                               approximation = FALSE)

cat("Modelo ARIMA seleccionado:", "\n")
print(modelo_pib_arima)

# INTERPRETACIÓN DEL MODELO:
# El modelo muestra ARIMA(p,d,q)(P,D,Q)[4]
# - [4] indica estacionalidad trimestral
# - d y D indican órdenes de diferenciación
# - Los otros parámetros indican la estructura AR y MA

# Extraer valores ajustados (serie desestacionalizada implícitamente)
pib_ajustado_arima <- fitted(modelo_pib_arima)

# 7.1.4 Comparación visual de métodos
comparacion_desest <- tibble(
  fecha = time(ts_pib),
  Original = as.numeric(ts_pib),
  Clásica = as.numeric(pib_desest_clasico),
  STL = as.numeric(pib_desest_stl),
  ARIMA = as.numeric(pib_ajustado_arima)
)

p_comp <- comparacion_desest %>%
  pivot_longer(-fecha, names_to = "Método", values_to = "PIB") %>%
  ggplot(aes(x = fecha, y = PIB, color = Método)) +
  geom_line(linewidth = 0.8, alpha = 0.8) +
  labs(
    title = "Comparación de Métodos de Desestacionalización",
    subtitle = "PIB de Argentina",
    x = "Año",
    y = "PIB",
    caption = "Línea negra = Serie original"
  ) +
  scale_color_manual(values = c("Original" = "black",
                                "Clásica" = "steelblue",
                                "STL" = "darkgreen",
                                "ARIMA" = "red")) +
  theme_minimal() +
  theme(legend.position = "bottom")

print(p_comp)

# INTERPRETACIÓN:
# - Los tres métodos dan resultados muy similares
# - La serie original (negra) tiene "dientes de sierra" (estacionalidad)
# - Las series desestacionalizadas son más suaves
# - ARIMA captura mejor los cambios abruptos (ej: pandemia)

# 7.1.5 Visualizar solo un período para ver el efecto claramente
# DECISIÓN: Zoom en 2018-2020 para ver pandemia
comparacion_desest %>%
  filter(fecha >= 2018 & fecha <= 2021) %>%
  pivot_longer(-fecha, names_to = "Método", values_to = "PIB") %>%
  ggplot(aes(x = fecha, y = PIB, color = Método)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2, alpha = 0.6) +
  labs(
    title = "Detalle: PIB durante la Pandemia",
    subtitle = "Efecto de la desestacionalización (2018-2021)",
    x = "Año",
    y = "PIB"
  ) +
  scale_color_manual(values = c("Original" = "black",
                                "Clásica" = "steelblue",
                                "STL" = "darkgreen",
                                "ARIMA" = "red")) +
  theme_minimal()

# OBSERVACIONES:
# - La caída de 2020 Q2 es más dramática en la serie desestacionalizada
# - Porque normalmente Q2 es el trimestre más alto
# - La desestacionalización revela la verdadera magnitud del shock


# =============================================================================
# PARTE 8: Pronóstico con ARIMA
# =============================================================================

# DECISIÓN 8.1: Hacer pronóstico de corto plazo
# RAZÓN: Con series económicas, pronósticos de largo plazo son poco confiables

cat("\n=== PRONÓSTICO ===\n")

# 8.1.1 Pronosticar 4 trimestres (1 año)
forecast_pib <- forecast(modelo_pib_arima, h = 4)

print(forecast_pib)

# Visualizar pronóstico
autoplot(forecast_pib) +
  labs(
    title = "Pronóstico del PIB Argentino",
    subtitle = paste("Modelo:", modelo_pib_arima),
    x = "Año",
    y = "PIB",
    caption = "Bandas: 80% y 95% de confianza"
  ) +
  theme_minimal()

# INTERPRETACIÓN:
# - El pronóstico sigue la tendencia reciente
# - Los intervalos de confianza se amplían hacia el futuro
# - La estacionalidad se proyecta automáticamente

# 8.1.2 Diagnóstico de residuos
# DECISIÓN: Verificar que los residuos sean ruido blanco
checkresiduals(modelo_pib_arima)

# INTERPRETACIÓN DEL DIAGNÓSTICO:
# - Residuos deben parecer ruido blanco (sin patrón)
# - ACF no debe mostrar autocorrelación significativa
# - Test de Ljung-Box: p > 0.05 indica buenos residuos


# =============================================================================
# PARTE 9: Test de Estacionariedad
# =============================================================================

# DECISIÓN 9.1: Probar estacionariedad con Test ADF
# RAZÓN: Es el test más usado en econometría

cat("\n=== TEST DE ESTACIONARIEDAD ===\n")

# 9.1.1 Test en serie original (nivel)
cat("\n1. PIB en nivel:\n")
adf_pib_nivel <- adf.test(ts_pib, alternative = "stationary")
print(adf_pib_nivel)

# INTERPRETACIÓN:
# H0: La serie tiene raíz unitaria (NO es estacionaria)
# Si p-valor > 0.05 → NO rechazamos H0 → Serie NO estacionaria
# Si p-valor < 0.05 → Rechazamos H0 → Serie ES estacionaria

# 9.1.2 Test en primera diferencia
# DECISIÓN: Diferenciar para eliminar tendencia
pib_diff <- diff(ts_pib)

cat("\n2. PIB en primera diferencia:\n")
adf_pib_diff <- adf.test(pib_diff, alternative = "stationary")
print(adf_pib_diff)

# INTERPRETACIÓN:
# Después de diferenciar, la serie pasa a ser estacionaria
# (p-valor < 0.05)

# 9.1.3 Visualizar el efecto de diferenciar
par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
plot(ts_pib, main = "PIB en Nivel (No Estacionaria)", 
     ylab = "PIB", xlab = "Año")
plot(pib_diff, main = "PIB en Primera Diferencia (Estacionaria)",
     ylab = "Cambio en PIB", xlab = "Año")
abline(h = 0, col = "red", lty = 2)
par(mfrow = c(1, 1))

# DECISIÓN 9.2: Test en tasas de crecimiento
# Las tasas de crecimiento son más interpretables económicamente

# Calcular tasa de crecimiento trimestral
pib_crecimiento <- diff(ts_pib) / stats::lag(ts_pib, -1) * 100

cat("\n3. Tasa de crecimiento del PIB:\n")
adf_pib_crec <- adf.test(na.omit(pib_crecimiento), alternative = "stationary")
print(adf_pib_crec)

# Visualizar
autoplot(pib_crecimiento) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(
    title = "Tasa de Crecimiento Trimestral del PIB",
    subtitle = "Serie estacionaria",
    y = "Crecimiento (%)",
    x = "Año"
  ) +
  theme_minimal()

# OBSERVACIONES:
# - Las tasas de crecimiento fluctúan alrededor de cero
# - Son estacionarias (media y varianza constantes)
# - Se ven claramente los ciclos económicos


# =============================================================================
# PARTE 10: Correlación Espuria con Datos Reales
# =============================================================================

cat("\n=== CORRELACIÓN ESPURIA ===\n")

# DECISIÓN 10.1: Analizar relación PIB - Empleo
# RAZÓN: Ambas variables están relacionadas económicamente PERO
# también pueden mostrar correlación espuria por tener tendencia

# 10.1.1 Preparar datos en el mismo período
# DECISIÓN: Usar solo el período donde ambas series se superponen

comparacion_empleo <- salarios_totales %>%
  select(fecha, salario_mensual) %>%
  left_join(empleo_desagregado %>% 
              select(fecha = fecha_trimestre, empleo_total = puestos_totales), 
            by = "fecha") %>%
  left_join(pib_total %>% select(fecha, pib), by = "fecha") %>%
  filter(!is.na(empleo_total) & !is.na(salario_mensual) & !is.na(pib))

cat("Período de análisis:", min(comparacion_empleo$fecha), "a", 
    max(comparacion_empleo$fecha), "\n")
cat("Observaciones:", nrow(comparacion_empleo), "\n\n")

# 10.1.2 Crear series temporales para el mismo período
ts_empleo_comp <- ts(comparacion_empleo$empleo_total,
                    start = c(2016, 1),
                    frequency = 4)

ts_pib_comp <- ts(comparacion_empleo$pib,
                 start = c(2016, 1),
                 frequency = 4)

# 10.1.3 Visualizar ambas series (estandarizadas)
comparacion_empleo %>%
  mutate(
    empleo_std = scale(empleo_total)[,1],
    pib_std = scale(pib)[,1]
  ) %>%
  pivot_longer(cols = c(empleo_std, pib_std),
               names_to = "variable",
               values_to = "valor") %>%
  mutate(variable = recode(variable,
                          empleo_std = "Empleo Total",
                          pib_std = "PIB")) %>%
  ggplot(aes(x = fecha, y = valor, color = variable)) +
  geom_line(linewidth = 1) +
  labs(
    title = "PIB y Empleo: ¿Correlación Real o Espuria?",
    subtitle = "Series estandarizadas (2016-2024)",
    x = "Trimestre",
    y = "Valores estandarizados",
    color = "Variable"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

# OBSERVACIÓN:
# - Ambas series tienen tendencia y ciclos
# - Parecen, en parte, moverse juntas (co-movimiento)
# - Pero ¿es correlación real o espuria?

# 10.1.4 Regresión en NIVELES (incorrecta)
# ADVERTENCIA: Esta es la forma INCORRECTA porque ambas series no son estacionarias

modelo_espurio <- lm(empleo_total ~ pib, data = comparacion_empleo)
summary(modelo_espurio)

cat("\n⚠️ ADVERTENCIA: Esta regresión es ESPURIA\n")
cat("R² alto y coeficientes significativos PERO...\n")
cat("Ambas variables tienen tendencia (no son estacionarias)\n\n")

# 10.1.5 Verificar estacionariedad de ambas series
cat("Test ADF - Empleo en nivel:\n")
print(adf.test(ts_empleo_comp, alternative = "stationary"))

cat("\nTest ADF - PIB en nivel:\n")
print(adf.test(ts_pib_comp, alternative = "stationary"))

# RESULTADO ESPERADO:
# - Ambas series NO son estacionarias (p > 0.05)
# - Por lo tanto, la regresión es espuria

# 10.1.6 Regresión CORRECTA: Con primeras diferencias
# DECISIÓN: Diferenciar ambas variables

comparacion_empleo <- comparacion_empleo %>%
  mutate(
    d_empleo = empleo_total - lag(empleo_total),
    d_pib = pib - lag(pib)
  ) %>%
  filter(!is.na(d_empleo) & !is.na(d_pib))

modelo_correcto <- lm(d_empleo ~ d_pib, data = comparacion_empleo)
summary(modelo_correcto)

cat("\n✓ Esta regresión usa series DIFERENCIADAS (estacionarias)\n")
cat("Los resultados ahora son confiables\n\n")

# 10.1.7 Comparación visual
par(mfrow = c(1, 2))

# Regresión espuria (niveles)
plot(comparacion_empleo$pib, comparacion_empleo$empleo_total,
     main = "Relación en NIVELES (espuria)",
     xlab = "PIB", ylab = "Empleo",
     pch = 19, col = "steelblue")
abline(lm(empleo_total ~ pib, data = comparacion_empleo), 
       col = "red", lwd = 2)

# Regresión correcta (diferencias)
plot(comparacion_empleo$d_pib, comparacion_empleo$d_empleo,
     main = "Relación en DIFERENCIAS (correcta)",
     xlab = "Cambio en PIB", ylab = "Cambio en Empleo",
     pch = 19, col = "darkgreen")
abline(modelo_correcto, col = "red", lwd = 2)

par(mfrow = c(1, 1))

# LECCIÓN CLAVE:
# - Siempre verificar estacionariedad antes de hacer regresiones
# - Si las series tienen tendencia, diferenciar primero
# - La correlación en niveles puede ser engañosa (espuria)


# =============================================================================
# PARTE 11: Análisis por Sectores Económicos
# =============================================================================

cat("\n=== ANÁLISIS SECTORIAL ===\n")

# DECISIÓN 11.1: Analizar sectores clave de la economía
# Seleccionamos sectores representativos para mostrar heterogeneidad

sectores_clave <- c(
  "Industria manufacturera",
  "Agricultura, ganadería, caza y silvicultura",
  "Construcción",
  "Comercio mayorista, minorista y reparaciones"
)

# Filtrar datos
pib_sectores_sel <- pib_sectores %>%
  filter(sector_agregado %in% sectores_clave) %>%
  arrange(periodo, sector_agregado)

# Visualizar evolución por sector
ggplot(pib_sectores_sel, aes(x = periodo, y = valor, color = sector_agregado)) +
  geom_line(linewidth = 1) +
  facet_wrap(~sector_agregado, scales = "free_y", ncol = 2) +
  labs(
    title = "PIB por Sectores Económicos en Argentina",
    subtitle = "Evolución 2004-2025",
    x = "Trimestre",
    y = "PIB sectorial (millones $2004)",
    caption = "Fuente: INDEC"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# DECISIÓN 11.2: Calcular estacionalidad por sector
# OBJETIVO: Ver qué sectores tienen mayor estacionalidad

for(sector in sectores_clave) {
  
  datos_sector <- pib_sectores %>%
    filter(sector_agregado == sector) %>%
    arrange(periodo)
  
  ts_sector <- ts(datos_sector$valor,
                 start = c(2004, 1),
                 frequency = 4)
  
  # Descomposición
  decomp <- stl(ts_sector, s.window = "periodic")
  
  # Calcular importancia relativa de cada componente
  var_seasonal <- var(decomp$time.series[, "seasonal"], na.rm = TRUE)
  var_trend <- var(decomp$time.series[, "trend"], na.rm = TRUE)
  var_remainder <- var(decomp$time.series[, "remainder"], na.rm = TRUE)
  
  pct_seasonal <- var_seasonal / (var_seasonal + var_trend + var_remainder) * 100
  
  cat("\nSector:", sector, "\n")
  cat("  % de varianza explicada por estacionalidad:", 
      round(pct_seasonal, 2), "%\n")
}

# INTERPRETACIÓN ESPERADA:
# - Agricultura: Alta estacionalidad (cosechas)
# - Industria: Menor estacionalidad
# - Comercio: Estacionalidad moderada (fin de año)
# - Construcción: Alta estacionalidad (clima)


# =============================================================================
# PARTE 12: Ejemplo Integrador - Salarios por Tipo de Empleo
# =============================================================================

cat("\n=== EJEMPLO INTEGRADOR: SALARIOS POR TIPO ===\n")

# OBJETIVO: Mostrar heterogeneidad en el mercado laboral

# Preparar datos
salarios_largos <- salarios_tipo %>%
  select(fecha = fecha_trimestre,
         Registrados = salario_medio_registrados,
         `No registrados` = salario_medio_no_registrados,
         Público = salario_medio_publico) %>%
  pivot_longer(-fecha, names_to = "tipo", values_to = "salario")

# Visualizar
ggplot(salarios_largos, aes(x = fecha, y = salario, color = tipo)) +
  geom_line(linewidth = 1.2) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Evolución de Salarios por Tipo de Empleo",
    subtitle = "Argentina 2016-2024",
    x = "Trimestre",
    y = "Salario mensual promedio ($)",
    color = "Tipo de empleo",
    caption = "Fuente: SIPA"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

# =============================================================================
# PARTE 13: Ejercicios Propuestos
# =============================================================================

cat("\n=== EJERCICIOS PARA ESTUDIANTES ===\n\n")

cat("EJERCICIO 1: Estacionalidad sectorial\n")
cat("- Elegir 2 sectores del archivo pib_sectores\n")
cat("- Crear series temporales y descomponerlas\n")
cat("- ¿Qué sector tiene mayor estacionalidad?\n")
cat("- Justificar económicamente los patrones encontrados\n\n")

cat("EJERCICIO 2: Pronóstico de empleo\n")
cat("- Usar la serie ts_empleo\n")
cat("- Ajustar un modelo ARIMA con auto.arima()\n")
cat("- Pronosticar 4 trimestres\n")
cat("- Interpretar los intervalos de confianza\n\n")

cat("EJERCICIO 3: Brecha salarial formal-informal\n")
cat("- Calcular la serie de brecha formal-informal\n")
cat("- ¿Es estacionaria? (usar ADF test)\n")
cat("- ¿Hay tendencia creciente o decreciente?\n")
cat("- ¿Qué implica esto para la calidad del empleo?\n\n")

cat("EJERCICIO 4: Correlación PIB sectorial\n")
cat("- Elegir un sector productivo (ej: Industria)\n")
cat("- Hacer regresión de empleo total vs PIB sectorial\n")
cat("- Verificar estacionariedad de ambas variables\n")
cat("- ¿La regresión es válida o espuria?\n\n")

cat("EJERCICIO 5: Impacto de la pandemia\n")
cat("- Identificar visualmente el trimestre de mayor caída (2020 Q2)\n")
cat("- Comparar PIB original vs desestacionalizado en ese período\n")
cat("- ¿Por qué la caída es más pronunciada en la serie desestacionalizada?\n\n")


# =============================================================================
# RESUMEN DE DECISIONES METODOLÓGICAS
# =============================================================================

cat("\n", strrep("=", 80), "\n")
cat("RESUMEN DE DECISIONES METODOLÓGICAS CLAVE\n")
cat(strrep("=", 80), "\n\n")

cat("1. ELECCIÓN DE DATOS:\n")
cat("   - Usamos datos trimestrales (frequency = 4)\n")
cat("   - Período 2004-2025 para PIB, 2016-2024 para salarios y empleo\n")
cat("   - Datos reales de Argentina (INDEC, SIPA)\n\n")

cat("2. DESCOMPOSICIÓN:\n")
cat("   - Modelo MULTIPLICATIVO para PIB (varianza crece con nivel)\n")
cat("   - Modelo ADITIVO para salarios (variación más constante)\n")
cat("   - Método STL preferido por robustez a outliers\n\n")

cat("3. DESESTACIONALIZACIÓN:\n")
cat("   - Comparamos 3 métodos: Clásica, STL, ARIMA\n")
cat("   - ARIMA con auto.arima() para selección automática\n")
cat("   - Los tres métodos dan resultados similares\n\n")

cat("4. ESTACIONARIEDAD:\n")
cat("   - Test ADF para verificar raíz unitaria\n")
cat("   - Diferenciación para eliminar tendencia\n")
cat("   - Tasas de crecimiento como alternativa interpretable\n\n")

cat("5. CORRELACIÓN ESPURIA:\n")
cat("   - NUNCA regresar series con tendencia sin verificar estacionariedad\n")
cat("   - Diferenciar ambas variables si son no estacionarias\n")
cat("   - Las primeras diferencias capturan cambios, no niveles\n\n")

cat("6. VISUALIZACIÓN:\n")
cat("   - SIEMPRE graficar antes de modelar\n")
cat("   - Usar gráficos estacionales para detectar patrones\n")
cat("   - Comparar métodos visualmente\n\n")

cat(strrep("=", 80), "\n")
cat("FIN DEL SCRIPT\n")
cat(strrep("=", 80), "\n")

