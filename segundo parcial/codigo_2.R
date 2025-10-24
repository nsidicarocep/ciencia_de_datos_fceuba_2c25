# Configuración
set.seed(2024)
library(ggplot2)
library(tidyr)
library(dplyr)

# Generar datos pareados: ingresos antes y después del programa
n <- 85

# Ingresos ANTES del programa (desempleados o subempleados)
ingreso_antes <- rnorm(n, mean = 25, sd = 8)

# Efecto del programa: aumenta ingresos en promedio 6.5 con variabilidad
efecto_individual <- rnorm(n, mean = 6.5, sd = 4.5)

# Ingresos DESPUÉS (antes + efecto individual)
ingreso_despues <- ingreso_antes + efecto_individual

# Crear dataframe
datos <- data.frame(
  participante = 1:n,
  antes = ingreso_antes,
  despues = ingreso_despues,
  diferencia = ingreso_despues - ingreso_antes
)

# ============================================
# ESTADÍSTICAS DESCRIPTIVAS
# ============================================
cat("=== ESTADÍSTICAS DESCRIPTIVAS ===\n\n")

cat("ANTES del programa:\n")
cat("  Media:", round(mean(datos$antes), 2), "mil pesos\n")
cat("  Mediana:", round(median(datos$antes), 2), "mil pesos\n")
cat("  SD:", round(sd(datos$antes), 2), "\n\n")

cat("DESPUÉS del programa:\n")
cat("  Media:", round(mean(datos$despues), 2), "mil pesos\n")
cat("  Mediana:", round(median(datos$despues), 2), "mil pesos\n")
cat("  SD:", round(sd(datos$despues), 2), "\n\n")

cat("DIFERENCIAS (Después - Antes):\n")
cat("  Media:", round(mean(datos$diferencia), 2), "mil pesos\n")
cat("  Mediana:", round(median(datos$diferencia), 2), "mil pesos\n")
cat("  SD:", round(sd(datos$diferencia), 2), "\n")
cat("  Min:", round(min(datos$diferencia), 2), "\n")
cat("  Max:", round(max(datos$diferencia), 2), "\n")

# Proporción con mejora
pct_mejora <- mean(datos$diferencia > 0) * 100
cat("  % con mejora (diferencia > 0):", round(pct_mejora, 1), "%\n\n")

# ============================================
# TEST T PAREADO
# ============================================
cat("=== TEST T PAREADO ===\n\n")

resultado_test <- t.test(datos$despues, datos$antes, paired = TRUE)

cat("H0: La media de las diferencias es 0 (no hay efecto)\n")
cat("H1: La media de las diferencias ≠ 0 (hay efecto)\n\n")

cat("Estadístico t:", round(resultado_test$statistic, 3), "\n")
cat("Grados de libertad:", resultado_test$parameter, "\n")
cat("P-valor:", format.pval(resultado_test$p.value, digits = 4), "\n\n")

cat("Diferencia promedio:", round(resultado_test$estimate, 2), "mil pesos\n")
cat("IC 95%: [", round(resultado_test$conf.int[1], 2), ",", 
    round(resultado_test$conf.int[2], 2), "]\n\n")

# Tamaño del efecto (Cohen's d para muestras pareadas)
cohens_d <- mean(datos$diferencia) / sd(datos$diferencia)
cat("Tamaño del efecto (Cohen's d):", round(cohens_d, 3), "\n")

if(abs(cohens_d) < 0.2) cat("  Interpretación: efecto pequeño\n")
if(abs(cohens_d) >= 0.2 & abs(cohens_d) < 0.5) cat("  Interpretación: efecto pequeño-moderado\n")
if(abs(cohens_d) >= 0.5 & abs(cohens_d) < 0.8) cat("  Interpretación: efecto moderado\n")
if(abs(cohens_d) >= 0.8) cat("  Interpretación: efecto grande\n")

cat("\n")

# ============================================
# VERIFICACIÓN DE SUPUESTOS
# ============================================
cat("=== VERIFICACIÓN DE SUPUESTOS ===\n\n")

