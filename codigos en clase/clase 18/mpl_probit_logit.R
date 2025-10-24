################################################################################
#                                                                              #
#     MODELOS CON VARIABLE DEPENDIENTE DICOTÓMICA: EJEMPLO COMPLETO          #
#                                                                              #
#     Dataset: mroz (participación laboral femenina)                          #
#     Modelos: MPL, Logit y Probit                                            #
#                                                                              #
################################################################################

# ==============================================================================
# 0. CONFIGURACIÓN INICIAL
# ==============================================================================

# Limpiar entorno
rm(list = ls())

# Cargar librerías necesarias
# Si no las tienes instaladas, ejecuta primero:
# install.packages(c("wooldridge", "tidyverse", "margins", "sandwich", 
#                    "lmtest", "caret", "pROC", "stargazer", "ggplot2"))

library(wooldridge)   # Para acceder a los datasets
library(tidyverse)    # Para manipulación de datos y gráficos
library(margins)      # Para calcular efectos marginales
library(sandwich)     # Para errores robustos
library(lmtest)       # Para tests con errores robustos
library(caret)        # Para matriz de confusión
library(pROC)         # Para curva ROC
library(stargazer)    # Para tablas de resultados
library(ggplot2)      # Para gráficos

# Configurar opciones
options(scipen = 999)  # Evitar notación científica
set.seed(123)          # Para reproducibilidad

# ==============================================================================
# 1. CARGAR Y EXPLORAR LOS DATOS
# ==============================================================================

# Cargar dataset mroz
# Este dataset contiene información sobre participación laboral de mujeres casadas
data("mroz")

# Ver estructura de los datos
cat("\n=== ESTRUCTURA DE LOS DATOS ===\n")
str(mroz)

# Ver primeras observaciones
cat("\n=== PRIMERAS OBSERVACIONES ===\n")
head(mroz)

# Resumen estadístico
cat("\n=== RESUMEN ESTADÍSTICO ===\n")
summary(mroz)

# VARIABLE DEPENDIENTE: inlf
# inlf = 1 si la mujer está en la fuerza laboral
# inlf = 0 si la mujer NO está en la fuerza laboral

# Ver proporción de mujeres trabajando
cat("\n=== PROPORCIÓN DE MUJERES EN LA FUERZA LABORAL ===\n")
prop.table(table(mroz$inlf))

# Visualizar variable dependiente
ggplot(mroz, aes(x = factor(inlf))) +
  geom_bar(fill = "steelblue", alpha = 0.7) +
  geom_text(stat = 'count', aes(label = after_stat(count)), vjust = -0.5) +
  labs(title = "Distribución de Participación Laboral",
       x = "En la fuerza laboral (0 = No, 1 = Sí)",
       y = "Frecuencia") +
  theme_minimal(base_size = 12)

# ==============================================================================
# 2. ANÁLISIS EXPLORATORIO
# ==============================================================================

cat("\n=== ANÁLISIS EXPLORATORIO ===\n")

# Crear subset de variables relevantes para nuestro análisis
# Vamos a predecir participación laboral (inlf) usando:
# - educ: años de educación
# - exper: años de experiencia laboral
# - age: edad
# - kidslt6: número de niños menores de 6 años
# - kidsge6: número de niños entre 6 y 18 años
# - nwifeinc: ingreso del esposo (en miles)

datos <- mroz %>%
  select(inlf, educ, exper, age, kidslt6, kidsge6, nwifeinc) %>%
  na.omit()  # Eliminar valores faltantes

cat("Observaciones totales:", nrow(datos), "\n")
cat("Observaciones con inlf=1:", sum(datos$inlf == 1), "\n")
cat("Observaciones con inlf=0:", sum(datos$inlf == 0), "\n")

# Estadísticas descriptivas por grupo
cat("\n=== ESTADÍSTICAS POR GRUPO ===\n")
datos %>%
  group_by(inlf) %>%
  summarise(
    n = n(),
    educ_media = mean(educ),
    exper_media = mean(exper),
    age_media = mean(age),
    kidslt6_media = mean(kidslt6),
    nwifeinc_media = mean(nwifeinc)
  ) %>%
  print()

# Visualizar relación entre variables
# Educación vs Participación laboral
ggplot(datos, aes(x = educ, y = inlf)) +
  geom_jitter(alpha = 0.3, height = 0.05, color = "steelblue") +
  geom_smooth(method = "loess", color = "red", se = TRUE) +
  labs(title = "Relación entre Educación y Participación Laboral",
       x = "Años de Educación",
       y = "Probabilidad de trabajar") +
  theme_minimal()

