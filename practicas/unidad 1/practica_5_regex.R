## ===================================================
## 20 EJERCICIOS BÁSICOS DE EXPRESIONES REGULARES CON STRINGR
## ===================================================
## Para: Curso de Ciencia de datos para economía y negocios
## Tema: Práctica con expresiones regulares
## ===================================================

# Cargamos las librerías necesarias
library(stringr)

# Crear vector con soluciones para comprobar resultados
soluciones <- list()

# ===================================================
# INSTRUCCIONES PARA LOS ESTUDIANTES
# ===================================================
# 
# Para cada string:
# 1. Copia el string en regex101.com (selecciona PCRE como motor)
# 2. Realiza los 5 ejercicios propuestos usando las funciones de stringr
# 3. Comprueba tus resultados con las soluciones al final
#
# Nota: En regex101.com podrás visualizar y entender mejor los patrones

# ===================================================
# STRING 1: Correo electrónico básico
# ===================================================
string1 <- "Mi correo es juan.perez@gmail.com y el de trabajo es jperez@empresa.com.ar"

# Ejercicios:
# 1.1. Detecta si el string contiene alguna dirección de correo electrónico
# 1.2. Extrae todas las direcciones de correo electrónico
# 1.3. Cuenta cuántas direcciones de correo hay
# 1.4. Reemplaza el dominio gmail.com por outlook.com
# 1.5. Extrae solo los nombres de usuario (la parte antes del @)

# ===================================================
# STRING 2: Texto con números de teléfono
# ===================================================
string2 <- "Contactos: Juan (123) 456-7890, María 987-654-3210 y Pedro +54 9 11 2345-6789"

# Ejercicios:
# 2.1. Detecta si hay números de teléfono en el texto
# 2.2. Extrae todos los números de teléfono completos
# 2.3. Extrae solo los dígitos de cada número (eliminando paréntesis, guiones y espacios)
# 2.4. Reemplaza todos los números por la palabra "[PRIVADO]"
# 2.5. Extrae solo los nombres de las personas

# ===================================================
# STRING 3: Fechas en diferentes formatos
# ===================================================
string3 <- "Fechas importantes: 15/04/2023, 2022-10-25 y 01.12.2024"

# Ejercicios:
# 3.1. Detecta si hay fechas en el texto
# 3.2. Extrae todas las fechas independientemente de su formato
# 3.3. Cuenta cuántas fechas hay en el texto
# 3.4. Extrae solo las fechas en formato DD/MM/YYYY
# 3.5. Reemplaza todas las fechas por "FECHA"

# ===================================================
# STRING 4: URL simple
# ===================================================
string4 <- "Visita mi sitio web https://www.mipagina.com/blog/articulo-123 o http://ejemplo.org"

# Ejercicios:
# 4.1. Detecta si hay URLs en el texto
# 4.2. Extrae todas las URLs completas
# 4.3. Extrae solo los dominios (ej: mipagina.com, ejemplo.org)
# 4.4. Reemplaza el protocolo http:// por https://
# 4.5. Cuenta cuántas URLs seguras (https) hay en el texto

# ===================================================
# STRING 5: Código de producto
# ===================================================
string5 <- "Los productos ABC-123, XYZ-456 y MNO-789 están en oferta"

# Ejercicios:
# 5.1. Detecta si hay códigos de producto en el formato LLL-DDD (tres letras, guion, tres dígitos)
# 5.2. Extrae todos los códigos de producto
# 5.3. Extrae solo las partes alfabéticas de los códigos
# 5.4. Extrae solo los números de los códigos
# 5.5. Reemplaza todos los códigos por "PRODUCTO"

# ===================================================
# STRING 6: Lista de nombres y apellidos
# ===================================================
string6 <- "Alumnos: Juan Pérez, María GARCÍA, pedro lópez"

# Ejercicios:
# 6.1. Detecta si hay nombres completos (nombre y apellido)
# 6.2. Extrae todos los nombres completos
# 6.3. Extrae solo los nombres (sin apellidos)
# 6.4. Extrae solo los apellidos
# 6.5. Normaliza los nombres para que todos tengan la primera letra en mayúscula y el resto en minúscula

# ===================================================
# STRING 7: Texto con hashtags
# ===================================================
string7 <- "Me encantó la película #StarWars y también #TheAvengers. #cine #películas"

