# ========================================================================
# SOLUCIONES DE EJERCICIOS DE FOR LOOPS EN R (CASTELLANO RIOPLATENSE)
# ========================================================================

# Cargamos librerías que vamos a usar
library(ggplot2)

# ========================================================================
# Ejercicio 1: Calculando Cuadrados
# ========================================================================

# Creamos un vector vacío para almacenar los resultados
cuadrados <- numeric(10)

# Iteramos del 1 al 10 calculando los cuadrados
for (i in 1:10) {
  cuadrados[i] <- i^2
}

# Imprimimos el resultado
print(cuadrados)


# ========================================================================
# Ejercicio 2: Suma de Elementos
# ========================================================================

# Definimos el vector con los números dados
numeros <- c(14, 23, 87, 26, 42, 55, 10, 8, 29, 33)

# Inicializamos una variable para almacenar la suma
suma_total <- 0

# Iteramos a través de cada elemento del vector
for (num in numeros) {
  suma_total <- suma_total + num
}

# Imprimimos el resultado
print(paste("La suma total es:", suma_total))


# ========================================================================
# Ejercicio 3: Filtrado con Condicionales
# ========================================================================

# Definimos el vector con los datos
datos <- c(12, 8, 15, 23, 4, 55, 16, 72, 9, 31, 26, 18, 5, 7)

# Creamos un vector vacío para almacenar los números mayores que 15
mayores_15 <- c()

# Iteramos a través de cada elemento y verificamos la condición
for (num in datos) {
  if (num > 15) {
    mayores_15 <- c(mayores_15, num)
  }
}

# Imprimimos el resultado
print(mayores_15)

# Método alternativo más eficiente (pre-asignando memoria)
mayores_15_eficiente <- numeric(0)
contador <- 0

for (num in datos) {
  if (num > 15) {
    contador <- contador + 1
    # Expandimos el vector solo cuando es necesario
    length(mayores_15_eficiente) <- contador
    mayores_15_eficiente[contador] <- num
  }
}

print(mayores_15_eficiente)


# ========================================================================
# Ejercicio 4: Tabla de Multiplicar
# ========================================================================

# Creamos una tabla de multiplicar del 1 al 5
cat("Tabla de multiplicar del 1 al 5:\n\n")

# Encabezado de la tabla
encabezado <- "   "
for (j in 1:5) {
  encabezado <- paste(encabezado, sprintf("%4d", j))
}
cat(encabezado, "\n")
cat(rep("-", 25), "\n")

# Generamos las filas de la tabla con bucles anidados
for (i in 1:5) {
  fila <- sprintf("%2d |", i)
  for (j in 1:5) {
    resultado <- i * j
    fila <- paste(fila, sprintf("%4d", resultado))
  }
  cat(fila, "\n")
}


# ========================================================================
# Ejercicio 5: Manipulación de Cadenas de Texto
# ========================================================================

# Definimos el vector de nombres
nombres <- c("Ana", "Juan", "María", "Pedro", "Lucía")

# Creamos un vector para almacenar los saludos
saludos <- character(length(nombres))

# Iteramos a través de cada nombre y creamos el saludo personalizado
for (i in 1:length(nombres)) {
  saludos[i] <- paste0("¡Hola, ", nombres[i], "!")
}

# Imprimimos el resultado
print(saludos)


# ========================================================================
# Ejercicio 6: Transformación de una Matriz
# ========================================================================

# Establecemos una semilla para reproducibilidad
set.seed(123)

# Creamos una matriz 4x4 con números aleatorios enteros entre 1 y 100
matriz_original <- matrix(sample(1:100, 16, replace = TRUE), nrow = 4, ncol = 4)
print("Matriz original:")
print(matriz_original)

# Creamos una nueva matriz para almacenar el resultado
matriz_transformada <- matrix(0, nrow = 4, ncol = 4)

# Utilizamos un bucle for anidado para transformar la matriz
for (i in 1:4) {
  for (j in 1:4) {
    # Obtenemos el elemento actual
    elemento <- matriz_original[i, j]
    
    # Verificamos si es par o impar y aplicamos la transformación
    if (elemento %% 2 == 0) {  # Si es par
      matriz_transformada[i, j] <- elemento^2
    } else {  # Si es impar
      matriz_transformada[i, j] <- elemento^3
    }
  }
}

print("Matriz transformada:")
print(matriz_transformada)


# ========================================================================
# Ejercicio 7: Análisis de un Conjunto de Datos
# ========================================================================

# Cargamos el conjunto de datos mtcars
data(mtcars)

# Obtenemos los nombres de las columnas
columnas <- names(mtcars)

# Creamos un data frame para almacenar los resultados
resultados <- data.frame(
  Columna = character(length(columnas)),
  Media = numeric(length(columnas)),
  Mediana = numeric(length(columnas)),
  Desviacion_Estandar = numeric(length(columnas))
)

