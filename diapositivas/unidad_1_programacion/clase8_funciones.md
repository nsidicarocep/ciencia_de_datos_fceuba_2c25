# Creación de Funciones Propias en R

## Introducción

Las **funciones propias** constituyen uno de los elementos más importantes para desarrollar análisis económicos eficientes y reproducibles. Permiten encapsular código que se utiliza repetidamente, facilitando el mantenimiento, la reutilización y la organización lógica de los análisis.

En el contexto del análisis económico, las funciones propias resultan especialmente útiles para:

- Automatizar cálculos de indicadores económicos estándar
- Estandarizar procesos de limpieza de datos específicos
- Implementar metodologías econométricas personalizadas
- Crear herramientas de validación y diagnóstico
- Modularizar análisis complejos en componentes reutilizables

```r
library(tidyverse)
```

---

## Anatomía de una Función

### Estructura básica

Una función en R se compone de cuatro elementos fundamentales:

```r
nombre_funcion <- function(argumentos) {
  # Cuerpo de la función
  return(valor_retorno)
}
```

### Componentes detallados

#### 1. Nombre de la función
- Debe ser descriptivo y seguir convenciones de nomenclatura
- Se recomienda utilizar snake_case
- Debe reflejar claramente la operación que realiza

#### 2. Palabra clave `function`
- Indica a R que se está definiendo una función
- Sintaxis obligatoria e invariable

#### 3. Lista de argumentos (parámetros)
- Especifica qué información requiere la función para operar
- Pueden tener valores por defecto
- Pueden ser opcionales u obligatorios

#### 4. Cuerpo de la función
- Contiene el código que se ejecutará
- Puede incluir múltiples operaciones
- Variables creadas aquí tienen scope local

#### 5. Valor de retorno
- Resultado que la función devuelve al entorno que la llamó
- Puede ser explícito (con `return()`) o implícito (última expresión)

---

## Argumentos y Parámetros

### Tipos de argumentos

#### Argumentos obligatorios
```r
calcular_ratio <- function(numerador, denominador) {
  # Ambos argumentos son requeridos
  resultado <- numerador / denominador
  return(resultado)
}
```

#### Argumentos con valores por defecto
```r
calcular_crecimiento <- function(valor_inicial, valor_final, anualizado = TRUE) {
  crecimiento <- (valor_final / valor_inicial) - 1
  
  if (anualizado) {
    # Valor por defecto permite comportamiento estándar
    return(crecimiento * 100)
  } else {
    return(crecimiento)
  }
}
```

#### Argumentos con múltiples valores por defecto
```r
generar_resumen <- function(datos, medidas = c("media", "mediana", "sd")) {
  resultado <- list()
  
  if ("media" %in% medidas) {
    resultado$media <- mean(datos, na.rm = TRUE)
  }
  
  if ("mediana" %in% medidas) {
    resultado$mediana <- median(datos, na.rm = TRUE)
  }
  
  if ("sd" %in% medidas) {
    resultado$desviacion_estandar <- sd(datos, na.rm = TRUE)
  }
  
  return(resultado)
}
```

### Validación de argumentos

```r
funcion_robusta <- function(datos, variable) {
  
  # Validación de tipos
  if (!is.data.frame(datos)) {
    stop("El argumento 'datos' debe ser un data.frame")
  }
  
  # Validación de existencia
  if (!variable %in% names(datos)) {
    stop("La variable '", variable, "' no existe en el dataset")
  }
  
  # Validación de contenido
  if (nrow(datos) == 0) {
    warning("Dataset vacío. Retornando NA.")
    return(NA)
  }
  
  # Procesamiento principal
  resultado <- mean(datos[[variable]], na.rm = TRUE)
  return(resultado)
}
```

---

## Scope de Variables

### Variables locales vs globales

