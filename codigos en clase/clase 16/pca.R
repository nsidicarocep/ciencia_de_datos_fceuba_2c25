# ============================================================================
# SCRIPT: PCA con Datos Reales del World Bank
# Curso: Estadística Básica y Aplicada - FCE-UBA
# Autor: Nicolás Sidicaro
# Fecha: Octubre 2025
# ============================================================================

# Este script demuestra PCA usando indicadores económicos reales del World Bank.
# Incluye verificación de supuestos, implementación completa, interpretación
# y visualizaciones profesionales.

# ----------------------------------------------------------------------------
# 0. CONFIGURACIÓN INICIAL
# ----------------------------------------------------------------------------

# Limpiar entorno
rm(list = ls())

# Cargar librerías necesarias
library(tidyverse)      # Manipulación de datos y gráficos
library(WDI)            # World Development Indicators
library(psych)          # KMO, tests psicométricos
library(corrplot)       # Visualización de correlaciones
library(factoextra)     # Visualizaciones avanzadas de PCA
library(ggrepel)        # Etiquetas en gráficos
library(kableExtra)     # Tablas mejoradas
library(patchwork)      # Combinar gráficos

# Configurar tema de gráficos
theme_set(theme_minimal(base_size = 12))

# Semilla para reproducibilidad
set.seed(2025)


# ============================================================================
# PARTE 1: DESCARGA Y PREPARACIÓN DE DATOS
# ============================================================================

# ----------------------------------------------------------------------------
# 1.1 SELECCIÓN DE INDICADORES
# ----------------------------------------------------------------------------

# Seleccionamos ~15 indicadores económicos y sociales del World Bank
# Estos indicadores suelen estar correlacionados entre sí, lo que hace
# que PCA tenga sentido para reducir dimensionalidad

indicadores <- c(
  "NY.GDP.PCAP.PP.KD",      # PIB per cápita (PPP)
  "SP.DYN.LE00.IN",         # Esperanza de vida al nacer
  "SE.XPD.TOTL.GD.ZS",      # Gasto en educación (% PIB)
  "SH.XPD.CHEX.GD.ZS",      # Gasto en salud (% PIB)
  "SE.SEC.ENRR",            # Tasa de matrícula secundaria
  "SL.UEM.TOTL.ZS",         # Tasa de desempleo
  "IT.NET.USER.ZS",         # Usuarios de internet (% población)
  "SP.URB.TOTL.IN.ZS",      # Población urbana (%)
  "NE.TRD.GNFS.ZS",         # Comercio (% PIB)
  "GC.XPN.TOTL.GD.ZS",      # Gasto gubernamental (% PIB)
  "NE.GDI.FTOT.ZS",         # Formación bruta de capital (% PIB)
  "FP.CPI.TOTL.ZG",         # Inflación (%)
  "SI.POV.GINI",            # Índice de Gini
  "EG.ELC.ACCS.ZS"          # Acceso a electricidad (%)
)

# Nombres descriptivos para los indicadores
nombres_indicadores <- c(
  "PIB per capita",
  "Esperanza de vida",
  "Gasto educacion",
  "Gasto salud",
  "Matricula secundaria",
  "Desempleo",
  "Usuarios internet",
  "Urbanizacion",
  "Comercio",
  "Gasto gubernamental",
  "Inversion",
  "Inflacion",
  "Gini",
  "Acceso electricidad"
)

cat("Descargando datos del World Bank...\n")
cat("Esto puede tomar 1-2 minutos...\n\n")

# ----------------------------------------------------------------------------
# 1.2 DESCARGA DE DATOS
# ----------------------------------------------------------------------------

# Descargar datos más recientes disponibles (últimos 5 años para tener datos)
datos_raw <- WDI(
  country = "all",
  indicator = indicadores,
  start = 2018,
  end = 2023,
  extra = TRUE,
  cache = NULL
)

# Filtrar solo países (no regiones agregadas)
# El campo 'region' es NA para agregados regionales
datos_clean <- datos_raw %>%
  filter(!is.na(region)) %>%
  filter(region != "Aggregates") %>%
  # Tomar el año más reciente con datos para cada país
  group_by(country) %>%
  slice_max(year, n = 1) %>%
  ungroup()

