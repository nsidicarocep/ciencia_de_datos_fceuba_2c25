# TRABAJO FINAL
## Ciencia de Datos para Economía y Negocios

---

## CRITERIOS DE EVALUACIÓN

El presente trabajo final tiene como objetivo evaluar la capacidad de los estudiantes para llevar a cabo un proyecto integral de análisis de datos, desde la formulación de hipótesis hasta la comunicación de resultados. A continuación se detallan los criterios de evaluación:

## Grupos 

El trabajo puede ser realizado de la siguiente manera: 

- Individualmente: corrección severa 
- De a dos: corrección normal 
- De a tres: corrección un poco más complicada
- De a cuatro: corrección severa

No implica que de a dos sea fácil, pero sí voy a ser más contemplativo. 

---

### 1. FORMULACIÓN DE HIPÓTESIS Y DISEÑO DE INVESTIGACIÓN

Los estudiantes deberán formular una **hipótesis falsable** y explicitar claramente los pasos metodológicos necesarios para responderla.

**Excepción:** En el caso de trabajos centrados en **Análisis de Componentes Principales (PCA)**, el enfoque puede orientarse a la aplicación del método sin necesidad de plantear una hipótesis causal.

**Requisitos:**
- Las hipótesis deben ser completas y específicas
- El diseño debe contemplar todas las dimensiones relevantes del problema

**Ejemplo:**
Si se desea analizar la tasa de criminalidad en diferentes zonas, el análisis deberá:
- Considerar distintos horarios
- Categorizar las zonas según el tránsito que tengan
- Incluir variables contextuales relevantes

---

### 2. ORGANIZACIÓN DEL PROYECTO

El proyecto deberá respetar estrictamente la estructura de carpetas y archivos vista en la clase de organización de proyectos.

**Estructura mínima requerida:**

```
proyecto/
├── data/
│   ├── raw/              # Datos crudos originales
│   ├── clean/            # Datos limpios
│   └── processed/        # Datos procesados
├── output/
│   ├── tables/           # Tablas finales
│   └── figures/          # Gráficos finales
├── scripts/              # Códigos del análisis
└── README.md
```

**Principio de autocontención:**
- Cada script debe generar un output específico
- El script siguiente debe tomar ese output como input
- Los códigos deben ser reproducibles de manera secuencial. Es decir, llamarse 01_descripcion_de_lo_que_hace.R, el siguiente 02_descripcion_siguiente.R, etc. Un ejemplo podría ser: 01_limpieza, 02_deteccion_de_outliers, 03_procesamiento_de_base, 04_tablas, 05_graficos

---

### 3. ANÁLISIS EXPLORATORIO DE DATOS (EDA)

Realizar un análisis exploratorio exhaustivo que incluya:

- **Identificación de columnas:** ¿Qué variables son relevantes para el análisis?
- **Tipo de datos:** Numérico, categórico, temporal, etc.
- **Datos vacíos:** Identificar presencia y patrón de valores faltantes
- **Estructura general:** Dimensiones del dataset, observaciones disponibles
- **Primeras observaciones:** Detección inicial de patrones o anomalías

---

### 4. ESTADÍSTICAS DESCRIPTIVAS

Calcular y presentar estadísticas descriptivas de las variables de interés, incluyendo:

- Medidas de tendencia central (media, mediana, moda)
- Medidas de dispersión (desvío estándar, rango intercuartílico)
- Distribución de frecuencias para variables categóricas
- Visualizaciones complementarias (histogramas, boxplots, etc.)

---

### 5. ANÁLISIS DE OUTLIERS Y DATOS FALTANTES

**5.1. Identificación**
- Detectar valores atípicos mediante métodos apropiados
- Cuantificar y caracterizar los datos faltantes

**5.2. Decisiones y justificación**
- Explicitar qué decisión se tomó con respecto a outliers y datos faltantes (eliminar, imputar, mantener)
- Fundamentar cada decisión tomada
- Detallar los supuestos que deben cumplirse para que esas decisiones sean válidas
- Analizar los posibles efectos de estas decisiones sobre los resultados

