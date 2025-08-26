# Fundamentos de Python - Guía Básica
*Material didáctico para el curso de programación en Python*

---

## 📚 Contenido del Notebook

1. [Introducción a Python](#introducción)
2. [Variables y Asignación](#variables)
3. [Tipos de Datos Básicos](#tipos-datos)
4. [Operaciones Básicas](#operaciones)
5. [Estructuras de Datos](#estructuras)
6. [Funciones](#funciones)
7. [Indexación y Subsetting](#indexacion)
8. [Librerías en Python](#librerias)

---

## 1. Introducción a Python {#introducción}

Python es un lenguaje de programación de alto nivel, interpretado y de propósito general. Fue creado por Guido van Rossum y se caracteriza por su sintaxis clara y legible, lo que lo convierte en una herramienta ideal tanto para principiantes como para desarrolladores experimentados.

### Características principales de Python
- **Sintaxis clara y legible**: diseñado para ser fácil de leer y escribir
- **Interpretado**: no requiere compilación previa, se ejecuta línea por línea
- **Multiplataforma**: funciona en Windows, macOS y sistemas Unix/Linux
- **Tipado dinámico**: no es necesario declarar el tipo de las variables
- **Extenso ecosistema**: cuenta con una amplia biblioteca estándar y paquetes externos
- **Comunidad activa**: respaldado por una gran comunidad de desarrolladores

### El entorno de trabajo en Python
Python utiliza un intérprete donde se ejecutan las instrucciones secuencialmente. Los comentarios se indican con el símbolo `#` para comentarios de una línea o con `"""` para comentarios de múltiples líneas.

```python
# Este es un comentario de una línea
# Los comentarios son ignorados por el intérprete
print("Mi primer programa en Python")

"""
Este es un comentario
de múltiples líneas
"""
```

La función `print()` es fundamental para mostrar resultados en la consola. A diferencia de otros lenguajes, Python no requiere punto y coma al final de las instrucciones.

---

## 2. Variables y Asignación {#variables}

Las variables en Python son referencias a objetos en memoria que almacenan valores de diferentes tipos. La asignación se realiza mediante el operador `=`, y el tipo de la variable se determina automáticamente según el valor asignado.

### Sintaxis de asignación

```python
# Sintaxis básica de asignación
nombre_variable = valor

# Python permite asignaciones múltiples
variable1, variable2, variable3 = valor1, valor2, valor3
```

```python
# Ejemplos de asignación de variables
mi_nombre = "Juan Carlos"
mi_edad = 25
mi_altura = 1.75
mi_peso = 70.5

# Verificar el contenido de las variables
print(mi_nombre)
print(mi_edad)
print(mi_altura)
print(mi_peso)

# Asignación múltiple
x, y, z = 10, 20, 30
print(f"x={x}, y={y}, z={z}")
```

### Reglas para nombrar variables

Las variables en Python deben seguir ciertas convenciones sintácticas:

1. **Inicio**: deben comenzar con una letra (a-z, A-Z) o un guión bajo (_)
2. **Composición**: pueden contener letras, números y guiones bajos
3. **Restricciones**: no pueden contener espacios ni caracteres especiales
4. **Sensibilidad**: Python distingue entre mayúsculas y minúsculas
5. **Palabras reservadas**: no pueden usar palabras clave del lenguaje

```python
# Nombres válidos (siguiendo convenciones PEP 8)
variable_numerica = 100
edad_estudiante = 20
_variable_privada = 300  # Convención para variables "privadas"
datos_2023 = 400
mi_variable = 500

# Verificar palabras reservadas
import keyword
print("Palabras reservadas en Python:")
print(keyword.kwlist)

# Ejemplos de nombres NO válidos (producirían errores):
# 2variable = 100        # No puede empezar con número
# mi-variable = 100      # No puede contener guiones
# mi variable = 100      # No puede contener espacios
# class = 100            # No puede usar palabras reservadas
```

### Verificación de variables y gestión de memoria

```python
# Listar variables en el espacio de nombres local
print("Variables definidas:")
for var in dir():
    if not var.startswith('_'):
        print(f"{var}: {eval(var)}")

# Verificar si una variable existe
if 'mi_nombre' in locals():
    print("La variable mi_nombre existe")

# Verificar el tipo y la identidad de objetos
print(f"Tipo de mi_edad: {type(mi_edad)}")
print(f"ID en memoria de mi_edad: {id(mi_edad)}")

# Eliminar una variable del espacio de nombres
del mi_peso
# print(mi_peso)  # Esto produciría un error
```

---

## 3. Tipos de Datos Básicos {#tipos-datos}

Python maneja varios tipos de datos fundamentales que determinan qué operaciones se pueden realizar con cada variable y cómo se comportan en memoria.

### 3.1 Tipo entero (int)

Los enteros en Python pueden tener longitud arbitraria, limitada únicamente por la memoria disponible del sistema.

```python
# Definición de variables enteras
numero_pequeño = 42
numero_grande = 123456789012345678901234567890
cantidad_estudiantes = 150

# Verificar el tipo de dato
print(f"Tipo de numero_pequeño: {type(numero_pequeño)}")
print(f"Tipo de numero_grande: {type(numero_grande)}")

# Python maneja automáticamente enteros de cualquier tamaño
print(f"Número grande: {numero_grande}")
print(f"Número grande al cuadrado: {numero_grande ** 2}")

# Diferentes bases numéricas
binario = 0b1010        # Base 2 (binario)
octal = 0o12           # Base 8 (octal)
hexadecimal = 0xa      # Base 16 (hexadecimal)

print(f"Binario 1010: {binario}")
print(f"Octal 12: {octal}")
print(f"Hexadecimal a: {hexadecimal}")
```

### 3.2 Tipo flotante (float)

Los números de punto flotante en Python siguen el estándar IEEE 754 de doble precisión.

```python
# Definición de variables flotantes
numero_decimal = 3.14159
temperatura = 36.5
precio = 150.00
notacion_cientifica = 1.5e-4  # 1.5 × 10^(-4)

# Verificar el tipo
print(f"Tipo de numero_decimal: {type(numero_decimal)}")
print(f"Notación científica: {notacion_cientifica}")

# Precisión de punto flotante
resultado = 0.1 + 0.2
print(f"0.1 + 0.2 = {resultado}")
print(f"¿Es 0.1 + 0.2 == 0.3? {resultado == 0.3}")

# Usar decimal para mayor precisión cuando sea necesario
from decimal import Decimal
decimal_preciso = Decimal('0.1') + Decimal('0.2')
print(f"Con Decimal: {decimal_preciso}")
```

### 3.3 Tipo cadena (str)

Las cadenas en Python son secuencias inmutables de caracteres Unicode.

```python
# Definición de variables de cadena
nombre = "María Fernanda"
apellido = 'González'
direccion = "Av. Corrientes 1234, Buenos Aires"

# Diferentes formas de definir cadenas
cadena_simple = 'Hola mundo'
cadena_doble = "Hola mundo"
cadena_multilinea = """Esta es una cadena
que abarca múltiples
líneas"""

# Cadenas con caracteres especiales
cadena_con_comillas = "Él dijo: 'Hola'"
cadena_con_escape = "Primera línea\nSegunda línea\tTabulado"

print(f"Cadena multilínea:\n{cadena_multilinea}")
print(f"Con comillas: {cadena_con_comillas}")
print(f"Con escape: {cadena_con_escape}")

# Verificar el tipo
print(f"Tipo de nombre: {type(nombre)}")
```

### Operaciones con cadenas de caracteres

```python
# Concatenación de cadenas
nombre_completo = nombre + " " + apellido
print(f"Nombre completo: {nombre_completo}")

# Formateo de cadenas (f-strings - recomendado en Python 3.6+)
edad = 25
presentacion = f"Mi nombre es {nombre_completo} y tengo {edad} años"
print(presentacion)

# Métodos de cadenas
print(f"Longitud del nombre: {len(nombre_completo)}")
print(f"En mayúsculas: {nombre_completo.upper()}")
print(f"En minúsculas: {nombre_completo.lower()}")
print(f"Primera letra mayúscula: {nombre_completo.title()}")

# Búsqueda en cadenas
print(f"¿Contiene 'María'? {nombre_completo.find('María') != -1}")
print(f"Comienza con 'María'? {nombre_completo.startswith('María')}")
print(f"Termina con 'González'? {nombre_completo.endswith('González')}")

# División y unión de cadenas
palabras = nombre_completo.split()
print(f"Palabras: {palabras}")
reunidas = "-".join(palabras)
print(f"Reunidas con guión: {reunidas}")
```

### 3.4 Tipo booleano (bool)

El tipo booleano es una subclase del tipo entero, donde `True` equivale a 1 y `False` a 0.

```python
# Definición de variables booleanas
es_estudiante = True
tiene_trabajo = False
vive_en_capital = True

# Verificar el tipo
print(f"Tipo de es_estudiante: {type(es_estudiante)}")

# Valores booleanos como números
print(f"True como número: {int(True)}")
print(f"False como número: {int(False)}")
print(f"True + True = {True + True}")

# Resultado de operaciones de comparación
edad = 20
es_mayor_edad = edad >= 18
print(f"¿Es mayor de edad? {es_mayor_edad}")
print(f"Tipo del resultado: {type(es_mayor_edad)}")

# Valores que se evalúan como False (falsy)
valores_falsy = [False, 0, 0.0, "", [], {}, None]
print("Valores que se evalúan como False:")
for valor in valores_falsy:
    print(f"{repr(valor)}: {bool(valor)}")
```

### 3.5 Tipo None

`None` es un tipo especial que representa la ausencia de valor.

```python
# Definición de variables con None
valor_indefinido = None
resultado_pendiente = None

print(f"Tipo de None: {type(valor_indefinido)}")
print(f"¿Es None? {valor_indefinido is None}")

# None se evalúa como False en contextos booleanos
print(f"bool(None): {bool(valor_indefinido)}")

# Comparación con None (usar 'is', no '==')
if valor_indefinido is None:
    print("La variable no tiene valor asignado")
```

### 3.6 Verificación y conversión de tipos

Python proporciona funciones incorporadas para verificar y convertir entre tipos de datos.

#### Verificación de tipos

```python
# Crear variables de ejemplo
numero = 42.5
texto = "123"
logico = True
lista = [1, 2, 3]

# Verificar tipos con isinstance()
print(f"¿numero es float? {isinstance(numero, float)}")
print(f"¿texto es str? {isinstance(texto, str)}")
print(f"¿logico es bool? {isinstance(logico, bool)}")
print(f"¿lista es list? {isinstance(lista, list)}")

# Verificar múltiples tipos
print(f"¿numero es int o float? {isinstance(numero, (int, float))}")

# Función type() para tipo exacto
print(f"Tipo exacto de logico: {type(logico)}")
print(f"¿logico es exactamente bool? {type(logico) is bool}")
```

#### Conversión de tipos

```python
# Conversiones numéricas
numero_original = 42
texto_numerico = "123.45"
logico_original = True

# Convertir a cadena
numero_como_texto = str(numero_original)
print(f"Número como texto: '{numero_como_texto}' (tipo: {type(numero_como_texto)})")

# Convertir texto a número
try:
    texto_como_float = float(texto_numerico)
    texto_como_int = int(float(texto_numerico))  # Dos pasos para evitar error
    print(f"Texto como float: {texto_como_float}")
    print(f"Texto como int: {texto_como_int}")
except ValueError as e:
    print(f"Error en conversión: {e}")

# Convertir booleano a número
logico_como_int = int(logico_original)
print(f"Booleano como int: {logico_como_int}")

# Conversiones que pueden fallar
texto_invalido = "abc"
try:
    resultado = float(texto_invalido)
except ValueError:
    print(f"No se puede convertir '{texto_invalido}' a número")
```

### Valores especiales y manejo de errores

```python
# Valores especiales en operaciones numéricas
import math

infinito_positivo = float('inf')
infinito_negativo = float('-inf')
no_numero = float('nan')

print(f"Infinito positivo: {infinito_positivo}")
print(f"Infinito negativo: {infinito_negativo}")
print(f"No es número: {no_numero}")

# Verificar valores especiales
print(f"¿Es infinito? {math.isinf(infinito_positivo)}")
print(f"¿Es NaN? {math.isnan(no_numero)}")
print(f"¿Es finito? {math.isfinite(42.5)}")

# Operaciones que pueden producir estos valores
try:
    division_por_cero = 1.0 / 0.0
except ZeroDivisionError:
    print("División por cero produce error en enteros")

# En punto flotante, Python devuelve inf
resultado_inf = 1.0 / 0.0  # Esto no produce error
print(f"1.0 / 0.0 = {resultado_inf}")
```

---

## 4. Operaciones Básicas {#operaciones}

Python soporta una amplia gama de operaciones aritméticas, de comparación y lógicas. Estas operaciones forman la base para manipular datos y crear lógica de programas.

### 4.1 Operaciones Aritméticas

Python proporciona operadores aritméticos que siguen las reglas matemáticas estándar con orden de precedencia.

```python
# Definir variables para los ejemplos
a = 15
b = 4

# Operaciones básicas
suma = a + b                # 19
resta = a - b               # 11
multiplicacion = a * b      # 60
division = a / b            # 3.75 (siempre devuelve float)
division_entera = a // b    # 3 (división entera)
modulo = a % b              # 3 (resto de la división)
potencia = a ** b           # 50625 (15^4)

# Mostrar resultados
print(f"Suma: {suma}")
print(f"Resta: {resta}")
print(f"Multiplicación: {multiplicacion}")
print(f"División: {division}")
print(f"División entera: {division_entera}")
print(f"Módulo: {modulo}")
print(f"Potencia: {potencia}")
```

#### Operaciones con tipos mixtos

```python
# Python maneja automáticamente conversiones de tipos
entero = 10
flotante = 3.5

resultado_mixto = entero + flotante  # Resultado será float
print(f"Entero + Float: {resultado_mixto} (tipo: {type(resultado_mixto)})")

# Operaciones con booleanos
resultado_bool = True + 5  # True se convierte en 1
print(f"True + 5 = {resultado_bool}")

# Operaciones especiales con cadenas
cadena = "Python"
repeticion = cadena * 3
print(f"Cadena repetida: {repeticion}")

suma_cadenas = "Hola" + " " + "Mundo"
print(f"Suma de cadenas: {suma_cadenas}")
```

#### Precedencia de operadores

```python
# Python sigue las reglas matemáticas de precedencia
resultado1 = 2 + 3 * 4      # 14 (no 20)
resultado2 = (2 + 3) * 4    # 20 (con paréntesis)
resultado3 = 2 ** 3 * 4     # 32 (potencia tiene mayor precedencia)
resultado4 = 2 * 3 ** 2     # 18 (no 36)

print(f"2 + 3 * 4 = {resultado1}")
print(f"(2 + 3) * 4 = {resultado2}")
print(f"2 ** 3 * 4 = {resultado3}")
print(f"2 * 3 ** 2 = {resultado4}")

# Operadores de asignación aumentada
x = 10
x += 5    # Equivale a x = x + 5
print(f"Después de x += 5: {x}")

x *= 2    # Equivale a x = x * 2
print(f"Después de x *= 2: {x}")

x //= 3   # Equivale a x = x // 3
print(f"Después de x //= 3: {x}")
```

### 4.2 Operaciones de Comparación

Los operadores de comparación evalúan relaciones entre valores y devuelven valores booleanos.

```python
# Variables para comparación
x = 10
y = 15
z = 10

# Operadores de comparación
igual = x == z              # True: igualdad
diferente = x != y          # True: desigualdad
menor_que = x < y           # True: menor que
menor_igual = x <= z        # True: menor o igual que
mayor_que = y > x           # True: mayor que
mayor_igual = y >= x        # True: mayor o igual que

# Mostrar resultados
print(f"x == z: {igual}")
print(f"x != y: {diferente}")
print(f"x < y: {menor_que}")
print(f"x <= z: {menor_igual}")
print(f"y > x: {mayor_que}")
print(f"y >= x: {mayor_igual}")

# Comparaciones encadenadas (característica única de Python)
resultado_encadenado = 5 < x < 20  # Equivale a (5 < x) and (x < 20)
print(f"5 < x < 20: {resultado_encadenado}")

edad = 25
es_adulto_joven = 18 <= edad <= 30
print(f"¿Es adulto joven (18-30 años)? {es_adulto_joven}")
```

#### Comparaciones con diferentes tipos

```python
# Comparación entre números
entero = 5
flotante = 5.0
print(f"5 == 5.0: {entero == flotante}")  # True
print(f"5 is 5.0: {entero is flotante}")  # False (diferentes objetos)

# Comparación con cadenas
numero = 5
texto = "5"
print(f"5 == '5': {numero == texto}")     # False: tipos diferentes

# Comparación lexicográfica de cadenas
cadena1 = "apple"
cadena2 = "banana"
print(f"'apple' < 'banana': {cadena1 < cadena2}")  # True (orden alfabético)

# Comparación de listas
lista1 = [1, 2, 3]
lista2 = [1, 2, 4]
print(f"[1,2,3] < [1,2,4]: {lista1 < lista2}")   # True (lexicográfico)
```

### 4.3 Operaciones Lógicas

Los operadores lógicos trabajan con valores booleanos y siguen las reglas del álgebra de Boole.

```python
# Variables booleanas para los ejemplos
condicion1 = True
condicion2 = False
condicion3 = True

# Operadores lógicos básicos
y_logico = condicion1 and condicion2    # False
o_logico = condicion1 or condicion2     # True
negacion = not condicion1               # False

print(f"True and False = {y_logico}")
print(f"True or False = {o_logico}")
print(f"not True = {negacion}")

# Operadores lógicos con evaluación perezosa (short-circuit)
def funcion_costosa():
    print("Función costosa ejecutada")
    return True

# En 'and', si el primer operando es False, no evalúa el segundo
resultado_and = False and funcion_costosa()  # No imprime mensaje
print(f"False and función(): {resultado_and}")

# En 'or', si el primer operando es True, no evalúa el segundo
resultado_or = True or funcion_costosa()    # No imprime mensaje
print(f"True or función(): {resultado_or}")
```

#### Operaciones lógicas con valores no booleanos

```python
# Python evalúa otros tipos en contexto booleano
# Valores "falsy": False, 0, 0.0, "", [], {}, None
# Todos los demás son "truthy"

valores_para_evaluar = [0, 1, "", "texto", [], [1], {}, {"a": 1}, None]

print("Evaluación booleana de diferentes valores:")
for valor in valores_para_evaluar:
    print(f"{repr(valor):12} -> {bool(valor)}")

# Uso práctico en condiciones
nombre = input("Ingrese su nombre (presione Enter para omitir): ") if False else ""
if nombre:  # Se evalúa como True si nombre no está vacío
    print(f"Hola, {nombre}")
else:
    print("No se ingresó nombre")

# Operadores lógicos devuelven el objeto, no True/False
resultado1 = "texto" and 42        # Devuelve 42
resultado2 = "" or "por defecto"   # Devuelve "por defecto"
resultado3 = None or [] or "valor" # Devuelve "valor"

print(f"'texto' and 42: {resultado1}")
print(f"'' or 'por defecto': {resultado2}")
print(f"None or [] or 'valor': {resultado3}")
```

#### Combinación de operaciones complejas

```python
# Ejemplo práctico: validación de credenciales
usuario = "admin"
contraseña = "123456"
es_admin = True
intentos_fallidos = 2

# Condición compleja para autorizar acceso
acceso_autorizado = (
    usuario == "admin" and 
    len(contraseña) >= 6 and 
    es_admin and 
    intentos_fallidos < 3
)

print(f"¿Acceso autorizado? {acceso_autorizado}")

# Uso de paréntesis para claridad
condicion_edad = (edad >= 18) and (edad <= 65)
condicion_experiencia = (experiencia >= 2) or (titulacion == "universitaria")
elegible = condicion_edad and condicion_experiencia

# Operadores de pertenencia
numeros_pares = [2, 4, 6, 8, 10]
numero_a_verificar = 6

es_par = numero_a_verificar in numeros_pares
no_es_impar = numero_a_verificar not in [1, 3, 5, 7, 9]

print(f"¿6 está en números pares? {es_par}")
print(f"¿6 no está en números impares? {no_es_impar}")
```

### 4.4 Operaciones con operadores especiales

```python
# Operadores de identidad (is, is not)
lista_a = [1, 2, 3]
lista_b = [1, 2, 3]
lista_c = lista_a

print(f"lista_a == lista_b: {lista_a == lista_b}")  # True (mismo contenido)
print(f"lista_a is lista_b: {lista_a is lista_b}")  # False (objetos diferentes)
print(f"lista_a is lista_c: {lista_a is lista_c}")  # True (mismo objeto)

# Casos especiales con números pequeños y cadenas
num1 = 5
num2 = 5
print(f"5 is 5: {num1 is num2}")  # True (optimización de Python)

num3 = 1000
num4 = 1000
print(f"1000 is 1000: {num3 is num4}")  # Puede ser False

# Operador walrus (:=) - Python 3.8+
# Permite asignación dentro de expresiones
numeros = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
cuadrados_pares = [y for x in numeros if (y := x**2) % 2 == 0]
print(f"Cuadrados pares: {cuadrados_pares}")

# Operadores bitwise (para números enteros)
a_bin = 12  # 1100 en binario
b_bin = 7   # 0111 en binario

print(f"AND bitwise: {a_bin & b_bin}")    # 4 (0100)
print(f"OR bitwise: {a_bin | b_bin}")     # 15 (1111)
print(f"XOR bitwise: {a_bin ^ b_bin}")    # 11 (1011)
print(f"NOT bitwise: {~a_bin}")           # -13
print(f"Desplazamiento izquierda: {a_bin << 2}")  # 48
print(f"Desplazamiento derecha: {a_bin >> 2}")    # 3
```

---

## 5. Estructuras de Datos {#estructuras}

Python proporciona varias estructuras de datos incorporadas que permiten organizar y manipular información de manera eficiente. Cada estructura tiene características específicas que la hacen adecuada para diferentes propósitos.

### 5.1 Listas

Las listas son secuencias ordenadas y mutables que pueden contener elementos de cualquier tipo.

#### Creación y características básicas

```python
# Crear listas de diferentes formas
edades = [25, 30, 28, 35, 22]
nombres = ["Ana", "Luis", "María", "Carlos", "Elena"]
mixta = [1, "texto", 3.14, True, None]
lista_vacia = []

print(f"Lista de edades: {edades}")
print(f"Lista de nombres: {nombres}")
print(f"Lista mixta: {mixta}")
print(f"Tipo de lista: {type(edades)}")

# Propiedades básicas
print(f"Longitud de edades: {len(edades)}")
print(f"¿Lista vacía? {len(lista_vacia) == 0}")

# Las listas son mutables
edades[0] = 26  # Modificar el primer elemento
print(f"Edades modificadas: {edades}")
```

#### Operaciones con listas

```python
# Agregar elementos
frutas = ["manzana", "banana"]
frutas.append("naranja")          # Agregar al final
print(f"Después de append: {frutas}")

frutas.insert(1, "pera")          # Insertar en posición específica
print(f"Después de insert: {frutas}")

frutas.extend(["uva", "kiwi"])    # Agregar múltiples elementos
print(f"Después de extend: {frutas}")

# Eliminar elementos
frutas.remove("banana")           # Eliminar por valor
print(f"Después de remove: {frutas}")

fruta_eliminada = frutas.pop()    # Eliminar y retornar el último
print(f"Fruta eliminada: {fruta_eliminada}")
print(f"Lista actual: {frutas}")

fruta_posicion = frutas.pop(1)    # Eliminar por posición
print(f"Eliminada en posición 1: {fruta_posicion}")
print(f"Lista final: {frutas}")
```

#### Métodos avanzados de listas

```python
# Lista de números para ejemplos
numeros = [3, 1, 4, 1, 5, 9, 2, 6, 5]
print(f"Lista original: {numeros}")

# Métodos de búsqueda y conteo
posicion_primer_5 = numeros.index(5)      # Primera posición del 5
cantidad_1s = numeros.count(1)            # Cantidad de veces que aparece 1

print(f"Primera posición del 5: {posicion_primer_5}")
print(f"Cantidad de 1s: {cantidad_1s}")

# Ordenamiento
numeros_copia = numeros.copy()        # Crear copia
numeros_copia.sort()                  # Ordenar en su lugar
print(f"Lista ordenada (in-place): {numeros_copia}")

numeros_ordenados = sorted(numeros)   # Crear nueva lista ordenada
print(f"Nueva lista ordenada: {numeros_ordenados}")
print(f"Lista original sin cambios: {numeros}")

# Ordenamiento descendente
numeros_desc = sorted(numeros, reverse=True)
print(f"Ordenamiento descendente: {numeros_desc}")

# Invertir lista
numeros_invertidos = numeros[::-1]    # Slicing para invertir
numeros_copia.reverse()               # Invertir en su lugar
print(f"Invertida con slicing: {numeros_invertidos}")
print(f"Invertida in-place: {numeros_copia}")
```

#### Comprensiones de listas

```python
# Comprensiones de listas: forma concisa de crear listas
numeros = range(1, 11)  # 1 al 10

# Cuadrados de números
cuadrados = [x**2 for x in numeros]
print(f"Cuadrados: {cuadrados}")

# Con condición: solo números pares
pares = [x for x in numeros if x % 2 == 0]
print(f"Números pares: {pares}")

# Transformación con condición
resultado = [x**2 if x % 2 == 0 else x**3 for x in numeros]
print(f"Cuadrados si es par, cubos si es impar: {resultado}")

# Comprensión anidada: matriz
matriz = [[i*j for j in range(1, 4)] for i in range(1, 4)]
print("Matriz 3x3:")
for fila in matriz:
    print(fila)

# Filtrar y transformar cadenas
palabras = ["python", "java", "javascript", "go", "rust"]
palabras_largas = [palabra.upper() for palabra in palabras if len(palabra) > 4]
print(f"Palabras largas en mayúsculas: {palabras_largas}")
```

### 5.2 Tuplas

Las tuplas son secuencias ordenadas e inmutables, ideales para datos que no deben cambiar.

#### Creación y características

```python
# Crear tuplas
coordenadas = (10, 20)
datos_persona = ("Ana", 25, "Ingeniera")
tupla_un_elemento = (42,)  # Coma necesaria para tupla de un elemento
tupla_sin_parentesis = 1, 2, 3  # Los paréntesis son opcionales

print(f"Coordenadas: {coordenadas}")
print(f"Datos persona: {datos_persona}")
print(f"Tupla un elemento: {tupla_un_elemento}")
print(f"Tipo: {type(coordenadas)}")

# Las tuplas son inmutables
try:
    coordenadas[0] = 15  # Esto causará error
except TypeError as e:
    print(f"Error al modificar tupla: {e}")

# Desempaquetado de tuplas
x, y = coordenadas
nombre, edad, profesion = datos_persona
print(f"Coordenada x: {x}, y: {y}")
print(f"Nombre: {nombre}, Edad: {edad}, Profesión: {profesion}")
```

#### Operaciones con tuplas

```python
# Operaciones básicas
tupla1 = (1, 2, 3)
tupla2 = (4, 5, 6)

# Concatenación
tupla_concatenada = tupla1 + tupla2
print(f"Concatenación: {tupla_concatenada}")

# Repetición
tupla_repetida = tupla1 * 3
print(f"Repetición: {tupla_repetida}")

# Métodos de tupla
numeros_tupla = (1, 2, 3, 2, 4, 2, 5)
print(f"Posición del primer 2: {numeros_tupla.index(2)}")
print(f"Cantidad de 2s: {numeros_tupla.count(2)}")

# Conversión entre listas y tuplas
lista_numeros = [1, 2, 3, 4, 5]
tupla_desde_lista = tuple(lista_numeros)
lista_desde_tupla = list(tupla_concatenada)

print(f"Lista a tupla: {tupla_desde_lista}")
print(f"Tupla a lista: {lista_desde_tupla}")

# Tuplas anidadas
matriz_tuplas = ((1, 2, 3), (4, 5, 6), (7, 8, 9))
print(f"Matriz como tuplas: {matriz_tuplas}")
print(f"Elemento [1][2]: {matriz_tuplas[1][2]}")
```

### 5.3 Diccionarios

Los diccionarios son colecciones de pares clave-valor, no ordenadas (hasta Python 3.6) y mutables.

#### Creación y operaciones básicas

```python
# Crear diccionarios
estudiante = {
    "nombre": "Ana García",
    "edad": 22,
    "carrera": "Ingeniería",
    "promedio": 8.5,
    "activo": True
}

# Diccionario vacío
diccionario_vacio = {}
otro_vacio = dict()

print(f"Estudiante: {estudiante}")
print(f"Tipo: {type(estudiante)}")

# Acceso a valores
print(f"Nombre: {estudiante['nombre']}")
print(f"Edad: {estudiante.get('edad')}")
print(f"Teléfono: {estudiante.get('telefono', 'No disponible')}")  # Valor por defecto

# Modificar y agregar elementos
estudiante["edad"] = 23           # Modificar existente
estudiante["telefono"] = "123456" # Agregar nuevo
print(f"Estudiante actualizado: {estudiante}")

# Eliminar elementos
del estudiante["telefono"]        # Eliminar con del
promedio_eliminado = estudiante.pop("promedio", None)  # Eliminar y obtener valor
print(f"Promedio eliminado: {promedio_eliminado}")
print(f"Estudiante sin promedio: {estudiante}")
```

#### Métodos de diccionarios

```python
# Métodos para obtener claves, valores y pares
calificaciones = {"matemática": 9, "física": 8, "química": 7, "biología": 9}

# Obtener vistas de claves, valores y elementos
claves = calificaciones.keys()
valores = calificaciones.values()
elementos = calificaciones.items()

print(f"Claves: {list(claves)}")
print(f"Valores: {list(valores)}")
print(f"Elementos: {list(elementos)}")

# Iterar sobre diccionarios
print("\nCalificaciones por materia:")
for materia, nota in calificaciones.items():
    print(f"{materia.title()}: {nota}")

# Estadísticas básicas
promedio = sum(calificaciones.values()) / len(calificaciones)
materia_mejor = max(calificaciones, key=calificaciones.get)
nota_mas_alta = max(calificaciones.values())

print(f"\nPromedio: {promedio:.2f}")
print(f"Mejor materia: {materia_mejor} ({calificaciones[materia_mejor]})")
print(f"Nota más alta: {nota_mas_alta}")
```

#### Diccionarios anidados y operaciones avanzadas

```python
# Diccionario anidado: base de datos de estudiantes
estudiantes_db = {
    "001": {
        "nombre": "Ana García",
        "edad": 22,
        "calificaciones": {"matemática": 9, "física": 8, "química": 7}
    },
    "002": {
        "nombre": "Luis Pérez",
        "edad": 21,
        "calificaciones": {"matemática": 7, "física": 9, "química": 8}
    },
    "003": {
        "nombre": "María López",
        "edad": 23,
        "calificaciones": {"matemática": 8, "física": 7, "química": 9}
    }
}

# Acceso a datos anidados
print(f"Nombre del estudiante 002: {estudiantes_db['002']['nombre']}")
print(f"Nota en física del estudiante 001: {estudiantes_db['001']['calificaciones']['física']}")

# Calcular promedio por estudiante
for id_estudiante, datos in estudiantes_db.items():
    califs = datos["calificaciones"]
    promedio = sum(califs.values()) / len(califs)
    print(f"{datos['nombre']}: {promedio:.2f}")

# Comprensión de diccionarios
promedios = {
    datos["nombre"]: sum(datos["calificaciones"].values()) / len(datos["calificaciones"])
    for datos in estudiantes_db.values()
}
print(f"\nPromedios por estudiante: {promedios}")

# Filtrar estudiantes con promedio alto
estudiantes_destacados = {
    nombre: promedio for nombre, promedio in promedios.items() 
    if promedio >= 8.0
}
print(f"Estudiantes destacados: {estudiantes_destacados}")
```

### 5.4 Conjuntos (Sets)

Los conjuntos son colecciones no ordenadas de elementos únicos, útiles para operaciones matemáticas de conjuntos.

#### Creación y operaciones básicas

```python
# Crear conjuntos
numeros_pares = {2, 4, 6, 8, 10}
numeros_impares = {1, 3, 5, 7, 9}
letras = set("python")  # Crear desde cadena
conjunto_vacio = set()  # No se puede usar {} para conjunto vacío

print(f"Números pares: {numeros_pares}")
print(f"Letras en 'python': {letras}")
print(f"Tipo: {type(numeros_pares)}")

# Los conjuntos eliminan duplicados automáticamente
con_duplicados = {1, 2, 2, 3, 3, 3, 4}
print(f"Conjunto sin duplicados: {con_duplicados}")

# Agregar y eliminar elementos
frutas = {"manzana", "banana", "naranja"}
frutas.add("pera")
frutas.update(["uva", "kiwi"])  # Agregar múltiples
print(f"Frutas después de agregar: {frutas}")

frutas.remove("banana")    # Error si no existe
frutas.discard("melón")    # No error si no existe
fruta_eliminada = frutas.pop()  # Eliminar elemento arbitrario
print(f"Frutas después de eliminar: {frutas}")
print(f"Fruta eliminada: {fruta_eliminada}")
```

#### Operaciones de conjuntos

```python
# Conjuntos para operaciones matemáticas
conjunto_a = {1, 2, 3, 4, 5}
conjunto_b = {4, 5, 6, 7, 8}
conjunto_c = {1, 2, 3}

# Unión
union = conjunto_a | conjunto_b
union_metodo = conjunto_a.union(conjunto_b)
print(f"Unión A ∪ B: {union}")

# Intersección
interseccion = conjunto_a & conjunto_b
interseccion_metodo = conjunto_a.intersection(conjunto_b)
print(f"Intersección A ∩ B: {interseccion}")

# Diferencia
diferencia = conjunto_a - conjunto_b
diferencia_metodo = conjunto_a.difference(conjunto_b)
print(f"Diferencia A - B: {diferencia}")

# Diferencia simétrica
diff_simetrica = conjunto_a ^ conjunto_b
diff_simetrica_metodo = conjunto_a.symmetric_difference(conjunto_b)
print(f"Diferencia simétrica A △ B: {diff_simetrica}")

# Relaciones entre conjuntos
print(f"¿C es subconjunto de A? {conjunto_c.issubset(conjunto_a)}")
print(f"¿A es superconjunto de C? {conjunto_a.issuperset(conjunto_c)}")
print(f"¿A y B son disjuntos? {conjunto_a.isdisjoint(conjunto_b)}")
```

#### Aplicaciones prácticas de conjuntos

```python
# Eliminar duplicados de una lista manteniendo eficiencia
lista_con_duplicados = [1, 2, 2, 3, 3, 3, 4, 4, 5]
sin_duplicados = list(set(lista_con_duplicados))
print(f"Lista sin duplicados: {sin_duplicados}")

# Encontrar elementos únicos en múltiples listas
lista1 = ["python", "java", "javascript", "go"]
lista2 = ["python", "c++", "java", "rust"]
lista3 = ["javascript", "typescript", "python"]

# Elementos en común
lenguajes_comunes = set(lista1) & set(lista2) & set(lista3)
print(f"Lenguajes en las tres listas: {lenguajes_comunes}")

# Todos los lenguajes únicos
todos_lenguajes = set(lista1) | set(lista2) | set(lista3)
print(f"Todos los lenguajes: {todos_lenguajes}")

# Lenguajes solo en la primera lista
solo_lista1 = set(lista1) - set(lista2) - set(lista3)
print(f"Solo en lista 1: {solo_lista1}")

# Validación de membresía (más eficiente que listas para búsquedas)
lenguajes_populares = {"python", "javascript", "java", "c++", "go"}
lenguaje_consulta = "python"

if lenguaje_consulta in lenguajes_populares:  # O(1) en promedio
    print(f"{lenguaje_consulta} es un lenguaje popular")
```

---

## 6. Funciones {#funciones}

Las funciones son bloques de código reutilizable que encapsulan lógica específica. Python proporciona numerosas funciones incorporadas y permite definir funciones personalizadas.

### 6.1 Funciones incorporadas

Python incluye más de 60 funciones incorporadas que cubren operaciones comunes.

#### Funciones matemáticas básicas

```python
# Funciones matemáticas incorporadas
numeros = [1, -3, 4.5, -2.7, 6, 0, 8.2]

# Funciones básicas
print(f"Suma: {sum(numeros)}")
print(f"Máximo: {max(numeros)}")
print(f"Mínimo: {min(numeros)}")
print(f"Valor absoluto de -3: {abs(-3)}")
print(f"Longitud de lista: {len(numeros)}")

# Redondeo
numero_decimal = 3.14159
print(f"Redondeado a 2 decimales: {round(numero_decimal, 2)}")
print(f"Redondeado sin decimales: {round(numero_decimal)}")

# Potencia
print(f"2 elevado a 8: {pow(2, 8)}")
print(f"2^8 mod 5: {pow(2, 8, 5)}")  # Potencia módulo

# Funciones para iterar
print(f"Rango 0-4: {list(range(5))}")
print(f"Rango 2-8 paso 2: {list(range(2, 9, 2))}")
print(f"Enumerar lista: {list(enumerate(['a', 'b', 'c']))}")
```

#### Funciones de conversión de tipos

```python
# Conversiones de tipos
datos_mixtos = [1, "2", 3.0, "4.5", True]

print("Conversiones de tipos:")
for dato in datos_mixtos:
    print(f"Original: {dato} ({type(dato).__name__})")
    try:
        print(f"  int(): {int(float(dato))}")
        print(f"  float(): {float(dato)}")
        print(f"  str(): {str(dato)}")
        print(f"  bool(): {bool(dato)}")
    except ValueError:
        print(f"  No se puede convertir a número")
    print()

# Conversiones a colecciones
cadena = "python"
numeros = (1, 2, 3, 4, 5)

print(f"Cadena a lista: {list(cadena)}")
print(f"Tupla a lista: {list(numeros)}")
print(f"Lista a tupla: {tuple(list(cadena))}")
print(f"Lista a conjunto: {set(list(cadena))}")
print(f"Pares a diccionario: {dict([('a', 1), ('b', 2)])}")
```

#### Funciones de filtrado y mapeo

```python
# Función filter()
numeros = range(1, 11)
pares = list(filter(lambda x: x % 2 == 0, numeros))
print(f"Números pares: {pares}")

# Función map()
cuadrados = list(map(lambda x: x**2, numeros))
print(f"Cuadrados: {cuadrados}")

# Función zip()
nombres = ["Ana", "Luis", "María"]
edades = [25, 30, 28]
profesiones = ["Médica", "Ingeniero", "Abogada"]

personas = list(zip(nombres, edades, profesiones))
print(f"Personas combinadas: {personas}")

# Desempaquetar con zip
datos_transpuestos = list(zip(*personas))
print(f"Datos transpuestos: {datos_transpuestos}")

# Función sorted()
palabras = ["python", "java", "go", "javascript"]
ordenadas_longitud = sorted(palabras, key=len)
ordenadas_reversa = sorted(palabras, reverse=True)

print(f"Ordenadas por longitud: {ordenadas_longitud}")
print(f"Ordenadas reversa: {ordenadas_reversa}")
```

#### Funciones de introspección

```python
# Funciones para examinar objetos
lista_ejemplo = [1, 2, 3]

print(f"Tipo de objeto: {type(lista_ejemplo)}")
print(f"ID en memoria: {id(lista_ejemplo)}")
print(f"¿Es instancia de list? {isinstance(lista_ejemplo, list)}")
print(f"¿Tiene atributo 'append'? {hasattr(lista_ejemplo, 'append')}")

# Función dir() para ver atributos y métodos
metodos_lista = [m for m in dir(lista_ejemplo) if not m.startswith('_')]
print(f"Métodos públicos de lista: {metodos_lista[:5]}...")

# Función vars() para variables de instancia
class Persona:
    def __init__(self, nombre, edad):
        self.nombre = nombre
        self.edad = edad

persona = Persona("Ana", 25)
print(f"Variables de instancia: {vars(persona)}")

# Función callable() para verificar si es llamable
print(f"¿Lista es llamable? {callable(lista_ejemplo)}")
print(f"¿len es llamable? {callable(len)}")
print(f"¿print es llamable? {callable(print)}")
```

### 6.2 Definición de funciones personalizadas

#### Sintaxis básica y parámetros

```python
# Función simple sin parámetros
def saludar():
    """Función que imprime un saludo."""
    print("¡Hola, mundo!")
    
# Llamar la función
saludar()

# Función con parámetros
def saludar_persona(nombre, apellido):
    """Saluda a una persona específica."""
    mensaje = f"¡Hola, {nombre} {apellido}!"
    return mensaje

# Usar la función
saludo = saludar_persona("Ana", "García")
print(saludo)

# Función con parámetros por defecto
def presentar_persona(nombre, edad=25, ciudad="Buenos Aires"):
    """Presenta una persona con información opcional."""
    presentacion = f"Me llamo {nombre}, tengo {edad} años y vivo en {ciudad}"
    return presentacion

# Diferentes formas de llamar la función
print(presentar_persona("Luis"))
print(presentar_persona("María", 30))
print(presentar_persona("Carlos", 28, "Córdoba"))
print(presentar_persona("Elena", ciudad="Rosario"))  # Parámetro nombrado
```

#### Tipos de parámetros

```python
# Función con *args (argumentos variables posicionales)
def sumar_numeros(*numeros):
    """Suma una cantidad variable de números."""
    total = 0
    for numero in numeros:
        total += numero
    return total

print(f"Suma de 1,2,3: {sumar_numeros(1, 2, 3)}")
print(f"Suma de 1,2,3,4,5: {sumar_numeros(1, 2, 3, 4, 5)}")

# Función con **kwargs (argumentos variables nombrados)
def crear_perfil(**datos):
    """Crea un perfil con datos variables."""
    perfil = {}
    for clave, valor in datos.items():
        perfil[clave] = valor
    return perfil

perfil1 = crear_perfil(nombre="Ana", edad=25, profesion="Médica")
perfil2 = crear_perfil(nombre="Luis", ciudad="Córdoba", hobby="fotografía")

print(f"Perfil 1: {perfil1}")
print(f"Perfil 2: {perfil2}")

# Función con todos los tipos de parámetros
def funcion_completa(obligatorio, opcional="valor", *args, **kwargs):
    """Demuestra todos los tipos de parámetros."""
    print(f"Obligatorio: {obligatorio}")
    print(f"Opcional: {opcional}")
    print(f"Args: {args}")
    print(f"Kwargs: {kwargs}")

funcion_completa("requerido", "cambiado", 1, 2, 3, extra="dato", otro=42)
```

#### Funciones como objetos de primera clase

```python
# Las funciones son objetos en Python
def multiplicar(x, y):
    """Multiplica dos números."""
    return x * y

def dividir(x, y):
    """Divide dos números."""
    if y != 0:
        return x / y
    else:
        return "Error: División por cero"

# Asignar función a variable
operacion = multiplicar
resultado = operacion(5, 3)
print(f"5 * 3 = {resultado}")

# Lista de funciones
operaciones = [multiplicar, dividir]
for op in operaciones:
    print(f"{op.__name__}(10, 2) = {op(10, 2)}")

# Función que devuelve otra función
def crear_multiplicador(factor):
    """Crea una función que multiplica por un factor específico."""
    def multiplicador(x):
        return x * factor
    return multiplicador

# Crear multiplicadores específicos
por_dos = crear_multiplicador(2)
por_diez = crear_multiplicador(10)

print(f"5 * 2 = {por_dos(5)}")
print(f"5 * 10 = {por_diez(5)}")
```

#### Funciones lambda (anónimas)

```python
# Función lambda básica
cuadrado = lambda x: x**2
print(f"Cuadrado de 5: {cuadrado(5)}")

# Lambda con múltiples parámetros
suma = lambda x, y: x + y
print(f"Suma de 3 y 4: {suma(3, 4)}")

# Uso común con funciones de orden superior
numeros = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# Filtrar números pares
pares = list(filter(lambda x: x % 2 == 0, numeros))
print(f"Números pares: {pares}")

# Mapear a cuadrados
cuadrados = list(map(lambda x: x**2, numeros))
print(f"Cuadrados: {cuadrados}")

# Ordenar lista de tuplas por segundo elemento
estudiantes = [("Ana", 8.5), ("Luis", 7.2), ("María", 9.1)]
ordenados = sorted(estudiantes, key=lambda tupla: tupla[1])
print(f"Estudiantes ordenados por nota: {ordenados}")

# Lambda en comprensiones (menos común)
resultado = [(lambda x: x**2)(x) for x in range(5)]
print(f"Cuadrados con lambda: {resultado}")
```

### 6.3 Documentación y buenas prácticas

#### Docstrings y anotaciones de tipo

```python
# Función con docstring completo
def calcular_estadisticas(numeros: list) -> dict:
    """
    Calcula estadísticas básicas de una lista de números.
    
    Args:
        numeros (list): Lista de números para analizar.
        
    Returns:
        dict: Diccionario con estadísticas (media, mediana, min, max).
        
    Raises:
        ValueError: Si la lista está vacía.
        TypeError: Si algún elemento no es numérico.
        
    Example:
        >>> calcular_estadisticas([1, 2, 3, 4, 5])
        {'media': 3.0, 'mediana': 3, 'minimo': 1, 'maximo': 5}
    """
    if not numeros:
        raise ValueError("La lista no puede estar vacía")
    
    # Verificar que todos los elementos sean numéricos
    for num in numeros:
        if not isinstance(num, (int, float)):
            raise TypeError(f"Elemento no numérico: {num}")
    
    numeros_ordenados = sorted(numeros)
    n = len(numeros)
    
    # Calcular estadísticas
    media = sum(numeros) / n
    mediana = (numeros_ordenados[n//2] if n % 2 == 1 
              else (numeros_ordenados[n//2-1] + numeros_ordenados[n//2]) / 2)
    minimo = min(numeros)
    maximo = max(numeros)
    
    return {
        'media': media,
        'mediana': mediana,
        'minimo': minimo,
        'maximo': maximo
    }

# Usar la función
datos = [2, 4, 6, 8, 10, 12, 14]
estadisticas = calcular_estadisticas(datos)
print(f"Estadísticas: {estadisticas}")

# Acceder a la documentación
print(f"Documentación:\n{calcular_estadisticas.__doc__}")
```

#### Decoradores básicos

```python
# Decorador simple para medir tiempo de ejecución
import time
import functools

def medir_tiempo(func):
    """Decorador que mide el tiempo de ejecución de una función."""
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        inicio = time.time()
        resultado = func(*args, **kwargs)
        fin = time.time()
        print(f"{func.__name__} ejecutada en {fin - inicio:.4f} segundos")
        return resultado
    return wrapper

# Aplicar decorador
@medir_tiempo
def operacion_lenta():
    """Simula una operación que toma tiempo."""
    time.sleep(0.1)  # Simular trabajo
    return sum(range(100000))

resultado = operacion_lenta()
print(f"Resultado: {resultado}")

# Decorador con parámetros
def validar_tipos(*tipos):
    """Decorador que valida tipos de argumentos."""
    def decorador(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for i, (arg, tipo_esperado) in enumerate(zip(args, tipos)):
                if not isinstance(arg, tipo_esperado):
                    raise TypeError(f"Argumento {i+1} debe ser {tipo_esperado.__name__}")
            return func(*args, **kwargs)
        return wrapper
    return decorador

@validar_tipos(int, int)
def dividir_enteros(a, b):
    """Divide dos enteros."""
    return a / b

# Uso del decorador con validación
try:
    print(f"División: {dividir_enteros(10, 2)}")
    print(f"División con error: {dividir_enteros(10.0, 2)}")  # Error de tipo
except TypeError as e:
    print(f"Error de validación: {e}")
```

#### Manejo de errores en funciones

```python
# Función con manejo completo de errores
def leer_archivo_numeros(nombre_archivo: str) -> list:
    """
    Lee números de un archivo, uno por línea.
    
    Args:
        nombre_archivo (str): Nombre del archivo a leer.
        
    Returns:
        list: Lista de números leídos del archivo.
        
    Raises:
        FileNotFoundError: Si el archivo no existe.
        ValueError: Si alguna línea no contiene un número válido.
    """
    numeros = []
    
    try:
        with open(nombre_archivo, 'r') as archivo:
            for numero_linea, linea in enumerate(archivo, 1):
                linea = linea.strip()
                if linea:  # Ignorar líneas vacías
                    try:
                        numero = float(linea)
                        numeros.append(numero)
                    except ValueError:
                        raise ValueError(f"Línea {numero_linea}: '{linea}' no es un número válido")
                        
    except FileNotFoundError:
        raise FileNotFoundError(f"El archivo '{nombre_archivo}' no existe")
    
    return numeros

# Función que usa manejo de errores
def procesar_archivo_numeros(nombre_archivo: str) -> dict:
    """Procesa un archivo de números y devuelve estadísticas."""
    try:
        numeros = leer_archivo_numeros(nombre_archivo)
        if numeros:
            estadisticas = calcular_estadisticas(numeros)
            estadisticas['cantidad'] = len(numeros)
            return estadisticas
        else:
            return {'error': 'El archivo está vacío'}
            
    except FileNotFoundError as e:
        return {'error': f'Archivo no encontrado: {e}'}
    except ValueError as e:
        return {'error': f'Error de formato: {e}'}
    except Exception as e:
        return {'error': f'Error inesperado: {e}'}

# Simular uso (sin archivo real)
resultado = procesar_archivo_numeros("archivo_inexistente.txt")
print(f"Resultado del procesamiento: {resultado}")
```

---

## 7. Indexación y Subsetting {#indexacion}

La indexación en Python permite acceder a elementos específicos de secuencias y colecciones. Python utiliza indexación basada en 0 (el primer elemento tiene índice 0) y soporta indexación negativa.

### 7.1 Indexación básica de secuencias

#### Indexación de listas y tuplas

```python
# Lista y tupla de ejemplo
ciudades = ["Buenos Aires", "Córdoba", "Rosario", "Mendoza", "La Plata"]
coordenadas = (34.6037, -58.3816, 100)  # lat, lng, altura

# Indexación positiva (desde el inicio)
print(f"Primera ciudad: {ciudades[0]}")
print(f"Tercera ciudad: {ciudades[2]}")
print(f"Latitud: {coordenadas[0]}")

# Indexación negativa (desde el final)
print(f"Última ciudad: {ciudades[-1]}")
print(f"Penúltima ciudad: {ciudades[-2]}")
print(f"Altura: {coordenadas[-1]}")

# Verificar índices válidos
longitud = len(ciudades)
print(f"Longitud de la lista: {longitud}")
print(f"Índices válidos: 0 a {longitud-1} o -{longitud} a -1")

# Manejo de errores en indexación
try:
    ciudad_inexistente = ciudades[10]
except IndexError as e:
    print(f"Error de índice: {e}")
```

#### Slicing (rebanado) de secuencias

```python
# Sintaxis de slicing: secuencia[inicio:fin:paso]
numeros = list(range(0, 20))  # [0, 1, 2, ..., 19]
print(f"Lista completa: {numeros}")

# Slicing básico
primeros_cinco = numeros[0:5]    # Elementos 0 a 4
print(f"Primeros cinco: {primeros_cinco}")

ultimos_cinco = numeros[-5:]     # Últimos cinco elementos
print(f"Últimos cinco: {ultimos_cinco}")

sin_primeros_dos = numeros[2:]   # Desde el índice 2 hasta el final
print(f"Sin primeros dos: {sin_primeros_dos[:8]}...")  # Mostrar solo algunos

sin_ultimos_tres = numeros[:-3]  # Desde el inicio hasta 3 antes del final
print(f"Sin últimos tres: {sin_ultimos_tres[-5:]}")

# Slicing con paso
pares = numeros[::2]             # Elementos en posiciones pares
print(f"Posiciones pares: {pares[:10]}")

impares = numeros[1::2]          # Elementos en posiciones impares
print(f"Posiciones impares: {impares[:10]}")

cada_tres = numeros[::3]         # Cada tercer elemento
print(f"Cada tres elementos: {cada_tres}")

# Slicing inverso
invertido = numeros[::-1]        # Toda la lista invertida
print(f"Lista invertida: {invertido[:10]}...")

cada_dos_inverso = numeros[::-2] # Cada dos elementos, pero invertido
print(f"Cada dos, invertido: {cada_dos_inverso[:10]}")
```

#### Slicing bidimensional (listas de listas)

```python
# Matriz como lista de listas
matriz = [
    [1, 2, 3, 4],
    [5, 6, 7, 8],
    [9, 10, 11, 12],
    [13, 14, 15, 16]
]

print("Matriz original:")
for fila in matriz:
    print(fila)

# Acceso a elementos específicos
print(f"\nElemento [1][2]: {matriz[1][2]}")
print(f"Elemento [-1][-1]: {matriz[-1][-1]}")

# Extraer filas completas
primera_fila = matriz[0]
ultima_fila = matriz[-1]
print(f"\nPrimera fila: {primera_fila}")
print(f"Última fila: {ultima_fila}")

# Extraer columnas (más complejo en listas)
primera_columna = [fila[0] for fila in matriz]
segunda_columna = [fila[1] for fila in matriz]
print(f"Primera columna: {primera_columna}")
print(f"Segunda columna: {segunda_columna}")

# Submatriz
submatriz = [fila[1:3] for fila in matriz[0:2]]
print(f"Submatriz 2x2: {submatriz}")

# Diagonal principal
diagonal = [matriz[i][i] for i in range(len(matriz))]
print(f"Diagonal principal: {diagonal}")
```

### 7.2 Indexación de cadenas

```python
# Las cadenas son secuencias inmutables
texto = "Programación en Python"
print(f"Texto: '{texto}'")
print(f"Longitud: {len(texto)}")

# Indexación básica
print(f"Primer carácter: '{texto[0]}'")
print(f"Último carácter: '{texto[-1]}'")
print(f"Carácter en posición 5: '{texto[5]}'")

# Slicing de cadenas
palabra1 = texto[0:12]       # "Programación"
palabra2 = texto[16:22]      # "Python"
print(f"Primera palabra: '{palabra1}'")
print(f"Segunda palabra: '{palabra2}'")

# Extraer cada segunda letra
cada_segunda = texto[::2]
print(f"Cada segunda letra: '{cada_segunda}'")

# Invertir cadena
texto_invertido = texto[::-1]
print(f"Texto invertido: '{texto_invertido}'")

# Buscar subcadenas
posicion_python = texto.find("Python")
if posicion_python != -1:
    print(f"'Python' encontrado en posición: {posicion_python}")
    python_extraido = texto[posicion_python:posicion_python+6]
    print(f"Extraído: '{python_extraido}'")

# Las cadenas son inmutables
try:
    texto[0] = 'p'  # Esto causará error
except TypeError as e:
    print(f"Error: {e}")
```

### 7.3 Indexación de diccionarios

#### Acceso básico y métodos

```python
# Diccionario de estudiantes
estudiantes = {
    "001": {"nombre": "Ana García", "edad": 22, "carrera": "Ingeniería"},
    "002": {"nombre": "Luis Pérez", "edad": 21, "carrera": "Medicina"},
    "003": {"nombre": "María López", "edad": 23, "carrera": "Derecho"}
}

# Acceso por clave
print(f"Estudiante 001: {estudiantes['001']}")
print(f"Nombre del estudiante 002: {estudiantes['002']['nombre']}")

# Acceso seguro con get()
estudiante_004 = estudiantes.get("004", "No encontrado")
print(f"Estudiante 004: {estudiante_004}")

# Acceso con valor por defecto para claves anidadas
def obtener_valor_anidado(diccionario, *claves, default=None):
    """Obtiene valor de diccionario anidado de forma segura."""
    for clave in claves:
        if isinstance(diccionario, dict) and clave in diccionario:
            diccionario = diccionario[clave]
        else:
            return default
    return diccionario

# Usar función de acceso seguro
edad_004 = obtener_valor_anidado(estudiantes, "004", "edad", default="No disponible")
edad_002 = obtener_valor_anidado(estudiantes, "002", "edad", default="No disponible")
print(f"Edad estudiante 004: {edad_004}")
print(f"Edad estudiante 002: {edad_002}")
```

#### Iteración e indexación de diccionarios

```python
# Iterar sobre claves
print("IDs de estudiantes:")
for id_estudiante in estudiantes.keys():
    print(f"  {id_estudiante}")

# Iterar sobre valores
print("\nDatos de estudiantes:")
for datos in estudiantes.values():
    print(f"  {datos['nombre']} - {datos['carrera']}")

# Iterar sobre pares clave-valor
print("\nEstudiantes completos:")
for id_est, datos in estudiantes.items():
    print(f"  {id_est}: {datos['nombre']}, {datos['edad']} años, {datos['carrera']}")

# Filtrar estudiantes por criterio
estudiantes_ingenieria = {
    id_est: datos for id_est, datos in estudiantes.items() 
    if datos['carrera'] == 'Ingeniería'
}
print(f"\nEstudiantes de Ingeniería: {estudiantes_ingenieria}")

# Crear índice por carrera
estudiantes_por_carrera = {}
for id_est, datos in estudiantes.items():
    carrera = datos['carrera']
    if carrera not in estudiantes_por_carrera:
        estudiantes_por_carrera[carrera] = []
    estudiantes_por_carrera[carrera].append((id_est, datos['nombre']))

print(f"\nEstudiantes agrupados por carrera: {estudiantes_por_carrera}")
```

### 7.4 Indexación avanzada y operaciones

#### Indexación con condiciones

```python
# Lista de números para filtrado
numeros = list(range(1, 21))  # 1 al 20
print(f"Números originales: {numeros}")

# Filtrar con comprensión de lista
pares = [x for x in numeros if x % 2 == 0]
mayores_10 = [x for x in numeros if x > 10]
cuadrados_pares = [x**2 for x in numeros if x % 2 == 0]

print(f"Números pares: {pares}")
print(f"Mayores a 10: {mayores_10}")
print(f"Cuadrados de pares: {cuadrados_pares}")

# Filtrar con enumerate para obtener índices
posiciones_pares = [i for i, x in enumerate(numeros) if x % 2 == 0]
print(f"Posiciones de números pares: {posiciones_pares}")

# Filtrar múltiples listas en paralelo
nombres = ["Ana", "Luis", "María", "Carlos", "Elena"]
edades = [22, 19, 25, 17, 30]
adultos = [(nombre, edad) for nombre, edad in zip(nombres, edades) if edad >= 18]
print(f"Adultos: {adultos}")
```

#### Indexación con funciones auxiliares

```python
# Funciones para indexación avanzada
def encontrar_indices(lista, valor):
    """Encuentra todos los índices donde aparece un valor."""
    return [i for i, x in enumerate(lista) if x == valor]

def encontrar_indices_condicion(lista, condicion):
    """Encuentra índices que cumplen una condición."""
    return [i for i, x in enumerate(lista) if condicion(x)]

def extraer_por_indices(lista, indices):
    """Extrae elementos de una lista usando una lista de índices."""
    return [lista[i] for i in indices if 0 <= i < len(lista)]

# Ejemplos de uso
calificaciones = [7, 8, 7, 9, 6, 8, 7, 10, 9, 7]
print(f"Calificaciones: {calificaciones}")

# Encontrar todas las posiciones con calificación 7
posiciones_7 = encontrar_indices(calificaciones, 7)
print(f"Posiciones con calificación 7: {posiciones_7}")

# Encontrar posiciones con calificaciones altas
posiciones_altas = encontrar_indices_condicion(calificaciones, lambda x: x >= 9)
print(f"Posiciones con calificaciones >= 9: {posiciones_altas}")

# Extraer calificaciones en posiciones específicas
indices_seleccionados = [0, 2, 4, 6]
califs_seleccionadas = extraer_por_indices(calificaciones, indices_seleccionados)
print(f"Calificaciones en posiciones {indices_seleccionados}: {califs_seleccionadas}")

# Función para obtener estadísticas por grupos
def agrupar_por_condicion(lista, condicion):
    """Agrupa elementos según una condición."""
    cumple = [x for x in lista if condicion(x)]
    no_cumple = [x for x in lista if not condicion(x)]
    return cumple, no_cumple

aprobados, reprobados = agrupar_por_condicion(calificaciones, lambda x: x >= 7)
print(f"Aprobados (>=7): {aprobados}")
print(f"Reprobados (<7): {reprobados}")
```

#### Indexación de estructuras complejas

```python
# Estructura de datos compleja: base de datos de universidad
universidad = {
    "facultades": {
        "ingenieria": {
            "carreras": ["Sistemas", "Civil", "Industrial"],
            "estudiantes": [
                {"id": "001", "nombre": "Ana", "carrera": "Sistemas", "año": 3},
                {"id": "002", "nombre": "Luis", "carrera": "Civil", "año": 2}
            ]
        },
        "medicina": {
            "carreras": ["Medicina", "Enfermería"],
            "estudiantes": [
                {"id": "003", "nombre": "María", "carrera": "Medicina", "año": 4}
            ]
        }
    },
    "profesores": [
        {"id": "P001", "nombre": "Dr. García", "facultad": "ingenieria"},
        {"id": "P002", "nombre": "Dra. López", "facultad": "medicina"}
    ]
}

# Función para buscar estudiantes por criterio
def buscar_estudiantes(universidad, criterio):
    """Busca estudiantes que cumplan un criterio en toda la universidad."""
    estudiantes_encontrados = []
    
    for facultad, datos_facultad in universidad["facultades"].items():
        for estudiante in datos_facultad["estudiantes"]:
            if criterio(estudiante):
                estudiante_completo = estudiante.copy()
                estudiante_completo["facultad"] = facultad
                estudiantes_encontrados.append(estudiante_completo)
    
    return estudiantes_encontrados

# Buscar estudiantes de tercer año o superior
estudiantes_avanzados = buscar_estudiantes(
    universidad, 
    lambda est: est["año"] >= 3
)
print("Estudiantes de 3er año o superior:")
for est in estudiantes_avanzados:
    print(f"  {est['nombre']} - {est['carrera']} (Año {est['año']})")

# Función para obtener resumen por facultad
def resumen_por_facultad(universidad):
    """Genera resumen estadístico por facultad."""
    resumen = {}
    
    for facultad, datos in universidad["facultades"].items():
        resumen[facultad] = {
            "total_carreras": len(datos["carreras"]),
            "total_estudiantes": len(datos["estudiantes"]),
            "carreras": datos["carreras"],
            "promedio_año": sum(est["año"] for est in datos["estudiantes"]) / len(datos["estudiantes"]) if datos["estudiantes"] else 0
        }
    
    return resumen

resumen = resumen_por_facultad(universidad)
print("\nResumen por facultad:")
for facultad, stats in resumen.items():
    print(f"{facultad.title()}:")
    print(f"  Carreras: {stats['total_carreras']} - {stats['carreras']}")
    print(f"  Estudiantes: {stats['total_estudiantes']}")
    print(f"  Año promedio: {stats['promedio_año']:.1f}")
```

---

## 8. Librerías en Python {#librerias}

Las librerías extienden significativamente las capacidades de Python, proporcionando funciones especializadas para diferentes dominios. Python cuenta con una biblioteca estándar extensa y un ecosistema de paquetes externos muy rico.

### 8.1 Conceptos básicos de librerías

#### ¿Qué son las librerías?

Las librerías (también llamadas módulos o paquetes) son colecciones de código reutilizable que extienden la funcionalidad básica de Python. Se clasifican en:

1. **Biblioteca estándar**: Incluida con Python, no requiere instalación adicional
2. **Paquetes externos**: Desarrollados por la comunidad, disponibles en PyPI
3. **Módulos locales**: Creados por el usuario para su proyecto específico

#### Ventajas del uso de librerías

- **Reutilización de código**: Evita escribir funcionalidades ya existentes
- **Eficiencia**: Implementaciones optimizadas y probadas
- **Especialización**: Herramientas específicas para cada dominio
- **Mantenimiento**: Actualizaciones y correcciones de errores centralizadas
- **Comunidad**: Aprovechamiento del trabajo colaborativo

### 8.2 Gestión de librerías

#### Importación de módulos

```python
# Diferentes formas de importar
import math                    # Importar módulo completo
import datetime as dt          # Importar con alias
from os import path           # Importar función específica
from collections import Counter, defaultdict  # Importar múltiples elementos

# Usar las importaciones
print(f"Pi: {math.pi}")
print(f"Raíz cuadrada de 16: {math.sqrt(16)}")

fecha_actual = dt.datetime.now()
print(f"Fecha actual: {fecha_actual}")

directorio_actual = path.getcwd()
print(f"Directorio actual: {directorio_actual}")

# Contar elementos en una lista
elementos = ['a', 'b', 'a', 'c', 'b', 'a']
contador = Counter(elementos)
print(f"Conteo de elementos: {contador}")
```

#### Exploración de módulos

```python
# Explorar un módulo importado
import random

# Ver atributos y métodos disponibles
atributos_random = [attr for attr in dir(random) if not attr.startswith('_')]
print(f"Primeros atributos de random: {atributos_random[:10]}")

# Información sobre funciones específicas
print(f"\nDocumentación de randint:")
print(random.randint.__doc__)

# Información del módulo
print(f"\nArchivo del módulo: {random.__file__}")
print(f"Nombre del módulo: {random.__name__}")

# Usar help() para información detallada
# help(random.choice)  # Descomenta para ver la ayuda completa
```

#### Instalación de paquetes externos

```python
# En un entorno real, usarías pip desde la terminal:
# pip install numpy pandas matplotlib requests

# En Jupyter/Colab, puedes usar:
# !pip install nombre_del_paquete

# Verificar paquetes instalados
import sys
print(f"Versión de Python: {sys.version}")

# Lista de módulos incorporados
import sys
modulos_incorporados = list(sys.builtin_module_names)
print(f"Algunos módulos incorporados: {modulos_incorporados[:10]}")

# Verificar si un paquete está disponible
def verificar_paquete(nombre_paquete):
    """Verifica si un paquete está instalado y es importable."""
    try:
        __import__(nombre_paquete)
        return True
    except ImportError:
        return False

paquetes_verificar = ['math', 'numpy', 'pandas', 'requests']
for paquete in paquetes_verificar:
    disponible = verificar_paquete(paquete)
    print(f"{paquete}: {'✓ Disponible' if disponible else '✗ No disponible'}")
```

### 8.3 Librerías de la biblioteca estándar

#### Módulo os y os.path para sistema operativo

```python
import os
import os.path

# Información del sistema
print(f"Sistema operativo: {os.name}")
print(f"Directorio actual: {os.getcwd()}")
print(f"Variables de entorno PATH: {os.environ.get('PATH', 'No encontrado')[:100]}...")

# Trabajar con rutas
ruta_ejemplo = "/home/usuario/documentos/archivo.txt"
print(f"\nRuta ejemplo: {ruta_ejemplo}")
print(f"Directorio padre: {os.path.dirname(ruta_ejemplo)}")
print(f"Nombre del archivo: {os.path.basename(ruta_ejemplo)}")
print(f"Extensión: {os.path.splitext(ruta_ejemplo)[1]}")

# Construir rutas de forma portable
ruta_construida = os.path.join("documentos", "proyectos", "archivo.py")
print(f"Ruta construida: {ruta_construida}")

# Verificar existencia (estas rutas probablemente no existan)
print(f"¿Existe el directorio actual? {os.path.exists('.')}")
print(f"¿Es un directorio? {os.path.isdir('.')}")
print(f"¿Es un archivo? {os.path.isfile('.')}")
```

#### Módulo datetime para fechas y tiempo

```python
import datetime

# Fecha y hora actual
ahora = datetime.datetime.now()
hoy = datetime.date.today()
hora_actual = datetime.time(ahora.hour, ahora.minute, ahora.second)

print(f"Fecha y hora completa: {ahora}")
print(f"Solo fecha: {hoy}")
print(f"Solo hora: {hora_actual}")

# Crear fechas específicas
mi_cumpleanos = datetime.date(1995, 5, 15)
mi_hora_favorita = datetime.time(14, 30, 0)  # 2:30 PM

print(f"Mi cumpleaños: {mi_cumpleanos}")
print(f"Mi hora favorita: {mi_hora_favorita}")

# Operaciones con fechas
dias_desde_cumpleanos = hoy - mi_cumpleanos
print(f"Días desde mi cumpleaños: {dias_desde_cumpleanos.days}")

# Formateo de fechas
fecha_formateada = ahora.strftime("%d/%m/%Y %H:%M:%S")
fecha_personalizada = ahora.strftime("%A, %B %d, %Y")

print(f"Fecha formateada: {fecha_formateada}")
print(f"Fecha personalizada: {fecha_personalizada}")

# Parseo de fechas desde cadenas
fecha_texto = "2023-12-25"
fecha_parseada = datetime.datetime.strptime(fecha_texto, "%Y-%m-%d")
print(f"Fecha parseada: {fecha_parseada}")

# Trabajar con timedelta
una_semana = datetime.timedelta(weeks=1)
fecha_futura = hoy + una_semana
fecha_pasada = hoy - datetime.timedelta(days=30)

print(f"En una semana: {fecha_futura}")
print(f"Hace 30 días: {fecha_pasada}")
```

#### Módulo random para números aleatorios

```python
import random

# Configurar semilla para reproducibilidad
random.seed(42)

# Números aleatorios básicos
print(f"Número flotante [0,1): {random.random()}")
print(f"Entero entre 1 y 10: {random.randint(1, 10)}")
print(f"Flotante entre 5 y 15: {random.uniform(5, 15)}")

# Selección aleatoria
frutas = ["manzana", "banana", "naranja", "uva", "pera"]
print(f"Fruta aleatoria: {random.choice(frutas)}")

# Múltiples selecciones
frutas_seleccionadas = random.choices(frutas, k=3)  # Con reemplazo
print(f"3 frutas (con reemplazo): {frutas_seleccionadas}")

frutas_muestra = random.sample(frutas, 3)  # Sin reemplazo
print(f"3 frutas (sin reemplazo): {frutas_muestra}")

# Mezclar lista
numeros = list(range(1, 11))
print(f"Lista original: {numeros}")
random.shuffle(numeros)
print(f"Lista mezclada: {numeros}")

# Distribuciones estadísticas
print(f"Normal (μ=0, σ=1): {random.gauss(0, 1):.3f}")
print(f"Exponencial (λ=1): {random.expovariate(1):.3f}")

# Generar datos de prueba
def generar_datos_estudiantes(n):
    """Genera datos aleatorios de estudiantes para pruebas."""
    nombres = ["Ana", "Luis", "María", "Carlos", "Elena", "Roberto", "Sofía"]
    carreras = ["Ingeniería", "Medicina", "Derecho", "Psicología", "Economía"]
    
    estudiantes = []
    for i in range(n):
        estudiante = {
            "id": f"EST{i+1:03d}",
            "nombre": random.choice(nombres),
            "edad": random.randint(18, 25),
            "carrera": random.choice(carreras),
            "promedio": round(random.uniform(6.0, 10.0), 2)
        }
        estudiantes.append(estudiante)
    
    return estudiantes

# Generar datos de prueba
estudiantes_aleatorios = generar_datos_estudiantes(5)
print("\nEstudiantes aleatorios generados:")
for est in estudiantes_aleatorios:
    print(f"  {est['id']}: {est['nombre']}, {est['carrera']}, Promedio: {est['promedio']}")
```

#### Módulo json para manejo de datos JSON

```python
import json

# Datos de ejemplo
datos_python = {
    "estudiantes": [
        {"nombre": "Ana", "edad": 22, "activo": True},
        {"nombre": "Luis", "edad": 21, "activo": False}
    ],
    "fecha_actualizacion": "2024-01-15",
    "total": 2
}

# Convertir a JSON (serialización)
json_string = json.dumps(datos_python, indent=2, ensure_ascii=False)
print("Datos en formato JSON:")
print(json_string)

# Convertir desde JSON (deserialización)
datos_desde_json = json.loads(json_string)
print(f"\nTipo después de cargar: {type(datos_desde_json)}")
print(f"Primer estudiante: {datos_desde_json['estudiantes'][0]}")

# Manejo de errores en JSON
json_invalido = '{"nombre": "Ana", "edad": 22,}'  # Coma extra
try:
    datos_invalidos = json.loads(json_invalido)
except json.JSONDecodeError as e:
    print(f"Error al parsear JSON: {e}")

# Función para trabajar con archivos JSON (simulada)
def guardar_json(datos, nombre_archivo):
    """Simula guardar datos en archivo JSON."""
    json_string = json.dumps(datos, indent=2, ensure_ascii=False)
    print(f"Guardando en {nombre_archivo}:")
    print(json_string[:200] + "..." if len(json_string) > 200 else json_string)

def cargar_json(contenido_json):
    """Simula cargar datos desde JSON."""
    try:
        return json.loads(contenido_json)
    except json.JSONDecodeError as e:
        print(f"Error al cargar JSON: {e}")
        return None

# Ejemplo de uso
guardar_json(datos_python, "estudiantes.json")
datos_cargados = cargar_json(json_string)
print(f"\nDatos cargados exitosamente: {datos_cargados['total']} estudiantes")
```

#### Módulo collections para estructuras de datos especializadas

```python
from collections import Counter, defaultdict, deque, namedtuple

# Counter: conteo automático
texto = "programación en python es muy útil para análisis"
palabras = texto.split()
conteo_palabras = Counter(palabras)

print(f"Palabras más comunes: {conteo_palabras.most_common(3)}")
print(f"Total de palabras únicas: {len(conteo_palabras)}")

# Conteo de caracteres
conteo_caracteres = Counter(texto.replace(" ", ""))
print(f"Caracteres más frecuentes: {conteo_caracteres.most_common(5)}")

# defaultdict: diccionario con valores por defecto
estudiantes_por_carrera = defaultdict(list)

estudiantes = [
    ("Ana", "Ingeniería"), ("Luis", "Medicina"), ("María", "Ingeniería"),
    ("Carlos", "Derecho"), ("Elena", "Medicina"), ("Roberto", "Ingeniería")
]

for nombre, carrera in estudiantes:
    estudiantes_por_carrera[carrera].append(nombre)

print("\nEstudiantes agrupados por carrera:")
for carrera, nombres in estudiantes_por_carrera.items():
    print(f"  {carrera}: {nombres}")

# deque: cola de doble extremo (eficiente para operaciones en los extremos)
cola_tareas = deque(["tarea1", "tarea2", "tarea3"])
print(f"\nCola inicial: {list(cola_tareas)}")

# Agregar elementos
cola_tareas.append("tarea4")          # Agregar al final
cola_tareas.appendleft("tarea0")      # Agregar al inicio
print(f"Después de agregar: {list(cola_tareas)}")

# Remover elementos
tarea_final = cola_tareas.pop()       # Remover del final
tarea_inicial = cola_tareas.popleft() # Remover del inicio
print(f"Removidas: {tarea_inicial}, {tarea_final}")
print(f"Cola final: {list(cola_tareas)}")

# namedtuple: tupla con nombres de campos
Estudiante = namedtuple('Estudiante', ['nombre', 'edad', 'carrera', 'promedio'])

# Crear instancias
est1 = Estudiante("Ana García", 22, "Ingeniería", 8.5)
est2 = Estudiante("Luis Pérez", 21, "Medicina", 7.8)

print(f"\nEstudiante 1: {est1}")
print(f"Nombre: {est1.nombre}, Promedio: {est1.promedio}")

# Las namedtuples son inmutables pero se pueden crear nuevas con _replace
est1_actualizado = est1._replace(edad=23, promedio=8.7)
print(f"Estudiante actualizado: {est1_actualizado}")

# Convertir a diccionario
est_dict = est1._asdict()
print(f"Como diccionario: {est_dict}")
```

#### Módulo itertools para iteración avanzada

```python
import itertools

# Combinaciones y permutaciones
colores = ['rojo', 'verde', 'azul']
numeros = [1, 2, 3]

# Producto cartesiano
producto = list(itertools.product(colores, numeros))
print(f"Producto cartesiano: {producto[:6]}...")

# Combinaciones
combinaciones_2 = list(itertools.combinations(colores, 2))
print(f"Combinaciones de 2: {combinaciones_2}")

# Permutaciones
permutaciones_2 = list(itertools.permutations(colores, 2))
print(f"Permutaciones de 2: {permutaciones_2}")

# Repetición infinita (usar con cuidado)
contador_infinito = itertools.count(start=1, step=2)  # 1, 3, 5, 7, ...
primeros_10_impares = list(itertools.islice(contador_infinito, 10))
print(f"Primeros 10 números impares: {primeros_10_impares}")

# Ciclo infinito
colores_ciclo = itertools.cycle(['rojo', 'verde', 'azul'])
primeros_8_colores = list(itertools.islice(colores_ciclo, 8))
print(f"Ciclo de colores: {primeros_8_colores}")

# Agrupar elementos consecutivos
datos = [1, 1, 2, 2, 2, 3, 1, 1, 3, 3]
grupos = [(clave, list(grupo)) for clave, grupo in itertools.groupby(datos)]
print(f"Elementos agrupados: {grupos}")

# Cadena de iteradores
lista1 = [1, 2, 3]
lista2 = [4, 5, 6]
lista3 = [7, 8, 9]
cadena = list(itertools.chain(lista1, lista2, lista3))
print(f"Listas encadenadas: {cadena}")

# Aplicación práctica: generar todas las combinaciones de configuración
opciones_config = {
    'base_datos': ['MySQL', 'PostgreSQL'],
    'servidor': ['Apache', 'Nginx'],
    'lenguaje': ['Python', 'Node.js']
}

combinaciones_config = list(itertools.product(*opciones_config.values()))
print(f"\nTotal de configuraciones posibles: {len(combinaciones_config)}")
print("Primeras 3 configuraciones:")
for i, config in enumerate(combinaciones_config[:3]):
    db, srv, lang = config
    print(f"  {i+1}: {lang} + {srv} + {db}")
```

### 8.4 Creación de módulos personalizados

#### Estructura básica de un módulo

```python
# Ejemplo de cómo crear un módulo personalizado
# En un archivo real, esto iría en un archivo separado (ej: matematicas_basicas.py)

"""
Módulo de matemáticas básicas
Contiene funciones para operaciones matemáticas comunes.
"""

# Constantes del módulo
PI = 3.141592653589793
E = 2.718281828459045

# Variables del módulo
_precision_decimal = 4  # Variable privada (convencion con _)

def cuadrado(x):
    """Calcula el cuadrado de un número."""
    return x ** 2

def cubo(x):
    """Calcula el cubo de un número."""
    return x ** 3

def factorial(n):
    """
    Calcula el factorial de un número.
    
    Args:
        n (int): Número entero no negativo
        
    Returns:
        int: Factorial de n
        
    Raises:
        ValueError: Si n es negativo
        TypeError: Si n no es entero
    """
    if not isinstance(n, int):
        raise TypeError("El factorial solo se define para enteros")
    if n < 0:
        raise ValueError("El factorial no se define para números negativos")
    
    if n <= 1:
        return 1
    return n * factorial(n - 1)

def es_primo(n):
    """
    Verifica si un número es primo.
    
    Args:
        n (int): Número a verificar
        
    Returns:
        bool: True si es primo, False en caso contrario
    """
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    
    for i in range(3, int(n ** 0.5) + 1, 2):
        if n % i == 0:
            return False
    return True

def estadisticas_basicas(numeros):
    """
    Calcula estadísticas básicas de una lista de números.
    
    Args:
        numeros (list): Lista de números
        
    Returns:
        dict: Diccionario con media, mediana, min, max
    """
    if not numeros:
        return None
    
    numeros_ordenados = sorted(numeros)
    n = len(numeros)
    
    # Media
    media = sum(numeros) / n
    
    # Mediana
    if n % 2 == 0:
        mediana = (numeros_ordenados[n//2 - 1] + numeros_ordenados[n//2]) / 2
    else:
        mediana = numeros_ordenados[n//2]
    
    return {
        'media': round(media, _precision_decimal),
        'mediana': mediana,
        'minimo': min(numeros),
        'maximo': max(numeros),
        'cantidad': n
    }

# Función principal del módulo (se ejecuta solo si se ejecuta directamente)
def main():
    """Función de prueba del módulo."""
    print("Probando módulo de matemáticas básicas:")
    print(f"Cuadrado de 5: {cuadrado(5)}")
    print(f"Factorial de 5: {factorial(5)}")
    print(f"¿7 es primo? {es_primo(7)}")
    
    datos = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    stats = estadisticas_basicas(datos)
    print(f"Estadísticas de {datos}: {stats}")

# Ejecutar main solo si este archivo se ejecuta directamente
if __name__ == "__main__":
    main()

# Simular el uso del módulo
print("Usando el módulo matemáticas_basicas:")
print(f"Pi: {PI}")
print(f"Cuadrado de 8: {cuadrado(8)}")
print(f"¿15 es primo? {es_primo(15)}")

numeros_ejemplo = [2, 4, 6, 8, 10, 12]
resultado_stats = estadisticas_basicas(numeros_ejemplo)
print(f"Estadísticas de números pares: {resultado_stats}")
```

#### Paquetes y estructura de proyecto

```python
# Ejemplo de estructura de un paquete Python
# En un proyecto real, esto sería una estructura de directorios

"""
Estructura de paquete ejemplo:

mi_proyecto/
├── __init__.py          # Hace que el directorio sea un paquete
├── utiles/
│   ├── __init__.py
│   ├── matematicas.py   # Módulo de matemáticas
│   └── texto.py         # Módulo de procesamiento de texto
├── datos/
│   ├── __init__.py
│   └── procesamiento.py # Módulo de procesamiento de datos
└── main.py              # Archivo principal
"""

# Contenido del archivo __init__.py del paquete principal
"""
# mi_proyecto/__init__.py

# Importar elementos principales del paquete
from .utiles.matematicas import estadisticas_basicas, es_primo
from .datos.procesamiento import limpiar_datos

# Definir qué se exporta cuando se hace 'from mi_proyecto import *'
__all__ = ['estadisticas_basicas', 'es_primo', 'limpiar_datos']

# Información del paquete
__version__ = '1.0.0'
__author__ = 'Tu Nombre'
__description__ = 'Paquete de utilidades para análisis de datos'
"""

# Simulación de cómo se usaría el paquete
def simular_uso_paquete():
    """Simula cómo se usaría un paquete estructurado."""
    
    # Funciones que simularían estar en diferentes módulos
    def procesar_texto(texto, normalizar=True):
        """Simula procesamiento de texto del módulo utiles.texto"""
        if normalizar:
            texto = texto.lower().strip()
        palabras = texto.split()
        return {
            'texto_original': texto,
            'palabras': palabras,
            'total_palabras': len(palabras),
            'palabras_unicas': len(set(palabras))
        }
    
    def validar_datos(datos, tipo_esperado=None):
        """Simula validación de datos del módulo datos.procesamiento"""
        if not datos:
            return {'valido': False, 'error': 'Datos vacíos'}
        
        if tipo_esperado:
            tipos_correctos = all(isinstance(item, tipo_esperado) for item in datos)
            if not tipos_correctos:
                return {'valido': False, 'error': f'Tipos incorrectos, se esperaba {tipo_esperado.__name__}'}
        
        return {'valido': True, 'cantidad': len(datos)}
    
    # Ejemplo de uso
    print("Simulación de uso del paquete estructurado:")
    
    # Procesamiento de texto
    texto_ejemplo = "  Python es un lenguaje de programación muy versátil  "
    resultado_texto = procesar_texto(texto_ejemplo)
    print(f"Análisis de texto: {resultado_texto}")
    
    # Validación de datos
    datos_numericos = [1, 2, 3, 4, 5]
    validacion = validar_datos(datos_numericos, int)
    print(f"Validación de datos: {validacion}")
    
    # Usar estadísticas del módulo anterior
    stats = estadisticas_basicas(datos_numericos)
    print(f"Estadísticas: {stats}")

simular_uso_paquete()
```

#### Mejores prácticas para módulos

```python
# Ejemplo de módulo con mejores prácticas
"""
utiles_avanzadas.py - Módulo con mejores prácticas

Este módulo demuestra las mejores prácticas para crear módulos:
- Documentación clara
- Manejo de errores
- Logging
- Configuración
- Testing
"""

import logging
from typing import List, Dict, Any, Optional, Union

# Configuración del logging para el módulo
logger = logging.getLogger(__name__)

# Configuración del módulo
CONFIG = {
    'precision_decimal': 4,
    'max_elementos': 10000,
    'debug': False
}

class UtilsError(Exception):
    """Excepción personalizada para errores del módulo."""
    pass

def configurar_modulo(debug: bool = False, precision: int = 4) -> None:
    """
    Configura parámetros globales del módulo.
    
    Args:
        debug: Habilitar modo debug
        precision: Precisión decimal para cálculos
    """
    CONFIG['debug'] = debug
    CONFIG['precision_decimal'] = precision
    
    if debug:
        logging.basicConfig(level=logging.DEBUG)
        logger.debug("Modo debug habilitado")

def procesar_lista_numerica(
    numeros: List[Union[int, float]], 
    operacion: str = 'suma'
) -> Dict[str, Any]:
    """
    Procesa una lista numérica con validaciones completas.
    
    Args:
        numeros: Lista de números a procesar
        operacion: Tipo de operación ('suma', 'producto', 'estadisticas')
        
    Returns:
        Diccionario con resultados del procesamiento
        
    Raises:
        UtilsError: Si hay errores en los datos o parámetros
        
    Example:
        >>> procesar_lista_numerica([1, 2, 3, 4, 5], 'suma')
        {'operacion': 'suma', 'resultado': 15, 'elementos': 5}
    """
    # Validaciones
    if not isinstance(numeros, list):
        raise UtilsError("Se esperaba una lista")
    
    if not numeros:
        raise UtilsError("La lista no puede estar vacía")
    
    if len(numeros) > CONFIG['max_elementos']:
        raise UtilsError(f"Lista demasiado grande (máximo {CONFIG['max_elementos']})")
    
    # Verificar que todos sean números
    for i, num in enumerate(numeros):
        if not isinstance(num, (int, float)):
            raise UtilsError(f"Elemento en posición {i} no es numérico: {num}")
    
    logger.debug(f"Procesando {len(numeros)} elementos con operación '{operacion}'")
    
    # Realizar operación
    if operacion == 'suma':
        resultado = sum(numeros)
    elif operacion == 'producto':
        resultado = 1
        for num in numeros:
            resultado *= num
    elif operacion == 'estadisticas':
        resultado = {
            'suma': sum(numeros),
            'media': round(sum(numeros) / len(numeros), CONFIG['precision_decimal']),
            'min': min(numeros),
            'max': max(numeros),
            'mediana': sorted(numeros)[len(numeros) // 2]
        }
    else:
        raise UtilsError(f"Operación no soportada: {operacion}")
    
    return {
        'operacion': operacion,
        'resultado': resultado,
        'elementos': len(numeros),
        'configuracion': CONFIG.copy()
    }

def batch_processor(
    listas_datos: List[List[Union[int, float]]], 
    operacion: str = 'suma'
) -> List[Dict[str, Any]]:
    """
    Procesa múltiples listas en lote con manejo de errores.
    
    Args:
        listas_datos: Lista de listas numéricas
        operacion: Operación a realizar en cada lista
        
    Returns:
        Lista de resultados, con errores marcados como None
    """
    resultados = []
    
    for i, lista in enumerate(listas_datos):
        try:
            resultado = procesar_lista_numerica(lista, operacion)
            resultado['indice'] = i
            resultados.append(resultado)
            logger.debug(f"Lista {i} procesada exitosamente")
        except UtilsError as e:
            logger.error(f"Error procesando lista {i}: {e}")
            resultados.append({
                'indice': i,
                'error': str(e),
                'operacion': operacion
            })
    
    return resultados

# Ejemplo de uso del módulo avanzado
def demo_modulo_avanzado():
    """Demuestra el uso del módulo con mejores prácticas."""
    print("Demo del módulo con mejores prácticas:")
    
    # Configurar módulo
    configurar_modulo(debug=True, precision=3)
    
    # Datos de prueba
    datos_validos = [1, 2, 3, 4, 5]
    datos_con_error = [1, 2, "tres", 4, 5]
    datos_vacios = []
    
    lotes_datos = [datos_validos, datos_con_error, datos_vacios, [10, 20, 30]]
    
    # Procesamiento individual
    try:
        resultado_suma = procesar_lista_numerica(datos_validos, 'suma')
        print(f"Suma exitosa: {resultado_suma}")
        
        resultado_stats = procesar_lista_numerica(datos_validos, 'estadisticas')
        print(f"Estadísticas: {resultado_stats['resultado']}")
        
    except UtilsError as e:
        print(f"Error: {e}")
    
    # Procesamiento en lote
    resultados_lote = batch_processor(lotes_datos, 'suma')
    print(f"\nResultados del procesamiento en lote:")
    for resultado in resultados_lote:
        if 'error' in resultado:
            print(f"  Lote {resultado['indice']}: ERROR - {resultado['error']}")
        else:
            print(f"  Lote {resultado['indice']}: {resultado['resultado']} (elementos: {resultado['elementos']})")

# Ejecutar demo
demo_modulo_avanzado()
```

### 8.5 Información del entorno y dependencias

```python
# Obtener información completa del entorno Python
import sys
import platform
from importlib import import_module

def info_entorno_python():
    """Muestra información completa del entorno Python."""
    print("=== INFORMACIÓN DEL ENTORNO PYTHON ===\n")
    
    # Información básica del sistema
    print("SISTEMA:")
    print(f"  Plataforma: {platform.platform()}")
    print(f"  Sistema operativo: {platform.system()} {platform.release()}")
    print(f"  Arquitectura: {platform.architecture()[0]}")
    print(f"  Procesador: {platform.processor()}")
    
    # Información de Python
    print(f"\nPYTHON:")
    print(f"  Versión: {sys.version}")
    print(f"  Implementación: {platform.python_implementation()}")
    print(f"  Compilador: {platform.python_compiler()}")
    print(f"  Ejecutable: {sys.executable}")
    
    # Información de paths
    print(f"\nRUTAS:")
    print(f"  Ruta de Python: {sys.path[0]}")
    print(f"  Módulos incorporados: {len(sys.builtin_module_names)}")
    
    # Módulos disponibles comunes
    modulos_comunes = [
        'os', 'sys', 'math', 'random', 'datetime', 'json', 'urllib',
        'sqlite3', 'csv', 'xml', 'email', 'http', 'collections'
    ]
    
    print(f"\nMÓDULOS DE LA BIBLIOTECA ESTÁNDAR:")
    disponibles = []
    for modulo in modulos_comunes:
        try:
            import_module(modulo)
            disponibles.append(modulo)
        except ImportError:
            pass
    
    print(f"  Disponibles: {', '.join(disponibles)}")
    print(f"  Total verificados: {len(disponibles)}/{len(modulos_comunes)}")
    
    # Paquetes externos comunes (si están disponibles)
    paquetes_externos = [
        'numpy', 'pandas', 'matplotlib', 'requests', 'scipy', 
        'sklearn', 'tensorflow', 'torch', 'flask', 'django'
    ]
    
    print(f"\nPAQUETES EXTERNOS COMUNES:")
    externos_disponibles = []
    for paquete in paquetes_externos:
        try:
            modulo = import_module(paquete)
            version = getattr(modulo, '__version__', 'Versión no disponible')
            externos_disponibles.append(f"{paquete} ({version})")
        except ImportError:
            pass
    
    if externos_disponibles:
        for paquete_info in externos_disponibles:
            print(f"  {paquete_info}")
    else:
        print("  Ningún paquete externo común detectado")
    
    print(f"  Disponibles: {len(externos_disponibles)}/{len(paquetes_externos)}")

# Ejecutar información del entorno
info_entorno_python()
```