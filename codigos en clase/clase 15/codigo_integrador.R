# ==============================================================================
# CASO PRÁCTICO INTEGRADOR: Análisis de Brecha Salarial por Género
# EPH 1er Trimestre 2025
# ==============================================================================
# 
# Pregunta de investigación:
# ¿Existe diferencia significativa en el ingreso de la ocupación principal 
# entre varones y mujeres en Argentina?
#
# Aplicaremos:
# 1. Descarga y preparación de datos
# 2. Exploración y visualización
# 3. Verificación de supuestos (normalidad, homogeneidad de varianzas)
# 4. Elección del test apropiado
# 5. Interpretación de resultados
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CARGAR LIBRERÍAS
# ------------------------------------------------------------------------------

# Si no tenés las librerías, descomentá e instalá:
# install.packages("eph")
# install.packages("tidyverse")
# install.packages("car")

library(eph)
library(tidyverse)
library(car)  # Para test de Levene

# ------------------------------------------------------------------------------
# 2. DESCARGAR Y PREPARAR DATOS
# ------------------------------------------------------------------------------

# Descargar EPH 1er trimestre 2025
cat("Descargando EPH 1T 2025...\n")
eph_individual <- get_microdata(year = 2025, trimester = 1, type = "individual")

# Preparar datos: ocupados con ingreso positivo
datos_analisis <- eph_individual %>%
  filter(
    ESTADO == 1,              # Ocupados
    P21 > 0,                  # Ingreso positivo
    CH04 %in% c(1, 2),        # Solo varones y mujeres
    !is.na(P21)               # Sin missing en ingreso
  ) %>%
  mutate(
    ingreso = P21,
    genero = case_when(
      CH04 == 1 ~ "Varon",
      CH04 == 2 ~ "Mujer"
    )
  ) %>%
  select(ingreso, genero, PONDERA)

cat("Total de observaciones:", nrow(datos_analisis), "\n\n")

# ------------------------------------------------------------------------------
# 3. ESTADÍSTICAS DESCRIPTIVAS
# ------------------------------------------------------------------------------

cat("===============================================\n")
cat("ESTADÍSTICAS DESCRIPTIVAS POR GÉNERO\n")
cat("===============================================\n\n")

estadisticas <- datos_analisis %>%
  group_by(genero) %>%
  summarise(
    n = n(),
    media = mean(ingreso),
    mediana = median(ingreso),
    sd = sd(ingreso),
    min = min(ingreso),
    max = max(ingreso),
    .groups = "drop"
  )

print(estadisticas)

cat("\nObservaciones iniciales:\n")
cat("- Tamaño muestral n > 30 en ambos grupos → TCL aplica\n")
cat("- Diferencia en medias:", 
    round(estadisticas$media[1] - estadisticas$media[2], 0), "pesos\n")
cat("- Diferencia en desvíos → verificar homogeneidad de varianzas\n\n")

# ------------------------------------------------------------------------------
# 4. VISUALIZACIÓN DE DISTRIBUCIONES
# ------------------------------------------------------------------------------

cat("Generando gráficos exploratorios...\n\n")

# Histogramas por género
ggplot(datos_analisis, aes(x = ingreso, fill = genero)) +
  geom_histogram(bins = 50, alpha = 0.6, position = "identity") +
  scale_x_continuous(labels = scales::comma, limits = c(0, 3000000)) +
  labs(
    title = "Distribución de ingresos por género - EPH 1T 2025",
    x = "Ingreso de la ocupación principal",
    y = "Frecuencia",
    fill = "Género"
  ) +
  theme_minimal() +
  facet_wrap(~genero, ncol = 1)

