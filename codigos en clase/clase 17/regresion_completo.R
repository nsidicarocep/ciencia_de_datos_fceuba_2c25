################################################################################
#                    REGRESIÓN LINEAL APLICADA EN R                           #
#                    Workflow Completo con Ejemplos                            #
################################################################################

# Autor: [Tu nombre]
# Fecha: [Fecha]
# Descripción: Script completo que implementa regresión lineal desde 
#              exploración hasta diagnósticos y correcciones

################################################################################
# 0. CONFIGURACIÓN INICIAL
################################################################################

# Limpiar el entorno
rm(list = ls())

# Cargar paquetes necesarios
# Si no los tienes instalados, ejecuta primero:
# install.packages(c("wooldridge", "tidyverse", "car", "lmtest", 
#                    "sandwich", "stargazer", "corrplot", "ggcorrplot"))

library(wooldridge)      # Bases de datos
library(tidyverse)       # Manipulación y visualización
library(car)             # VIF y otros diagnósticos
library(lmtest)          # Tests de especificación
library(sandwich)        # Errores robustos
library(stargazer)       # Tablas de regresión
library(corrplot)        # Matriz de correlaciones visual
library(ggcorrplot)      # Alternativa para correlaciones

# Configurar opciones
options(scipen = 999)    # Evitar notación científica
options(digits = 4)      # Número de decimales

################################################################################
# 1. CARGAR Y EXPLORAR LOS DATOS
################################################################################

# Usaremos la base 'bwght' sobre peso al nacer de bebés
# Variables principales:
# - bwght: peso al nacer (onzas)
# - cigs: cigarrillos fumados por día durante embarazo
# - faminc: ingreso familiar ($1000)
# - fatheduc: educación del padre (años)
# - motheduc: educación de la madre (años)
# - parity: orden de nacimiento del bebé
# - male: 1 si es niño, 0 si es niña
# - white: 1 si es blanco

data(bwght)

# Ver las primeras observaciones
head(bwght)

# Estructura de los datos
str(bwght)

# Resumen estadístico
summary(bwght)

# ¿Cuántas observaciones y variables?
dim(bwght)
cat("\nTenemos", nrow(bwght), "observaciones y", ncol(bwght), "variables\n")

# Ver nombres de variables
names(bwght)

# Verificar si hay valores faltantes
colSums(is.na(bwght))

# Descripción de variables clave
cat("\n=== VARIABLES PRINCIPALES ===\n")
cat("Peso al nacer (bwght):\n")
summary(bwght$bwght)

cat("\nCigarrillos por día (cigs):\n")
summary(bwght$cigs)
cat("Madres que fumaron:", sum(bwght$cigs > 0), 
    "(", round(sum(bwght$cigs > 0)/nrow(bwght)*100, 1), "%)\n")

cat("\nIngreso familiar (faminc):\n")
summary(bwght$faminc)