**Ejemplo de justificación:**
"Se decidió eliminar observaciones con valores faltantes en la variable 'ingreso' porque representan menos del 5% de la muestra y no se observa un patrón sistemático en su ausencia. Se asume que los datos faltan completamente al azar (MCAR). Por lo tanto, no se debería esperar un efecto en las estadísticas. Sin embargo, en caso de que los datos falten por otros motivos, esta decisión puede producir un sesgo hacia determinado lado."

**Aclaración**
En caso de trabajar con series temporales, deberán hacer interpolación de datos y justificar por qué hicieron dicha interpolación. 

---

### 6. EVALUACIÓN DEL IMPACTO DE LA LIMPIEZA

Una vez realizadas modificaciones a los datos (eliminación o transformación), se deberá:

- Recalcular las estadísticas descriptivas más relevantes
- Comparar con las estadísticas originales
- Cuantificar el nivel de alteración producido
- Evaluar si las conclusiones podrían verse afectadas

---

### 7. ANÁLISIS DE ESTADÍSTICA INFERENCIAL

Los estudiantes deberán aplicar **al menos** los siguientes métodos de inferencia estadística:

**Opción A:**
- Al menos un **test de hipótesis**
- Un **análisis de regresión** o **ANOVA**

**Opción B:**
- Al menos un **test de hipótesis**
- Un **Análisis de Componentes Principales (PCA)**

**Requisito fundamental:**
Los análisis inferenciales deben estar directamente relacionados con la hipótesis planteada o con el objetivo del estudio.

**Aclaración:**
Al refererirme a test no me refiero a test que analicen si se cumplen determinados supuestos (eso lo deben hacer siempre), sino a test de comparación de grupos, medias, individuos, etc. 

---

### 8. VISUALIZACIONES Y STORYTELLING

**8.1. Gráficos editorializados (mínimo 2)**

Crear al menos **dos gráficos editorializados** que:
- Aporten al storytelling del análisis
- Cumplan con todos los elementos de buenas visualizaciones vistos en clase:
  - Títulos claros y descriptivos
  - Etiquetas en los ejes
  - Leyendas apropiadas
  - Uso adecuado de colores
  - Proporciones correctas
  - Fuente de datos
  - Interpretación accesible

**8.2. Gráficos adicionales**

Si se elaboran gráficos adicionales (exploratorios o complementarios):
- No requieren el mismo nivel de editorialización
- Deben cumplir con los criterios básicos de claridad y lectura
- Pueden ser más simples en su presentación

---

### 9. CONCLUSIONES

Redactar conclusiones que incluyan:

- **Respuesta a la hipótesis:** ¿Se confirmó o refutó?
- **Principales hallazgos:** ¿Qué se descubrió en el análisis?
- **Limitaciones del estudio:** Datos faltantes, tamaño muestral, supuestos no cumplidos
- **Implicancias:** Relevancia práctica de los resultados
- **Futuras líneas de investigación:** ¿Qué análisis complementarios podrían realizarse?

---

## FORMATO DE ENTREGA

- **Códigos:** Scripts en R organizados según la estructura de carpetas
- **Informe:** Documento en formato diapositivas (puede ser por google slides, PowerPoint o como gusten siempre y cuando sean diapositivas) que integre análisis, visualizaciones y conclusiones
- **Datos:** Incluir datos raw y procesados en las carpetas correspondientes
- **README:** Archivo que explique cómo reproducir el análisis (opcional)

Todo debe ser cargado en un Github público y deberán cargar el link, junto a los miembros del grupo en un formulario que se compartirá la semana de la entrega. Si no es cargado en Github o en el formulario no se va a considerar entregado. 

---

## CRITERIOS GENERALES DE EVALUACIÓN

- **Rigor metodológico:** Aplicación correcta de técnicas estadísticas
- **Reproducibilidad:** Capacidad de replicar el análisis
- **Claridad expositiva:** Comunicación efectiva de resultados
- **Pensamiento crítico:** Reflexión sobre limitaciones y supuestos
- **Calidad de código:** Legibilidad, documentación, eficiencia

---