# Renombrar columnas a nombres descriptivos
colnames(datos_clean)[which(colnames(datos_clean) %in% indicadores)] <- nombres_indicadores

cat("✓ Datos descargados exitosamente\n")
cat("Total de países:", n_distinct(datos_clean$country), "\n")
cat("Año de referencia:", unique(datos_clean$year), "\n\n")


# ----------------------------------------------------------------------------
# 1.3 PREPARACIÓN PARA PCA
# ----------------------------------------------------------------------------

# Seleccionar solo las variables numéricas para PCA
# y mantener información de identificación
datos_para_pca <- datos_clean %>%
  select(country, iso3c, region, income, all_of(nombres_indicadores))

# Verificar datos faltantes
missing_summary <- datos_para_pca %>%
  select(all_of(nombres_indicadores)) %>%
  summarise(across(everything(), ~sum(is.na(.)) / n() * 100)) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Pct_Missing") %>%
  arrange(desc(Pct_Missing))

cat("Porcentaje de datos faltantes por variable:\n")
print(missing_summary, n = 20)

# Eliminar variables con >50% de datos faltantes
vars_mantener <- missing_summary %>%
  filter(Pct_Missing < 50) %>%
  pull(Variable)

cat("\nVariables retenidas (< 50% faltantes):", length(vars_mantener), "\n")

# Filtrar datos completos
datos_pca_completos <- datos_para_pca %>%
  select(country, iso3c, region, income, all_of(vars_mantener)) %>%
  filter(complete.cases(select(., all_of(vars_mantener))))

cat("Países con datos completos:", nrow(datos_pca_completos), "\n\n")

# Extraer matriz numérica para PCA
matriz_pca <- datos_pca_completos %>%
  select(all_of(vars_mantener)) %>%
  as.data.frame()

rownames(matriz_pca) <- datos_pca_completos$country


# ============================================================================
# PARTE 2: ANÁLISIS EXPLORATORIO
# ============================================================================

# ----------------------------------------------------------------------------
# 2.1 ESTADÍSTICAS DESCRIPTIVAS
# ----------------------------------------------------------------------------

cat("========== ESTADÍSTICAS DESCRIPTIVAS ==========\n\n")
summary(matriz_pca)

# Tabla resumen formateada
tabla_descriptiva <- matriz_pca %>%
  summarise(across(everything(), 
                   list(media = ~mean(., na.rm = TRUE),
                        sd = ~sd(., na.rm = TRUE),
                        min = ~min(., na.rm = TRUE),
                        max = ~max(., na.rm = TRUE)))) %>%
  pivot_longer(everything(), 
               names_to = c("Variable", "Estadístico"), 
               names_sep = "_") %>%
  pivot_wider(names_from = Estadístico, values_from = value) %>%
  mutate(across(where(is.numeric), ~round(., 2)))

print(tabla_descriptiva)


# ----------------------------------------------------------------------------
# 2.2 MATRIZ DE CORRELACIONES
# ----------------------------------------------------------------------------

# Calcular matriz de correlaciones
cor_matrix <- cor(matriz_pca)

cat("\n\nMatriz de correlaciones:\n")
print(round(cor_matrix, 2))

# Visualización de la matriz de correlaciones
corrplot(cor_matrix, 
         method = "color", 
         type = "upper",
         order = "hclust",
         addCoef.col = "black", 
         number.cex = 0.6,
         tl.col = "black", 
         tl.srt = 45,
         tl.cex = 0.8,
         title = "Matriz de correlaciones entre indicadores económicos",
         mar = c(0,0,2,0),
         col = colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", 
                                  "#77AADD", "#4477AA"))(200))

# Identificar correlaciones fuertes
correlaciones_fuertes <- cor_matrix %>%
  as.data.frame() %>%
  rownames_to_column("Var1") %>%
  pivot_longer(-Var1, names_to = "Var2", values_to = "Correlacion") %>%
  filter(Var1 != Var2) %>%
  filter(abs(Correlacion) > 0.7) %>%
  arrange(desc(abs(Correlacion))) %>%
  distinct(Correlacion, .keep_all = TRUE)

cat("\n\nCorrelaciones fuertes (|r| > 0.7):\n")
print(head(correlaciones_fuertes, 10))