# Test de normalidad de las DIFERENCIAS
shapiro_diff <- shapiro.test(datos$diferencia)
cat("Shapiro-Wilk test (normalidad de diferencias):\n")
cat("  W =", round(shapiro_diff$statistic, 4), "\n")
cat("  p-valor =", round(shapiro_diff$p.value, 4), "\n")

if(shapiro_diff$p.value > 0.05) {
  cat("  ✓ No se rechaza normalidad (p > 0.05)\n\n")
} else {
  cat("  ✗ Se rechaza normalidad (p < 0.05)\n")
  cat("  Considerar test de Wilcoxon como alternativa\n\n")
}

# Test de Wilcoxon (no paramétrico) para comparar
wilcox_result <- wilcox.test(datos$despues, datos$antes, paired = TRUE)
cat("Test de Wilcoxon (alternativa no paramétrica):\n")
cat("  V =", wilcox_result$statistic, "\n")
cat("  p-valor =", format.pval(wilcox_result$p.value, digits = 4), "\n\n")

# ============================================
# VISUALIZACIONES
# ============================================

# 1. Boxplot comparativo
datos_long <- datos %>%
  pivot_longer(cols = c(antes, despues), 
               names_to = "momento", 
               values_to = "ingreso")

p1 <- ggplot(datos_long, aes(x = momento, y = ingreso, fill = momento)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.3, size = 1) +
  scale_fill_manual(values = c("antes" = "coral", "despues" = "steelblue")) +
  labs(title = "Comparación de Ingresos: Antes vs Después del Programa",
       subtitle = paste0("n = ", n, " participantes"),
       x = "Momento de Medición",
       y = "Ingreso Mensual (miles de pesos)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold"))

print(p1)

# 2. Histograma de las diferencias
p2 <- ggplot(datos, aes(x = diferencia)) +
  geom_histogram(aes(y = after_stat(density)), 
                 bins = 20, 
                 fill = "darkgreen", 
                 alpha = 0.7, 
                 color = "white") +
  geom_density(color = "red", size = 1.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "black", size = 1) +
  geom_vline(xintercept = mean(datos$diferencia), 
             linetype = "solid", color = "blue", size = 1) +
  labs(title = "Distribución de las Diferencias (Después - Antes)",
       subtitle = paste0("Diferencia media = ", round(mean(datos$diferencia), 2), 
                        " mil pesos | p-valor = ", format.pval(resultado_test$p.value, digits = 3)),
       x = "Cambio en Ingreso (miles de pesos)",
       y = "Densidad") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

print(p2)

# 3. Gráfico de líneas pareadas (muestra aleatoria de 30 para claridad)
set.seed(123)
muestra_visual <- sample(1:n, min(30, n))
datos_muestra <- datos[muestra_visual, ]
datos_muestra_long <- datos_muestra %>%
  pivot_longer(cols = c(antes, despues), 
               names_to = "momento", 
               values_to = "ingreso") %>%
  mutate(momento = factor(momento, levels = c("antes", "despues")))

p3 <- ggplot(datos_muestra_long, aes(x = momento, y = ingreso, group = participante)) +
  geom_line(alpha = 0.3, color = "gray50") +
  geom_point(aes(color = momento), size = 2, alpha = 0.7) +
  scale_color_manual(values = c("antes" = "coral", "despues" = "steelblue")) +
  labs(title = "Trayectorias Individuales (muestra de 30 participantes)",
       subtitle = "Cada línea representa un participante",
       x = "Momento de Medición",
       y = "Ingreso Mensual (miles de pesos)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold"))

print(p3)

# 4. Q-Q plot de las diferencias
p4 <- ggplot(datos, aes(sample = diferencia)) +
  stat_qq() +
  stat_qq_line(color = "red", size = 1) +
  labs(title = "Q-Q Plot de las Diferencias",
       subtitle = "Verificación de normalidad",
       x = "Cuantiles Teóricos",
       y = "Cuantiles de la Muestra") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

print(p4)
