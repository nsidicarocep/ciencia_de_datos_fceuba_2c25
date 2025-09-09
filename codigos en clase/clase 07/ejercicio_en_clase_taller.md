# Ejercicio en clase taller 

## Generación de la Base de Datos

```r
# =============================================================================
# CONFIGURACIÓN Y GENERACIÓN DE DATOS
# =============================================================================

library(tidyverse)
library(lubridate)

set.seed(2024)

# TABLA 1: Trabajadores (base principal)
trabajadores <- tibble(
  id_trabajador = 1:800,
  dni = sample(20000000:45000000, 800),
  edad = sample(18:65, 800, replace = TRUE),
  genero = sample(c("Mujer", "Hombre"), 800, replace = TRUE, prob = c(0.52, 0.48)),
  nivel_educativo = sample(c("Primario", "Secundario", "Terciario", "Universitario"), 
                          800, replace = TRUE, prob = c(0.15, 0.45, 0.2, 0.2)),
  provincia_nacimiento = sample(c("Buenos Aires", "CABA", "Córdoba", "Santa Fe", "Mendoza", "Tucumán"), 
                               800, replace = TRUE, prob = c(0.35, 0.15, 0.15, 0.15, 0.1, 0.1)),
  fecha_nacimiento = as.Date("2024-01-01") - years(edad) - days(sample(0:364, 800, replace = TRUE)),
  estado_civil = sample(c("Soltero", "Casado", "Divorciado", "Viudo"), 800, replace = TRUE, prob = c(0.4, 0.45, 0.1, 0.05))
)

# TABLA 2: Empleos
empleos <- tibble(
  id_empleo = 1:1200,
  id_trabajador = sample(trabajadores$id_trabajador, 1200, replace = TRUE),
  id_empresa = sample(1:150, 1200, replace = TRUE),
  fecha_inicio = sample(seq(as.Date("2020-01-01"), as.Date("2024-01-01"), by = "day"), 1200, replace = TRUE),
  fecha_fin = ifelse(runif(1200) < 0.3, 
                     sample(seq(as.Date("2021-01-01"), as.Date("2024-12-31"), by = "day"), 1200, replace = TRUE),
                     NA),
  salario_bruto = round(rnorm(1200, mean = 180000, sd = 60000)),
  horas_semanales = sample(c(20, 35, 40, 48), 1200, replace = TRUE, prob = c(0.1, 0.2, 0.6, 0.1)),
  sector = sample(c("Público", "Privado", "Cuenta Propia"), 1200, replace = TRUE, prob = c(0.25, 0.65, 0.1)),
  rama_actividad = sample(c("Industria", "Servicios", "Comercio", "Construcción", "Agro", "Tecnología"), 
                         1200, replace = TRUE, prob = c(0.2, 0.35, 0.2, 0.1, 0.05, 0.1))
) %>%
  mutate(
    fecha_fin = as.Date(fecha_fin, origin = "1970-01-01"),
    salario_bruto = pmax(salario_bruto, 80000),
    empleo_activo = is.na(fecha_fin) | fecha_fin > as.Date("2024-01-01")
  )

# TABLA 3: Empresas
empresas <- tibble(
  id_empresa = 1:150,
  razon_social = paste("Empresa", 1:150, "SA"),
  cuit = paste0("30-", sample(10000000:99999999, 150), "-", sample(0:9, 150)),
  provincia_sede = sample(c("Buenos Aires", "CABA", "Córdoba", "Santa Fe", "Mendoza"), 
                         150, replace = TRUE, prob = c(0.4, 0.3, 0.15, 0.1, 0.05)),
  tamaño_empresa = sample(c("Micro", "Pequeña", "Mediana", "Grande"), 150, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1)),
  año_fundacion = sample(1950:2020, 150, replace = TRUE),
  facturacion_anual = case_when(
    tamaño_empresa == "Micro" ~ round(runif(150, 1, 50) * 1000000),
    tamaño_empresa == "Pequeña" ~ round(runif(150, 50, 200) * 1000000),
    tamaño_empresa == "Mediana" ~ round(runif(150, 200, 1000) * 1000000),
    tamaño_empresa == "Grande" ~ round(runif(150, 1000, 5000) * 1000000)
  ),
  certificacion_iso = sample(c(TRUE, FALSE), 150, replace = TRUE, prob = c(0.3, 0.7))
)

# TABLA 4: Viviendas
viviendas <- tibble(
  id_trabajador = trabajadores$id_trabajador,
  tipo_vivienda = sample(c("Casa", "Departamento", "Inquilinato", "Villa"), 800, replace = TRUE, prob = c(0.6, 0.25, 0.1, 0.05)),
  provincia_vivienda = sample(c("Buenos Aires", "CABA", "Córdoba", "Santa Fe", "Mendoza", "Tucumán"), 
                             800, replace = TRUE, prob = c(0.4, 0.2, 0.15, 0.15, 0.05, 0.05)),
  tenencia = sample(c("Propietario", "Inquilino", "Ocupante", "Familiar"), 800, replace = TRUE, prob = c(0.5, 0.3, 0.1, 0.1)),
  ambientes = sample(1:6, 800, replace = TRUE, prob = c(0.1, 0.2, 0.3, 0.25, 0.1, 0.05)),
  m2_superficie = round(20 + ambientes * 15 + rnorm(800, 0, 10)),
  valor_estimado = case_when(
    provincia_vivienda == "CABA" ~ m2_superficie * runif(800, 3000, 5000),
    provincia_vivienda == "Buenos Aires" ~ m2_superficie * runif(800, 1500, 3000),
    TRUE ~ m2_superficie * runif(800, 800, 2000)
  ),
  distancia_trabajo_km = round(runif(800, 0.5, 50), 1),
  tiempo_traslado_min = round(distancia_trabajo_km * runif(800, 1.5, 3) + rnorm(800, 0, 5))
) %>%
  mutate(
    m2_superficie = pmax(m2_superficie, 15),
    tiempo_traslado_min = pmax(tiempo_traslado_min, 5)
  )

# TABLA 5: Movilidad laboral
movilidad <- expand_grid(
  id_trabajador = sample(trabajadores$id_trabajador, 400),
  año = 2020:2024
) %>%
  group_by(id_trabajador) %>%
  slice_sample(n = sample(1:4, 1)) %>%
  ungroup() %>%
  mutate(
    id_empleo = sample(empleos$id_empleo, n()),
    tipo_cambio = sample(c("Promoción", "Cambio empresa", "Cambio sector", "Despido", "Renuncia"), 
                        n(), replace = TRUE),
    variacion_salarial = case_when(
      tipo_cambio == "Promoción" ~ runif(n(), 0.1, 0.4),
      tipo_cambio == "Cambio empresa" ~ runif(n(), -0.1, 0.3),
      tipo_cambio == "Cambio sector" ~ runif(n(), -0.2, 0.2),
      tipo_cambio == "Despido" ~ runif(n(), -0.3, 0),
      tipo_cambio == "Renuncia" ~ runif(n(), -0.1, 0.2)
    )
  )
```