# Niños pequeños vs Participación laboral
ggplot(datos, aes(x = factor(kidslt6), fill = factor(inlf))) +
  geom_bar(position = "fill") +
  scale_fill_manual(values = c("0" = "coral", "1" = "steelblue"),
                    labels = c("No trabaja", "Trabaja")) +
  labs(title = "Participación Laboral según Número de Niños Pequeños",
       x = "Número de niños menores de 6 años",
       y = "Proporción",
       fill = "Estado") +
  theme_minimal()

# ==============================================================================
# 3. DIVISIÓN TRAIN-TEST
# ==============================================================================

# Dividir datos en entrenamiento (70%) y prueba (30%)
cat("\n=== DIVISIÓN DE DATOS ===\n")

indices_train <- createDataPartition(datos$inlf, p = 0.7, list = FALSE)
datos_train <- datos[indices_train, ]
datos_test <- datos[-indices_train, ]

cat("Observaciones entrenamiento:", nrow(datos_train), "\n")
cat("Observaciones prueba:", nrow(datos_test), "\n")
cat("Proporción trabaja (train):", mean(datos_train$inlf), "\n")
cat("Proporción trabaja (test):", mean(datos_test$inlf), "\n")

# ==============================================================================
# 4. MODELO DE PROBABILIDAD LINEAL (MPL)
# ==============================================================================

cat("\n\n========================================\n")
cat("         MODELO MPL (MCO)               \n")
cat("========================================\n\n")

# 4.1 Estimación básica con MCO
modelo_mpl <- lm(inlf ~ educ + exper + age + kidslt6 + kidsge6 + nwifeinc,
                 data = datos_train)

# Resultados básicos
cat("=== RESULTADOS MPL (Errores Estándar Clásicos) ===\n")
summary(modelo_mpl)

# 4.2 MPL con errores robustos (White)
# Los errores robustos corrigen la heteroscedasticidad
cat("\n=== RESULTADOS MPL (Errores Robustos) ===\n")
coeftest(modelo_mpl, vcov = vcovHC(modelo_mpl, type = "HC1"))

# INTERPRETACIÓN:
# Cada coeficiente representa el cambio en la PROBABILIDAD (en puntos porcentuales)
# cuando la variable independiente aumenta en 1 unidad, manteniendo todo lo demás constante
# 
# Por ejemplo, si el coef. de educ = 0.038:
# "Un año adicional de educación aumenta la probabilidad de trabajar en 3.8 puntos porcentuales"

# 4.3 Predicciones del MPL
predicciones_mpl_train <- predict(modelo_mpl, newdata = datos_train)
predicciones_mpl_test <- predict(modelo_mpl, newdata = datos_test)

# 4.4 Verificar problema de predicciones fuera de [0,1]
cat("\n=== PROBLEMA DEL MPL: PREDICCIONES FUERA DE RANGO ===\n")
cat("Predicciones < 0 (train):", sum(predicciones_mpl_train < 0), "\n")
cat("Predicciones > 1 (train):", sum(predicciones_mpl_train > 1), "\n")
cat("Predicciones < 0 (test):", sum(predicciones_mpl_test < 0), "\n")
cat("Predicciones > 1 (test):", sum(predicciones_mpl_test > 1), "\n")

# 4.5 Gráfico de predicciones
df_plot_mpl <- data.frame(
  observado = datos_train$inlf,
  predicho = predicciones_mpl_train
)

ggplot(df_plot_mpl, aes(x = predicho, y = observado)) +
  geom_point(alpha = 0.3, color = "steelblue") +
  geom_vline(xintercept = c(0, 1), linetype = "dashed", color = "red") +
  geom_smooth(method = "lm", se = FALSE, color = "darkgreen") +
  labs(title = "MPL: Predicciones vs Observaciones",
       subtitle = "Las líneas rojas muestran el rango [0,1]",
       x = "Probabilidad Predicha",
       y = "Valor Observado (0/1)") +
  theme_minimal()

# ==============================================================================
# 5. MODELO LOGIT
# ==============================================================================

cat("\n\n========================================\n")
cat("            MODELO LOGIT                \n")
cat("========================================\n\n")

# 5.1 Estimación del modelo Logit
modelo_logit <- glm(inlf ~ educ + exper + age + kidslt6 + kidsge6 + nwifeinc,
                    data = datos_train,
                    family = binomial(link = "logit"))

