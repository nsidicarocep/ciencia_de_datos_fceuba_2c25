# Configuración
set.seed(2024)
library(ggplot2)

# Generar datos de ingresos con distribución log-normal (típica de ingresos)
ingresos <- rlnorm(500, meanlog = 3.5, sdlog = 0.7)

# Crear dataframe
datos <- data.frame(ingreso = ingresos)

# Calcular estadísticas descriptivas
media <- mean(ingresos)
mediana <- median(ingresos)
desv_std <- sd(ingresos)
q1 <- quantile(ingresos, 0.25)
q3 <- quantile(ingresos, 0.75)
iqr <- q3 - q1
skewness <- mean((ingresos - media)^3) / (desv_std^3)

# Crear histograma con líneas de referencia
ggplot(datos, aes(x = ingreso)) +
  geom_histogram(aes(y = after_stat(density)), 
                 bins = 30, 
                 fill = "steelblue", 
                 color = "white", 
                 alpha = 0.7) +
  geom_density(color = "red", size = 1.2) +
  geom_vline(aes(xintercept = media), 
             color = "darkgreen", 
             linetype = "dashed", 
             size = 1) +
  geom_vline(aes(xintercept = mediana), 
             color = "orange", 
             linetype = "dashed", 
             size = 1) +
  labs(title = "Distribución de Ingresos Mensuales (n=500)",
       subtitle = paste0("Media (verde) = ", round(media, 1), 
                        " | Mediana (naranja) = ", round(mediana, 1),
                        " | Asimetría = ", round(skewness, 2)),
       x = "Ingreso Mensual (miles de pesos)",
       y = "Densidad") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(size = 10))

# Imprimir estadísticas adicionales
cat("\n=== ESTADÍSTICAS DESCRIPTIVAS ===\n")
cat("Media:", round(media, 2), "\n")
cat("Mediana:", round(mediana, 2), "\n")
cat("Desv. Estándar:", round(desv_std, 2), "\n")
cat("Q1:", round(q1, 2), "\n")
cat("Q3:", round(q3, 2), "\n")
cat("IQR:", round(iqr, 2), "\n")
cat("Coef. de Variación:", round(desv_std/media, 2), "\n")
cat("Skewness:", round(skewness, 2), "\n")

# Test de normalidad
shapiro_result <- shapiro.test(ingresos)
cat("\nShapiro-Wilk test p-value:", round(shapiro_result$p.value, 6), "\n")

# Porcentaje de observaciones > media
pct_sobre_media <- mean(ingresos > media) * 100
cat("% observaciones > media:", round(pct_sobre_media, 1), "%\n")