```r
# Variable global
multiplicador_global <- 1.21

calcular_precio_con_iva <- function(precio_base) {
  # Variable local (solo existe dentro de la función)
  iva <- 0.21
  precio_final <- precio_base * (1 + iva)
  
  # Esta variable local no afecta variables globales del mismo nombre
  multiplicador_global <- 2.0  # Variable local, no modifica la global
  
  return(precio_final)
}

# Al ejecutar la función, multiplicador_global mantiene su valor original
resultado <- calcular_precio_con_iva(100)
print(multiplicador_global)  # Sigue siendo 1.21
```

### Acceso a variables del entorno superior

```r
# Variable en el entorno superior
tasa_interes_base <- 0.05

calcular_interes_compuesto <- function(capital, años) {
  # La función puede acceder a variables del entorno superior
  # pero es mejor práctica pasarlas como argumentos
  monto_final <- capital * (1 + tasa_interes_base)^años
  return(monto_final)
}

# Mejor práctica: pasar todas las variables necesarias como argumentos
calcular_interes_compuesto_mejorado <- function(capital, años, tasa_interes) {
  monto_final <- capital * (1 + tasa_interes)^años
  return(monto_final)
}
```

---

## Valores de Retorno

### Return explícito vs implícito

```r
# Return explícito (recomendado para claridad)
calcular_media_explicito <- function(valores) {
  resultado <- mean(valores, na.rm = TRUE)
  return(resultado)
}

# Return implícito (R devuelve la última expresión evaluada)
calcular_media_implicito <- function(valores) {
  mean(valores, na.rm = TRUE)  # Esta expresión se retorna automáticamente
}

# Ambas funciones son equivalentes, pero la explícita es más clara
```

### Múltiples valores de retorno

```r
# Retornar lista con múltiples elementos
estadisticas_descriptivas <- function(valores) {
  resultado <- list(
    n = length(valores),
    media = mean(valores, na.rm = TRUE),
    mediana = median(valores, na.rm = TRUE),
    desviacion = sd(valores, na.rm = TRUE),
    minimo = min(valores, na.rm = TRUE),
    maximo = max(valores, na.rm = TRUE)
  )
  
  return(resultado)
}

# Uso de la función
datos_ejemplo <- c(10, 15, 12, 18, 14, 16, 11, 13)
stats <- estadisticas_descriptivas(datos_ejemplo)

# Acceder a elementos específicos
print(stats$media)
print(stats$desviacion)
```

### Return condicional

```r
validar_y_procesar <- function(datos, umbral = 0) {
  
  # Return temprano si no se cumplen condiciones
  if (nrow(datos) == 0) {
    return(NULL)
  }
  
  if (!"valor" %in% names(datos)) {
    return("Error: Columna 'valor' no encontrada")
  }
  
  # Procesamiento principal
  datos_filtrados <- datos %>%
    filter(valor > umbral)
  
  if (nrow(datos_filtrados) == 0) {
    return("Advertencia: Ningún valor supera el umbral")
  }
  
  # Return del resultado exitoso
  return(datos_filtrados)
}
```

---

## Ejemplo Práctico 1: Cálculo de Indicadores Financieros

```r
# Función para calcular múltiples ratios financieros
calcular_ratios_financieros <- function(ingresos, gastos, activos, pasivos, patrimonio) {
  
  # Validaciones de entrada
  if (any(c(ingresos, gastos, activos, pasivos, patrimonio) < 0)) {
    stop("Los valores financieros no pueden ser negativos")
  }
  
  if (activos != (pasivos + patrimonio)) {
    warning("Ecuación contable no balanceada: Activos ≠ Pasivos + Patrimonio")
  }
  
  # Cálculos de ratios
  utilidad_neta <- ingresos - gastos
  
  ratios <- list(
    # Rentabilidad
    margen_neto = round((utilidad_neta / ingresos) * 100, 2),
    roe = round((utilidad_neta / patrimonio) * 100, 2),
    roa = round((utilidad_neta / activos) * 100, 2),
    
    # Estructura financiera
    endeudamiento = round((pasivos / activos) * 100, 2),
    autonomia = round((patrimonio / activos) * 100, 2),
    
    # Valores absolutos para referencia
    utilidad_neta = utilidad_neta,
    activos_totales = activos
  )
  
  # Agregar interpretaciones
  ratios$interpretacion <- list()
  
  if (ratios$margen_neto > 10) {
    ratios$interpretacion$margen <- "Margen saludable"
  } else if (ratios$margen_neto > 5) {
    ratios$interpretacion$margen <- "Margen aceptable"
  } else {
    ratios$interpretacion$margen <- "Margen bajo"
  }
  
  if (ratios$endeudamiento > 70) {
    ratios$interpretacion$riesgo <- "Alto apalancamiento"
  } else if (ratios$endeudamiento > 40) {
    ratios$interpretacion$riesgo <- "Apalancamiento moderado"
  } else {
    ratios$interpretacion$riesgo <- "Bajo apalancamiento"
  }
  
  return(ratios)
}

# Aplicación de la función
empresa_ejemplo <- calcular_ratios_financieros(
  ingresos = 1000000,
  gastos = 850000,
  activos = 2000000,
  pasivos = 1200000,
  patrimonio = 800000
)

print(empresa_ejemplo)
```

