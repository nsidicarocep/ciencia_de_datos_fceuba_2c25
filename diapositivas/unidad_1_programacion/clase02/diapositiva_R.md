# Fundamentos de R - Guía Básica
*Material didáctico para el curso de programación en R*

---

## 📚 Contenido del Notebook

1. [Introducción a R](#introducción)
2. [Variables y Asignación](#variables)
3. [Tipos de Datos Básicos](#tipos-datos)
4. [Operaciones Básicas](#operaciones)
5. [Estructuras de Datos](#estructuras)
6. [Funciones](#funciones)
7. [Indexación y Subsetting](#indexacion)
8. [Paquetes en R](#paquetes)
9. [Lectura de Datos](#lectura-datos)

---

## 1. Introducción a R {#introducción}

R es un lenguaje de programación especializado en computación estadística y análisis de datos. Fue desarrollado como una implementación del lenguaje S y se caracteriza por ser software libre distribuido bajo la licencia GNU GPL.

### Características principales de R
- **Software libre**: no requiere licencias comerciales para su uso
- **Orientado al análisis estadístico**: diseñado específicamente para el tratamiento de datos
- **Extensible**: cuenta con un sistema de paquetes que amplía sus funcionalidades
- **Multiplataforma**: funciona en Windows, macOS y sistemas Unix/Linux
- **Comunidad activa**: respaldado por una amplia comunidad académica y científica

### El entorno de trabajo en R
R utiliza un intérprete de comandos donde se ejecutan las instrucciones línea por línea. Los comentarios se indican con el símbolo `#` y son ignorados por el intérprete.

```r
# Este es un comentario explicativo
# Las líneas que comienzan con # no se ejecutan
print("Mi primer programa en R")
```

El comando `print()` es una función que muestra el contenido de su argumento en la consola. En este caso, imprime la cadena de caracteres "Mi primer programa en R".

---

## 2. Variables y Asignación {#variables}

Las variables en R son contenedores que almacenan valores de diferentes tipos. La asignación de valores se realiza mediante el operador `<-`, aunque también es posible utilizar el operador `=`.

### Sintaxis de asignación

```r
# Sintaxis recomendada con <-
nombre_variable <- valor

# Sintaxis alternativa con =
nombre_variable = valor
```

El operador `<-` es preferido en la comunidad de R por razones históricas y de claridad en el código.

```r
# Ejemplos de asignación de variables
mi_nombre <- "Juan Carlos"
mi_edad <- 25
mi_altura <- 1.75
mi_peso <- 70.5

# Verificar el contenido de las variables
print(mi_nombre)
print(mi_edad)
print(mi_altura)
print(mi_peso)
```

### Reglas para nombrar variables

Las variables en R deben seguir ciertas reglas sintácticas:

1. **Inicio**: deben comenzar con una letra (a-z, A-Z) o un punto (.)
2. **Composición**: pueden contener letras, números, puntos y guiones bajos (_)
3. **Restricciones**: no pueden contener espacios ni caracteres especiales como -, +, *, etc.
4. **Sensibilidad**: R distingue entre mayúsculas y minúsculas

```r
# Nombres válidos
variable_numerica <- 100
Variable_Numerica <- 200  # Esta es diferente a la anterior
.variable_oculta <- 300   # Variables que comienzan con punto
datos_2023 <- 400
mi.variable <- 500

# Ejemplos de nombres NO válidos (producirían errores):
# 2variable <- 100        # No puede empezar con número
# mi-variable <- 100      # No puede contener guiones
# mi variable <- 100      # No puede contener espacios
```

### Verificación de variables existentes

```r
# Listar variables en el entorno actual
ls()

# Verificar si una variable existe
exists("mi_nombre")

# Eliminar una variable del entorno
rm(mi_peso)
```

---

## 3. Tipos de Datos Básicos {#tipos-datos}

R maneja varios tipos de datos fundamentales que determinan qué operaciones se pueden realizar con cada variable y cómo se almacenan en memoria.

### 3.1 Tipo numérico (numeric)

El tipo `numeric` representa números reales (con decimales). En R, por defecto, todos los números se almacenan como `numeric` a menos que se especifique lo contrario.

```r
# Definición de variables numéricas
numero_decimal <- 3.14159
temperatura <- 36.5
precio <- 150.00
poblacion <- 45000000

# Verificar el tipo de dato
class(numero_decimal)
class(temperatura)

# También podemos usar typeof() para información más detallada
typeof(numero_decimal)  # Devuelve "double" (precisión doble)
```

El tipo `numeric` en R internamente utiliza precisión doble (64 bits) para el almacenamiento de números reales.

### 3.2 Tipo entero (integer)

Los enteros se representan explícitamente agregando la letra `L` al final del número. Si no se especifica, R trata los números como `numeric`.

```r
# Definición explícita de enteros
numero_entero <- 42L
cantidad_estudiantes <- 150L

# Verificar el tipo
class(numero_entero)
typeof(numero_entero)  # Devuelve "integer"

# Comparación entre numeric e integer
numero_normal <- 42
numero_entero <- 42L

class(numero_normal)   # "numeric"
class(numero_entero)   # "integer"

# Conversión explícita a entero
valor_convertido <- as.integer(3.14)
print(valor_convertido)  # Resultado: 3 (se trunca, no redondea)
```

### 3.3 Tipo carácter (character)

El tipo `character` almacena cadenas de texto. Se pueden utilizar comillas simples (') o dobles (") para delimitar las cadenas.

```r
# Definición de variables de carácter
nombre <- "María Fernanda"
apellido <- 'González'
direccion <- "Av. Corrientes 1234, Buenos Aires"
codigo_postal <- "C1043AAZ"

# Verificar el tipo
class(nombre)

# Las cadenas pueden contener números, pero se tratan como texto
numero_como_texto <- "123"
class(numero_como_texto)  # "character", no "numeric"
```

### Operaciones con cadenas de caracteres

```r
# Concatenación de cadenas
nombre_completo <- paste(nombre, apellido)
print(nombre_completo)

# Concatenación con separador específico
nombre_completo2 <- paste(nombre, apellido, sep = " - ")
print(nombre_completo2)

# Longitud de una cadena
longitud_nombre <- nchar(nombre)
print(longitud_nombre)
```

### 3.4 Tipo lógico (logical)

El tipo `logical` representa valores booleanos: `TRUE` (verdadero) o `FALSE` (falso). Estos valores son fundamentales para operaciones de comparación y control de flujo.

```r
# Definición de variables lógicas
es_estudiante <- TRUE
tiene_trabajo <- FALSE
vive_en_capital <- TRUE

# Verificar el tipo
class(es_estudiante)

# Abreviaciones (no recomendadas en código formal)
valor_verdadero <- T
valor_falso <- F

# Resultado de operaciones de comparación
edad <- 20
es_mayor_edad <- edad >= 18
print(es_mayor_edad)  # TRUE
class(es_mayor_edad)  # "logical"
```

### 3.5 Verificación y conversión de tipos

R proporciona funciones específicas para verificar y convertir entre tipos de datos.

#### Funciones de verificación (`is.*`)

```r
# Crear variables de ejemplo
numero <- 42.5
texto <- "123"
logico <- TRUE

# Verificar tipos
is.numeric(numero)    # TRUE
is.character(texto)   # TRUE
is.logical(logico)    # TRUE

# Verificaciones cruzadas
is.numeric(texto)     # FALSE
is.character(numero)  # FALSE
```

#### Funciones de conversión (`as.*`)

```r
# Conversiones numéricas
numero_original <- 42
texto_numerico <- "123.45"
logico_original <- TRUE

# Convertir a carácter
numero_como_texto <- as.character(numero_original)
print(numero_como_texto)  # "42"
class(numero_como_texto)  # "character"

# Convertir texto a número
texto_como_numero <- as.numeric(texto_numerico)
print(texto_como_numero)  # 123.45
class(texto_como_numero)  # "numeric"

# Convertir lógico a número
logico_como_numero <- as.numeric(logico_original)
print(logico_como_numero)  # 1 (TRUE se convierte en 1, FALSE en 0)

# Conversiones que pueden fallar
texto_invalido <- "abc"
resultado <- as.numeric(texto_invalido)  # Produce NA con advertencia
print(resultado)  # NA
```

### Valores especiales en R

```r
# Valores especiales importantes
valor_faltante <- NA      # Not Available (dato faltante)
infinito_positivo <- Inf  # Infinito positivo
infinito_negativo <- -Inf # Infinito negativo
no_numero <- NaN          # Not a Number (resultado inválido)

# Verificar valores especiales
is.na(valor_faltante)     # TRUE
is.infinite(infinito_positivo)  # TRUE
is.nan(no_numero)         # TRUE
```

---

## 4. Operaciones Básicas {#operaciones}

R soporta una amplia gama de operaciones que se pueden clasificar en aritméticas, de comparación y lógicas. Estas operaciones forman la base para manipular y analizar datos.

### 4.1 Operaciones Aritméticas

Las operaciones aritméticas en R siguen las reglas matemáticas estándar, incluyendo la precedencia de operadores.

```r
# Definir variables para los ejemplos
a <- 15
b <- 4

# Operaciones básicas
suma <- a + b              # 19
resta <- a - b             # 11
multiplicacion <- a * b    # 60
division <- a / b          # 3.75
```

#### Operaciones de potencia y módulo

```r
# Potenciación
potencia1 <- a ^ b         # 15^4 = 50625
potencia2 <- a ** b        # Sintaxis alternativa, mismo resultado

# Módulo (resto de la división)
modulo <- a %% b           # 15 mod 4 = 3

# División entera
division_entera <- a %/% b # 15 ÷ 4 = 3 (parte entera)

# Mostrar resultados
print(paste("Suma:", suma))
print(paste("Resta:", resta))
print(paste("Multiplicación:", multiplicacion))
print(paste("División:", division))
print(paste("Potencia:", potencia1))
print(paste("Módulo:", modulo))
print(paste("División entera:", division_entera))
```

#### Precedencia de operadores

```r
# R sigue las reglas matemáticas de precedencia
resultado1 <- 2 + 3 * 4     # 14 (no 20)
resultado2 <- (2 + 3) * 4   # 20 (con paréntesis)
resultado3 <- 2 ^ 3 * 4     # 32 (potencia tiene mayor precedencia)
resultado4 <- 2 * 3 ^ 2     # 18 (no 36)

print(resultado1)
print(resultado2)
print(resultado3)
print(resultado4)
```

### 4.2 Operaciones de Comparación

Los operadores de comparación evalúan la relación entre valores y devuelven resultados lógicos (`TRUE` o `FALSE`).

```r
# Variables para comparación
x <- 10
y <- 15
z <- 10

# Operadores de comparación
igual <- x == z            # TRUE: igualdad
diferente <- x != y        # TRUE: desigualdad
menor_que <- x < y         # TRUE: menor que
menor_igual <- x <= z      # TRUE: menor o igual que
mayor_que <- y > x         # TRUE: mayor que
mayor_igual <- y >= x      # TRUE: mayor o igual que

# Mostrar resultados
print(paste("x == z:", igual))
print(paste("x != y:", diferente))
print(paste("x < y:", menor_que))
print(paste("x <= z:", menor_igual))
print(paste("y > x:", mayor_que))
print(paste("y >= x:", mayor_igual))
```

#### Comparaciones con tipos diferentes

```r
# Comparación entre tipos numéricos
entero <- 5L
decimal <- 5.0
print(entero == decimal)   # TRUE: R convierte automáticamente

# Comparación con caracteres
numero <- 5
texto <- "5"
print(numero == texto)     # FALSE: tipos diferentes

# Conversión explícita para comparar
print(numero == as.numeric(texto))  # TRUE
print(as.character(numero) == texto)  # TRUE
```

### 4.3 Operaciones Lógicas

Los operadores lógicos combinan valores booleanos y son fundamentales para crear condiciones complejas.

```r
# Variables lógicas para los ejemplos
condicion1 <- TRUE
condicion2 <- FALSE
condicion3 <- TRUE

# Operadores lógicos básicos
y_logico <- condicion1 & condicion2    # AND: FALSE
o_logico <- condicion1 | condicion2    # OR: TRUE
negacion <- !condicion1                # NOT: FALSE

print(paste("TRUE & FALSE =", y_logico))
print(paste("TRUE | FALSE =", o_logico))
print(paste("!TRUE =", negacion))
```

#### Diferencia entre & y && (| y ||)

```r
# & y | operan elemento por elemento (vectorizados)
# && y || evalúan solo el primer elemento

vector1 <- c(TRUE, FALSE, TRUE)
vector2 <- c(FALSE, TRUE, TRUE)

# Operación vectorizada
resultado_vectorizado <- vector1 & vector2
print(resultado_vectorizado)  # FALSE TRUE TRUE

# Operación no vectorizada (solo primer elemento)
resultado_escalar <- vector1 && vector2
print(resultado_escalar)     # FALSE
```

#### Combinación de operaciones

```r
# Ejemplo práctico: evaluar condiciones múltiples
edad <- 25
tiene_licencia <- TRUE
tiene_auto <- FALSE

# Puede manejar: mayor de 18 Y tiene licencia
puede_manejar <- (edad >= 18) & tiene_licencia
print(paste("Puede manejar:", puede_manejar))

# Puede viajar: puede manejar O tiene auto
puede_viajar <- puede_manejar | tiene_auto
print(paste("Puede viajar solo:", puede_viajar))

# Condición compleja
puede_trabajar_delivery <- (edad >= 18) & tiene_licencia & tiene_auto
print(paste("Puede trabajar en delivery:", puede_trabajar_delivery))
```

### 4.4 Operaciones con valores especiales

```r
# Operaciones con NA
valor1 <- 10
valor_na <- NA

suma_con_na <- valor1 + valor_na    # NA
print(suma_con_na)

# Verificar si hay NA
print(is.na(suma_con_na))          # TRUE

# Operaciones con infinito
infinito <- Inf
resultado_inf <- 10 / infinito      # 0
print(resultado_inf)

# Operación que produce NaN
resultado_nan <- 0 / 0              # NaN
print(resultado_nan)
print(is.nan(resultado_nan))        # TRUE
```

---

## 5. Estructuras de Datos {#estructuras}

R proporciona varias estructuras de datos para organizar y manipular información. Cada estructura tiene características específicas que la hacen adecuada para diferentes tipos de análisis.

### 5.1 Vectores

Los vectores son la estructura de datos más fundamental en R. Un vector es una secuencia ordenada de elementos del mismo tipo de dato.

#### Creación de vectores

```r
# Vector numérico
edades <- c(25, 30, 28, 35, 22)
print(edades)
class(edades)

# Vector de caracteres
nombres <- c("Ana", "Luis", "María", "Carlos", "Elena")
print(nombres)
class(nombres)

# Vector lógico
aprobados <- c(TRUE, FALSE, TRUE, TRUE, FALSE)
print(aprobados)
class(aprobados)
```

La función `c()` (combine) es la forma más común de crear vectores. Todos los elementos deben ser del mismo tipo; si no lo son, R realizará una conversión automática (coerción).

#### Coerción automática

```r
# Vector mixto: R convierte todo al tipo más "flexible"
vector_mixto <- c(1, 2, "tres", 4)
print(vector_mixto)  # "1" "2" "tres" "4" (todo convertido a character)
class(vector_mixto)  # "character"

# Jerarquía de coerción: logical < integer < numeric < character
vector_jerarquia <- c(TRUE, 1L, 2.5, "texto")
print(vector_jerarquia)  # Todos convertidos a character
```

#### Secuencias y repeticiones

```r
# Secuencia simple
secuencia_simple <- 1:10
print(secuencia_simple)

# Secuencia con paso específico
secuencia_paso <- seq(from = 0, to = 20, by = 2.5)
print(secuencia_paso)

# Secuencia con longitud específica
secuencia_longitud <- seq(from = 0, to = 1, length.out = 11)
print(secuencia_longitud)

# Repetición de valores
repeticion_simple <- rep(5, times = 6)
print(repeticion_simple)  # 5 5 5 5 5 5

# Repetición de vectores
repeticion_vector <- rep(c(1, 2, 3), times = 3)
print(repeticion_vector)  # 1 2 3 1 2 3 1 2 3

# Repetición de cada elemento
repeticion_each <- rep(c(1, 2, 3), each = 3)
print(repeticion_each)    # 1 1 1 2 2 2 3 3 3
```

#### Operaciones con vectores

```r
# Operaciones aritméticas vectorizadas
vector1 <- c(10, 20, 30, 40)
vector2 <- c(1, 2, 3, 4)

suma_vectores <- vector1 + vector2       # 11 22 33 44
producto_vectores <- vector1 * vector2   # 10 40 90 160
division_vectores <- vector1 / vector2   # 10 10 10 10

print(suma_vectores)
print(producto_vectores)
print(division_vectores)

# Operación con escalar (reciclaje)
vector_escalado <- vector1 * 2           # 20 40 60 80
print(vector_escalado)
```

#### Funciones estadísticas para vectores

```r
# Vector de ejemplo
calificaciones <- c(7.5, 8.2, 6.8, 9.1, 5.5, 8.7, 7.9, 6.2)

# Funciones básicas
longitud <- length(calificaciones)       # Número de elementos
suma_total <- sum(calificaciones)        # Suma de todos los elementos
promedio <- mean(calificaciones)         # Media aritmética
mediana <- median(calificaciones)        # Mediana
valor_minimo <- min(calificaciones)      # Valor mínimo
valor_maximo <- max(calificaciones)      # Valor máximo
rango <- range(calificaciones)           # Vector con min y max

print(paste("Longitud:", longitud))
print(paste("Suma:", suma_total))
print(paste("Promedio:", round(promedio, 2)))
print(paste("Mediana:", mediana))
print(paste("Mínimo:", valor_minimo))
print(paste("Máximo:", valor_maximo))
print(paste("Rango:", paste(rango, collapse = " - ")))
```

#### Funciones estadísticas avanzadas

```r
# Medidas de dispersión
varianza <- var(calificaciones)          # Varianza muestral
desviacion_std <- sd(calificaciones)     # Desviación estándar
cuartiles <- quantile(calificaciones)    # Cuartiles

print(paste("Varianza:", round(varianza, 3)))
print(paste("Desviación estándar:", round(desviacion_std, 3)))
print("Cuartiles:")
print(cuartiles)

# Resumen estadístico completo
resumen <- summary(calificaciones)
print(resumen)
```

### 5.2 Listas

Las listas son estructuras de datos heterogéneas que pueden contener elementos de diferentes tipos, incluyendo otras listas.

#### Creación de listas

```r
# Lista simple
mi_lista <- list(
  nombre = "Juan",
  edad = 30,
  casado = FALSE,
  hijos = c("Ana", "Luis")
)

print(mi_lista)
str(mi_lista)  # Estructura de la lista
```

#### Listas anidadas

```r
# Lista más compleja con diferentes tipos de datos
persona <- list(
  informacion_personal = list(
    nombre = "María",
    apellido = "González",
    edad = 28
  ),
  direccion = list(
    calle = "Av. Corrientes",
    numero = 1234,
    ciudad = "Buenos Aires",
    codigo_postal = "C1043AAZ"
  ),
  calificaciones = c(8.5, 9.2, 7.8, 8.9),
  materias = c("Matemática", "Física", "Química", "Biología"),
  becado = TRUE
)

print(str(persona))
```

#### Acceso a elementos de listas

```r
# Diferentes formas de acceder a elementos
# Usando nombres con $
nombre_persona <- persona$informacion_personal$nombre
print(nombre_persona)

# Usando corchetes dobles [[]]
edad_persona <- persona[["informacion_personal"]][["edad"]]
print(edad_persona)

# Usando números de posición
primera_calificacion <- persona[[3]][1]  # Tercer elemento, primer subelemento
print(primera_calificacion)

# Usando corchetes simples [] (devuelve una sublista)
info_direccion <- persona["direccion"]
class(info_direccion)  # "list"
```

### 5.3 Matrices

Las matrices son arreglos bidimensionales de elementos del mismo tipo de dato, organizados en filas y columnas.

#### Creación de matrices

```r
# Matriz básica
matriz_numeros <- matrix(1:12, nrow = 3, ncol = 4)
print(matriz_numeros)

# Especificar si llenar por filas o columnas
matriz_por_filas <- matrix(1:12, nrow = 3, ncol = 4, byrow = TRUE)
print(matriz_por_filas)

# Matriz con nombres de filas y columnas
matriz_con_nombres <- matrix(
  c(85, 90, 78, 88, 92, 76), 
  nrow = 2, 
  ncol = 3,
  dimnames = list(
    c("Estudiante_A", "Estudiante_B"),      # Nombres de filas
    c("Matemática", "Física", "Química")    # Nombres de columnas
  )
)
print(matriz_con_nombres)
```

#### Propiedades de matrices

```r
# Información sobre la matriz
dimensiones <- dim(matriz_con_nombres)    # Dimensiones (filas, columnas)
num_filas <- nrow(matriz_con_nombres)     # Número de filas
num_columnas <- ncol(matriz_con_nombres)  # Número de columnas
nombres_filas <- rownames(matriz_con_nombres)    # Nombres de filas
nombres_columnas <- colnames(matriz_con_nombres) # Nombres de columnas

print(paste("Dimensiones:", paste(dimensiones, collapse = " x ")))
print(paste("Filas:", num_filas))
print(paste("Columnas:", num_columnas))
print("Nombres de filas:")
print(nombres_filas)
print("Nombres de columnas:")
print(nombres_columnas)
```

#### Operaciones con matrices

```r
# Crear dos matrices para operaciones
matriz_a <- matrix(1:6, nrow = 2, ncol = 3)
matriz_b <- matrix(7:12, nrow = 2, ncol = 3)

print("Matriz A:")
print(matriz_a)
print("Matriz B:")
print(matriz_b)

# Operaciones elemento por elemento
suma_matrices <- matriz_a + matriz_b
producto_elemento <- matriz_a * matriz_b

print("Suma de matrices:")
print(suma_matrices)
print("Producto elemento por elemento:")
print(producto_elemento)

# Transposición
matriz_transpuesta <- t(matriz_a)
print("Matriz A transpuesta:")
print(matriz_transpuesta)
```

### 5.4 Data Frames

Los data frames son la estructura de datos más importante para el análisis estadístico. Son similares a las tablas en bases de datos o las hojas de cálculo.

#### Creación de data frames

```r
# Data frame básico
estudiantes <- data.frame(
  nombre = c("Ana", "Luis", "María", "Carlos", "Elena"),
  edad = c(20, 22, 21, 23, 20),
  carrera = c("Medicina", "Ingeniería", "Psicología", "Derecho", "Biología"),
  promedio = c(8.5, 7.2, 9.1, 6.8, 8.9),
  becado = c(TRUE, FALSE, TRUE, FALSE, TRUE)
)

print(estudiantes)
```

#### Propiedades de data frames

```r
# Información estructural
estructura <- str(estudiantes)           # Estructura detallada
dimensiones <- dim(estudiantes)          # Dimensiones
nombres_variables <- names(estudiantes)  # Nombres de columnas
nombres_obs <- rownames(estudiantes)     # Nombres de filas

print("Dimensiones del data frame:")
print(dimensiones)
print("Nombres de variables:")
print(nombres_variables)

# Primeras y últimas observaciones
print("Primeras 3 observaciones:")
print(head(estudiantes, 3))
print("Últimas 2 observaciones:")
print(tail(estudiantes, 2))
```

#### Resumen estadístico de data frames

```r
# Resumen estadístico automático
resumen_completo <- summary(estudiantes)
print(resumen_completo)

# Información específica por variable
print("Promedio de edad:")
print(mean(estudiantes$edad))

print("Distribución por carrera:")
print(table(estudiantes$carrera))

print("Proporción de becados:")
print(table(estudiantes$becado))
```

#### Agregar y modificar columnas

```r
# Agregar nueva columna
estudiantes$año_nacimiento <- 2024 - estudiantes$edad
estudiantes$categoria_promedio <- ifelse(estudiantes$promedio >= 8, "Alto", "Regular")

print("Data frame con nuevas columnas:")
print(estudiantes)

# Modificar columna existente
estudiantes$edad <- estudiantes$edad + 1  # Simular paso de un año

print("Edades actualizadas:")
print(estudiantes[c("nombre", "edad")])
```

---

## 6. Funciones {#funciones}

Las funciones son bloques de código reutilizable que realizan tareas específicas. R incluye numerosas funciones incorporadas y permite crear funciones personalizadas.

### 6.1 Funciones incorporadas

R proporciona una amplia biblioteca de funciones predefinidas para diferentes propósitos.

#### Funciones matemáticas básicas

```r
# Vector de ejemplo para las operaciones
numeros <- c(4, 9, 16, 25, -3, 7.5)

# Funciones de raíz y potencia
raices_cuadradas <- sqrt(numeros)         # Raíz cuadrada
potencias_cuadradas <- numeros^2          # Elevar al cuadrado
logaritmo_natural <- log(abs(numeros))    # Logaritmo natural (abs para evitar log de negativos)
logaritmo_base10 <- log10(abs(numeros))   # Logaritmo base 10

print("Números originales:")
print(numeros)
print("Raíces cuadradas:")
print(raices_cuadradas)
print("Logaritmos naturales:")
print(round(logaritmo_natural, 3))
```

#### Funciones de redondeo

```r
# Números decimales para redondeo
decimales <- c(3.14159, 2.718, -1.414, 0.577)

# Diferentes tipos de redondeo
redondeado <- round(decimales, 2)         # Redondeo normal a 2 decimales
hacia_arriba <- ceiling(decimales)        # Redondeo hacia arriba (techo)
hacia_abajo <- floor(decimales)           # Redondeo hacia abajo (piso)
truncado <- trunc(decimales)              # Truncamiento (elimina decimales)

print("Números originales:")
print(decimales)
print("Redondeado a 2 decimales:")
print(redondeado)
print("Hacia arriba:")
print(hacia_arriba)
print("Hacia abajo:")
print(hacia_abajo)
print("Truncado:")
print(truncado)
```

#### Funciones estadísticas

```r
# Dataset de ejemplo: calificaciones de un curso
calificaciones <- c(6.5, 7.8, 8.2, 5.9, 9.1, 7.5, 8.8, 6.2, 7.9, 8.5, 
                   9.3, 6.8, 7.2, 8.9, 5.8, 8.1, 7.6, 9.0, 6.9, 8.3)

# Medidas de tendencia central
media <- mean(calificaciones)             # Media aritmética
mediana <- median(calificaciones)         # Mediana
moda_estimada <- as.numeric(names(sort(table(calificaciones), decreasing = TRUE))[1])

# Medidas de dispersión
varianza <- var(calificaciones)           # Varianza muestral
desviacion_estandar <- sd(calificaciones) # Desviación estándar
rango_intercuartil <- IQR(calificaciones) # Rango intercuartílico

# Valores extremos
minimo <- min(calificaciones)
maximo <- max(calificaciones)
rango_total <- max(calificaciones) - min(calificaciones)

print(paste("Media:", round(media, 2)))
print(paste("Mediana:", mediana))
print(paste("Varianza:", round(varianza, 3)))
print(paste("Desviación estándar:", round(desviacion_estandar, 3)))
print(paste("Rango intercuartílico:", round(rango_intercuartil, 2)))
print(paste("Rango total:", rango_total))
```

#### Funciones de cadenas de caracteres

```r
# Ejemplos con texto
nombres_completos <- c("Ana María González", "Luis Carlos Pérez", "María Elena Rodríguez")

# Longitud de cadenas
longitudes <- nchar(nombres_completos)
print("Longitudes de nombres:")
print(longitudes)

# Conversión de mayúsculas y minúsculas
mayusculas <- toupper(nombres_completos)
minusculas <- tolower(nombres_completos)

print("En mayúsculas:")
print(mayusculas)
print("En minúsculas:")
print(minusculas)

# Extracción de subcadenas
primeros_nombres <- substr(nombres_completos, 1, 8)
print("Primeros 8 caracteres:")
print(primeros_nombres)
```

### 6.2 Creación de funciones personalizadas

Las funciones personalizadas permiten encapsular código que se utiliza repetidamente.

#### Sintaxis básica

```r
# Estructura general de una función
nombre_funcion <- function(parametro1, parametro2, ...) {
  # Código de la función
  resultado <- # cálculos
  return(resultado)  # Opcional: R devuelve la última expresión evaluada
}
```

#### Función simple

```r
# Función para calcular el área de un círculo
calcular_area_circulo <- function(radio) {
  if (radio < 0) {
    stop("El radio no puede ser negativo")
  }
  area <- pi * radio^2
  return(area)
}

# Usar la función
area_circulo <- calcular_area_circulo(5)
print(paste("Área del círculo:", round(area_circulo, 2)))

# Aplicar a un vector de radios
radios <- c(1, 2, 3, 4, 5)
areas <- calcular_area_circulo(radios)
print("Áreas de múltiples círculos:")
print(round(areas, 2))
```

#### Función con múltiples parámetros

```r
# Función para calcular estadísticas descriptivas
estadisticas_descriptivas <- function(datos, incluir_cuartiles = FALSE) {
  # Verificar que los datos sean numéricos
  if (!is.numeric(datos)) {
    stop("Los datos deben ser numéricos")
  }
  
  # Remover valores faltantes
  datos_limpios <- datos[!is.na(datos)]
  
  if (length(datos_limpios) == 0) {
    stop("No hay datos válidos para analizar")
  }
  
  # Calcular estadísticas básicas
  resultado <- list(
    n = length(datos_limpios),
    media = mean(datos_limpios),
    mediana = median(datos_limpios),
    desviacion_std = sd(datos_limpios),
    minimo = min(datos_limpios),
    maximo = max(datos_limpios)
  )
  
  # Agregar cuartiles si se solicita
  if (incluir_cuartiles) {
    resultado$cuartiles <- quantile(datos_limpios)
  }
  
  return(resultado)
}

# Usar la función
datos_prueba <- c(7.5, 8.2, 6.8, 9.1, 5.5, 8.7, 7.9, 6.2, NA, 8.4)
estadisticas <- estadisticas_descriptivas(datos_prueba, incluir_cuartiles = TRUE)

print("Estadísticas descriptivas:")
print(estadisticas)
```

#### Función con valores por defecto

```r
# Función para convertir temperatura
convertir_temperatura <- function(valor, desde = "celsius", hacia = "fahrenheit") {
  # Validar parámetros
  escalas_validas <- c("celsius", "fahrenheit", "kelvin")
  
  if (!(desde %in% escalas_validas) || !(hacia %in% escalas_validas)) {
    stop("Escalas válidas: celsius, fahrenheit, kelvin")
  }
  
  # Convertir todo a Celsius primero
  if (desde == "fahrenheit") {
    celsius <- (valor - 32) * 5/9
  } else if (desde == "kelvin") {
    celsius <- valor - 273.15
  } else {
    celsius <- valor
  }
  
  # Convertir desde Celsius a la escala destino
  if (hacia == "fahrenheit") {
    resultado <- celsius * 9/5 + 32
  } else if (hacia == "kelvin") {
    resultado <- celsius + 273.15
  } else {
    resultado <- celsius
  }
  
  return(round(resultado, 2))
}

# Ejemplos de uso
temp_fahrenheit <- convertir_temperatura(25)  # Celsius a Fahrenheit (por defecto)
temp_kelvin <- convertir_temperatura(25, hacia = "kelvin")
temp_celsius <- convertir_temperatura(77, desde = "fahrenheit", hacia = "celsius")

print(paste("25°C =", temp_fahrenheit, "°F"))
print(paste("25°C =", temp_kelvin, "K"))
print(paste("77°F =", temp_celsius, "°C"))
```

#### Función que devuelve múltiples valores

```r
# Función para análisis de regresión lineal simple
regresion_simple <- function(x, y) {
  # Verificar que x e y tengan la misma longitud
  if (length(x) != length(y)) {
    stop("x e y deben tener la misma longitud")
  }
  
  # Remover pares con valores faltantes
  datos_completos <- complete.cases(x, y)
  x_limpio <- x[datos_completos]
  y_limpio <- y[datos_completos]
  
  n <- length(x_limpio)
  
  if (n < 2) {
    stop("Se necesitan al menos 2 observaciones válidas")
  }
  
  # Calcular coeficientes
  x_media <- mean(x_limpio)
  y_media <- mean(y_limpio)
  
  numerador <- sum((x_limpio - x_media) * (y_limpio - y_media))
  denominador <- sum((x_limpio - x_media)^2)
  
  if (denominador == 0) {
    stop("No hay variación en x")
  }
  
  pendiente <- numerador / denominador
  intercepto <- y_media - pendiente * x_media
  
  # Calcular R-cuadrado
  y_predicho <- intercepto + pendiente * x_limpio
  sct <- sum((y_limpio - y_media)^2)  # Suma total de cuadrados
  sce <- sum((y_limpio - y_predicho)^2)  # Suma de cuadrados del error
  r_cuadrado <- 1 - sce / sct
  
  # Devolver resultados
  return(list(
    intercepto = round(intercepto, 4),
    pendiente = round(pendiente, 4),
    r_cuadrado = round(r_cuadrado, 4),
    n = n,
    ecuacion = paste("y =", round(intercepto, 4), "+", round(pendiente, 4), "* x")
  ))
}

# Ejemplo de uso
x_datos <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
y_datos <- c(2.1, 3.9, 6.2, 8.1, 9.8, 12.2, 14.1, 15.9, 18.2, 20.1)

resultado_regresion <- regresion_simple(x_datos, y_datos)
print("Resultado de regresión lineal:")
print(resultado_regresion)
```

---

## 7. Indexación y Subsetting {#indexacion}

La indexación permite acceder a elementos específicos de las estructuras de datos. R utiliza indexación basada en 1 (el primer elemento tiene índice 1).

### 7.1 Indexación de vectores

#### Indexación por posición

```r
# Vector de ejemplo
ciudades <- c("Buenos Aires", "Córdoba", "Rosario", "Mendoza", "La Plata", "Tucumán")

# Acceso a elementos individuales
primera_ciudad <- ciudades[1]        # "Buenos Aires"
tercera_ciudad <- ciudades[3]        # "Rosario"
ultima_ciudad <- ciudades[length(ciudades)]  # "Tucumán"

print(paste("Primera ciudad:", primera_ciudad))
print(paste("Tercera ciudad:", tercera_ciudad))
print(paste("Última ciudad:", ultima_ciudad))

# Acceso a múltiples elementos
primeras_tres <- ciudades[1:3]       # Primeras tres ciudades
ciudades_seleccionadas <- ciudades[c(1, 3, 5)]  # Posiciones específicas

print("Primeras tres ciudades:")
print(primeras_tres)
print("Ciudades en posiciones 1, 3 y 5:")
print(ciudades_seleccionadas)
```

#### Indexación negativa (exclusión)

```r
# Excluir elementos específicos
sin_primera <- ciudades[-1]          # Todas menos la primera
sin_primera_y_ultima <- ciudades[-c(1, length(ciudades))]  # Sin primera ni última

print("Sin la primera ciudad:")
print(sin_primera)
print("Sin primera ni última:")
print(sin_primera_y_ultima)
```

#### Indexación lógica

```r
# Vector numérico para ejemplos lógicos
temperaturas <- c(22.5, 28.3, 19.7, 31.2, 25.8, 18.5, 29.7, 26.1)
dias <- c("Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo", "Lunes")

# Crear condiciones lógicas
temp_alta <- temperaturas > 25       # Vector lógico
temp_muy_alta <- temperaturas > 28   # Vector lógico

print("Temperaturas altas (>25°C):")
print(temperaturas[temp_alta])
print("Días con temperatura alta:")
print(dias[temp_alta])

print("Temperaturas muy altas (>28°C):")
print(temperaturas[temp_muy_alta])
print("Días con temperatura muy alta:")
print(dias[temp_muy_alta])

# Condiciones múltiples
temp_moderada <- temperaturas >= 20 & temperaturas <= 30
print("Temperaturas moderadas (20-30°C):")
print(temperaturas[temp_moderada])
```

#### Indexación por nombres

```r
# Vector con nombres
poblacion_provincias <- c(
  "Buenos Aires" = 17569053,
  "Córdoba" = 3798261,
  "Santa Fe" = 3397532,
  "Mendoza" = 1990338,
  "Tucumán" = 1687305
)

# Acceso por nombres
poblacion_cordoba <- poblacion_provincias["Córdoba"]
poblacion_varias <- poblacion_provincias[c("Buenos Aires", "Santa Fe")]

print("Población de Córdoba:")
print(poblacion_cordoba)
print("Población de Buenos Aires y Santa Fe:")
print(poblacion_varias)
```

### 7.2 Indexación de data frames

#### Indexación por filas y columnas

```r
# Data frame de ejemplo
ventas <- data.frame(
  mes = c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio"),
  producto_A = c(150, 180, 220, 190, 230, 210),
  producto_B = c(120, 140, 160, 170, 180, 165),
  producto_C = c(90, 110, 130, 125, 140, 135),
  stringsAsFactors = FALSE
)

print("Data frame de ventas:")
print(ventas)

# Acceso a filas específicas
primera_fila <- ventas[1, ]          # Primera fila completa
primeras_tres_filas <- ventas[1:3, ]  # Primeras tres filas

print("Primera fila:")
print(primera_fila)
print("Primeras tres filas:")
print(primeras_tres_filas)

# Acceso a columnas específicas
columna_mes <- ventas[, 1]           # Primera columna (mes)
ventas_productos <- ventas[, 2:4]    # Columnas de productos

print("Columna mes:")
print(columna_mes)
print("Ventas de productos:")
print(ventas_productos)

# Acceso a elementos específicos
venta_marzo_prodA <- ventas[3, 2]    # Fila 3, columna 2
print(paste("Ventas Producto A en Marzo:", venta_marzo_prodA))
```

#### Indexación por nombres de columnas

```r
# Acceso usando nombres de columnas
ventas_prodA <- ventas$producto_A    # Usando $
ventas_prodB <- ventas[["producto_B"]]  # Usando [[]]
mes_prodC <- ventas[, c("mes", "producto_C")]  # Múltiples columnas

print("Ventas Producto A:")
print(ventas_prodA)
print("Mes y Producto C:")
print(mes_prodC)

# Crear nuevas variables basadas en columnas existentes
ventas$total <- ventas$producto_A + ventas$producto_B + ventas$producto_C
ventas$promedio <- ventas$total / 3

print("Data frame con nuevas columnas:")
print(ventas)
```

#### Filtrado condicional de data frames

```r
# Filtrar filas basado en condiciones
# Meses con ventas de Producto A > 200
ventas_altas_A <- ventas[ventas$producto_A > 200, ]

print("Meses con ventas altas de Producto A:")
print(ventas_altas_A)

# Múltiples condiciones
ventas_condiciones <- ventas[ventas$producto_A > 180 & ventas$producto_B > 150, ]

print("Meses con buenas ventas en A y B:")
print(ventas_condiciones)

# Filtrar y seleccionar columnas específicas
resumen_altas <- ventas[ventas$total > 500, c("mes", "total")]

print("Meses con ventas totales altas:")
print(resumen_altas)
```

### 7.3 Indexación de matrices

```r
# Matriz de ejemplo
calificaciones_matriz <- matrix(
  c(8.5, 7.2, 9.1, 6.8, 8.9, 7.5, 8.2, 9.0, 7.8, 8.6, 7.9, 8.4),
  nrow = 4,
  ncol = 3,
  dimnames = list(
    c("Ana", "Luis", "María", "Carlos"),
    c("Matemática", "Física", "Química")
  )
)

print("Matriz de calificaciones:")
print(calificaciones_matriz)

# Acceso a filas específicas
calif_ana <- calificaciones_matriz[1, ]      # Primera fila (Ana)
calif_maria_carlos <- calificaciones_matriz[3:4, ]  # María y Carlos

print("Calificaciones de Ana:")
print(calif_ana)

# Acceso a columnas específicas
matematica <- calificaciones_matriz[, 1]     # Primera columna
fisica_quimica <- calificaciones_matriz[, 2:3]  # Física y Química

print("Calificaciones en Matemática:")
print(matematica)

# Elemento específico
calif_luis_fisica <- calificaciones_matriz[2, 2]  # Luis en Física
print(paste("Calificación de Luis en Física:", calif_luis_fisica))

# Usando nombres
calif_maria_quimica <- calificaciones_matriz["María", "Química"]
print(paste("Calificación de María en Química:", calif_maria_quimica))
```

### 7.4 Funciones auxiliares para indexación

```r
# Vector con algunos valores faltantes
datos_incompletos <- c(5, 8, NA, 12, 15, NA, 20, 25)

# Identificar valores faltantes
valores_na <- is.na(datos_incompletos)
print("Posiciones con NA:")
print(which(valores_na))

# Datos completos (sin NA)
datos_completos <- datos_incompletos[!is.na(datos_incompletos)]
print("Datos sin NA:")
print(datos_completos)

# Función which() para encontrar posiciones
posiciones_mayores_10 <- which(datos_incompletos > 10)
print("Posiciones con valores > 10:")
print(posiciones_mayores_10)

# Función match() para encontrar coincidencias
buscar_valores <- c(8, 15, 30)
posiciones_encontradas <- match(buscar_valores, datos_incompletos)
print("Posiciones de valores buscados:")
print(posiciones_encontradas)  # NA indica que no se encontró

# Función %in% para verificar membresía
esta_presente <- buscar_valores %in% datos_incompletos
print("¿Valores están presentes?")
print(esta_presente)
```

---

## 8. Paquetes en R {#paquetes}

Los paquetes extienden la funcionalidad básica de R, proporcionando funciones especializadas para diferentes áreas de análisis.

### 8.1 Conceptos básicos de paquetes

#### ¿Qué son los paquetes?

Los paquetes son colecciones de funciones, datos y documentación que expanden las capacidades de R. El sistema base de R incluye varios paquetes fundamentales, pero la verdadera potencia viene de los miles de paquetes adicionales disponibles.

#### Tipos de paquetes

1. **Paquetes base**: Incluidos automáticamente con R
2. **Paquetes recomendados**: Instalados por defecto pero deben cargarse explícitamente
3. **Paquetes contribuidos**: Desarrollados por la comunidad, disponibles en CRAN

### 8.2 Gestión de paquetes

#### Instalación de paquetes

```r
# Instalar un paquete desde CRAN (solo necesario una vez)
# install.packages("nombre_del_paquete")

# Ejemplos (no ejecutar en este notebook):
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("readr")

# Instalar múltiples paquetes
# install.packages(c("ggplot2", "dplyr", "tidyr"))
```

#### Cargar paquetes

```r
# Cargar paquetes en la sesión actual
library(datasets)  # Paquete de datasets incluido en R base
library(utils)     # Utilidades básicas

# Verificar paquetes cargados
search()

# Información sobre un paquete específico
# help(package = "datasets")
```

#### Verificar paquetes instalados

```r
# Listar todos los paquetes instalados
paquetes_instalados <- installed.packages()
print(paste("Número de paquetes instalados:", nrow(paquetes_instalados)))

# Verificar si un paquete específico está instalado
if ("datasets" %in% rownames(installed.packages())) {
  print("El paquete datasets está instalado")
} else {
  print("El paquete datasets no está instalado")
}

# Información de la sesión actual
sessionInfo()
```