---

## **EJERCICIO 1: Análisis de Desigualdad Salarial Multi-dimensional (20 minutos)**

### Objetivo: 
Crear cuartiles salariales por género y nivel educativo, analizar proporciones y calcular brechas de género en el cuartil superior.

### Consigna:
Integrar todas las tablas principales (trabajadores, empleos activos, empresas, viviendas) y realizar un análisis de inequidad salarial. Calcular cuartiles salariales agrupados por género y nivel educativo. Determinar qué proporción de cada grupo está en cada cuartil. Convertir a formato comparativo y calcular la brecha de género específicamente en el Q4.

### Especificaciones técnicas:
- **Filtro obligatorio:** Solo empleos con `empleo_activo == TRUE`
- **Fórmula de brecha:** `brecha_Q4 = proporcion_Q4_Hombre - proporcion_Q4_Mujer`
- **Orden final:** Descendente por brecha_Q4

### Funciones clave: 
`inner_join()`, `ntile()`, `group_by()`, `summarise()`, `pivot_wider()`

### Columnas requeridas:
- `nivel_educativo`
- `Hombre` (proporción en Q4) 
- `Mujer` (proporción en Q4)
- `brecha_Q4`

---

## **EJERCICIO 2: Matriz de Transición Laboral Temporal (25 minutos)**

### Objetivo:
Analizar la movilidad entre sectores laborales usando window functions para identificar transiciones y crear una matriz de flujos.

### Consigna:
Usar la tabla de movilidad para identificar cambios de sector por trabajador a lo largo del tiempo. Calcular las probabilidades de transición desde cada sector hacia otros sectores. Crear una matriz cuadrada que muestre estos flujos. Identificar qué sectores retienen más trabajadores versus cuáles los expulsan.

### Especificaciones técnicas:
- **Preparación:** Unir `movilidad` con `empleos` para obtener variable `sector`
- **Orden obligatorio:** Por `id_trabajador` y `año` antes de aplicar lag
- **Cálculo de proporciones:** Dentro de cada `sector_anterior`