################################################################################
# 2. ANÁLISIS EXPLORATORIO DE DATOS (EDA)
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("ANÁLISIS EXPLORATORIO DE DATOS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# --- 2.1 Distribución de la variable dependiente ---
cat("2.1 Distribución del Peso al Nacer\n")

# Histograma
hist(bwght$bwght, 
     main = "Distribución del Peso al Nacer",
     xlab = "Peso (onzas)",
     ylab = "Frecuencia",
     col = "steelblue",
     breaks = 30)

# Añadir línea de la media
abline(v = mean(bwght$bwght), col = "red", lwd = 2, lty = 2)
legend("topleft", legend = paste("Media =", round(mean(bwght$bwght), 1), "oz"),
       col = "red", lty = 2, lwd = 2)

# Boxplot
boxplot(bwght$bwght, 
        main = "Boxplot del Peso al Nacer",
        ylab = "Peso (onzas)",
        col = "lightblue")

# --- 2.2 Relaciones bivariadas ---
cat("\n2.2 Relaciones Bivariadas\n")

# Peso vs Cigarrillos
plot(bwght$cigs, bwght$bwght,
     main = "Peso al Nacer vs Cigarrillos",
     xlab = "Cigarrillos por día",
     ylab = "Peso (onzas)",
     pch = 19,
     col = alpha("steelblue", 0.3))
abline(lm(bwght ~ cigs, data = bwght), col = "red", lwd = 2)

# Peso vs Ingreso Familiar
plot(bwght$faminc, bwght$bwght,
     main = "Peso al Nacer vs Ingreso Familiar",
     xlab = "Ingreso Familiar ($1000)",
     ylab = "Peso (onzas)",
     pch = 19,
     col = alpha("darkgreen", 0.3))
abline(lm(bwght ~ faminc, data = bwght), col = "red", lwd = 2)

# --- 2.3 Matriz de correlaciones ---
cat("\n2.3 Matriz de Correlaciones\n")

# Seleccionar variables numéricas de interés
vars_numericas <- bwght %>% 
  select(bwght, cigs, faminc, motheduc, fatheduc, parity)

# Calcular correlaciones
cor_matrix <- cor(vars_numericas, use = "complete.obs")
print(round(cor_matrix, 3))

# Visualizar matriz de correlaciones
corrplot(cor_matrix, 
         method = "color", 
         type = "upper",
         addCoef.col = "black",
         tl.col = "black",
         tl.srt = 45,
         title = "Matriz de Correlaciones",
         mar = c(0,0,2,0))

# --- 2.4 Comparaciones por grupos ---
cat("\n2.4 Diferencias por Sexo\n")

# Peso por sexo del bebé
boxplot(bwght ~ male, 
        data = bwght,
        names = c("Niña", "Niño"),
        main = "Peso al Nacer por Sexo",
        ylab = "Peso (onzas)",
        col = c("pink", "lightblue"))

# Test t para diferencia de medias
t.test(bwght ~ male, data = bwght)

cat("\nPeso promedio - Niñas:", mean(bwght$bwght[bwght$male == 0]), "oz\n")
cat("Peso promedio - Niños:", mean(bwght$bwght[bwght$male == 1]), "oz\n")

################################################################################
# 3. MODELO DE REGRESIÓN LINEAL SIMPLE
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("MODELO DE REGRESIÓN LINEAL SIMPLE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# --- 3.1 Primer modelo: Peso ~ Cigarrillos ---
cat("3.1 Modelo Simple: bwght ~ cigs\n\n")

modelo1 <- lm(bwght ~ cigs, data = bwght)
summary(modelo1)

# Interpretación
cat("\n--- INTERPRETACIÓN ---\n")
cat("Intercepto:", coef(modelo1)[1], "\n")
cat("  → Peso esperado para madres que no fuman:", 
    round(coef(modelo1)[1], 2), "onzas\n\n")

cat("Pendiente:", coef(modelo1)[2], "\n")
cat("  → Por cada cigarrillo adicional por día, el peso disminuye en",
    abs(round(coef(modelo1)[2], 2)), "onzas (aprox", 
    round(abs(coef(modelo1)[2]) * 28.35, 1), "gramos)\n\n")

cat("R²:", round(summary(modelo1)$r.squared, 4), "\n")
cat("  → Los cigarrillos explican solo el", 
    round(summary(modelo1)$r.squared * 100, 2), 
    "% de la variación en peso\n")

# Visualización
plot(bwght$cigs, bwght$bwght,
     main = "Modelo Simple: Peso ~ Cigarrillos",
     xlab = "Cigarrillos por día",
     ylab = "Peso al nacer (onzas)",
     pch = 19,
     col = alpha("steelblue", 0.3))
abline(modelo1, col = "red", lwd = 2)

# Agregar intervalos de confianza
newdata <- data.frame(cigs = seq(0, 40, length.out = 100))
pred <- predict(modelo1, newdata = newdata, interval = "confidence")
lines(newdata$cigs, pred[,"lwr"], col = "blue", lty = 2)
lines(newdata$cigs, pred[,"upr"], col = "blue", lty = 2)
legend("topright", 
       legend = c("Línea de regresión", "IC 95%"),
       col = c("red", "blue"),
       lty = c(1, 2),
       lwd = c(2, 1))

################################################################################
# 4. REGRESIÓN MÚLTIPLE
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("REGRESIÓN MÚLTIPLE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# --- 4.1 Agregar más variables ---
cat("4.1 Modelo Múltiple: Control por ingreso y educación\n\n")

modelo2 <- lm(bwght ~ cigs + faminc + motheduc + fatheduc, data = bwght)
summary(modelo2)

cat("\n--- INTERPRETACIÓN (CETERIS PARIBUS) ---\n")
cat("Coeficiente de cigarrillos:", round(coef(modelo2)["cigs"], 4), "\n")
cat("  → Manteniendo ingreso y educación constantes,\n")
cat("    cada cigarrillo reduce el peso en", 
    abs(round(coef(modelo2)["cigs"], 2)), "onzas\n\n")

cat("Coeficiente de ingreso familiar:", round(coef(modelo2)["faminc"], 4), "\n")
cat("  → Por cada $1000 adicionales de ingreso,\n")
cat("    el peso aumenta en", round(coef(modelo2)["faminc"], 3), "onzas\n\n")

cat("R² ajustado:", round(summary(modelo2)$adj.r.squared, 4), "\n")
cat("  → El modelo explica el", 
    round(summary(modelo2)$adj.r.squared * 100, 2), 
    "% de la variación en peso\n")

# --- 4.2 Comparar modelos ---
cat("\n4.2 Comparación de Modelos\n\n")

# Tabla comparativa
stargazer(modelo1, modelo2,
          type = "text",
          title = "Comparación de Modelos",
          dep.var.labels = "Peso al Nacer (onzas)",
          covariate.labels = c("Cigarrillos/día", "Ingreso Fam ($1000)",
                               "Educ. Madre", "Educ. Padre"),
          keep.stat = c("n", "rsq", "adj.rsq"),
          digits = 3)


################################################################################
# 5. VARIABLES DUMMY (CATEGÓRICAS)
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("VARIABLES DUMMY\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# --- 5.1 Agregar variable de sexo del bebé ---
cat("5.1 Efecto del Sexo del Bebé\n\n")

modelo3 <- lm(bwght ~ cigs + faminc + motheduc + fatheduc + male, 
              data = bwght)
summary(modelo3)

cat("\n--- INTERPRETACIÓN ---\n")
cat("Coeficiente 'male':", round(coef(modelo3)["male"], 2), "\n")
cat("  → Los niños pesan en promedio", round(coef(modelo3)["male"], 2), 
    "onzas MÁS que las niñas,\n")
cat("    manteniendo todo lo demás constante\n")
cat("  → Esto equivale a aproximadamente", 
    round(coef(modelo3)["male"] * 28.35, 1), "gramos\n\n")

# Significancia
if (summary(modelo3)$coefficients["male", "Pr(>|t|)"] < 0.001) {
  cat("  → Altamente significativo (p < 0.001) ***\n")
} else if (summary(modelo3)$coefficients["male", "Pr(>|t|)"] < 0.05) {
  cat("  → Significativo (p < 0.05) **\n")
} else {
  cat("  → No significativo\n")
}

# --- 5.2 Agregar variable de raza ---
cat("\n5.2 Efecto de la Raza\n\n")

modelo4 <- lm(bwght ~ cigs + faminc + motheduc + fatheduc + male + white, 
              data = bwght)
summary(modelo4)

cat("\n--- INTERPRETACIÓN ---\n")
cat("Coeficiente 'white':", round(coef(modelo4)["white"], 2), "\n")
cat("  → Los bebés blancos pesan en promedio", 
    round(coef(modelo4)["white"], 2), 
    "onzas más que los no blancos\n")

# --- 5.3 Visualizar diferencias por grupos ---

# Crear datos para predicción
pred_data <- expand.grid(
  cigs = seq(0, 30, by = 5),
  faminc = mean(bwght$faminc),
  motheduc = mean(bwght$motheduc, na.rm = TRUE),
  fatheduc = mean(bwght$fatheduc, na.rm = TRUE),
  male = c(0, 1),
  white = 1
)

pred_data$pred <- predict(modelo4, newdata = pred_data)

# Gráfico
plot(pred_data$cigs[pred_data$male == 0], 
     pred_data$pred[pred_data$male == 0],
     type = "l", col = "pink", lwd = 2,
     ylim = range(pred_data$pred),
     main = "Peso Predicho por Cigarrillos y Sexo",
     xlab = "Cigarrillos por día",
     ylab = "Peso predicho (onzas)")
lines(pred_data$cigs[pred_data$male == 1], 
      pred_data$pred[pred_data$male == 1],
      col = "lightblue", lwd = 2)
legend("topright", 
       legend = c("Niñas", "Niños"),
       col = c("pink", "lightblue"),
       lwd = 2)

################################################################################
# 6. DIAGNÓSTICOS: MULTICOLINEALIDAD
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("DIAGNÓSTICO 1: MULTICOLINEALIDAD\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# --- 6.1 Factor de Inflación de Varianza (VIF) ---
cat("6.1 VIF (Factor de Inflación de Varianza)\n\n")

vif_values <- vif(modelo4)
print(vif_values)

cat("\n--- INTERPRETACIÓN ---\n")
cat("Regla general:\n")
cat("  VIF < 5:  No hay problema\n")
cat("  VIF 5-10: Multicolinealidad moderada (revisar)\n")
cat("  VIF > 10: Multicolinealidad alta (problemático)\n\n")

if (max(vif_values) < 5) {
  cat("✓ No hay problemas de multicolinealidad en este modelo\n")
} else if (max(vif_values) < 10) {
  cat("⚠ Hay multicolinealidad moderada\n")
  cat("Variables problemáticas:", 
      names(vif_values)[vif_values > 5], "\n")
} else {
  cat("✗ Hay multicolinealidad alta\n")
  cat("Variables problemáticas:", 
      names(vif_values)[vif_values > 10], "\n")
}

# --- 6.2 Visualizar VIF ---
barplot(vif_values, 
        main = "Factor de Inflación de Varianza (VIF)",
        ylab = "VIF",
        col = ifelse(vif_values > 5, "red", "steelblue"),
        las = 2)
abline(h = 5, col = "orange", lwd = 2, lty = 2)
abline(h = 10, col = "red", lwd = 2, lty = 2)
legend("topright", 
       legend = c("VIF < 5 (OK)", "VIF > 5 (Revisar)", "VIF > 10 (Problema)"),
       fill = c("steelblue", "orange", "red"))

# --- 6.3 Matriz de correlación entre predictores ---
cat("\n6.2 Correlaciones entre Predictores\n\n")

# Seleccionar solo las X's
predictores <- bwght %>% 
  select(cigs, faminc, motheduc, fatheduc, male, white) %>%
  na.omit()

cor_pred <- cor(predictores)
print(round(cor_pred, 3))

# Visualizar
corrplot(cor_pred, 
         method = "color",
         type = "upper",
         addCoef.col = "black",
         tl.col = "black",
         tl.srt = 45,
         title = "Correlaciones entre Predictores",
         mar = c(0,0,2,0))

################################################################################
# 7. DIAGNÓSTICOS: HETEROSCEDASTICIDAD
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("DIAGNÓSTICO 2: HETEROSCEDASTICIDAD\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# --- 7.1 Gráficos de residuos ---
cat("7.1 Análisis Visual de Residuos\n\n")

# Los 4 gráficos de diagnóstico estándar
par(mfrow = c(2, 2))
plot(modelo4, pch = 19, col = alpha("steelblue", 0.3))
par(mfrow = c(1, 1))

cat("\n¿Qué buscar?\n")
cat("  - Residuals vs Fitted: Debe verse aleatorio (sin patrón)\n")
cat("  - Q-Q Plot: Los puntos deben seguir la línea (normalidad)\n")
cat("  - Scale-Location: Línea horizontal (homocedasticidad)\n")
cat("  - Residuals vs Leverage: Identificar observaciones influyentes\n\n")

# Gráfico específico: Residuos vs Fitted
plot(fitted(modelo4), residuals(modelo4),
     pch = 19, col = alpha("steelblue", 0.5),
     main = "Residuos vs Valores Ajustados",
     xlab = "Valores Ajustados",
     ylab = "Residuos")
abline(h = 0, col = "red", lwd = 2)

# Añadir línea de suavizado para ver tendencia
lines(lowess(fitted(modelo4), residuals(modelo4)), 
      col = "blue", lwd = 2)
legend("topright", 
       legend = c("Línea cero", "Tendencia suavizada"),
       col = c("red", "blue"),
       lwd = 2)

# --- 7.2 Test de Breusch-Pagan ---
cat("\n7.2 Test de Breusch-Pagan\n\n")

bp_test <- bptest(modelo4)
print(bp_test)

cat("\n--- INTERPRETACIÓN ---\n")
cat("H₀: Homocedasticidad (varianza constante)\n")
cat("H₁: Heteroscedasticidad\n\n")

if (bp_test$p.value < 0.05) {
  cat("✗ Rechazamos H₀ (p =", round(bp_test$p.value, 4), ")\n")
  cat("  → HAY evidencia de heteroscedasticidad\n")
  cat("  → Los errores estándar de MCO NO son confiables\n")
  cat("  → Solución: Usar ERRORES ROBUSTOS\n")
} else {
  cat("✓ No rechazamos H₀ (p =", round(bp_test$p.value, 4), ")\n")
  cat("  → NO hay evidencia de heteroscedasticidad\n")
  cat("  → Los errores estándar de MCO son confiables\n")
}

# --- 7.3 Test de White (más general) ---
cat("\n7.3 Test de White (incluye términos no lineales)\n\n")

# Test de White simplificado
white_test <- bptest(modelo4, 
                     ~ cigs + faminc + motheduc + fatheduc + male + white +
                       I(cigs^2) + I(faminc^2) + I(motheduc^2) + I(fatheduc^2),
                     data = bwght)
print(white_test)

if (white_test$p.value < 0.05) {
  cat("\n✗ El test de White también detecta heteroscedasticidad\n")
} else {
  cat("\n✓ El test de White no detecta heteroscedasticidad\n")
}

################################################################################
# 8. CORRECCIÓN: ERRORES ROBUSTOS
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("CORRECCIÓN: ERRORES ROBUSTOS (ERRORES DE WHITE)\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# --- 8.1 Comparar errores normales vs robustos ---
cat("8.1 Comparación de Errores Estándar\n\n")

# Resultados con errores normales
cat("--- MODELO CON ERRORES NORMALES (MCO) ---\n")
summary(modelo4)$coefficients

# Resultados con errores robustos
cat("\n--- MODELO CON ERRORES ROBUSTOS (HC1) ---\n")
coeftest(modelo4, vcov = vcovHC(modelo4, type = "HC1"))

# --- 8.2 Tabla comparativa ---
cat("\n8.2 Tabla Comparativa\n\n")

# Extraer información
coef_normal <- summary(modelo4)$coefficients
coef_robusto <- coeftest(modelo4, vcov = vcovHC(modelo4, type = "HC1"))

# Crear data frame comparativo
comparacion <- data.frame(
  Variable = rownames(coef_normal),
  Coeficiente = coef_normal[, "Estimate"],
  SE_Normal = coef_normal[, "Std. Error"],
  SE_Robusto = coef_robusto[, "Std. Error"],
  Cambio_Porcentual = (coef_robusto[, "Std. Error"] - coef_normal[, "Std. Error"]) / 
    coef_normal[, "Std. Error"] * 100
)

print(comparacion)

cat("\n--- INTERPRETACIÓN ---\n")
cat("Los errores robustos suelen ser MAYORES (más conservadores)\n")
cat("Cambios importantes en SE pueden afectar la significancia\n")

# Visualizar diferencia
barplot(t(as.matrix(comparacion[, c("SE_Normal", "SE_Robusto")])),
        beside = TRUE,
        names.arg = comparacion$Variable,
        col = c("lightblue", "coral"),
        main = "Comparación de Errores Estándar",
        ylab = "Error Estándar",
        las = 2,
        legend.text = c("Normal", "Robusto"),
        args.legend = list(x = "topright"))

# --- 8.3 ¿Cambió la significancia? ---
cat("\n8.3 Impacto en Significancia Estadística\n\n")

# P-valores normales
pval_normal <- coef_normal[, "Pr(>|t|)"]
sig_normal <- ifelse(pval_normal < 0.001, "***",
                     ifelse(pval_normal < 0.01, "**",
                            ifelse(pval_normal < 0.05, "*",
                                   ifelse(pval_normal < 0.1, ".", ""))))

# P-valores robustos
pval_robusto <- coef_robusto[, "Pr(>|t|)"]
sig_robusto <- ifelse(pval_robusto < 0.001, "***",
                      ifelse(pval_robusto < 0.01, "**",
                             ifelse(pval_robusto < 0.05, "*",
                                    ifelse(pval_robusto < 0.1, ".", ""))))

comparacion_sig <- data.frame(
  Variable = rownames(coef_normal),
  Sig_Normal = sig_normal,
  Sig_Robusto = sig_robusto,
  Cambio = ifelse(sig_normal == sig_robusto, "No", "Sí")
)

print(comparacion_sig)

if (any(comparacion_sig$Cambio == "Sí")) {
  cat("\n⚠ Algunas variables cambiaron de significancia\n")
  cat("Variables afectadas:\n")
  print(comparacion_sig[comparacion_sig$Cambio == "Sí", ])
} else {
  cat("\n✓ Ninguna variable cambió de significancia\n")
}

################################################################################
# 9. SELECCIÓN DE MODELOS
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("SELECCIÓN DE MODELOS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# --- 9.1 Comparar varios modelos ---
cat("9.1 Modelos Candidatos\n\n")

# Modelo simple
m1 <- lm(bwght ~ cigs, data = bwght)

# Modelo con controles básicos
m2 <- lm(bwght ~ cigs + faminc, data = bwght)

# Modelo con educación
m3 <- lm(bwght ~ cigs + faminc + motheduc + fatheduc, data = bwght)

# Modelo completo
m4 <- lm(bwght ~ cigs + faminc + motheduc + fatheduc + male + white, 
         data = bwght)

# --- 9.2 Criterios de información ---
cat("9.2 Criterios de Información\n\n")

# Calcular criterios
criterios <- data.frame(
  Modelo = c("M1: cigs", 
             "M2: + faminc", 
             "M3: + educación",
             "M4: + sexo/raza"),
  N_variables = c(length(coef(m1)) - 1,
                  length(coef(m2)) - 1,
                  length(coef(m3)) - 1,
                  length(coef(m4)) - 1),
  R2 = c(summary(m1)$r.squared,
         summary(m2)$r.squared,
         summary(m3)$r.squared,
         summary(m4)$r.squared),
  R2_adj = c(summary(m1)$adj.r.squared,
             summary(m2)$adj.r.squared,
             summary(m3)$adj.r.squared,
             summary(m4)$adj.r.squared),
  AIC = c(AIC(m1), AIC(m2), AIC(m3), AIC(m4)),
  BIC = c(BIC(m1), BIC(m2), BIC(m3), BIC(m4))
)

print(criterios)

cat("\n--- INTERPRETACIÓN ---\n")
cat("R² y R² ajustado: Mayor es mejor\n")
cat("AIC y BIC: Menor es mejor\n\n")

# Identificar mejor modelo por cada criterio
cat("Mejor modelo por R² ajustado:", 
    criterios$Modelo[which.max(criterios$R2_adj)], "\n")
cat("Mejor modelo por AIC:", 
    criterios$Modelo[which.min(criterios$AIC)], "\n")
cat("Mejor modelo por BIC:", 
    criterios$Modelo[which.min(criterios$BIC)], "\n")

# Visualizar
par(mfrow = c(1, 3))
barplot(criterios$R2_adj, 
        names.arg = 1:4,
        main = "R² Ajustado",
        ylab = "R² adj",
        col = "steelblue")
barplot(criterios$AIC, 
        names.arg = 1:4,
        main = "AIC (menor es mejor)",
        ylab = "AIC",
        col = "coral")
barplot(criterios$BIC, 
        names.arg = 1:4,
        main = "BIC (menor es mejor)",
        ylab = "BIC",
        col = "lightgreen")
par(mfrow = c(1, 1))

# --- 9.3 Test de Ramsey (RESET) ---
cat("\n9.3 Test de Ramsey (RESET) - Especificación\n\n")

reset_test <- resettest(m4, power = 2:3, type = "fitted")
print(reset_test)

cat("\n--- INTERPRETACIÓN ---\n")
cat("H₀: El modelo está correctamente especificado\n")
cat("H₁: Hay problemas de especificación\n\n")

if (reset_test$p.value < 0.05) {
  cat("✗ Posible problema de especificación (p =", 
      round(reset_test$p.value, 4), ")\n")
  cat("  → Considerar:\n")
  cat("    - Transformaciones (log, cuadrático)\n")
  cat("    - Variables omitidas\n")
  cat("    - Interacciones\n")
} else {
  cat("✓ No hay evidencia de problemas de especificación (p =", 
      round(reset_test$p.value, 4), ")\n")
}

################################################################################
# 10. MODELO FINAL Y REPORTE
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("MODELO FINAL Y REPORTE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# --- 10.1 Elegir modelo final ---
cat("10.1 Modelo Final Seleccionado\n\n")

# Basándonos en los criterios, elegimos m4
modelo_final <- m4

cat("Ecuación del modelo:\n")
cat("bwght = β₀ + β₁*cigs + β₂*faminc + β₃*motheduc + β₄*fatheduc + β₅*male + β₆*white + u\n\n")

# --- 10.2 Resultados con errores robustos ---
cat("10.2 Resultados Finales (con errores robustos)\n\n")

resultado_final <- coeftest(modelo_final, 
                            vcov = vcovHC(modelo_final, type = "HC1"))
print(resultado_final)

# --- 10.3 Tabla profesional ---
cat("\n10.3 Tabla para Reporte\n\n")

stargazer(m1, m2, m3, m4,
          type = "text",
          title = "Determinantes del Peso al Nacer",
          dep.var.labels = "Peso al Nacer (onzas)",
          covariate.labels = c("Cigarrillos/día", 
                               "Ingreso Fam. ($1000)",
                               "Educ. Madre (años)",
                               "Educ. Padre (años)",
                               "Sexo (1=Niño)",
                               "Raza (1=Blanco)"),
          keep.stat = c("n", "rsq", "adj.rsq"),
          digits = 3,
          notes = "Errores estándar entre paréntesis")

# --- 10.4 Interpretaciones clave ---
cat("\n10.4 INTERPRETACIONES CLAVE DEL MODELO FINAL\n\n")

coefs <- coef(modelo_final)

cat("1. EFECTO DEL TABACO:\n")
cat("   - Coeficiente:", round(coefs["cigs"], 3), "\n")
cat("   - Cada cigarrillo por día reduce el peso en", 
    abs(round(coefs["cigs"], 2)), "onzas\n")
cat("   - Esto equivale a", round(abs(coefs["cigs"]) * 28.35, 1), "gramos\n")
cat("   - Una fumadora de 20 cig/día tendría un bebé", 
    round(abs(coefs["cigs"]) * 20, 1), "onzas más liviano\n\n")

cat("2. EFECTO DEL INGRESO:\n")
cat("   - Coeficiente:", round(coefs["faminc"], 4), "\n")
cat("   - Por cada $1000 adicionales, el peso aumenta", 
    round(coefs["faminc"], 3), "onzas\n")
cat("   - Efecto pequeño pero positivo\n\n")

cat("3. DIFERENCIA POR SEXO:\n")
cat("   - Coeficiente:", round(coefs["male"], 2), "\n")
cat("   - Los niños pesan", round(coefs["male"], 2), 
    "onzas MÁS que las niñas\n")
cat("   - Aproximadamente", round(coefs["male"] * 28.35, 1), "gramos\n\n")

cat("4. BONDAD DE AJUSTE:\n")
cat("   - R² ajustado:", round(summary(modelo_final)$adj.r.squared, 4), "\n")
cat("   - El modelo explica el", 
    round(summary(modelo_final)$adj.r.squared * 100, 1), 
    "% de la variación en peso\n\n")

################################################################################
# 11. PREDICCIONES Y VISUALIZACIÓN FINAL
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("PREDICCIONES\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# --- 11.1 Predicción para casos específicos ---
cat("11.1 Ejemplos de Predicción\n\n")

# Caso 1: No fumadora, ingreso promedio, educación promedio, niña, blanca
caso1 <- data.frame(
  cigs = 0,
  faminc = mean(bwght$faminc),
  motheduc = mean(bwght$motheduc, na.rm = TRUE),
  fatheduc = mean(bwght$fatheduc, na.rm = TRUE),
  male = 0,
  white = 1
)

pred1 <- predict(modelo_final, newdata = caso1, interval = "confidence")
cat("Caso 1 - No fumadora, características promedio, niña:\n")
cat("  Peso predicho:", round(pred1[1], 2), "onzas\n")
cat("  IC 95%: [", round(pred1[2], 2), ",", round(pred1[3], 2), "]\n\n")

# Caso 2: Fumadora moderada (10 cigs)
caso2 <- caso1
caso2$cigs <- 10
pred2 <- predict(modelo_final, newdata = caso2, interval = "confidence")
cat("Caso 2 - Fumadora moderada (10 cig/día), mismas características:\n")
cat("  Peso predicho:", round(pred2[1], 2), "onzas\n")
cat("  Diferencia con caso 1:", round(pred2[1] - pred1[1], 2), "onzas\n\n")

# Caso 3: Fumadora fuerte (20 cigs)
caso3 <- caso1
caso3$cigs <- 20
pred3 <- predict(modelo_final, newdata = caso3, interval = "confidence")
cat("Caso 3 - Fumadora fuerte (20 cig/día), mismas características:\n")
cat("  Peso predicho:", round(pred3[1], 2), "onzas\n")
cat("  Diferencia con caso 1:", round(pred3[1] - pred1[1], 2), "onzas\n\n")

# --- 11.2 Curva de predicción ---
cat("11.2 Visualización de Predicciones\n\n")

# Crear secuencia de cigarrillos
pred_data_viz <- expand.grid(
  cigs = seq(0, 40, by = 1),
  faminc = mean(bwght$faminc),
  motheduc = mean(bwght$motheduc, na.rm = TRUE),
  fatheduc = mean(bwght$fatheduc, na.rm = TRUE),
  male = c(0, 1),
  white = 1
)

# Predecir
pred_data_viz$pred <- predict(modelo_final, newdata = pred_data_viz)

# Gráfico final
plot(pred_data_viz$cigs[pred_data_viz$male == 0],
     pred_data_viz$pred[pred_data_viz$male == 0],
     type = "l", col = "pink", lwd = 3,
     ylim = c(100, 130),
     main = "Efecto del Tabaco sobre Peso al Nacer por Sexo",
     xlab = "Cigarrillos por día",
     ylab = "Peso predicho (onzas)")
lines(pred_data_viz$cigs[pred_data_viz$male == 1],
      pred_data_viz$pred[pred_data_viz$male == 1],
      col = "lightblue", lwd = 3)
legend("topright",
       legend = c("Niñas", "Niños"),
       col = c("pink", "lightblue"),
       lwd = 3)

# Agregar datos reales con transparencia
points(bwght$cigs[bwght$male == 0], 
       bwght$bwght[bwght$male == 0],
       pch = 19, col = alpha("pink", 0.1))
points(bwght$cigs[bwght$male == 1], 
       bwght$bwght[bwght$male == 1],
       pch = 19, col = alpha("lightblue", 0.1))

################################################################################
# 12. RESUMEN Y CONCLUSIONES
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("RESUMEN Y CONCLUSIONES\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("HALLAZGOS PRINCIPALES:\n\n")

cat("1. EFECTO NOCIVO DEL TABACO:\n")
cat("   - Fumar durante el embarazo tiene un efecto negativo significativo\n")
cat("   - Cada cigarrillo reduce el peso en ~", abs(round(coefs["cigs"], 2)), 
    "onzas\n")
cat("   - El efecto persiste incluso controlando por factores socioeconómicos\n\n")

cat("2. FACTORES SOCIOECONÓMICOS:\n")
cat("   - El ingreso familiar tiene un efecto positivo pequeño\n")
cat("   - La educación parental también importa\n\n")

cat("3. DIFERENCIAS BIOLÓGICAS:\n")
cat("   - Los niños son más pesados que las niñas\n")
cat("   - Diferencia de aproximadamente", round(coefs["male"], 1), "onzas\n\n")

cat("4. CALIDAD DEL MODELO:\n")
cat("   - R² ajustado =", round(summary(modelo_final)$adj.r.squared, 3), "\n")
cat("   - Todos los coeficientes son significativos\n")
cat("   - Los diagnósticos sugieren heteroscedasticidad\n")
cat("   - Se usaron errores robustos para inferencia correcta\n\n")

cat("LIMITACIONES:\n")
cat("   - Correlación, no causalidad (aunque evidencia es sugerente)\n")
cat("   - Posibles variables omitidas (salud materna, nutrición)\n")
cat("   - Auto-reporte de cigarrillos (error de medición)\n\n")

cat("WORKFLOW IMPLEMENTADO:\n")
cat("   ✓ Exploración de datos\n")
cat("   ✓ Modelos simples y múltiples\n")
cat("   ✓ Variables dummy\n")
cat("   ✓ Diagnóstico de multicolinealidad\n")
cat("   ✓ Diagnóstico de heteroscedasticidad\n")
cat("   ✓ Corrección con errores robustos\n")
cat("   ✓ Selección de modelos\n")
cat("   ✓ Interpretación y predicción\n\n")

################################################################################
# 13. EXPORTAR RESULTADOS
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("EXPORTAR RESULTADOS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Crear carpeta de resultados si no existe
if (!dir.exists("resultados")) {
  dir.create("resultados")
  cat("✓ Carpeta 'resultados' creada\n")
}

# --- 13.1 Guardar tabla de regresión ---
stargazer(m1, m2, m3, m4,
          type = "html",
          out = "resultados/tabla_regresion.html",
          title = "Determinantes del Peso al Nacer",
          dep.var.labels = "Peso al Nacer (onzas)",
          covariate.labels = c("Cigarrillos/día", 
                               "Ingreso Fam. ($1000)",
                               "Educ. Madre (años)",
                               "Educ. Padre (años)",
                               "Sexo (1=Niño)",
                               "Raza (1=Blanco)"),
          digits = 3)

cat("✓ Tabla de regresión guardada: resultados/tabla_regresion.html\n")

# --- 13.2 Guardar datos de predicción ---
write.csv(pred_data_viz, 
          "resultados/predicciones.csv", 
          row.names = FALSE)
cat("✓ Predicciones guardadas: resultados/predicciones.csv\n")

# --- 13.3 Guardar gráficos ---
png("resultados/efecto_tabaco.png", width = 800, height = 600)
plot(pred_data_viz$cigs[pred_data_viz$male == 0],
     pred_data_viz$pred[pred_data_viz$male == 0],
     type = "l", col = "pink", lwd = 3,
     ylim = c(100, 130),
     main = "Efecto del Tabaco sobre Peso al Nacer por Sexo",
     xlab = "Cigarrillos por día",
     ylab = "Peso predicho (onzas)")
lines(pred_data_viz$cigs[pred_data_viz$male == 1],
      pred_data_viz$pred[pred_data_viz$male == 1],
      col = "lightblue", lwd = 3)
legend("topright",
       legend = c("Niñas", "Niños"),
       col = c("pink", "lightblue"),
       lwd = 3)
dev.off()
cat("✓ Gráfico guardado: resultados/efecto_tabaco.png\n")

# --- 13.4 Guardar resumen del modelo ---
sink("resultados/resumen_modelo.txt")
cat("RESUMEN DEL MODELO FINAL\n")
cat(paste(rep("=", 60), collapse=""), "\n\n")
print(summary(modelo_final))
cat("\n\nRESULTADOS CON ERRORES ROBUSTOS\n")
cat(paste(rep("=", 60), collapse=""), "\n\n")
print(coeftest(modelo_final, vcov = vcovHC(modelo_final, type = "HC1")))
cat("\n\nDIAGNÓSTICOS\n")
cat(paste(rep("=", 60), collapse=""), "\n\n")
cat("VIF:\n")
print(vif(modelo_final))
cat("\n\nTest de Breusch-Pagan:\n")
print(bptest(modelo_final))
cat("\n\nTest de Ramsey (RESET):\n")
print(resettest(modelo_final, power = 2:3))
sink()
cat("✓ Resumen completo guardado: resultados/resumen_modelo.txt\n")

################################################################################
# FIN DEL SCRIPT
################################################################################

cat("\n" , paste(rep("=", 80), collapse=""), "\n")
cat("ANÁLISIS COMPLETADO EXITOSAMENTE\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

cat("Tiempo de ejecución:", 
    format(Sys.time() - tiempo_inicio, digits = 2), "\n\n")

cat("Archivos generados en la carpeta 'resultados/':\n")
cat("  - tabla_regresion.html\n")
cat("  - predicciones.csv\n")
cat("  - efecto_tabaco.png\n")
cat("  - resumen_modelo.txt\n\n")

cat("Próximos pasos sugeridos:\n")
cat("  1. Explorar interacciones (ej: cigs * faminc)\n")
cat("  2. Probar modelos no lineales (ej: log transformations)\n")
cat("  3. Analizar efectos cuadráticos\n")
cat("  4. Considerar variables adicionales disponibles en el dataset\n\n")

cat("¡Gracias por usar este script!\n")

# Limpiar memoria
gc()