# Resultados
cat("=== RESULTADOS LOGIT ===\n")
summary(modelo_logit)

# ⚠️ ADVERTENCIA: NO interpretar los coeficientes directamente como efectos marginales
# Solo podemos interpretar:
# - SIGNO: positivo = aumenta probabilidad, negativo = disminuye probabilidad
# - SIGNIFICANCIA: el coeficiente es estadísticamente distinto de cero

# 5.2 Efectos Marginales Promedio (AME) - RECOMENDADO
cat("\n=== EFECTOS MARGINALES PROMEDIO (Logit) ===\n")
efectos_logit <- margins(modelo_logit)
summary(efectos_logit)

# INTERPRETACIÓN DE EFECTOS MARGINALES:
# Estos SÍ se interpretan como cambios en probabilidad
# Ejemplo: si AME de educ = 0.038:
# "Un año adicional de educación aumenta la probabilidad de trabajar en 3.8 puntos porcentuales"

# 5.3 Odds-Ratios (interpretación alternativa)
cat("\n=== ODDS-RATIOS (Logit) ===\n")
odds_ratios <- exp(coef(modelo_logit))
print(odds_ratios)

# INTERPRETACIÓN DE ODDS-RATIOS:
# OR = 1: no hay efecto
# OR > 1: aumenta las chances (odds)
# OR < 1: disminuye las chances
# 
# Ejemplo: si OR de educ = 1.14:
# "Un año adicional de educación multiplica las chances de trabajar por 1.14"
# (equivalente a un aumento del 14% en las chances)

# 5.4 Predicciones del Logit
predicciones_logit_train <- predict(modelo_logit, newdata = datos_train, 
                                    type = "response")
predicciones_logit_test <- predict(modelo_logit, newdata = datos_test, 
                                   type = "response")

# Verificar que están en [0,1]
cat("\n=== VERIFICACIÓN: Logit siempre predice en [0,1] ===\n")
cat("Mínimo (train):", min(predicciones_logit_train), "\n")
cat("Máximo (train):", max(predicciones_logit_train), "\n")
cat("Mínimo (test):", min(predicciones_logit_test), "\n")
cat("Máximo (test):", max(predicciones_logit_test), "\n")

# 5.5 R² de McFadden
logLik_full <- logLik(modelo_logit)
logLik_null <- logLik(glm(inlf ~ 1, data = datos_train, 
                          family = binomial(link = "logit")))
r2_mcfadden <- 1 - (as.numeric(logLik_full) / as.numeric(logLik_null))

cat("\n=== BONDAD DE AJUSTE ===\n")
cat("R² de McFadden:", round(r2_mcfadden, 4), "\n")
cat("Interpretación: valores entre 0.2-0.4 son buenos para este tipo de modelos\n")

# ==============================================================================
# 6. MODELO PROBIT
# ==============================================================================

cat("\n\n========================================\n")
cat("            MODELO PROBIT               \n")
cat("========================================\n\n")

# 6.1 Estimación del modelo Probit
modelo_probit <- glm(inlf ~ educ + exper + age + kidslt6 + kidsge6 + nwifeinc,
                     data = datos_train,
                     family = binomial(link = "probit"))

# Resultados
cat("=== RESULTADOS PROBIT ===\n")
summary(modelo_probit)

# 6.2 Efectos Marginales Promedio (AME)
cat("\n=== EFECTOS MARGINALES PROMEDIO (Probit) ===\n")
efectos_probit <- margins(modelo_probit)
summary(efectos_probit)

# 6.3 Predicciones del Probit
predicciones_probit_train <- predict(modelo_probit, newdata = datos_train, 
                                     type = "response")
predicciones_probit_test <- predict(modelo_probit, newdata = datos_test, 
                                    type = "response")

# 6.4 R² de McFadden
logLik_full_probit <- logLik(modelo_probit)
logLik_null_probit <- logLik(glm(inlf ~ 1, data = datos_train, 
                                 family = binomial(link = "probit")))
r2_mcfadden_probit <- 1 - (as.numeric(logLik_full_probit) / 
                             as.numeric(logLik_null_probit))

cat("\n=== BONDAD DE AJUSTE (Probit) ===\n")
cat("R² de McFadden:", round(r2_mcfadden_probit, 4), "\n")

# ==============================================================================
# 7. COMPARACIÓN DE MODELOS
# ==============================================================================

cat("\n\n========================================\n")
cat("       COMPARACIÓN DE MODELOS           \n")
cat("========================================\n\n")