### Ejemplo de uso y output esperado:
```r
# $margen_neto
# [1] 15
# 
# $roe
# [1] 18.75
# 
# $roa
# [1] 7.5
# 
# $endeudamiento
# [1] 60
# 
# $autonomia
# [1] 40
# 
# $interpretacion
# $interpretacion$margen
# [1] "Margen saludable"
# 
# $interpretacion$riesgo
# [1] "Apalancamiento moderado"
```

---

## Ejemplo Práctico 2: Análisis de Series Temporales Económicas

```r
# Función para analizar tendencias en series económicas
analizar_tendencia_economica <- function(datos, variable_temporal, 
                                       periodo_comparacion = 12, 
                                       incluir_estacionalidad = TRUE) {
  
  # Validaciones
  required_cols <- c("fecha", variable_temporal)
  missing_cols <- setdiff(required_cols, names(datos))
  
  if (length(missing_cols) > 0) {
    stop("Columnas faltantes: ", paste(missing_cols, collapse = ", "))
  }
  
  if (nrow(datos) < periodo_comparacion) {
    stop("Datos insuficientes. Se requieren al menos ", periodo_comparacion, " observaciones")
  }
  
  # Preparación de datos
  datos_ordenados <- datos %>%
    arrange(fecha) %>%
    filter(!is.na(.data[[variable_temporal]]))
  
  # Cálculo de tendencia
  modelo_tendencia <- lm(
    as.formula(paste(variable_temporal, "~ as.numeric(fecha)")), 
    data = datos_ordenados
  )
  
  pendiente_anual <- coef(modelo_tendencia)[2] * 365.25
  r_cuadrado <- summary(modelo_tendencia)$r.squared
  p_valor_tendencia <- summary(modelo_tendencia)$coefficients[2, 4]
  
  # Análisis de volatilidad
  valores <- datos_ordenados[[variable_temporal]]
  volatilidad <- sd(valores) / mean(valores) * 100
  
  # Análisis estacional (si se solicita)
  componente_estacional <- NULL
  if (incluir_estacionalidad && nrow(datos_ordenados) >= 24) {
    
    datos_estacional <- datos_ordenados %>%
      mutate(mes = month(fecha)) %>%
      group_by(mes) %>%
      summarise(
        promedio_mes = mean(.data[[variable_temporal]], na.rm = TRUE),
        .groups = "drop"
      ) %>%
      mutate(
        desviacion_promedio = promedio_mes - mean(promedio_mes)
      )
    
    # Test F para estacionalidad
    modelo_estacional <- aov(
      as.formula(paste(variable_temporal, "~ factor(month(fecha))")), 
      data = datos_ordenados
    )
    p_valor_estacional <- summary(modelo_estacional)[[1]][1, "Pr(>F)"]
    
    componente_estacional <- list(
      datos_por_mes = datos_estacional,
      significativa = p_valor_estacional < 0.05,
      p_valor = p_valor_estacional
    )
  }
  
  # Compilar resultados
  resultado <- list(
    tendencia = list(
      pendiente_anual = pendiente_anual,
      significativa = p_valor_tendencia < 0.05,
      r_cuadrado = r_cuadrado,
      interpretacion = case_when(
        p_valor_tendencia >= 0.05 ~ "Sin tendencia significativa",
        pendiente_anual > 0 ~ "Tendencia creciente",
        TRUE ~ "Tendencia decreciente"
      )
    ),
    
    volatilidad = list(
      coeficiente_variacion = round(volatilidad, 2),
      clasificacion = case_when(
        volatilidad > 20 ~ "Alta volatilidad",
        volatilidad > 10 ~ "Volatilidad moderada",
        TRUE ~ "Baja volatilidad"
      )
    ),
    
    estacionalidad = componente_estacional,
    
    resumen = list(
      observaciones = nrow(datos_ordenados),
      periodo_analizado = paste(min(datos_ordenados$fecha), "a", max(datos_ordenados$fecha)),
      valor_promedio = round(mean(valores), 2),
      valor_actual = round(tail(valores, 1), 2)
    )
  )
  
  return(resultado)
}

# Datos de ejemplo para demostración
datos_pib <- tibble(
  fecha = seq(as.Date("2020-01-01"), as.Date("2023-12-31"), by = "quarter"),
  pib_real = 100 + cumsum(rnorm(16, 0.5, 1.2))
)

# Análisis de la serie
resultado_analisis <- analizar_tendencia_economica(
  datos = datos_pib,
  variable_temporal = "pib_real",
  periodo_comparacion = 8,
  incluir_estacionalidad = TRUE
)

# Visualizar componentes principales
print("Tendencia:")
print(resultado_analisis$tendencia)

print("Volatilidad:")
print(resultado_analisis$volatilidad)

print("Resumen:")
print(resultado_analisis$resumen)
```