# Ejercicios:
# 7.1. Detecta si hay hashtags en el texto
# 7.2. Extrae todos los hashtags (incluyendo el símbolo #)
# 7.3. Extrae todos los hashtags (sin el símbolo #)
# 7.4. Cuenta cuántos hashtags hay en el texto
# 7.5. Reemplaza todos los hashtags por el mismo texto pero en mayúsculas

# ===================================================
# STRING 8: Texto con direcciones IP
# ===================================================
string8 <- "Direcciones IP bloqueadas: 192.168.1.1, 10.0.0.1 y 172.16.254.1"

# Ejercicios:
# 8.1. Detecta si hay direcciones IP en el texto
# 8.2. Extrae todas las direcciones IP
# 8.3. Cuenta cuántas direcciones IP hay
# 8.4. Reemplaza el último número de cada dirección IP por "X"
# 8.5. Extrae solo el primer octeto de cada dirección IP (ej: 192, 10, 172)

# ===================================================
# STRING 9: Texto con precios
# ===================================================
string9 <- "Productos: Camisa $25.99, Pantalón $45, Zapatos $99.50"

# Ejercicios:
# 9.1. Detecta si hay precios en el texto
# 9.2. Extrae todos los precios (incluyendo el símbolo $)
# 9.3. Extrae todos los precios (solo los números, sin el símbolo $)
# 9.4. Calcula la suma de todos los precios (pista: usa as.numeric())
# 9.5. Reemplaza todos los precios por "€XX.XX" (convierte a euros multiplicando por 0.85)

# ===================================================
# STRING 10: Párrafo con palabras específicas
# ===================================================
string10 <- "Python es un lenguaje de programación muy popular. También me gusta programar en R y JavaScript. La programación es divertida."

# Ejercicios:
# 10.1. Detecta si se menciona la palabra "programación" en el texto
# 10.2. Cuenta cuántas veces aparece la palabra "programación" (en cualquier parte del texto)
# 10.3. Extrae todas las menciones de lenguajes de programación (Python, R, JavaScript)
# 10.4. Reemplaza todos los nombres de lenguajes por "LENGUAJE"
# 10.5. Divide el texto en oraciones (pista: separar por punto y espacio)

# ===================================================
# STRING 11: Datos personales con DNI
# ===================================================
string11 <- "Datos: Ana García (DNI: 12345678A), Luis Martínez (DNI: 87654321B)"

# Ejercicios:
# 11.1. Detecta si hay números de DNI en el texto (formato: 8 dígitos y una letra)
# 11.2. Extrae todos los números de DNI completos
# 11.3. Extrae solo los dígitos de los DNI (sin la letra)
# 11.4. Extrae solo las letras de los DNI
# 11.5. Anonimiza los DNI mostrando solo los dos primeros dígitos y la letra (ej: 12XXXXXA)

# ===================================================
# STRING 12: Tweets con menciones
# ===================================================
string12 <- "@usuario1 Excelente artículo! Deberías hablar con @experto_tema y @otra_persona"

# Ejercicios:
# 12.1. Detecta si hay menciones de usuarios (formato @nombre) en el texto
# 12.2. Extrae todas las menciones (con el símbolo @)
# 12.3. Extrae todos los nombres de usuario (sin el símbolo @)
# 12.4. Cuenta cuántas menciones hay en el texto
# 12.5. Reemplaza todas las menciones por "[USUARIO]"

# ===================================================
# STRING 13: Texto con horas
# ===================================================
string13 <- "Horarios de reuniones: 09:30, 14:15 y 18:45 horas"

# Ejercicios:
# 13.1. Detecta si hay horas en formato HH:MM en el texto
# 13.2. Extrae todas las horas
# 13.3. Cuenta cuántas horas hay
# 13.4. Convierte todas las horas al formato de 12 horas (ej: 09:30 AM, 02:15 PM, 06:45 PM)
# 13.5. Extrae solo los minutos de cada hora

# ===================================================
# STRING 14: Texto con porcentajes
# ===================================================
string14 <- "Estadísticas: 25% de descuento, tasa de éxito del 72.5%, margen de error 3.5%"

# Ejercicios:
# 14.1. Detecta si hay porcentajes en el texto
# 14.2. Extrae todos los porcentajes (incluyendo el símbolo %)
# 14.3. Extrae todos los valores numéricos de los porcentajes (sin el símbolo %)
# 14.4. Calcula el promedio de los porcentajes (pista: usa as.numeric())
# 14.5. Convierte todos los porcentajes a fracciones decimales (ej: 25% a 0.25)