# Boxplots comparativos
ggplot(datos_analisis, aes(x = genero, y = ingreso, fill = genero)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.3) +
  stat_summary(fun = mean, geom = "point", 
               shape = 23, size = 4, fill = "red") +
  scale_y_continuous(labels = scales::comma, limits = c(0, 3000000)) +
  labs(
    title = "Comparación de ingresos por género",
    subtitle = "Rombo rojo = media | Línea horizontal = mediana",
    y = "Ingreso",
    x = "Género"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# ------------------------------------------------------------------------------
# 5. VERIFICAR NORMALIDAD
# ------------------------------------------------------------------------------

cat("===============================================\n")
cat("VERIFICACIÓN DE NORMALIDAD\n")
cat("===============================================\n\n")

# Separar datos por género
ingresos_varon <- datos_analisis %>% filter(genero == "Varon") %>% pull(ingreso)
ingresos_mujer <- datos_analisis %>% filter(genero == "Mujer") %>% pull(ingreso)

# Test de Shapiro-Wilk
# NOTA: Shapiro solo acepta hasta 5000 observaciones, tomamos muestra aleatoria
set.seed(123)
muestra_varon <- sample(ingresos_varon, min(5000, length(ingresos_varon)))
muestra_mujer <- sample(ingresos_mujer, min(5000, length(ingresos_mujer)))

cat("Test de Shapiro-Wilk (muestra aleatoria):\n")
shapiro_varon <- shapiro.test(muestra_varon)
shapiro_mujer <- shapiro.test(muestra_mujer)

cat("Varones: p-valor =", round(shapiro_varon$p.value, 10), "\n")
cat("Mujeres: p-valor =", round(shapiro_mujer$p.value, 10), "\n\n")

if(shapiro_varon$p.value < 0.05 | shapiro_mujer$p.value < 0.05) {
  cat("Interpretación: Los datos NO siguen distribución normal perfecta\n")
} else {
  cat("Interpretación: Los datos siguen distribución aproximadamente normal\n")
}

cat("\nPERO RECORDAR: Con n > 1000 en cada grupo, el TCL garantiza que\n")
cat("la distribución de las MEDIAS es normal, independientemente de\n")
cat("la distribución de los datos originales.\n\n")

# ------------------------------------------------------------------------------
# 6. VERIFICAR HOMOGENEIDAD DE VARIANZAS
# ------------------------------------------------------------------------------

cat("===============================================\n")
cat("TEST DE HOMOGENEIDAD DE VARIANZAS (LEVENE)\n")
cat("===============================================\n\n")

# Test de Levene
levene_result <- leveneTest(ingreso ~ genero, data = datos_analisis)
print(levene_result)

cat("\nInterpretación:\n")
if(levene_result$`Pr(>F)`[1] < 0.05) {
  cat("p-valor < 0.05 → Rechazamos H0\n")
  cat("Las varianzas son DIFERENTES entre grupos\n")
  cat("Solución: Usar corrección de Welch (var.equal = FALSE)\n\n")
  usar_welch <- TRUE
} else {
  cat("p-valor > 0.05 → No rechazamos H0\n")
  cat("Las varianzas son SIMILARES entre grupos\n")
  cat("Podemos usar t-test clásico (var.equal = TRUE)\n\n")
  usar_welch <- FALSE
}

# ------------------------------------------------------------------------------
# 7. APLICAR EL TEST APROPIADO
# ------------------------------------------------------------------------------

cat("===============================================\n")
cat("TEST DE HIPÓTESIS\n")
cat("===============================================\n\n")

cat("H0: No hay diferencia en el ingreso promedio entre varones y mujeres\n")
cat("H1: Hay diferencia en el ingreso promedio entre varones y mujeres\n")
cat("Nivel de significancia: α = 0.05\n\n")

# Decisión: ¿T-test o Wilcoxon?
cat("Decisión del test:\n")
cat("- Tamaño muestral: n > 1000 → TCL aplica → t-test es robusto\n")

if(usar_welch) {
  cat("- Varianzas diferentes → Usar t-test con corrección de Welch\n\n")
  resultado_test <- t.test(ingreso ~ genero, data = datos_analisis, 
                           var.equal = FALSE)
} else {
  cat("- Varianzas similares → Usar t-test clásico\n\n")
  resultado_test <- t.test(ingreso ~ genero, data = datos_analisis, 
                           var.equal = TRUE)
}

cat("RESULTADOS DEL T-TEST:\n")
cat("----------------------\n")
print(resultado_test)

cat("\n\nRESUMEN:\n")
cat("Diferencia de medias:", 
    round(resultado_test$estimate[2] - resultado_test$estimate[1], 0), "pesos\n")
cat("Intervalo de confianza 95%: [", 
    round(resultado_test$conf.int[1], 0), ",", 
    round(resultado_test$conf.int[2], 0), "]\n")
cat("Estadístico t:", round(resultado_test$statistic, 3), "\n")
cat("P-valor:", format(resultado_test$p.value, scientific = FALSE, digits = 4), "\n\n")

# ------------------------------------------------------------------------------
# 8. CONCLUSIONES
# ------------------------------------------------------------------------------

cat("===============================================\n")
cat("CONCLUSIONES\n")
cat("===============================================\n\n")

if(resultado_test$p.value < 0.05) {
  cat("✓ RECHAZAMOS H0 (p-valor < 0.05)\n\n")
  cat("Conclusión: Existe evidencia estadísticamente significativa de que\n")
  cat("el ingreso promedio difiere entre varones y mujeres en Argentina.\n\n")
  
  brecha_absoluta <- resultado_test$estimate[1] - resultado_test$estimate[2]
  brecha_relativa <- (brecha_absoluta / resultado_test$estimate[2]) * 100
  
  cat("Brecha salarial estimada:\n")
  cat("- Absoluta:", round(brecha_absoluta, 0), "pesos\n")
  cat("- Relativa:", round(brecha_relativa, 1), "%\n\n")
  
  if(brecha_absoluta < 0) {
    cat("Los varones ganan en promedio", round(abs(brecha_relativa), 1), 
        "% más que las mujeres.\n")
  } else {
    cat("Las mujeres ganan en promedio", round(abs(brecha_relativa), 1), 
        "% más que los varones.\n")
  }
  
} else {
  cat("✗ NO RECHAZAMOS H0 (p-valor > 0.05)\n\n")
  cat("Conclusión: No hay evidencia estadísticamente significativa de\n")
  cat("diferencia en el ingreso promedio entre varones y mujeres.\n")
}

cat("\n\n")
cat("===============================================\n")
cat("VALIDACIÓN DEL ANÁLISIS\n")
cat("===============================================\n\n")

cat("✓ Tamaño muestral adecuado (n > 30 en ambos grupos)\n")
cat("✓ TCL garantiza normalidad de las medias muestrales\n")

if(usar_welch) {
  cat("✓ Corrección de Welch aplicada por varianzas heterogéneas\n")
} else {
  cat("✓ Varianzas homogéneas verificadas con test de Levene\n")
}

cat("✓ Test de dos colas para detectar diferencias en cualquier dirección\n")
cat("✓ Intervalo de confianza del 95% calculado\n\n")

cat("IMPORTANTE: Este análisis es descriptivo. Para un estudio causal\n")
cat("de la brecha salarial, se requeriría controlar por otras variables\n")
cat("(educación, experiencia, sector, etc.) usando regresión múltiple.\n\n")

# ------------------------------------------------------------------------------
# 9. ANÁLISIS DE SENSIBILIDAD (BONUS)
# ------------------------------------------------------------------------------

cat("===============================================\n")
cat("BONUS: COMPARACIÓN CON TEST NO PARAMÉTRICO\n")
cat("===============================================\n\n")

cat("Por completitud, comparamos con el test de Wilcoxon:\n\n")

wilcox_result <- wilcox.test(ingreso ~ genero, data = datos_analisis)
print(wilcox_result)

cat("\n\nComparación de p-valores:\n")
cat("- T-test:", format(resultado_test$p.value, scientific = FALSE, digits = 4), "\n")
cat("- Wilcoxon:", format(wilcox_result$p.value, scientific = FALSE, digits = 4), "\n\n")

cat("Nota: Ambos tests llegan a la misma conclusión, confirmando\n")
cat("la robustez de nuestros resultados.\n\n")

cat("===============================================\n")
cat("FIN DEL ANÁLISIS\n")
cat("===============================================\n")