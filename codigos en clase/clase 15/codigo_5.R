# Tabla de contingencia
tabla <- matrix(c(120, 80, 60,   # Educación baja
                  100, 110, 90,  # Educación media
                  70, 130, 140), # Educación alta
                nrow = 3, byrow = TRUE,
                dimnames = list(
                  Educacion = c("Baja", "Media", "Alta"),
                  Partido = c("A", "B", "C")
                ))

print(tabla)

# H0: Las variables son independientes
# H1: Las variables están relacionadas

resultado <- chisq.test(tabla)
print(resultado)

# Visualización con mosaicplot
mosaicplot(tabla, 
           main = paste("Educación vs Preferencia Política\n",
                        "Chi-cuadrado p-valor =", 
                        round(resultado$p.value, 4)),
           color = TRUE)

# Visualización moderna con ggplot
library(tidyr)
as.data.frame.table(tabla) %>%
  ggplot(aes(x = Educacion, y = Freq, fill = Partido)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Distribución de preferencia política por educación",
       y = "Proporción",
       ) +
  theme_minimal()