# 7.1 Tabla comparativa de coeficientes
cat("=== TABLA COMPARATIVA ===\n")
stargazer(modelo_mpl, modelo_logit, modelo_probit,
          type = "text",
          title = "Comparación de Modelos",
          column.labels = c("MPL", "Logit", "Probit"),
          keep.stat = c("n", "rsq"),
          digits = 4)

# 7.2 Comparación de Efectos Marginales
cat("\n=== COMPARACIÓN DE EFECTOS MARGINALES ===\n")
MPL <- as.data.frame(coef(modelo_mpl)[-1])  # Excluir intercepto
Logit_AME <- as.data.frame(summary(efectos_logit)$AME)
Probit_AME <- as.data.frame(summary(efectos_probit)$AME)

MPL <- MPL %>% 
  rownames_to_column() %>% 
  rename(mpl=`coef(modelo_mpl)[-1]`)

Logit_AME <- Logit_AME %>% 
  rownames_to_column() %>% 
  rename(logit_ame=`summary(efectos_logit)$AME`)

Probit_AME <- Probit_AME %>% 
  rownames_to_column() %>% 
  rename(probit_ame=`summary(efectos_probit)$AME`)

regresiones_comp <- MPL %>% 
  left_join(Logit_AME) %>% 
  left_join(Probit_AME)

print(regresiones_comp)

# 7.3 Gráfico comparativo de predicciones
df_comparacion <- data.frame(
  educ = datos_train$educ,
  observado = datos_train$inlf,
  MPL = predicciones_mpl_train,
  Logit = predicciones_logit_train,
  Probit = predicciones_probit_train
)

df_comparacion_long <- df_comparacion %>%
  pivot_longer(cols = c(MPL, Logit, Probit), 
               names_to = "Modelo", 
               values_to = "Prediccion")

ggplot(df_comparacion_long, aes(x = educ, y = Prediccion, color = Modelo)) +
  geom_smooth(se = FALSE, linewidth = 1.2) +
  geom_point(aes(y = observado), alpha = 0.1, color = "gray50") +
  scale_color_manual(values = c("MPL" = "red", "Logit" = "blue", 
                                "Probit" = "darkgreen")) +
  labs(title = "Comparación de Predicciones: MPL vs Logit vs Probit",
       subtitle = "Probabilidad de trabajar según años de educación",
       x = "Años de Educación",
       y = "Probabilidad Predicha") +
  theme_minimal() +
  theme(legend.position = "bottom")

# ==============================================================================
# 8. EVALUACIÓN DE MODELOS: MATRIZ DE CONFUSIÓN
# ==============================================================================

cat("\n\n========================================\n")
cat("        MATRIZ DE CONFUSIÓN             \n")
cat("========================================\n\n")

# Función para crear matriz de confusión
crear_matriz_confusion <- function(predicciones, reales, punto_corte = 0.5, 
                                   nombre_modelo) {
  
  # Clasificar según punto de corte
  clasificacion <- ifelse(predicciones > punto_corte, 1, 0)
  
  # Crear matriz de confusión
  conf_matrix <- confusionMatrix(
    factor(clasificacion, levels = c(0, 1)),
    factor(reales, levels = c(0, 1)),
    positive = "1"
  )
  
  cat("\n=== MATRIZ DE CONFUSIÓN:", nombre_modelo, "===\n")
  cat("Punto de corte:", punto_corte, "\n\n")
  print(conf_matrix$table)
  
  cat("\n=== MÉTRICAS ===\n")
  cat("Accuracy:", round(conf_matrix$overall["Accuracy"], 4), "\n")
  cat("Sensitividad (Recall):", round(conf_matrix$byClass["Sensitivity"], 4), "\n")
  cat("Especificidad:", round(conf_matrix$byClass["Specificity"], 4), "\n")
  cat("Precisión:", round(conf_matrix$byClass["Precision"], 4), "\n")
  cat("F1-Score:", round(conf_matrix$byClass["F1"], 4), "\n")
  
  return(conf_matrix)
}

# 8.1 Matriz de confusión para cada modelo (conjunto de prueba)

# MPL
conf_mpl <- crear_matriz_confusion(predicciones_mpl_test, 
                                   datos_test$inlf, 
                                   punto_corte = 0.5,
                                   nombre_modelo = "MPL")

# Logit
conf_logit <- crear_matriz_confusion(predicciones_logit_test, 
                                     datos_test$inlf, 
                                     punto_corte = 0.5,
                                     nombre_modelo = "LOGIT")

