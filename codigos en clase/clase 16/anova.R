# ============================================================================
# SCRIPT: ANOVA y PCA con Datos Reales
# Curso: Estadística Básica y Aplicada - FCE-UBA
# Autor: Nicolás Sidicaro
# Fecha: Octubre 2025
# ============================================================================

# Este script demuestra ANOVA y PCA usando datos reales de gapminder y otros
# datasets. Incluye todos los pasos: exploración, análisis, verificación de
# supuestos y visualizaciones.

# ----------------------------------------------------------------------------
# 0. CONFIGURACIÓN INICIAL
# ----------------------------------------------------------------------------

# Limpiar entorno
rm(list = ls())

# Cargar librerías necesarias
library(tidyverse)      # Manipulación de datos y gráficos
library(gapminder)      # Dataset de desarrollo económico
library(car)            # Tests de diagnóstico (Levene)
library(emmeans)        # Comparaciones post-hoc
library(psych)          # KMO, factor analysis
library(corrplot)       # Visualización de correlaciones
library(ggpubr)         # Tests estadísticos en gráficos
library(patchwork)      # Combinar gráficos

# Configurar tema de gráficos
theme_set(theme_minimal(base_size = 12))

# Semilla para reproducibilidad
set.seed(2025)


# ============================================================================
# PARTE 1: ANOVA (ANALYSIS OF VARIANCE)
# ============================================================================

# ----------------------------------------------------------------------------
# 1.1 EXPLORACIÓN DE DATOS
# ----------------------------------------------------------------------------

# Usaremos gapminder para comparar esperanza de vida entre continentes
# Filtrar datos del año más reciente (2007)
datos_anova <- gapminder %>%
  filter(year == 2007)

# Ver estructura de los datos
glimpse(datos_anova)

# Estadísticas descriptivas por continente
datos_anova %>%
  group_by(continent) %>%
  summarise(
    n = n(),
    media = mean(lifeExp),
    sd = sd(lifeExp),
    min = min(lifeExp),
    max = max(lifeExp)
  ) %>%
  print()


# ----------------------------------------------------------------------------
# 1.2 VISUALIZACIÓN EXPLORATORIA
# ----------------------------------------------------------------------------

# Boxplot por continente
p1 <- ggplot(datos_anova, aes(x = continent, y = lifeExp, fill = continent)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.3) +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3, fill = "red") +
  theme(legend.position = "bottom")

print(p1)

# Histogramas por continente
p2 <- ggplot(datos_anova, aes(x = lifeExp, fill = continent)) +
  geom_histogram(bins = 15, alpha = 0.7) +
  facet_wrap(~continent, scales = "free_y") +
  theme(legend.position = "none")

print(p2)


# ----------------------------------------------------------------------------
# 1.3 ANOVA DE UN FACTOR (ONE-WAY ANOVA)
# ----------------------------------------------------------------------------

# Pregunta de investigación: ¿Difiere la esperanza de vida entre continentes?

# H0: μ_Africa = μ_Americas = μ_Asia = μ_Europe = μ_Oceania
# H1: Al menos una media es diferente

# Ajustar modelo ANOVA
modelo_anova <- aov(lifeExp ~ continent, data = datos_anova)

# Tabla ANOVA
summary(modelo_anova)

# Interpretación:
# - p-valor < 0.001 → Rechazamos H0
# - Conclusión: La esperanza de vida difiere significativamente entre continentes

# Tamaño del efecto (eta-cuadrado)
# Proporción de varianza explicada por el continente
ss_between <- summary(modelo_anova)[[1]]$`Sum Sq`[1]
ss_total <- sum(summary(modelo_anova)[[1]]$`Sum Sq`)
eta_squared <- ss_between / ss_total
cat("\nEta-cuadrado:", round(eta_squared, 3))
cat("\nEl continente explica el", round(eta_squared * 100, 1), 
    "% de la varianza en esperanza de vida\n")


# ----------------------------------------------------------------------------
# 1.4 VERIFICACIÓN DE SUPUESTOS
# ----------------------------------------------------------------------------