### Funciones clave:
`lag()`, `pivot_wider()`, `names_from`, `values_from`

### Columnas requeridas:
- Matriz: `sector_anterior` (filas) y sectores como columnas con proporciones
- Retención: `sector`, `prop_retencion`

---

## **EJERCICIO 3: Análisis Geoespacial de Productividad (20 minutos)**

### Objetivo:
Crear un índice compuesto de productividad provincial y analizar flujos de trabajadores entre provincias.

### Consigna:
Calcular un índice de productividad por provincia que combine salarios, costo de vida, nivel educativo y tamaño empresarial. Clasificar provincias en cuartiles de productividad. Analizar qué porcentaje de trabajadores de cada provincia trabaja fuera de su provincia de nacimiento.

### Especificaciones técnicas:
- **Fórmula del índice:** `(salario_promedio / costo_vida_estimado) * (1 + prop_universitarios) * (1 + prop_empresas_grandes)`
- **Costo de vida:** `mean(valor_estimado / m2_superficie)`
- **Redondeo:** 2 decimales para el índice

### Funciones clave:
`group_by()`, `summarise()`, `ntile()`, `pivot_wider()`

### Columnas requeridas:
- Productividad: `provincia_vivienda`, `indice_productividad`, `cuartil_productividad`
- Flujos: `provincia_nacimiento`, `prop_exportacion`

---

## **EJERCICIO 4: Segmentación Empresarial Avanzada (15 minutos)**

### Objetivo:
Clasificar empresas usando múltiples métricas en cuartiles y crear tipologías empresariales.

### Consigna:
Calcular métricas clave por empresa (salario promedio, diversidad de género, rotación laboral, nivel educativo). Convertir estas métricas en cuartiles. Crear una tipología empresarial combinando cuartiles de salario y diversidad. Analizar cómo se distribuyen estas tipologías por sector.

### Especificaciones técnicas:
- **Filtro obligatorio:** Solo empresas con 3+ empleados
- **Conversión educativa:** Primario=1, Secundario=2, Terciario=3, Universitario=4
- **Fórmula diversidad:** `1 - abs(prop_mujeres - 0.5) * 2`
- **Rotación:** `sum(!is.na(fecha_fin)) / n()`
- **Tipología:** Elite (Q4 salario Y Q4 diversidad), Tradicional (Q4 salario Y Q1-Q2 diversidad), Emergente (Q1-Q2 salario Y Q4 diversidad), Básica (resto)

### Funciones clave:
`inner_join()`, `ntile()`, `case_when()`, `pivot_wider()`

### Columnas requeridas:
- `rama_actividad`, `Elite`, `Tradicional`, `Emergente`, `Básica` (proporciones)

---

## **EJERCICIO INTEGRADOR: Dashboard de Inequidad Laboral (20 minutos)**

### Objetivo:
Combinar todas las técnicas en un análisis comprensivo de inequidad salarial con múltiples dimensiones.

### Consigna:
Crear un pipeline completo que integre todas las tablas, genere variables derivadas, calcule cuartiles por múltiples agrupaciones, analice proporciones y produzca un dashboard comparativo de brechas salariales. Incluir análisis de movilidad geográfica y eficiencia de traslados. Producir ranking de equidad por provincia y nivel educativo.

### Especificaciones técnicas:
- **Índice socioeconómico:** Basado en cuartiles de `valor_estimado` (>Q4="Alto", >Q2="Medio", resto="Bajo")
- **Eficiencia traslado:** `salario_bruto / (tiempo_traslado_min * 22 * 2)`
- **Cuartiles:** Uno por provincia-género, otro por rama de actividad
- **Fórmula brecha salarial:** `(salario_mediano_Hombre - salario_mediano_Mujer) / salario_mediano_Hombre * 100`
- **Índice de equidad:** `100 - (brecha_salarial_promedio + brecha_q4_promedio * 100) / 2`
- **Filtros finales:** Excluir `NA` e infinitos en brechas salariales

### Funciones clave:
`inner_join()`, `ntile()`, `pivot_wider()`, `quantile()`, `median()`

### Columnas requeridas:
- Dashboard: `provincia_vivienda`, `nivel_educativo`, `brecha_salarial`, `brecha_q4`
- Rankings: Top 3 brechas provinciales, nivel educativo más equitativo, ranking provincial de equidad

### Análisis esperados:
1. Identificar las 3 combinaciones provincia-educación con mayor brecha salarial
2. Determinar qué nivel educativo tiene menor brecha promedio en Q4
3. Crear ranking de equidad laboral por provincia usando el índice especificado