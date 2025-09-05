# 10 Ejercicios Prácticos: Análisis Económico con WDI

## Configuración inicial

Antes de comenzar, ejecuta este código para preparar el entorno:

```r
library(tidyverse)
library(WDI)

# Países de América Latina para todos los ejercicios
paises_latam <- c("AR", "BO", "BR", "CL", "CO", "CR", "EC", "GT", "MX", "PE", "UY", "VE")
```

---

## EJERCICIO 1: Condicionales Básicos
**Tema:** `if_else()` y `case_when()`

**Datos necesarios:**
```r
# PIB per cápita y población
datos_ej1 <- WDI(country = paises_latam, 
                 indicator = c("NY.GDP.PCAP.CD", "SP.POP.TOTL"), 
                 start = 2022, end = 2022)
```

**Enunciado:**
Usando los datos de PIB per cápita y población de 2022:

1. Crea una variable `nivel_desarrollo` usando `if_else()` que clasifique países como "Alto" si el PIB per cápita > $12,000, y "Medio-Bajo" en caso contrario.

2. Crea una variable `categoria_poblacion` usando `case_when()` con estas categorías:
   - "Muy Grande": > 100 millones
   - "Grande": 25-100 millones  
   - "Mediano": 5-25 millones
   - "Pequeño": < 5 millones

3. Crea una variable `prioridad_desarrollo` que combine ambos criterios:
   - "Urgente": países pequeños con desarrollo medio-bajo
   - "Moderada": países grandes con desarrollo medio-bajo
   - "Baja": países con alto desarrollo
   - "Monitoreo": todos los demás

**Resultado esperado:** Un dataframe con las nuevas variables de clasificación.

---

## EJERCICIO 2: Lógica Condicional Compleja
**Tema:** `case_when()` con múltiples condiciones

**Datos necesarios:**
```r
# Inflación, desempleo y Gini
datos_ej2 <- WDI(country = paises_latam,
                 indicator = c("FP.CPI.TOTL.ZG", "SL.UEM.TOTL.ZS", "SI.POV.GINI"),
                 start = 2020, end = 2022)
```

**Enunciado:**
Usando los datos más recientes disponibles para cada país:

1. Filtra para conservar solo el año más reciente con datos completos para cada país.

2. Crea una variable `estabilidad_macro` usando `case_when()`:
   - "Muy Estable": inflación ≤ 5% Y desempleo ≤ 6%
   - "Estable": inflación ≤ 10% Y desempleo ≤ 10%
   - "Moderadamente Inestable": inflación ≤ 20% O desempleo ≤ 15%
   - "Inestable": todos los demás casos

3. Crea una variable `politica_recomendada` que considere:
   - Si inflación > 15%: "Control monetario"
   - Si desempleo > 10%: "Estímulo empleo"  
   - Si Gini > 50: "Reducir desigualdad"
   - Si inflación ≤ 5% Y desempleo ≤ 6%: "Mantener curso"
   - Otros casos: "Política mixta"

**Resultado esperado:** Análisis de estabilidad macroeconómica y recomendaciones por país.

---

## EJERCICIO 3: Window Functions - Análisis Temporal
**Tema:** `lag()`, `lead()`, y cálculos temporales

**Datos necesarios:**
```r
# PIB (crecimiento anual)
datos_ej3 <- WDI(country = c("AR", "BR", "CL", "MX"),
                 indicator = "NY.GDP.MKTP.KD.ZG",
                 start = 2015, end = 2023)
```

**Enunciado:**
Analiza la evolución del crecimiento del PIB:

1. Para cada país, calcula usando window functions:
   - `crecimiento_anterior`: valor del año anterior con `lag()`
   - `crecimiento_siguiente`: valor del año siguiente con `lead()`
   - `aceleracion`: diferencia entre crecimiento actual y anterior
   - `sera_mejor`: TRUE si el próximo año será mejor que el actual

