# Ejercicios Prácticos con Datos Reales
**Tidyverse - Las 6 Funciones Principales**

## 📋 Bases de datos a utilizar

### Base 1: Employment by sex, education and economic activity - ILOSTAT
Variables principales: país, año, sexo, sector económico, empleo (miles)

Descargar de: https://rplumber.ilo.org/files/website/bulk/indicator.html - El archivo se llama EMP_TEMP_SEX_EDU_EC2_NB_A 

Diccionarios en: https://ilostat.ilo.org/es/data/bulk/ 

### Base 2: Average monthly earnings by sex and economic activity - ILOSTAT  
Variables principales: país, año, sexo, sector económico, salario promedio

Descargar de: https://rplumber.ilo.org/files/website/bulk/indicator.html - El archivo se llama EAR_4MTH_SEX_ECO_CUR_NB_A 

Diccionarios en: https://ilostat.ilo.org/es/data/bulk/

### Base 3: Empleo por sectores Argentina 1950-2018 (Argendata)
**URL**: https://raw.githubusercontent.com/argendatafundar/data/main/ESTPRO/empleo_sectores_ggdc_1950_2018.csv
Variables principales: año, sector, empleo

### Base 4: VAB sectorial por provincia 2004-2022 (Argendata)  
**URL**: https://raw.githubusercontent.com/argendatafundar/data/main/ESTPRO/vab_sectorial_provincia.csv
Variables principales: provincia, año, actividad, valor agregado bruto

### Base 5: Salarios SBC por sector 1996-2022 (Argendata)
**URL**: https://raw.githubusercontent.com/argendatafundar/data/main/SEBACO/12_salarios_sbc_y_desagregado.csv  
Variables principales: fecha, sector, salario

---

## 🎯 EJERCICIOS BÁSICOS - Bases ILOSTAT

### Ejercicio 1: Exploración básica 
**Base**: Employment by Demographics  
**Funciones**: `select()`, `arrange()`

Seleccionar solo las columnas de país, año, sexo y empleo total. Ordenar por país y año de forma ascendente. Mostrar las primeras 15 filas y determinar cuántos países únicos hay en la base.

---

### Ejercicio 2: Filtros básicos
**Base**: Employment by Demographics  
**Funciones**: `filter()`, `select()`

Filtrar datos solo para el año 2020 y para mujeres. Seleccionar país, sector económico y empleo. ¿Cuántas observaciones quedan después del filtro? ¿Cuáles son los 3 países con mayor empleo femenino?

---

### Ejercicio 3: Creación de variables
**Base**: Employment by Demographics  
**Funciones**: `mutate()`, `filter()`

Crear una variable que clasifique el empleo en: "Alto" (≥1000 miles), "Medio" (500-999 miles), "Bajo" (<500 miles). Filtrar solo los países con empleo "Alto". ¿Cuáles son los 5 sectores con mayor frecuencia de empleo alto?

---

### Ejercicio 4: Análisis por grupos  
**Base**: Employment by Demographics  
**Funciones**: `group_by()`, `summarise()`, `arrange()`

Agrupar por década (crear variable década primero). Calcular el empleo promedio, máximo y mínimo por década. Ordenar por empleo promedio de mayor a menor. ¿En qué década el empleo fue mayor en promedio?

---

## 💰 EJERCICIOS INTERMEDIOS - Salarios

### Ejercicio 5: Brecha salarial por género
**Base**: Average Monthly Earnings  
**Funciones**: `filter()`, `group_by()`, `summarise()`

Filtrar datos para el período 2015-2020. Agrupar por sexo y sector económico. Calcular salario promedio y mediano por grupo. ¿En qué sectores la diferencia salarial entre géneros es mayor en términos absolutos?

---

### Ejercicio 6: Ranking de sectores por salarios
**Base**: Average Monthly Earnings  
**Funciones**: `group_by()`, `summarise()`, `arrange()`, `mutate()`

Ignorando la variable sexo, agrupar por sector económico. Calcular salario promedio por sector. Crear una variable de ranking (1 = mayor salario) y mostrar solo los top 10 sectores mejor pagados. ¿Cuál es la diferencia salarial entre el sector #1 y #10?

---

### Ejercicio 7: Crecimiento salarial por décadas 
**Base**: Average Monthly Earnings  
**Funciones**: `mutate()`, `filter()`, `group_by()`, `summarise()`

**Desafío especial**: Sin usar `lag()` o `lead()`, calcular el crecimiento salarial promedio por década.