# Iteramos por cada columna y calculamos las estadísticas
for (i in 1:length(columnas)) {
  # Obtenemos la columna actual
  col_actual <- mtcars[[columnas[i]]]
  
  # Calculamos las estadísticas
  resultados$Columna[i] <- columnas[i]
  resultados$Media[i] <- mean(col_actual)
  resultados$Mediana[i] <- median(col_actual)
  resultados$Desviacion_Estandar[i] <- sd(col_actual)
}

# Mostramos los resultados
print(resultados)


# ========================================================================
# Ejercicio 8: Simulación de Lanzamiento de Dados
# ========================================================================

# Establecemos una semilla para reproducibilidad
set.seed(456)

# Inicializamos un vector para contar las apariciones de cada número
conteo <- integer(6)  # Inicializa con ceros para los números del 1 al 6

# Simulamos 1000 lanzamientos de dado
for (i in 1:1000) {
  # Simulamos un lanzamiento
  resultado <- sample(1:6, 1)
  
  # Incrementamos el contador correspondiente
  conteo[resultado] <- conteo[resultado] + 1
}

# Creamos una tabla con los resultados
tabla_resultados <- data.frame(
  Numero = 1:6,
  Frecuencia = conteo,
  Porcentaje = round(conteo/10, 2)  # Dividimos por 10 para obtener porcentaje
)

# Mostramos la tabla
print(tabla_resultados)

# Creamos un gráfico de barras
barplot(conteo, names.arg = 1:6, 
        main = "Frecuencia de cada número en 1000 lanzamientos",
        xlab = "Número del dado", 
        ylab = "Frecuencia", 
        col = "skyblue")

# Alternativa con ggplot2
ggplot(tabla_resultados, aes(x = as.factor(Numero), y = Frecuencia)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  geom_text(aes(label = Frecuencia), vjust = -0.5) +
  theme_minimal() +
  labs(title = "Frecuencia de cada número en 1000 lanzamientos",
       x = "Número del dado",
       y = "Frecuencia")


# ========================================================================
# Ejercicio 9: Contador de Vocales
# ========================================================================

# Definimos la función para contar vocales
contar_vocales <- function(texto) {
  # Convertimos el texto a minúsculas
  texto <- tolower(texto)
  
  # Dividimos el texto en caracteres individuales
  caracteres <- strsplit(texto, "")[[1]]
  
  # Inicializamos un vector para contar cada vocal
  conteo_vocales <- c(a = 0, e = 0, i = 0, o = 0, u = 0)
  
  # Iteramos por cada carácter
  for (caracter in caracteres) {
    # Verificamos si el carácter es una vocal y actualizamos el contador
    if (caracter == "a") conteo_vocales["a"] <- conteo_vocales["a"] + 1
    else if (caracter == "e") conteo_vocales["e"] <- conteo_vocales["e"] + 1
    else if (caracter == "i") conteo_vocales["i"] <- conteo_vocales["i"] + 1
    else if (caracter == "o") conteo_vocales["o"] <- conteo_vocales["o"] + 1
    else if (caracter == "u") conteo_vocales["u"] <- conteo_vocales["u"] + 1
  }
  
  return(conteo_vocales)
}

# Probamos la función con la frase dada
frase_prueba <- "Esta es una prueba para contar vocales en una frase"
resultado <- contar_vocales(frase_prueba)
print(resultado)

# Calculamos el total de vocales
total_vocales <- sum(resultado)
print(paste("Total de vocales en la frase:", total_vocales))

# Creamos un gráfico para visualizar el resultado
barplot(resultado, 
        main = "Frecuencia de vocales", 
        col = rainbow(5))


# ========================================================================
# Ejercicio 10: Calculadora de Fibonacci
# ========================================================================

# Definimos la función para calcular la secuencia de Fibonacci
fibonacci <- function(n) {
  # Manejamos casos especiales
  if (n <= 0) return(numeric(0))
  if (n == 1) return(c(0))
  if (n == 2) return(c(0, 1))
  
  # Inicializamos el vector para almacenar la secuencia
  fib_seq <- numeric(n)
  fib_seq[1] <- 0  # Primer número
  fib_seq[2] <- 1  # Segundo número
  
  # Calculamos el resto de la secuencia
  for (i in 3:n) {
    fib_seq[i] <- fib_seq[i-1] + fib_seq[i-2]
  }
  
  return(fib_seq)
}

# Probamos la función con n = 15
resultado <- fibonacci(15)
print(resultado)

# Visualizamos la secuencia
plot(resultado, type = "b", 
     xlab = "Índice", 
     ylab = "Valor",
     main = "Secuencia de Fibonacci", 
     col = "blue", 
     pch = 19)
grid()