2. Identifica períodos de **recesión técnica** (2 años consecutivos de crecimiento negativo) creando una variable `recesion_tecnica`.

3. Para cada país, encuentra el **año de mejor performance** usando `row_number()` y crea una variable `mejor_año` (TRUE/FALSE).

4. Calcula el **crecimiento promedio histórico** de cada país hasta cada año usando `cummean()`.

**Resultado esperado:** Análisis temporal completo del crecimiento económico.

---

## EJERCICIO 4: Window Functions - Rankings y Acumulativas
**Tema:** `rank()`, `cumsum()`, `rollmean()`

**Datos necesarios:**
```r
# PIB per cápita anual
datos_ej4 <- WDI(country = paises_latam,
                 indicator = "NY.GDP.PCAP.CD", 
                 start = 2018, end = 2022)
```

**Enunciado:**
Realiza un análisis de competitividad regional:

1. Para cada año, calcula el **ranking regional** de PIB per cápita usando:
   - `ranking_regional`: posición con `rank()`
   - `percentil_regional`: percentil con `percent_rank()`

2. Para cada país, calcula indicadores históricos:
   - `pib_maximo_historico`: máximo alcanzado hasta ese año con `cummax()`
   - `distancia_a_pico`: porcentaje de distancia al máximo histórico
   - `promedio_movil_3años`: promedio móvil de 3 años con `rollmean()`

3. Clasifica países según su **trayectoria**:
   - "Líder sostenido": ranking ≤ 3 en los últimos 3 años
   - "Ascendente": mejorando posiciones consistentemente
   - "Descendente": perdiendo posiciones
   - "Volátil": ranking muy variable

**Resultado esperado:** Análisis de competitividad y trayectorias de desarrollo.

---

## EJERCICIO 5: Pivot Longer - Reestructuración Temporal
**Tema:** `pivot_longer()` con datos económicos

**Datos necesarios:**
```r
# Múltiples indicadores por año
datos_ej5 <- WDI(country = c("AR", "BR", "CL"),
                 indicator = c("NY.GDP.PCAP.CD", "FP.CPI.TOTL.ZG", "SL.UEM.TOTL.ZS"),
                 start = 2020, end = 2023)
```

**Enunciado:**
Los datos del WDI vienen en formato largo. Tu tarea es simular el problema típico de datos "anchos":

1. **Simula datos anchos**: Usa `pivot_wider()` para crear una tabla donde cada indicador-año sea una columna (ej: "PIB_2020", "PIB_2021", "Inflacion_2020", etc.).

2. **Identifica el problema**: Explica por qué este formato es problemático para análisis temporal.

3. **Convierte a formato largo**: Usa `pivot_longer()` para volver al formato original, creando columnas para:
   - `indicador`: tipo de variable económica
   - `año`: año de la observación  
   - `valor`: valor del indicador

4. **Realiza análisis que solo son posibles en formato largo**:
   - Correlación entre indicadores por país
   - Evolución promedio regional por indicador
   - Identificar el año con mayor volatilidad en cada indicador

**Resultado esperado:** Demostración práctica de por qué el formato largo es superior para análisis.

---

## EJERCICIO 6: Pivot Wider - Matrices de Análisis
**Tema:** `pivot_wider()` para reportes y comparaciones

**Datos necesarios:**
```r
# Exportaciones como % del PIB
datos_ej6 <- WDI(country = paises_latam,
                 indicator = "NE.EXP.GNFS.ZS",
                 start = 2021, end = 2022)
```

**Enunciado:**
Crea diferentes vistas analíticas usando `pivot_wider()`:

1. **Matriz de comparación temporal**: Crea una tabla donde:
   - Filas: países
   - Columnas: años (2021, 2022)
   - Valores: exportaciones como % del PIB
   - Agrega una columna con el cambio porcentual entre años