# SUPUESTO 1: Normalidad de residuos
# Gráficos de diagnóstico
par(mfrow = c(2, 2))
plot(modelo_anova)
par(mfrow = c(1, 1))

# Test de Shapiro-Wilk (solo si n < 5000)
residuos <- residuals(modelo_anova)
shapiro_test <- shapiro.test(residuos)
cat("\nTest de Shapiro-Wilk:")
cat("\nW =", round(shapiro_test$statistic, 4))
cat("\np-value =", round(shapiro_test$p.value, 4))

if(shapiro_test$p.value > 0.05) {
  cat("\nLos residuos son consistentes con normalidad ✓\n")
} else {
  cat("\nLos residuos no son normales (considerar transformación)\n")
}

# SUPUESTO 2: Homogeneidad de varianzas
# Test de Levene
levene_result <- leveneTest(lifeExp ~ continent, data = datos_anova)
print(levene_result)

if(levene_result$`Pr(>F)`[1] > 0.05) {
  cat("\nLas varianzas son homogéneas ✓\n")
} else {
  cat("\nLas varianzas NO son homogéneas (considerar Welch ANOVA)\n")
}

# Si se viola homogeneidad, usar Welch ANOVA
welch_result <- oneway.test(lifeExp ~ continent, data = datos_anova, 
                            var.equal = FALSE)
print(welch_result)


# ----------------------------------------------------------------------------
# 1.5 COMPARACIONES POST-HOC
# ----------------------------------------------------------------------------

# ANOVA solo nos dice "hay diferencias", no cuáles
# Usamos test de Tukey para comparaciones múltiples

# Test de Tukey HSD (Honest Significant Difference)
comparaciones_tukey <- emmeans(modelo_anova, pairwise ~ continent, 
                               adjust = "tukey")

# Ver todas las comparaciones
print(summary(comparaciones_tukey$contrasts))

# Extraer comparaciones significativas
comp_df <- as.data.frame(summary(comparaciones_tukey$contrasts))
comp_significativas <- comp_df %>%
  filter(p.value < 0.05) %>%
  arrange(p.value)

cat("\nComparaciones significativas (p < 0.05):\n")
print(comp_significativas)

# ----------------------------------------------------------------------------
# 1.6 ANOVA DE DOS FACTORES (TWO-WAY ANOVA)
# ----------------------------------------------------------------------------

# Ahora incluiremos un segundo factor: año (1952 vs 2007)
# Pregunta: ¿Hay interacción entre continente y año?

# Preparar datos con dos años
datos_twoway <- gapminder %>%
  filter(year %in% c(1952, 2007)) %>%
  mutate(year = factor(year))

# Estadísticas descriptivas
datos_twoway %>%
  group_by(continent, year) %>%
  summarise(
    n = n(),
    media = round(mean(lifeExp), 1),
    sd = round(sd(lifeExp), 1),
    .groups = "drop"
  ) %>%
  print()

# Visualización de interacción
ggplot(datos_twoway, aes(x = continent, y = lifeExp, 
                         color = year, group = year)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", linewidth = 1) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Modelo Two-Way ANOVA con interacción
modelo_twoway <- aov(lifeExp ~ continent * year, data = datos_twoway)
summary(modelo_twoway)

# Interpretación:
# - continent: Efecto principal significativo
# - year: Efecto principal significativo (mejora general)
# - continent:year: Interacción significativa (la mejora varía por continente)


# ----------------------------------------------------------------------------
# 1.7 ALTERNATIVA NO PARAMÉTRICA: KRUSKAL-WALLIS
# ----------------------------------------------------------------------------

# Si los supuestos de ANOVA no se cumplen, usar test no paramétrico
kruskal_result <- kruskal.test(lifeExp ~ continent, data = datos_anova)
print(kruskal_result)

# Post-hoc para Kruskal-Wallis: Test de Dunn
# install.packages("FSA") si no está instalado
# library(FSA)
# dunn_result <- dunnTest(lifeExp ~ continent, data = datos_anova, method = "bonferroni")
# print(dunn_result)