# ===================================================
# STRING 15: Listado de etiquetas HTML
# ===================================================
string15 <- "<div>Contenedor principal</div> <p>Párrafo con <a>enlace</a> y <span>texto</span></p>"

# Ejercicios:
# 15.1. Detecta si hay etiquetas HTML en el texto
# 15.2. Extrae todas las etiquetas HTML de apertura (ej: <div>, <p>)
# 15.3. Extrae todas las etiquetas HTML de cierre (ej: </div>, </p>)
# 15.4. Extrae los nombres de todas las etiquetas (sin los símbolos < >)
# 15.5. Reemplaza todas las etiquetas HTML por corchetes (ej: <div> por [div])

# ===================================================
# STRING 16: Lista de países y capitales
# ===================================================
string16 <- "España (Madrid), Francia (París), Italia (Roma), Alemania (Berlín)"

# Ejercicios:
# 16.1. Detecta si hay pares de país-capital en el texto (formato: País (Capital))
# 16.2. Extrae todos los pares país-capital completos
# 16.3. Extrae solo los nombres de los países
# 16.4. Extrae solo los nombres de las capitales (sin los paréntesis)
# 16.5. Reorganiza el texto para mostrar "Capital es la capital de País" para cada par

# ===================================================
# STRING 17: URLs con parámetros
# ===================================================
string17 <- "Enlaces: https://ejemplo.com?id=123&nombre=Juan y https://otrositio.org?categoria=libros&pagina=2"

# Ejercicios:
# 17.1. Detecta si hay URLs con parámetros en el texto
# 17.2. Extrae todas las URLs completas con sus parámetros
# 17.3. Extrae solo la parte de los parámetros de cada URL (después del signo ?)
# 17.4. Cuenta cuántos parámetros hay en cada URL (pista: contar los símbolos &)
# 17.5. Extrae el valor del parámetro "id" o "categoria" según corresponda

# ===================================================
# STRING 18: Texto con códigos postales
# ===================================================
string18 <- "Direcciones: Calle Principal 123, CP 28001, Madrid y Avenida Central 456, CP 08001, Barcelona"

# Ejercicios:
# 18.1. Detecta si hay códigos postales en el texto (formato: CP seguido de 5 dígitos)
# 18.2. Extrae todos los códigos postales completos (incluyendo "CP")
# 18.3. Extrae solo los números de los códigos postales (sin "CP")
# 18.4. Extrae las ciudades asociadas a cada código postal
# 18.5. Reemplaza los códigos postales por "CP XXXXX"

# ===================================================
# STRING 19: Fórmulas matemáticas simples
# ===================================================
string19 <- "Fórmulas: y = 2x + 3, z = a^2 - b^2, w = (x + y) / 2"

# Ejercicios:
# 19.1. Detecta si hay fórmulas en el texto (pista: buscar patrones con =)
# 19.2. Extrae todas las fórmulas completas
# 19.3. Extrae solo las variables del lado izquierdo de cada fórmula (antes del =)
# 19.4. Extrae solo las expresiones del lado derecho (después del =)
# 19.5. Reemplaza todas las variables x, y, z por A, B, C respectivamente

# ===================================================
# STRING 20: Fragmento de código de programación
# ===================================================
string20 <- "function calcular(a, b) { let resultado = a * b; return resultado; }"

# Ejercicios:
# 20.1. Detecta si hay una declaración de función en el texto
# 20.2. Extrae el nombre de la función
# 20.3. Extrae los parámetros de la función (lo que está entre paréntesis)
# 20.4. Extrae el cuerpo de la función (lo que está entre llaves)
# 20.5. Reemplaza el operador * por + (para cambiar multiplicación por suma)



# ===================================================
# SOLUCIONES (primeras 4 strings)
# ===================================================

# Soluciones String 1
soluciones[[1]] <- list(
  e1 = str_detect(string1, "\\S+@\\S+\\.\\S+"),  # TRUE
  e2 = str_extract_all(string1, "\\S+@\\S+\\.\\S+")[[1]],  # "juan.perez@gmail.com" "jperez@empresa.com.ar"
  e3 = str_count(string1, "\\S+@\\S+\\.\\S+"),  # 2
  e4 = str_replace(string1, "gmail\\.com", "outlook.com"),  # "Mi correo es juan.perez@outlook.com y el de trabajo es jperez@empresa.com.ar"
  e5 = str_extract_all(string1, "\\S+(?=@)")[[1]]  # "juan.perez" "jperez"
)