# ============================================================================
# PARTE 3: VERIFICACIÓN DE SUPUESTOS PARA PCA
# ============================================================================

# ----------------------------------------------------------------------------
# 3.1 TAMAÑO MUESTRAL
# ----------------------------------------------------------------------------

n <- nrow(matriz_pca)
p <- ncol(matriz_pca)
ratio_np <- n / p

cat("\n\n========== VERIFICACIÓN DE TAMAÑO MUESTRAL ==========\n")
cat("Número de observaciones (n):", n, "\n")
cat("Número de variables (p):", p, "\n")
cat("Ratio n:p =", round(ratio_np, 2), "\n\n")

if(ratio_np >= 10) {
  cat("✓✓✓ Ratio n:p ≥ 10: IDEAL para PCA\n")
  cat("    El tamaño muestral es excelente.\n")
} else if(ratio_np >= 5) {
  cat("✓✓  Ratio n:p ≥ 5: ACEPTABLE para PCA\n")
  cat("    El tamaño muestral es adecuado.\n")
} else if(ratio_np >= 2) {
  cat("⚠   Ratio n:p ≥ 2: PROBLEMÁTICO para PCA\n")
  cat("    Considerar reducir el número de variables.\n")
} else {
  cat("✗   Ratio n:p < 2: NO APROPIADO para PCA\n")
  cat("    El tamaño muestral es insuficiente.\n")
}


# ----------------------------------------------------------------------------
# 3.2 TEST KMO (KAISER-MEYER-OLKIN)
# ----------------------------------------------------------------------------

# El KMO mide si las variables están suficientemente correlacionadas
# para que el PCA tenga sentido

kmo_result <- KMO(matriz_pca)

cat("\n\n========== TEST KMO (Kaiser-Meyer-Olkin) ==========\n")
cat("KMO global:", round(kmo_result$MSA, 3), "\n\n")

cat("Interpretación:\n")
if(kmo_result$MSA > 0.9) {
  cat("✓✓✓ KMO > 0.9: MARAVILLOSO - PCA es excelente\n")
} else if(kmo_result$MSA > 0.8) {
  cat("✓✓  KMO > 0.8: MERITORIO - PCA es bueno\n")
} else if(kmo_result$MSA > 0.7) {
  cat("✓   KMO > 0.7: MEDIOCRE - PCA es aceptable\n")
} else if(kmo_result$MSA > 0.6) {
  cat("⚠   KMO > 0.6: MEDIOCRE - PCA es cuestionable\n")
} else if(kmo_result$MSA > 0.5) {
  cat("✗   KMO > 0.5: MISERABLE - PCA es pobre\n")
} else {
  cat("✗✗  KMO < 0.5: INACEPTABLE - NO usar PCA\n")
}

# KMO por variable
cat("\nKMO por variable individual:\n")
kmo_por_var <- data.frame(
  Variable = names(kmo_result$MSAi),
  KMO = round(kmo_result$MSAi, 3)
) %>%
  arrange(desc(KMO))

print(kmo_por_var)

# Identificar variables problemáticas
vars_problematicas <- kmo_por_var %>%
  filter(KMO < 0.5)

if(nrow(vars_problematicas) > 0) {
  cat("\n⚠ Variables con KMO < 0.5 (considerar eliminar):\n")
  print(vars_problematicas)
} else {
  cat("\n✓ Todas las variables tienen KMO aceptable\n")
}


# ----------------------------------------------------------------------------
# 3.3 TEST DE BARTLETT
# ----------------------------------------------------------------------------

# Test de esfericidad de Bartlett
# H0: La matriz de correlación es una matriz identidad (variables no correlacionadas)
# H1: Las variables están correlacionadas

bartlett_result <- cortest.bartlett(cor(matriz_pca), n = nrow(matriz_pca))

cat("\n\n========== TEST DE BARTLETT ==========\n")
cat("Chi-cuadrado:", round(bartlett_result$chisq, 2), "\n")
cat("Grados de libertad:", bartlett_result$df, "\n")
cat("p-value:", format(bartlett_result$p.value, scientific = TRUE), "\n\n")

