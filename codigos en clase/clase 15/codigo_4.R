# Salarios antes y después del programa
antes <- c(42, 45, 38, 50, 44, 48, 41, 46, 43, 49)
despues <- c(46, 48, 42, 54, 47, 52, 44, 49, 46, 53)

# H0: No hay diferencia (μ_diferencia = 0)
# H1: Hay aumento (μ_diferencia > 0)

resultado <- t.test(despues, antes, paired = TRUE, alternative = "greater")
print(resultado)

# Visualización de diferencias
diferencias <- despues - antes
tibble(
  trabajador = 1:10,
  diferencia = diferencias
) %>%
  ggplot(aes(x = trabajador, y = diferencia)) +
  geom_col(fill = ifelse(diferencias > 0, "steelblue", "red"),
           alpha = 0.7) +
  geom_hline(yintercept = 0, linewidth = 1) +
  geom_hline(yintercept = mean(diferencias), 
             color = "red", linetype = "dashed", linewidth = 1) +
  labs(title = "Cambio en salarios después del programa",
       x = "Trabajador",
       y = "Diferencia (miles de pesos)")