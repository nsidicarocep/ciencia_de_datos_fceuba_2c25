# Ejercicios de Programación - Conceptos Fundamentales

## Ejercicio 1: Variables y Tipos de Datos

Definir las siguientes variables con los valores correspondientes:
- `nombre_estudiante`: su nombre completo
- `edad`: su edad actual
- `promedio_carrera`: un valor decimal que represente su promedio académico
- `materias_aprobadas`: cantidad de materias aprobadas (número entero)
- `tiene_beca`: valor lógico indicando si posee algún tipo de beca
- `universidad`: nombre de su institución educativa

Luego, verificar el tipo de dato de cada variable y mostrar su contenido.

## Ejercicio 2: Operaciones Aritméticas y Lógicas

Un estudiante tiene las siguientes calificaciones parciales: 7.5, 8.2, 6.8, 9.1. 

Calcular:
- El promedio de las calificaciones
- La calificación más alta y más baja
- La diferencia entre la calificación más alta y más baja
- Determinar si el promedio es mayor o igual a 7.0 (condición para aprobar)
- Verificar si todas las calificaciones son mayores a 6.0

## Ejercicio 3: Creación y Manipulación de Vectores

Crear un vector con los siguientes datos de temperaturas registradas durante una semana (en grados Celsius): 22.5, 25.3, 28.1, 24.7, 26.9, 29.2, 27.8.

Realizar las siguientes operaciones:
- Calcular la temperatura promedio de la semana
- Identificar cuántos días la temperatura superó los 26°C
- Convertir todas las temperaturas a grados Fahrenheit (fórmula: F = C × 9/5 + 32)
- Encontrar la posición del día con la temperatura más alta

## Ejercicio 4: Trabajo con Cadenas de Caracteres

Dado el siguiente vector de nombres completos:
["María González", "Juan Carlos Pérez", "Ana Sofía Martín", "Luis Fernando Rodríguez"]

Realizar las siguientes operaciones:
- Calcular la longitud de cada nombre completo
- Convertir todos los nombres a mayúsculas
- Extraer los primeros 10 caracteres de cada nombre
- Contar cuántos nombres contienen más de 15 caracteres

## Ejercicio 5: Indexación y Filtrado

Crear un vector con las edades de 15 personas: [23, 19, 25, 31, 28, 22, 34, 27, 21, 26, 30, 24, 29, 20, 32].

Realizar las siguientes tareas:
- Obtener las edades de las posiciones 3, 7 y 12
- Seleccionar todas las edades menores a 25 años
- Encontrar las posiciones de las personas mayores de 30 años
- Calcular el promedio de edad de las personas menores a 26 años

## Ejercicio 6: Manipulación de DataFrames

Crear una tabla con información de productos de una tienda:

| Producto | Precio | Categoria | Stock | Descuento |
|----------|--------|-----------|-------|-----------|
| Notebook | 85000 | Electrónicos | 15 | 0.10 |
| Escritorio | 25000 | Muebles | 8 | 0.05 |
| Mouse | 3500 | Electrónicos | 45 | 0.00 |
| Silla | 18000 | Muebles | 12 | 0.15 |
| Teclado | 7500 | Electrónicos | 30 | 0.08 |
| Lámpara | 12000 | Muebles | 20 | 0.12 |

Realizar las siguientes operaciones:
- Agregar una nueva columna llamada `precio_final` que calcule el precio con descuento aplicado
- Agregar una columna `valor_stock` que multiplique precio_final por stock
- Filtrar productos de la categoría "Electrónicos"
- Encontrar el producto con mayor valor de stock
- Calcular el valor total del inventario (suma de todos los valores de stock)

## Ejercicio 7: Estructuras de Datos Complejas

Crear una estructura de datos (tabla/data frame) con la siguiente información de estudiantes:

| Nombre | Edad | Carrera | Promedio | Activo |
|--------|------|---------|----------|---------|
| Carlos | 22 | Ingeniería | 8.5 | Verdadero |
| María | 21 | Medicina | 9.2 | Verdadero |
| Juan | 23 | Derecho | 7.8 | Falso |
| Ana | 20 | Psicología | 8.9 | Verdadero |

Realizar las siguientes consultas:
- Mostrar solo los estudiantes activos
- Calcular el promedio general de calificaciones
- Encontrar al estudiante con el promedio más alto
- Contar cuántos estudiantes hay por carrera

## Ejercicio 8: Análisis Estadístico Básico

Dado el siguiente conjunto de datos que representa las ventas mensuales de una empresa (en miles de pesos): [150, 175, 190, 165, 200, 185, 220, 195, 210, 180, 225, 205].

Calcular:
- Media, mediana y desviación estándar
- El mes con mayor y menor venta
- Cuántos meses superaron la media de ventas
- El crecimiento porcentual entre el primer y último mes

## Ejercicio 9: Manipulación de Datos Faltantes

Crear un vector con las siguientes calificaciones, donde algunos valores están ausentes: [8.5, 7.2, NA, 9.1, 6.8, NA, 8.9, 7.5, 8.2, NA].

Realizar las siguientes operaciones:
- Identificar las posiciones con valores faltantes
- Calcular el promedio excluyendo los valores faltantes
- Reemplazar los valores faltantes con el promedio calculado
- Contar cuántos valores válidos y faltantes hay en total

## Ejercicio 10: Integración de Conceptos

Una empresa registra las horas trabajadas por sus empleados durante una semana. Los datos son los siguientes:

- Empleados: ["García", "López", "Martínez", "Fernández", "González"]
- Horas por día: 
  - García: [8, 7, 8, 8, 6]
  - López: [9, 8, 9, 7, 8]
  - Martínez: [7, 8, 8, 9, 7]
  - Fernández: [8, 8, 8, 8, 8]
  - González: [6, 7, 8, 9, 8]

Tareas a realizar:
- Crear una estructura de datos apropiada para almacenar esta información
- Calcular el total de horas trabajadas por cada empleado
- Determinar quién trabajó más horas en la semana
- Calcular el promedio diario de horas por empleado
- Identificar qué empleados trabajaron más de 40 horas en la semana
- Crear una función que determine si un empleado califica para horas extras (más de 8 horas diarias)