2. **Dashboard de clasificación**: Transforma los datos para crear:
   - Filas: niveles de apertura ("Alta" >30%, "Media" 20-30%, "Baja" <20%)
   - Columnas: años
   - Valores: número de países en cada categoría

3. **Reporte ejecutivo**: Crea una tabla donde:
   - Filas: estadísticas (promedio, mediana, máximo, mínimo)
   - Columnas: años
   - Valores: estadísticas de exportaciones regionales

**Resultado esperado:** Tres formatos diferentes de reporte para distintas audiencias.

---

## EJERCICIO 7: Joins Básicos - Integrando Fuentes
**Tema:** `inner_join()`, `left_join()`, `full_join()`

**Datos necesarios:**
```r
# Datos demográficos
datos_demo <- WDI(country = paises_latam,
                  indicator = c("SP.POP.TOTL", "SP.URB.TOTL.IN.ZS"),
                  start = 2022, end = 2022)

# Datos económicos (algunos países pueden faltar)
datos_econ <- WDI(country = c("AR", "BR", "CL", "CO", "MX", "PE"),
                  indicator = c("NY.GDP.MKTP.CD", "GC.DOD.TOTL.GD.ZS"),
                  start = 2022, end = 2022)
```

**Enunciado:**
Integra información de diferentes fuentes del WDI:

1. **Análisis de cobertura**:
   - Usa `anti_join()` para identificar países con datos demográficos pero sin datos económicos
   - Usa `semi_join()` para identificar países que tienen ambos tipos de datos

2. **Integración conservadora**: 
   - Usa `inner_join()` para conservar solo países con datos completos
   - Calcula estadísticas para este subconjunto "limpio"

3. **Integración comprehensiva**:
   - Usa `left_join()` tomando datos demográficos como base
   - Analiza el patrón de datos faltantes
   - Crea variables indicadoras de disponibilidad de datos

4. **Validación del join**:
   - Verifica que no se hayan duplicado observaciones
   - Confirma que el número de filas es el esperado

**Resultado esperado:** Dataset integrado con análisis de calidad de datos.

---

## EJERCICIO 8: Joins Complejos - Datos Panel
**Tema:** Joins con múltiples claves y validaciones

**Datos necesarios:**
```r
# PIB anual 2020-2022
pib_anual <- WDI(country = c("AR", "BR", "CL"),
                 indicator = "NY.GDP.MKTP.KD.ZG",
                 start = 2020, end = 2022)

# Inflación anual 2020-2022 (simular datos faltantes)
inflacion_anual <- WDI(country = c("AR", "BR", "CL"),
                       indicator = "FP.CPI.TOTL.ZG", 
                       start = 2020, end = 2022) %>%
  filter(!(country == "Chile" & year == 2021))  # Simular dato faltante
```

**Enunciado:**
Trabaja con datos panel que requieren joins por país Y año:

1. **Join con claves múltiples**:
   - Une ambos datasets usando `left_join()` con claves `country` y `year`
   - Identifica qué combinaciones país-año tienen datos faltantes

2. **Manejo de datos faltantes**:
   - Crea variables indicadoras para identificar patrones de datos faltantes
   - Calcula qué porcentaje de datos está completo por país y por año

3. **Interpolación simple**:
   - Para datos de inflación faltantes, crea una estimación usando el promedio del año anterior y posterior
   - Marca estas estimaciones con una variable `dato_estimado`

4. **Análisis de relación**:
   - Solo con datos completos (no estimados), analiza la correlación entre crecimiento PIB e inflación
   - Identifica outliers usando `case_when()`

**Resultado esperado:** Dataset panel completo con análisis de calidad y relaciones.

---

## EJERCICIO 9: Análisis Integrado - Crisis COVID
**Tema:** Combinando todas las técnicas

**Datos necesarios:**
```r
# Múltiples indicadores 2018-2023
datos_covid <- WDI(country = paises_latam,
                   indicator = c("NY.GDP.MKTP.KD.ZG", "SL.UEM.TOTL.ZS", 
                                "GC.XPN.TOTL.GD.ZS", "BX.KLT.DINV.WD.GD.ZS"),
                   start = 2018, end = 2023)
```