# Probit
conf_probit <- crear_matriz_confusion(predicciones_probit_test, 
                                      datos_test$inlf, 
                                      punto_corte = 0.5,
                                      nombre_modelo = "PROBIT")

# 8.2 Comparación de métricas
cat("\n=== RESUMEN COMPARATIVO DE MÉTRICAS (Test Set) ===\n")
metricas_comparacion <- data.frame(
  Modelo = c("MPL", "Logit", "Probit"),
  Accuracy = c(
    conf_mpl$overall["Accuracy"],
    conf_logit$overall["Accuracy"],
    conf_probit$overall["Accuracy"]
  ),
  Sensitividad = c(
    conf_mpl$byClass["Sensitivity"],
    conf_logit$byClass["Sensitivity"],
    conf_probit$byClass["Sensitivity"]
  ),
  Especificidad = c(
    conf_mpl$byClass["Specificity"],
    conf_logit$byClass["Specificity"],
    conf_probit$byClass["Specificity"]
  ),
  F1_Score = c(
    conf_mpl$byClass["F1"],
    conf_logit$byClass["F1"],
    conf_probit$byClass["F1"]
  )
)
print(metricas_comparacion)

# ==============================================================================
# 9. CURVA ROC Y AUC
# ==============================================================================

cat("\n\n========================================\n")
cat("          CURVA ROC Y AUC               \n")
cat("========================================\n\n")

# Calcular curva ROC para cada modelo
roc_mpl <- roc(datos_test$inlf, predicciones_mpl_test, quiet = TRUE)
roc_logit <- roc(datos_test$inlf, predicciones_logit_test, quiet = TRUE)
roc_probit <- roc(datos_test$inlf, predicciones_probit_test, quiet = TRUE)

# AUC (Area Under the Curve)
cat("=== AUC (Area Under the Curve) ===\n")
cat("MPL:", round(auc(roc_mpl), 4), "\n")
cat("Logit:", round(auc(roc_logit), 4), "\n")
cat("Probit:", round(auc(roc_probit), 4), "\n")
cat("\nInterpretación: AUC cercano a 1 indica mejor capacidad predictiva\n")

# Gráfico de curvas ROC
plot(roc_mpl, col = "red", lwd = 2, main = "Comparación Curvas ROC")
plot(roc_logit, col = "blue", lwd = 2, add = TRUE)
plot(roc_probit, col = "darkgreen", lwd = 2, add = TRUE)
legend("bottomright", 
       legend = c(
         paste("MPL (AUC =", round(auc(roc_mpl), 3), ")"),
         paste("Logit (AUC =", round(auc(roc_logit), 3), ")"),
         paste("Probit (AUC =", round(auc(roc_probit), 3), ")")
       ),
       col = c("red", "blue", "darkgreen"),
       lwd = 2)

# ==============================================================================
# 10. ANÁLISIS DE SENSIBILIDAD: PUNTO DE CORTE
# ==============================================================================

cat("\n\n========================================\n")
cat("   ANÁLISIS DE PUNTO DE CORTE           \n")
cat("========================================\n\n")

# Probar diferentes puntos de corte para el modelo Logit
puntos_corte <- seq(0.3, 0.7, by = 0.05)
resultados_corte <- data.frame()

for (corte in puntos_corte) {
  clasificacion <- ifelse(predicciones_logit_test > corte, 1, 0)
  conf_temp <- confusionMatrix(
    factor(clasificacion, levels = c(0, 1)),
    factor(datos_test$inlf, levels = c(0, 1)),
    positive = "1"
  )
  
  resultados_corte <- rbind(resultados_corte, data.frame(
    Punto_Corte = corte,
    Accuracy = conf_temp$overall["Accuracy"],
    Sensitividad = conf_temp$byClass["Sensitivity"],
    Especificidad = conf_temp$byClass["Specificity"],
    F1 = conf_temp$byClass["F1"]
  ))
}

cat("=== MÉTRICAS SEGÚN PUNTO DE CORTE (Logit) ===\n")
print(resultados_corte)

# Gráfico de métricas vs punto de corte
resultados_corte_long <- resultados_corte %>%
  pivot_longer(cols = c(Accuracy, Sensitividad, Especificidad, F1),
               names_to = "Metrica",
               values_to = "Valor")

