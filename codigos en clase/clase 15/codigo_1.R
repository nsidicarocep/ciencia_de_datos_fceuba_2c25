# Simulación: Distribución muestral del promedio
library(tidyverse)

# Población: ingresos con distribución asimétrica
poblacion <- rexp(100000, rate = 1/50000)

# Tomar 1000 muestras de tamaño 100
promedios_muestrales <- replicate(1000, {
  muestra <- sample(poblacion, 100)
  mean(muestra)
})

# Visualizar
tibble(promedio = promedios_muestrales) %>%
  ggplot(aes(x = promedio)) +
  geom_histogram(bins = 50, fill = "steelblue", alpha = 0.7) +
  geom_vline(xintercept = mean(poblacion), 
             color = "red", linewidth = 1.5) +
  labs(title = "Distribución muestral del promedio",
       subtitle = "1000 muestras de tamaño 100",
       x = "Promedio muestral",
       y = "Frecuencia")