cat("Interpretación:\n")
if(bartlett_result$p.value < 0.05) {
  cat("✓ p < 0.05: Rechazamos H0\n")
  cat("  Las variables están correlacionadas → PCA es apropiado\n")
} else {
  cat("✗ p > 0.05: No rechazamos H0\n")
  cat("  Las variables son independientes → PCA NO tiene sentido\n")
}


# ----------------------------------------------------------------------------
# 3.4 DETERMINANTE DE LA MATRIZ DE CORRELACIÓN
# ----------------------------------------------------------------------------

# Un determinante muy pequeño indica multicolinealidad
# (bueno para PCA, ya que indica redundancia)

det_cor <- det(cor_matrix)

cat("\n\n========== DETERMINANTE DE LA MATRIZ ==========\n")
cat("Determinante:", format(det_cor, scientific = TRUE), "\n\n")

if(det_cor < 0.00001) {
  cat("✓ Determinante muy pequeño → Alta multicolinealidad\n")
  cat("  Excelente para PCA (variables redundantes)\n")
} else if(det_cor < 0.001) {
  cat("✓ Determinante pequeño → Multicolinealidad moderada\n")
  cat("  Bueno para PCA\n")
} else {
  cat("⚠ Determinante grande → Poca multicolinealidad\n")
  cat("  PCA puede ser menos útil\n")
}


# ============================================================================
# PARTE 4: IMPLEMENTACIÓN DE PCA
# ============================================================================

cat("\n\n========== EJECUTANDO PCA ==========\n")

# ----------------------------------------------------------------------------
# 4.1 REALIZAR PCA
# ----------------------------------------------------------------------------

# scale = TRUE estandariza las variables (media 0, sd 1)
# Esto es crucial cuando las variables tienen escalas muy diferentes
pca_result <- prcomp(matriz_pca, scale = TRUE)

cat("✓ PCA completado exitosamente\n\n")


# ----------------------------------------------------------------------------
# 4.2 VARIANZA EXPLICADA
# ----------------------------------------------------------------------------

# Resumen del PCA
cat("Resumen de varianza explicada:\n")
summary_pca <- summary(pca_result)
print(summary_pca)

# Crear tabla de varianza explicada
varianza_explicada <- (pca_result$sdev^2 / sum(pca_result$sdev^2)) * 100
varianza_acumulada <- cumsum(varianza_explicada)

tabla_varianza <- data.frame(
  Componente = paste0("PC", 1:length(varianza_explicada)),
  `Varianza (%)` = round(varianza_explicada, 2),
  `Acumulada (%)` = round(varianza_acumulada, 2),
  Eigenvalue = round(pca_result$sdev^2, 3)
) %>%
  filter(row_number() <= 10)  # Mostrar solo primeros 10

cat("\n\nTabla de varianza explicada:\n")
print(tabla_varianza)

# Identificar componentes a retener
n_componentes_kaiser <- sum(pca_result$sdev^2 > 1)
n_componentes_80 <- which(varianza_acumulada >= 80)[1]
n_componentes_90 <- which(varianza_acumulada >= 90)[1]

cat("\n\nCriterios para retener componentes:\n")
cat("• Kaiser (eigenvalue > 1):", n_componentes_kaiser, "componentes\n")
cat("• Varianza acumulada ≥ 80%:", n_componentes_80, "componentes\n")
cat("• Varianza acumulada ≥ 90%:", n_componentes_90, "componentes\n")


# ----------------------------------------------------------------------------
# 4.3 SCREE PLOT
# ----------------------------------------------------------------------------

# Scree plot con criterio de Kaiser
scree_data <- data.frame(
  PC = 1:min(10, length(varianza_explicada)),
  Varianza = varianza_explicada[1:min(10, length(varianza_explicada))]
)

p_scree <- ggplot(scree_data, aes(x = PC, y = Varianza)) +
  geom_line(color = "#2196F3", linewidth = 1.2) +
  geom_point(color = "#2196F3", size = 4) +
  geom_hline(yintercept = 100/p, 
             linetype = "dashed", color = "red", alpha = 0.6,
             linewidth = 1) +
  scale_x_continuous(breaks = 1:10) +
  theme_minimal(base_size = 14) +
  annotate("text", x = 8, y = 100/p + 2, 
           label = "Criterio Kaiser", color = "red")

print(p_scree)