ggplot(resultados_corte_long, aes(x = Punto_Corte, y = Valor, 
                                  color = Metrica)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  labs(title = "Métricas según Punto de Corte",
       subtitle = "Modelo Logit",
       x = "Punto de Corte",
       y = "Valor de la Métrica",
       color = "Métrica") +
  theme_minimal() +
  theme(legend.position = "bottom")

cat("\nNota: La elección del punto de corte depende del problema:\n")
cat("- Si los falsos negativos son más costosos → usar punto de corte bajo\n")
cat("- Si los falsos positivos son más costosos → usar punto de corte alto\n")
cat("- Para balance → usar 0.5 o proporción de 1s en los datos\n")

# ==============================================================================
# 11. INTERPRETACIÓN PRÁCTICA DE UN CASO
# ==============================================================================

cat("\n\n========================================\n")
cat("     INTERPRETACIÓN DE UN CASO          \n")
cat("========================================\n\n")

# Crear un perfil hipotético
perfil <- data.frame(
  educ = 16,      # 16 años de educación (universitaria)
  exper = 10,     # 10 años de experiencia
  age = 35,       # 35 años de edad
  kidslt6 = 1,    # 1 niño menor de 6 años
  kidsge6 = 0,    # 0 niños entre 6 y 18
  nwifeinc = 30   # Ingreso del esposo: $30,000
)

cat("=== PERFIL A PREDECIR ===\n")
print(perfil)

# Predicciones
pred_mpl_perfil <- predict(modelo_mpl, newdata = perfil)
pred_logit_perfil <- predict(modelo_logit, newdata = perfil, type = "response")
pred_probit_perfil <- predict(modelo_probit, newdata = perfil, type = "response")

cat("\n=== PREDICCIONES ===\n")
cat("MPL:", round(pred_mpl_perfil, 4), "\n")
cat("Logit:", round(pred_logit_perfil, 4), "\n")
cat("Probit:", round(pred_probit_perfil, 4), "\n")

cat("\nInterpretación:\n")
cat("Una mujer con este perfil tiene aproximadamente un", 
    round(pred_logit_perfil * 100, 1), 
    "% de probabilidad de estar en la fuerza laboral\n")

# Análisis de sensibilidad: ¿Qué pasa si no tiene niños pequeños?
perfil_sin_ninos <- perfil
perfil_sin_ninos$kidslt6 <- 0

pred_logit_sin_ninos <- predict(modelo_logit, newdata = perfil_sin_ninos, 
                                type = "response")

cat("\nSi no tuviera niños menores de 6 años:\n")
cat("Probabilidad de trabajar:", round(pred_logit_sin_ninos * 100, 1), "%\n")
cat("Diferencia:", round((pred_logit_sin_ninos - pred_logit_perfil) * 100, 1), 
    "puntos porcentuales\n")

# ==============================================================================
# 12. VERIFICACIÓN DE SUPUESTOS
# ==============================================================================

cat("\n\n========================================\n")
cat("    VERIFICACIÓN DE SUPUESTOS           \n")
cat("========================================\n\n")

# 12.1 Test de heteroscedasticidad en MPL (Breusch-Pagan)
cat("=== TEST DE HETEROSCEDASTICIDAD (MPL) ===\n")
library(lmtest)
bp_test <- bptest(modelo_mpl)
print(bp_test)

if (bp_test$p.value < 0.05) {
  cat("\nConclusión: Hay evidencia de heteroscedasticidad\n")
  cat("Solución: Usar errores robustos (ya implementado arriba)\n")
} else {
  cat("\nConclusión: No hay evidencia fuerte de heteroscedasticidad\n")
}

# 12.2 Multicolinealidad (VIF)
cat("\n=== FACTOR DE INFLACIÓN DE VARIANZA (VIF) ===\n")
library(car)
vif_valores <- vif(modelo_mpl)
print(round(vif_valores, 2))

cat("\nInterpretación:\n")
cat("VIF < 5: No hay problema de multicolinealidad\n")
cat("VIF 5-10: Multicolinealidad moderada\n")
cat("VIF > 10: Multicolinealidad severa\n")

# 12.3 Test de Ramsey (RESET) para especificación
cat("\n=== TEST DE RAMSEY (RESET) - Especificación del modelo ===\n")
reset_test <- resettest(modelo_mpl, power = 2:3, type = "fitted")
print(reset_test)

if (reset_test$p.value < 0.05) {
  cat("\nConclusión: Hay evidencia de error de especificación\n")
  cat("Posibles soluciones: agregar términos cuadráticos, interacciones, etc.\n")
} else {
  cat("\nConclusión: No hay evidencia fuerte de error de especificación\n")
}

