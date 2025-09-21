# Diccionario de Datos - Sistema Laboral y Empresarial

## Descripción General del Sistema

Este sistema contiene información sobre empleadores, sus establecimientos y los trabajadores empleados en cada uno de ellos. Los datos están organizados en tres tablas relacionales que permiten analizar aspectos laborales, financieros y geográficos del mercado de trabajo.

---

## Tabla 1: EMPLEADORES

Cada fila representa una empresa o empleador único en el sistema.

### Variables

| Variable | Tipo | Descripción |
|----------|------|-------------|
| **cuit_empleador** | Texto | Número de CUIT (Clave Única de Identificación Tributaria) del empleador. Formato: XX-XXXXXXXX-X. **Clave primaria de la tabla**. |
| **actividad_economica** | Texto | Sector económico principal en el que opera la empresa. Valores posibles: "Agropecuaria", "Petróleo y Minería", "Industria liviana", "Industria pesada", "Comercio", "Servicios intensivos en conocimiento", "Otros servicios". |
| **tipo_sociedad** | Texto | Forma jurídica de la empresa. Valores posibles: "S.A." (Sociedad Anónima), "S.R.L." (Sociedad de Responsabilidad Limitada), "S.A.S." (Sociedad por Acciones Simplificada), "Cooperativa", "Unipersonal", "Sociedad Anónima Unipersonal". |
| **provincia_sede** | Texto | Provincia donde está radicada la sede principal de la empresa. Valores posibles: "Buenos Aires", "CABA", "Córdoba", "Santa Fe", "Mendoza", "Tucumán", "Entre Ríos", "Salta", "Misiones", "Neuquén". |
| **obra_social** | Texto | Obra social que ofrece la empresa a sus empleados. Valores posibles: "OSDE", "Swiss Medical", "OSECAC", "OSPRERA", "OSPE", "IOMA", "PAMI", "Otra". |
| **ingreso_anual** | Numérico | Ingresos totales de la empresa en el año fiscal, expresados en pesos argentinos. |
| **gasto_anual** | Numérico | Gastos totales de la empresa en el año fiscal, expresados en pesos argentinos. |
| **impuesto_pagado** | Numérico | Total de impuestos abonados por la empresa en el año, en pesos argentinos. |
| **subsidios_recibidos** | Numérico | Subsidios o ayudas estatales recibidas por la empresa durante el año, en pesos argentinos. Valor 0 si no recibió subsidios. |



---

## Tabla 2: ESTABLECIMIENTOS

Cada fila representa un establecimiento o sede física donde opera un empleador.

### Variables

| Variable | Tipo | Descripción |
|----------|------|-------------|
| **cuit_empleador** | Texto | CUIT del empleador al que pertenece el establecimiento. **Clave foránea** que vincula con la tabla EMPLEADORES. |
| **id_establecimiento** | Texto | Identificador único del establecimiento. Formato: CUIT-EST-N donde N es un número secuencial. **Clave primaria de la tabla**. |
| **tipo_actividades** | Texto | Tipo de actividades que se realizan en el establecimiento. Valores posibles: "Administrativas", "Productivo", "Almacenamiento", "Comercial", "Todas" (cuando se realizan múltiples actividades). |
| **provincia_establecimiento** | Texto | Provincia donde se localiza físicamente el establecimiento. Puede ser diferente a la provincia de la sede del empleador. |
| **departamento** | Texto | Departamento o partido donde se encuentra el establecimiento. Formato: "Departamento N" donde N es un número. |
| **direccion** | Texto | Dirección física del establecimiento. Incluye tipo de vía (Av., Calle, Ruta, Camino), nombre y número. |
| **parque_industrial** | Texto | Indica si el establecimiento está ubicado dentro de un parque industrial. Valores posibles: "Sí", "No". |

**Nota:** Un mismo empleador puede tener múltiples establecimientos.

---

## Tabla 3: EMPLEADOS

Cada fila representa la información laboral de un empleado en un mes específico (datos panel).

### Variables