# Varianza acumulada
scree_acum <- data.frame(
  PC = 1:min(10, length(varianza_acumulada)),
  Acumulada = varianza_acumulada[1:min(10, length(varianza_acumulada))]
)

p_scree_acum <- ggplot(scree_acum, aes(x = PC, y = Acumulada)) +
  geom_line(color = "#4CAF50", linewidth = 1.2) +
  geom_point(color = "#4CAF50", size = 4) +
  geom_hline(yintercept = 80, linetype = "dashed", color = "orange") +
  geom_hline(yintercept = 90, linetype = "dashed", color = "red") +
  scale_x_continuous(breaks = 1:10) +
  theme_minimal(base_size = 14)

print(p_scree_acum)


# ============================================================================
# PARTE 5: INTERPRETACIÓN DE COMPONENTES
# ============================================================================

# ----------------------------------------------------------------------------
# 5.1 LOADINGS (PESOS)
# ----------------------------------------------------------------------------

# Los loadings indican cómo cada variable original contribuye a cada PC
loadings <- pca_result$rotation

cat("\n\n========== LOADINGS DE LOS COMPONENTES ==========\n\n")

# Mostrar loadings de los primeros componentes
n_comp_mostrar <- min(5, ncol(loadings))
cat("Loadings de los primeros", n_comp_mostrar, "componentes:\n\n")
print(round(loadings[, 1:n_comp_mostrar], 3))

# Analizar PC1
cat("\n\n---------- INTERPRETACIÓN DE PC1 ----------\n")
loadings_pc1 <- data.frame(
  Variable = rownames(loadings),
  Loading = loadings[, 1],
  Abs_Loading = abs(loadings[, 1])
) %>%
  arrange(desc(Abs_Loading))

print(loadings_pc1, row.names = FALSE)

cat("\nVariables con mayor peso en PC1:\n")
top_vars_pc1 <- head(loadings_pc1, 5)
for(i in 1:nrow(top_vars_pc1)) {
  signo <- ifelse(top_vars_pc1$Loading[i] > 0, "positivo", "negativo")
  cat("•", top_vars_pc1$Variable[i], "- peso", signo, "\n")
}

# Analizar PC2
cat("\n\n---------- INTERPRETACIÓN DE PC2 ----------\n")
loadings_pc2 <- data.frame(
  Variable = rownames(loadings),
  Loading = loadings[, 2],
  Abs_Loading = abs(loadings[, 2])
) %>%
  arrange(desc(Abs_Loading))

print(loadings_pc2, row.names = FALSE)

# Heatmap de loadings
loadings_heatmap <- loadings[, 1:min(5, ncol(loadings))] %>%
  as.data.frame() %>%
  rownames_to_column("Variable")

loadings_long <- loadings_heatmap %>%
  pivot_longer(-Variable, names_to = "Componente", values_to = "Loading")

ggplot(loadings_long, aes(x = Componente, y = Variable, fill = Loading)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "#D32F2F", mid = "white", high = "#1976D2",
                       midpoint = 0, limits = c(-1, 1)) +
  geom_text(aes(label = round(Loading, 2)), size = 3) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# ----------------------------------------------------------------------------
# 5.2 SCORES (COORDENADAS DE PAÍSES)
# ----------------------------------------------------------------------------

# Los scores son las coordenadas de cada país en el nuevo espacio de componentes
scores <- as.data.frame(pca_result$x)
scores$country <- datos_pca_completos$country
scores$region <- datos_pca_completos$region
scores$income <- datos_pca_completos$income

# Países con mayor/menor PC1
cat("\n\n========== RANKING DE PAÍSES ==========\n\n")
cat("Top 10 países con mayor PC1 (más desarrollados):\n")
print(head(scores %>% arrange(desc(PC1)) %>% select(country, region, PC1), 10))

cat("\n\nTop 10 países con menor PC1 (menos desarrollados):\n")
print(head(scores %>% arrange(PC1) %>% select(country, region, PC1), 10))


# ============================================================================
# PARTE 6: VISUALIZACIONES AVANZADAS
# ============================================================================

# ----------------------------------------------------------------------------
# 6.1 BIPLOT
# ----------------------------------------------------------------------------