---

## Reglas y Mejores Prácticas

### 1. Nomenclatura y documentación

```r
# Buena práctica: Función bien documentada
#' Calcular índice de concentración de Herfindahl-Hirschman
#'
#' @param participaciones Vector numérico con participaciones de mercado (0-100)
#' @param normalizado Logical. Si TRUE, retorna HHI normalizado (0-1)
#' @return Numeric. Valor del índice HHI
#' @examples
#' participaciones <- c(30, 25, 20, 15, 10)
#' calcular_hhi(participaciones)
calcular_hhi <- function(participaciones, normalizado = FALSE) {
  
  # Validar que las participaciones sumen 100 (aproximadamente)
  if (abs(sum(participaciones) - 100) > 0.01) {
    warning("Las participaciones no suman 100%")
  }
  
  # Cálculo del HHI
  hhi <- sum(participaciones^2)
  
  if (normalizado) {
    # HHI normalizado: (HHI - 1/n) / (1 - 1/n)
    n <- length(participaciones)
    hhi_norm <- (hhi/10000 - 1/n) / (1 - 1/n)
    return(hhi_norm)
  }
  
  return(hhi)
}
```

### 2. Principio de responsabilidad única

```r
# Incorrecto: Función que hace demasiadas cosas
funcion_sobrecargada <- function(datos) {
  # Limpia datos, calcula estadísticas, genera gráficos, 
  # exporta resultados... demasiadas responsabilidades
}

# Correcto: Funciones específicas
limpiar_datos_economicos <- function(datos) {
  # Solo se encarga de limpiar
}

calcular_estadisticas_descriptivas <- function(datos) {
  # Solo se encarga de calcular estadísticas
}

generar_grafico_tendencia <- function(datos) {
  # Solo se encarga de graficar
}
```

### 3. Manejo consistente de errores

```r
# Establecer convenciones claras
procesar_indicador_economico <- function(datos, indicador) {
  
  # Errores críticos: stop()
  if (missing(datos) || is.null(datos)) {
    stop("Argumento 'datos' es obligatorio")
  }
  
  # Problemas menores: warning()
  if (any(is.na(datos[[indicador]]))) {
    warning("Se encontraron valores faltantes en ", indicador)
  }
  
  # Casos especiales: return con mensaje
  if (nrow(datos) < 5) {
    return(list(resultado = NA, mensaje = "Datos insuficientes"))
  }
  
  # Procesamiento normal
  resultado <- mean(datos[[indicador]], na.rm = TRUE)
  return(list(resultado = resultado, mensaje = "Cálculo exitoso"))
}
```

