# Datos simulados
set.seed(123)
salarios_hombres <- rnorm(50, mean = 55, sd = 12)
salarios_mujeres <- rnorm(50, mean = 48, sd = 10)

# H0: μ_hombres = μ_mujeres (no hay diferencia)
# H1: μ_hombres > μ_mujeres (test de una cola)

resultado <- t.test(salarios_hombres, salarios_mujeres, 
                    alternative = "greater")
print(resultado)

# Visualización
datos_comparacion <- tibble(
  salario = c(salarios_hombres, salarios_mujeres),
  genero = rep(c("Hombres", "Mujeres"), each = 50)
)

ggplot(datos_comparacion, aes(x = genero, y = salario, fill = genero)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.3) +
  stat_summary(fun = mean, geom = "point", 
               shape = 23, size = 4, fill = "red") +
  labs(title = "Comparación de salarios por género",
       subtitle = paste("p-valor =", round(resultado$p.value, 4)),
       y = "Salario (miles de pesos)",
       caption='Código 3 de Codigos en clase') +
  theme_minimal()