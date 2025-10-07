# Ejemplo: Test de una cola
library(ggplot2)

# Generar distribución bajo H0
x <- seq(-4, 4, length.out = 1000)
y <- dnorm(x)

# Estadístico observado
t_obs <- 2.3

# Crear visualización
tibble(x = x, y = y) %>%
  ggplot(aes(x = x, y = y)) +
  geom_line(linewidth = 1) +
  geom_area(data = . %>% filter(x >= t_obs),
            fill = "red", alpha = 0.3) +
  geom_vline(xintercept = t_obs, 
             color = "red", linewidth = 1.5, linetype = "dashed") +
  annotate("text", x = t_obs + 0.5, y = 0.3, 
           label = paste("t observado =", t_obs),
           color = "red") +
  annotate("text", x = 3, y = 0.05, 
           label = paste("p-valor =", round(1 - pnorm(t_obs), 4)),
           color = "red", size = 5) +
  labs(title = "Visualizacion del p-valor",
       x = "Estadistico t",
       y = "Densidad") + 
  theme_classic()