**Enunciado:**
Realiza un análisis completo del impacto de COVID-19:

1. **Preparación de datos**:
   - Filtra para conservar solo países con datos en al menos 4 de los 6 años
   - Usa `pivot_wider()` y `pivot_longer()` para crear una estructura analítica óptima

2. **Análisis temporal con window functions**:
   - Calcula el impacto de 2020 vs 2019 para cada indicador usando `lag()`
   - Identifica el año de peor performance por país usando `rank()`
   - Calcula la recuperación acumulada desde 2020 usando `cumsum()`

3. **Clasificación con condicionales**:
   - Clasifica países según impacto COVID usando `case_when()`:
     - "Impacto severo": caída PIB > 8% en 2020
     - "Impacto moderado": caída PIB 3-8%
     - "Impacto leve": caída PIB < 3%
     - "Sin contracción": crecimiento positivo en 2020

4. **Análisis comparativo**:
   - Crea una matriz pre-COVID (2018-2019) vs post-COVID (2021-2023)
   - Identifica qué países se han recuperado completamente

**Resultado esperado:** Análisis comprehensivo del impacto y recuperación post-COVID.

---

## EJERCICIO 10: Dashboard Económico Regional
**Tema:** Proyecto final integrando todas las funciones

**Datos necesarios:**
```r
# Dataset comprehensivo
dashboard_data <- WDI(country = paises_latam,
                      indicator = c("NY.GDP.PCAP.CD", "FP.CPI.TOTL.ZG", 
                                   "SL.UEM.TOTL.ZS", "NE.EXP.GNFS.ZS",
                                   "BX.KLT.DINV.WD.GD.ZS", "SI.POV.GINI"),
                      start = 2019, end = 2023)
```

**Enunciado:**
Crea un dashboard económico regional completo:

1. **Módulo de Rankings** (Window Functions):
   - Ranking actual (2023) de países por PIB per cápita
   - Cambios de posición vs 2019 usando `lag()`
   - Identificar "ganadores" y "perdedores" de la década

2. **Módulo de Estabilidad** (Condicionales):
   - Índice de estabilidad combinando inflación, desempleo y volatilidad del PIB
   - Clasificación de riesgo país usando múltiples criterios
   - Recomendaciones de política automáticas

3. **Módulo de Integración** (Joins):
   - Combinar datos WDI con clasificaciones manuales (crear tu propia tabla de subregiones)
   - Análisis por subregión (Cono Sur, Andinos, Centroamérica, etc.)

4. **Módulo de Reportes** (Pivots):
   - Tabla ejecutiva: países en filas, indicadores clave en columnas
   - Tabla temporal: años en columnas, estadísticas regionales en filas
   - Matriz de correlaciones entre indicadores

5. **Análisis Final**:
   - Identifica el país "más equilibrado" (buen desempeño en múltiples dimensiones)
   - Detecta países con patrones atípicos o preocupantes
   - Genera recomendaciones automáticas basadas en los datos

**Resultado esperado:** Dashboard completo que demuestre dominio de todas las técnicas aprendidas.

---

## Criterios de Evaluación

Para cada ejercicio, los estudiantes deben:

1. **Código funcional**: El código debe ejecutarse sin errores
2. **Técnica correcta**: Usar las funciones apropiadas para cada tarea
3. **Interpretación**: Comentar los resultados obtenidos
4. **Validación**: Verificar que los resultados tienen sentido económico
5. **Documentación**: Código bien comentado y reproducible

## Consejos Generales

- Siempre explora los datos antes de aplicar transformaciones
- Verifica que los joins no introduzcan duplicados inesperados
- Maneja datos faltantes de manera explícita
- Usa `glimpse()` y `summary()` para validar transformaciones
- Documenta las decisiones metodológicas tomadas