# Soluciones String 2
soluciones[[2]] <- list(
  e1 = str_detect(string2, "\\(\\d+\\)\\s*\\d+-\\d+|\\d+-\\d+-\\d+|\\+\\d+\\s+\\d+\\s+\\d+\\s+\\d+-\\d+"),  # TRUE
  e2 = str_extract_all(string2, "\\(\\d+\\)\\s*\\d+-\\d+|\\d+-\\d+-\\d+|\\+\\d+\\s+\\d+\\s+\\d+\\s+\\d+-\\d+")[[1]],  # "(123) 456-7890" "987-654-3210" "+54 9 11 2345-6789"
  e3 = str_extract_all(string2, "\\d+", simplify = TRUE),  # Todos los números extraídos
  e4 = str_replace_all(string2, "\\(\\d+\\)\\s*\\d+-\\d+|\\d+-\\d+-\\d+|\\+\\d+\\s+\\d+\\s+\\d+\\s+\\d+-\\d+", "[PRIVADO]"),  # "Contactos: Juan [PRIVADO], María [PRIVADO] y Pedro [PRIVADO]"
  e5 = str_extract_all(string2, "\\b[A-Z][a-z]+\\b")[[1]]  # "Juan" "María" "Pedro"
)

# Soluciones String 3
soluciones[[3]] <- list(
  e1 = str_detect(string3, "\\d{1,2}[/.-]\\d{1,2}[/.-]\\d{4}"),  # TRUE
  e2 = str_extract_all(string3, "\\d{1,2}[/.-]\\d{1,2}[/.-]\\d{4}|\\d{4}-\\d{2}-\\d{2}")[[1]],  # "15/04/2023" "2022-10-25" "01.12.2024"
  e3 = str_count(string3, "\\d{1,2}[/.-]\\d{1,2}[/.-]\\d{4}|\\d{4}-\\d{2}-\\d{2}"),  # 3
  e4 = str_extract_all(string3, "\\d{1,2}/\\d{1,2}/\\d{4}")[[1]],  # "15/04/2023"
  e5 = str_replace_all(string3, "\\d{1,2}[/.-]\\d{1,2}[/.-]\\d{4}|\\d{4}-\\d{2}-\\d{2}", "FECHA")  # "Fechas importantes: FECHA, FECHA y FECHA"
)

# Soluciones String 4
soluciones[[4]] <- list(
  e1 = str_detect(string4, "https?://\\S+"),  # TRUE
  e2 = str_extract_all(string4, "https?://\\S+")[[1]],  # "https://www.mipagina.com/blog/articulo-123" "http://ejemplo.org"
  e3 = str_extract_all(string4, "(?<=https?://(?:www\\.)?)[\\w.-]+\\.\\w+")[[1]],  # "mipagina.com" "ejemplo.org"
  e4 = str_replace_all(string4, "http://", "https://"),  # "Visita mi sitio web https://www.mipagina.com/blog/articulo-123 o https://ejemplo.org"
  e5 = str_count(string4, "https://")  # 1
)

# Soluciones String 5
soluciones[[5]] <- list(
  e1 = str_detect(string5, "[A-Z]{3}-\\d{3}"),  # TRUE
  e2 = str_extract_all(string5, "[A-Z]{3}-\\d{3}")[[1]],  # "ABC-123" "XYZ-456" "MNO-789"
  e3 = str_extract_all(string5, "[A-Z]{3}(?=-\\d{3})")[[1]],  # "ABC" "XYZ" "MNO"
  e4 = str_extract_all(string5, "(?<=[A-Z]{3}-)\\d{3}")[[1]],  # "123" "456" "789"
  e5 = str_replace_all(string5, "[A-Z]{3}-\\d{3}", "PRODUCTO")  # "Los productos PRODUCTO, PRODUCTO y PRODUCTO están en oferta"
)

# Ejercicios adicionales
# 
# Para cada ejercicio, intenta:
# 1. Primero resolver con regex101.com para entender el patrón
# 2. Luego implementar la solución en R con stringr
# 3. Armar variaciones propias del ejercicio

# Ejemplo de flujo de trabajo para un estudiante:
# 
# 1. Copio el string1 en regex101.com
# 2. Para extraer emails pruebo con el patrón: \S+@\S+\.\S+
# 3. En R implemento:
#    emails <- str_extract_all(string1, "\\S+@\\S+\\.\\S+")
# 4. Verifico el resultado y ajusto si es necesario