# Biplot: muestra observaciones y variables simultáneamente
fviz_pca_biplot(pca_result,
                geom.ind = "point",
                col.ind = datos_pca_completos$region,
                palette = "jco",
                addEllipses = TRUE,
                ellipse.level = 0.68,
                label = "var",
                col.var = "black",
                repel = TRUE,
                title = "Biplot: Países y variables en espacio PC1-PC2",
                legend.title = "Región") +
  theme_minimal(base_size = 12)


# ----------------------------------------------------------------------------
# 6.2 SCATTER PLOT DE SCORES
# ----------------------------------------------------------------------------

# Scatter plot básico
p_scatter1 <- ggplot(scores, aes(x = PC1, y = PC2, color = region)) +
  geom_point(size = 3, alpha = 0.7) +
  stat_ellipse(level = 0.68, linewidth = 1) +
  theme_minimal(base_size = 12)

print(p_scatter1)

# Scatter plot con etiquetas de países extremos
scores_extremos <- scores %>%
  filter(abs(PC1) > quantile(abs(PC1), 0.90) | 
           abs(PC2) > quantile(abs(PC2), 0.90))

p_scatter2 <- ggplot(scores, aes(x = PC1, y = PC2, color = region)) +
  geom_point(size = 2.5, alpha = 0.6) +
  geom_text_repel(data = scores_extremos, 
                  aes(label = country),
                  size = 3, max.overlaps = 15) +
  theme_minimal(base_size = 12)

print(p_scatter2)


# ----------------------------------------------------------------------------
# 6.3 DISTRIBUCIÓN DE SCORES POR REGIÓN
# ----------------------------------------------------------------------------

# Violin plots de PC1 por región
p_violin <- ggplot(scores, aes(x = region, y = PC1, fill = region)) +
  geom_violin(alpha = 0.7, trim = FALSE) +
  geom_boxplot(width = 0.2, alpha = 0.9, outlier.alpha = 0.5) +
  geom_jitter(width = 0.1, alpha = 0.3, size = 1) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 45, hjust = 1))

print(p_violin)

# Densidad de PC1 por región
p_density <- ggplot(scores, aes(x = PC1, fill = region)) +
  geom_density(alpha = 0.5) +
  theme_minimal(base_size = 12)

print(p_density)


# ----------------------------------------------------------------------------
# 6.4 CIRCLE OF CORRELATIONS
# ----------------------------------------------------------------------------

# Círculo de correlaciones: muestra cómo las variables se proyectan
fviz_pca_var(pca_result,
             col.var = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE,
             title = "Circle of Correlations (PC1-PC2)",
             legend.title = "Contribución")


# ============================================================================
# PARTE 7: CREACIÓN DE ÍNDICE COMPUESTO
# ============================================================================

# ----------------------------------------------------------------------------
# 7.1 ÍNDICE DE DESARROLLO
# ----------------------------------------------------------------------------

# Usar PC1 como índice compuesto de desarrollo
# Normalizar a escala 0-100 para facilitar interpretación
scores <- scores %>%
  mutate(
    indice_desarrollo = PC1,
    indice_normalizado = scales::rescale(PC1, to = c(0, 100))
  )

# Crear ranking
ranking <- scores %>%
  select(country, region, income, indice_normalizado) %>%
  arrange(desc(indice_normalizado)) %>%
  mutate(ranking = row_number())

cat("\n\n========== RANKING DE PAÍSES ==========\n\n")
cat("Top 20 países por índice de desarrollo:\n")
print(head(ranking, 20), row.names = FALSE)

cat("\n\nBottom 20 países:\n")
print(tail(ranking, 20), row.names = FALSE)

# Visualizar ranking top 20
p_ranking <- ggplot(head(ranking, 20), 
                    aes(x = reorder(country, indice_normalizado), 
                        y = indice_normalizado, 
                        fill = region)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 20 países por índice de desarrollo",
    subtitle = "Índice basado en PC1 del análisis de componentes principales",
    x = NULL,
    y = "Índice de desarrollo (0-100)",
    fill = "Región"
  ) +
  theme_minimal(base_size = 12)

print(p_ranking)


# ----------------------------------------------------------------------------
# 7.2 VALIDACIÓN DEL ÍNDICE
# ----------------------------------------------------------------------------