**Estrategia sugerida**: 
- Crear variable de década
- Filtrar solo un país específico 
- Para cada década, calcular el salario del primer año y del último año
- Calcular el crecimiento porcentual: (salario_final - salario_inicial) / salario_inicial * 100

¿En qué década los salarios reales crecieron más?

---

## 🇦🇷 EJERCICIOS ARGENTINA - Datos históricos

### Ejercicio 8: Transformación productiva argentina
**Base**: Empleo sectores 1950-2018  
**Funciones**: `filter()`, `mutate()`, `arrange()`

Filtrar años cada 10 años: 1950, 1960, 1970, 1980, 1990, 2000, 2010, 2018. Crear una variable que clasifique los períodos en: "Industrialización" (1950-1970), "Crisis y ajuste" (1980-2000), "Siglo XXI" (2001-2018). ¿Cómo cambió la participación de la industria manufacturera vs servicios a lo largo del tiempo?

---

### Ejercicio 9: Estabilidad sectorial  
**Base**: Empleo sectores 1950-2018  
**Funciones**: `group_by()`, `summarise()`, `mutate()`, `arrange()`

Agrupar por sector productivo. Calcular empleo promedio por sector en todo el período y el coeficiente de variación (desviación estándar / media) para medir volatilidad. Crear ranking de sectores por empleo promedio y por estabilidad. ¿Qué sectores combinan alta participación con baja volatilidad?

---

## 🏭 EJERCICIOS INTEGRADORES - Nuevas bases

### Ejercicio 10: Especialización provincial 
**Base**: VAB sectorial por provincia 2004-2022  
**Funciones**: Todas las principales

**Consigna completa**:
1. Filtrar solo los años 2004, 2010, 2016, 2022 para analizar cambios cada 6 años
2. Crear una variable que calcule la participación de cada actividad en el VAB total de cada provincia por año  
3. Identificar la actividad principal (mayor participación) de cada provincia en cada año
4. Crear una variable que clasifique las provincias según su especialización:
   - "Primario" si agricultura/minería > 30%
   - "Industrial" si industria manufacturera > 25%  
   - "Servicios" si servicios > 60%
   - "Diversificado" en otros casos
5. Calcular cuántas provincias hay de cada tipo por año
6. Determinar qué provincias cambiaron de especialización entre 2004 y 2022

**Preguntas clave**: ¿Argentina se está desindustrializando a nivel provincial? ¿Qué provincias mantienen perfil industrial?

---

### Ejercicio 11: Evolución salarial por sectores SBC
**Base**: Salarios SBC 1996-2022  
**Funciones**: Todas las principales

**Consigna completa**:
1. Crear variables de año y década a partir de la fecha
2. Filtrar solo décadas completas: 2000s (2000-2009), 2010s (2010-2019), 2020s (2020-2022)
3. Para cada sector y década, calcular el salario real promedio (asumiendo inflación constante como proxy)
4. Crear una variable de crecimiento salarial por década por sector (comparando con década anterior)
5. Identificar los 5 sectores con mayor crecimiento salarial en cada década
6. Calcular la brecha salarial: ratio entre el sector mejor y peor pagado por década  

**Preguntas clave**: ¿La brecha salarial intersectorial se amplió o redujo? ¿Qué sectores son consistentemente mejor remunerados?

---

## 📝 Metodología de trabajo sugerida

### Para cada ejercicio:

**1. Exploración inicial** (siempre primero)
- Usar `glimpse()`, `head()`, `summary()`
- Entender estructura y variables disponibles
- Identificar valores faltantes o atípicos

**2. Planificación** (pseudocódigo)
- Escribir los pasos en lenguaje natural
- Identificar qué funciones usar en cada paso
- Considerar el orden lógico de las operaciones

**3. Implementación paso a paso**
- Construir el pipeline gradualmente
- Probar cada paso antes de agregar el siguiente
- Usar variables intermedias si es necesario

---

## 🔍 Estrategias para cálculos sin lag/lead

### Crecimiento entre períodos:
```
Opción A: Filtrar años específicos
- Crear datasets separados para año inicial y final
- Unir manualmente los resultados 

Opción B: Usar min() y max() por grupo
- Agrupar por década y variable de interés
- Calcular valor mínimo y máximo por grupo
- Calcular crecimiento: (max - min) / min * 100

Opción C: Comparación con año base
- Definir un año base (ej: 2000)
- Calcular crecimiento acumulado desde año base
```

### Para análisis de convergencia:
```
- Calcular diferencias absolutas respecto a media nacional
- Usar coeficiente de variación entre provincias por año
- Comparar dispersión inicial vs final
```