### 4. Valores por defecto razonables

```r
# Valores por defecto basados en estándares del dominio
calcular_valor_presente <- function(flujos_futuros, 
                                   tasa_descuento = 0.10,  # Tasa estándar del mercado
                                   periodos = length(flujos_futuros)) {
  
  factores_descuento <- (1 + tasa_descuento)^(-1:periodos)
  valor_presente <- sum(flujos_futuros * factores_descuento[-1])
  
  return(valor_presente)
}
```

### 5. Testing y validación

```r
# Incluir validaciones internas
funcion_robusta <- function(x, y) {
  
  # Assertions para desarrollo
  stopifnot(
    "x debe ser numérico" = is.numeric(x),
    "y debe ser numérico" = is.numeric(y),
    "x e y deben tener la misma longitud" = length(x) == length(y)
  )
  
  resultado <- x * y
  
  # Validar resultado antes de retornar
  if (any(is.infinite(resultado))) {
    warning("Se detectaron valores infinitos en el resultado")
  }
  
  return(resultado)
}
```

---

## Consideraciones Avanzadas

### Funciones que retornan funciones

```r
# Factory function: crea funciones específicas
crear_calculadora_impuesto <- function(tasa_impuesto) {
  
  function(monto_base) {
    impuesto <- monto_base * tasa_impuesto
    total <- monto_base + impuesto
    
    return(list(
      base = monto_base,
      impuesto = impuesto,
      total = total,
      tasa_aplicada = tasa_impuesto
    ))
  }
}

# Crear calculadoras específicas
calcular_iva <- crear_calculadora_impuesto(0.21)
calcular_iibb <- crear_calculadora_impuesto(0.035)

# Usar las funciones creadas
resultado_iva <- calcular_iva(1000)
resultado_iibb <- calcular_iibb(1000)
```

### Manejo de argumentos variables

```r
# Función que acepta múltiples series temporales
analizar_multiples_series <- function(..., metodo = "correlacion") {
  
  # Capturar todas las series pasadas
  series <- list(...)
  
  # Validar que todas sean numéricas
  if (!all(sapply(series, is.numeric))) {
    stop("Todas las series deben ser numéricas")
  }
  
  # Aplicar análisis según método
  if (metodo == "correlacion") {
    resultado <- cor(do.call(cbind, series), use = "complete.obs")
  } else if (metodo == "covarianza") {
    resultado <- cov(do.call(cbind, series), use = "complete.obs")
  }
  
  return(resultado)
}

# Uso con múltiples series
serie1 <- rnorm(100)
serie2 <- rnorm(100)
serie3 <- rnorm(100)

matriz_correlacion <- analizar_multiples_series(serie1, serie2, serie3)
```

---

## Conclusiones

La creación de funciones propias representa una habilidad fundamental para el desarrollo de análisis económicos eficientes y reproducibles. Las funciones bien diseñadas facilitan la modularización del código, mejoran la legibilidad del análisis y reducen la probabilidad de errores.

Los principios fundamentales para el desarrollo de funciones efectivas incluyen:

- **Claridad en el propósito**: cada función debe tener una responsabilidad específica y bien definida
- **Validación robusta**: implementar verificaciones apropiadas de argumentos y resultados  
- **Documentación adecuada**: explicar claramente qué hace la función y cómo utilizarla
- **Manejo consistente de errores**: establecer convenciones claras para diferentes tipos de problemas
- **Reutilización**: diseñar funciones que puedan aplicarse en diferentes contextos

La inversión en tiempo para desarrollar funciones de calidad se compensa mediante la reducción significativa en el tiempo requerido para análisis futuros y la mejora en la confiabilidad de los resultados obtenidos.