| Variable | Tipo | Descripción |
|----------|------|-------------|
| **mes** | Numérico | Mes del año al que corresponde el registro. Valores de 1 a 12. |
| **cuil_empleado** | Texto | CUIL (Código Único de Identificación Laboral) del trabajador. Formato: XX-XXXXXXXX-X. **Parte de la clave primaria** junto con mes. |
| **cuit_empleador** | Texto | CUIT del empleador. **Clave foránea** que vincula con la tabla EMPLEADORES. |
| **id_establecimiento** | Texto | Identificador del establecimiento donde trabaja el empleado. **Clave foránea** que vincula con la tabla ESTABLECIMIENTOS. |
| **remuneracion_total** | Numérico | Remuneración total mensual del empleado, incluyendo salario base y adicionales, en pesos argentinos. |
| **salario_mensual** | Numérico | Salario base mensual del empleado, sin adicionales, en pesos argentinos. |
| **horas_trabajadas** | Numérico | Cantidad de horas trabajadas en el mes. Valor estándar: 160 horas mensuales para jornada completa. |
| **sexo** | Texto | Sexo del empleado. Valores posibles: "Masculino", "Femenino". |
| **nivel_educativo** | Texto | Máximo nivel educativo alcanzado por el empleado. Valores posibles: "Secundario", "Universitario", "Posgrado". |
| **edad** | Numérico | Edad del empleado en años. Rango típico: 18-70 años. |
| **antigüedad_meses** | Numérico | Antigüedad del empleado en la empresa, expresada en meses completos. |
| **tipo_contrato** | Texto | Modalidad contractual del empleado. Valores posibles: "Permanente" (contrato por tiempo indeterminado), "Temporal" (contrato a plazo fijo), "Pasantía". |
| **categoria_ocupacional** | Texto | Categoría laboral del empleado. Valores posibles: "Directivo", "Profesional", "Técnico", "Administrativo", "Operario". |
| **fecha_ingreso** | Fecha | Fecha en la que el empleado comenzó a trabajar en la empresa. Formato: YYYY-MM-DD. |

**Nota:** La tabla tiene estructura de panel, con múltiples observaciones mensuales para cada empleado.

---

## Relaciones entre Tablas

```
EMPLEADORES (1) ←→ (N) ESTABLECIMIENTOS
     ↓
     |
     ↓ (1)
     |
     ↓
EMPLEADOS (N)
     ↓
     |
     ↓ (N)
     |
ESTABLECIMIENTOS (1)
```

- Un **empleador** puede tener múltiples **establecimientos**
- Cada **establecimiento** pertenece a un único **empleador**
- Un **empleado** trabaja en un único **establecimiento** (y por ende, para un único **empleador**)
- Un **establecimiento** puede tener múltiples **empleados**

---

## Claves y Relaciones

### Claves Primarias
- **EMPLEADORES**: `cuit_empleador`
- **ESTABLECIMIENTOS**: `id_establecimiento`
- **EMPLEADOS**: `cuil_empleado` + `mes` (clave compuesta)

### Claves Foráneas
- **ESTABLECIMIENTOS**: `cuit_empleador` → EMPLEADORES
- **EMPLEADOS**: `cuit_empleador` → EMPLEADORES
- **EMPLEADOS**: `id_establecimiento` → ESTABLECIMIENTOS

---

## Notas Metodológicas

1. **Datos Panel**: La tabla EMPLEADOS contiene 12 observaciones por cada trabajador (una por mes), permitiendo análisis longitudinales.

2. **Coherencia Salarial**: Los salarios varían según:
   - Categoría ocupacional
   - Nivel educativo
   - Antigüedad en la empresa
   - Actividad económica del empleador

3. **Distribución Geográfica**: Hay mayor concentración de empleadores en Buenos Aires y CABA, reflejando la realidad económica argentina.

4. **Valores Faltantes**: El dataset no contiene valores faltantes (NA). Todos los campos están completos.

5. **Periodicidad**: Los datos corresponden al año 2024, con información mensual de enero (mes 1) a diciembre (mes 12).
6. **Salarios**: Los salarios y remuneraciones son independientes del mes. Es decir, no se consideran períodos inflacionarios ni meses en los que se pagan mayores sueldos que otros (no hay aguinaldo). 