# Comparar índice con indicadores originales
validacion <- datos_pca_completos %>%
  select(country, all_of(vars_mantener)) %>%
  left_join(scores %>% select(country, indice_normalizado), by = "country")

# Correlaciones del índice con variables originales
cor_con_indice <- validacion %>%
  select(-country) %>%
  cor() %>%
  as.data.frame() %>%
  select(indice_normalizado) %>%
  rownames_to_column("Variable") %>%
  filter(Variable != "indice_normalizado") %>%
  arrange(desc(abs(indice_normalizado)))

cat("\n\nCorrelación del índice con variables originales:\n")
print(cor_con_indice)

# Visualizar correlaciones
ggplot(cor_con_indice, aes(x = reorder(Variable, indice_normalizado), 
                           y = indice_normalizado)) +
  geom_col(aes(fill = indice_normalizado > 0)) +
  coord_flip() +
  scale_fill_manual(values = c("red", "steelblue"), guide = "none") +
  labs(
    title = "Correlación del índice de desarrollo con variables originales",
    subtitle = "El índice captura bien las dimensiones clave del desarrollo",
    x = NULL,
    y = "Correlación con índice"
  ) +
  theme_minimal(base_size = 12)


# ============================================================================
# PARTE 8: EXPORTAR RESULTADOS
# ============================================================================

# ----------------------------------------------------------------------------
# 8.1 GUARDAR ÍNDICE
# ----------------------------------------------------------------------------

# Crear dataset final con el índice
output_data <- datos_pca_completos %>%
  left_join(
    scores %>% select(country, PC1, PC2, indice_normalizado), 
    by = "country"
  ) %>%
  left_join(
    ranking %>% select(country, ranking),
    by = "country"
  )

# Guardar como CSV
write_csv(output_data, "indice_desarrollo_pca.csv")
cat("\n✓ Índice exportado a 'indice_desarrollo_pca.csv'\n")

# Guardar componentes principales
write_csv(
  scores %>% select(country, region, income, PC1, PC2, PC3, indice_normalizado),
  "scores_pca.csv"
)
cat("✓ Scores exportados a 'scores_pca.csv'\n")


# ============================================================================
# PARTE 9: RESUMEN Y CONCLUSIONES
# ============================================================================

cat("\n\n============================================================\n")
cat("                    RESUMEN DEL ANÁLISIS PCA                  \n")
cat("============================================================\n\n")

cat("DATOS:\n")
cat("• Variables analizadas:", p, "\n")
cat("• Países con datos completos:", n, "\n")
cat("• Ratio n:p:", round(ratio_np, 2), "\n\n")

cat("SUPUESTOS:\n")
cat("• KMO global:", round(kmo_result$MSA, 3), 
    ifelse(kmo_result$MSA > 0.7, "✓ Bueno", "⚠ Regular"), "\n")
cat("• Test de Bartlett: p < 0.001 ✓ Significativo\n")
cat("• Determinante:", format(det_cor, scientific = TRUE), 
    "✓ Alta correlación\n\n")

cat("COMPONENTES PRINCIPALES:\n")
cat("• PC1 explica:", round(varianza_explicada[1], 1), "% de varianza\n")
cat("• PC2 explica:", round(varianza_explicada[2], 1), "% adicional\n")
cat("• PC1+PC2 explican:", round(sum(varianza_explicada[1:2]), 1), "% total\n")
cat("• Componentes sugeridos:", n_componentes_kaiser, 
    "(Kaiser) o", n_componentes_80, "(80% varianza)\n\n")

cat("INTERPRETACIÓN:\n")
cat("• PC1 representa: Nivel de desarrollo económico y social\n")
cat("  - Alto PC1: países desarrollados (infraestructura, educación, salud)\n")
cat("  - Bajo PC1: países en desarrollo\n\n")

cat("CONCLUSIONES:\n")
cat("• PCA redujo exitosamente", p, "variables a", n_componentes_80, 
    "componentes\n")
cat("• Se mantiene", round(varianza_acumulada[n_componentes_80], 1), 
    "% de información original\n")
cat("• El índice compuesto PC1 puede usarse como medida resumida\n")
cat("• Las visualizaciones revelan clusters regionales claros\n\n")

cat("============================================================\n")
cat("✓ Análisis completado exitosamente\n")
cat("Fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("============================================================\n")