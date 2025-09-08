
# Fundamentos de Bases de Datos

## 1. Bases de Datos Relacionales (SQL)

Las bases de datos relacionales han sido el pilar de almacenamiento de datos estructurados durante décadas. Vamos a explorar sus características fundamentales y cómo se diseñan eficientemente.

### 1.1 ¿Qué es una Primary Key (Clave Primaria)?

Una clave primaria es un campo (o conjunto de campos) que identifica de manera única cada registro en una tabla. Pensemos en ello como el "DNI" de cada fila.

**Características principales:**
- Debe ser única para cada registro
- No puede contener valores nulos
- Debe ser estable (no cambiar con frecuencia)
- Optimiza las búsquedas y las operaciones

**Ejemplo:**
En una tabla de `Clientes`, podríamos tener un campo `cliente_id` que es un número único asignado a cada cliente. Este campo sería la clave primaria.

```sql
CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY,
    nombre VARCHAR(100),
    email VARCHAR(100),
    telefono VARCHAR(20)
);
```

### 1.2 ¿Qué es una Foreign Key (Clave Foránea)?

Una clave foránea es un campo en una tabla que hace referencia a la clave primaria de otra tabla. Establece una relación entre dos tablas, garantizando la integridad referencial.

**Características:**
- Crea relaciones entre tablas
- Mantiene la integridad de los datos
- Previene la eliminación de datos relacionados
- Permite construir consultas complejas entre tablas

**Ejemplo:**
En una tabla de `Pedidos`, tendríamos un campo `cliente_id` que hace referencia a la tabla `Clientes`. Esto conecta cada pedido con su cliente correspondiente.

```sql
CREATE TABLE Pedidos (
    pedido_id INT PRIMARY KEY,
    cliente_id INT,
    fecha_pedido DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);
```

### 1.3 Diseño Eficiente de Bases de Datos Relacionales

Un principio fundamental en el diseño de bases de datos relacionales es **minimizar la redundancia**. Esto se logra mediante un proceso llamado normalización.

#### ¿Por qué evitar la redundancia?

Imaginemos un escenario donde tenemos una única tabla con todas las transacciones y los datos de los usuarios:

```
TABLA: Transacciones
| transaccion_id | fecha      | monto  | usuario_id | nombre_usuario | email_usuario         | direccion_usuario      |
|----------------|------------|--------|------------|----------------|------------------------|------------------------|
| 1              | 2023-01-15 | 1500   | 101        | Ana García     | ana@ejemplo.com       | Calle Principal 123    |
| 2              | 2023-01-16 | 750    | 102        | Juan Pérez     | juan@ejemplo.com      | Avenida Central 456    |
| 3              | 2023-01-17 | 2000   | 101        | Ana García     | ana@ejemplo.com       | Calle Principal 123    |
```

**Problemas con este diseño:**

1. **Modificaciones complejas:** Si Ana cambia su email, habría que actualizar múltiples filas, lo que aumenta el riesgo de inconsistencias.
   
   Por ejemplo, si actualizamos solo algunas ocurrencias del email de Ana:
   ```
   | transaccion_id | ... | nombre_usuario | email_usuario         | ... |
   |----------------|-----|----------------|------------------------|-----|
   | 1              | ... | Ana García     | ana@ejemplo.com       | ... |
   | 3              | ... | Ana García     | ana_nueva@ejemplo.com | ... |
   ```
   ¡Ahora tenemos información contradictoria en nuestra base de datos!

2. **Desperdicio de espacio:** La información de cada usuario se repite en cada transacción.

3. **Mayor probabilidad de errores:** Al ingresar datos repetidamente, aumenta la posibilidad de errores tipográficos o inconsistencias.

#### Solución: Diseño normalizado

Un mejor diseño sería separar la información en tablas relacionadas:

**Tabla: Usuarios**
```
| usuario_id | nombre      | email           | direccion          |
|------------|-------------|-----------------|---------------------|
| 101        | Ana García  | ana@ejemplo.com | Calle Principal 123 |
| 102        | Juan Pérez  | juan@ejemplo.com| Avenida Central 456 |
```

**Tabla: Transacciones**
```
| transaccion_id | fecha      | monto  | usuario_id |
|----------------|------------|--------|------------|
| 1              | 2023-01-15 | 1500   | 101        |
| 2              | 2023-01-16 | 750    | 102        |
| 3              | 2023-01-17 | 2000   | 101        |
```

**Ventajas:**
- Si Ana cambia su email, solo se actualiza una fila en la tabla Usuarios
- Menor almacenamiento requerido
- Menor probabilidad de inconsistencias
- Mayor flexibilidad para consultas y análisis

### 1.4 Conceptos Fundamentales de Modelado de Datos

Para diseñar bases de datos eficientes, es esencial comprender algunos conceptos clave del modelado de datos.

#### Entidades y Atributos

**Entidad:** Un objeto o concepto del mundo real que queremos representar en nuestra base de datos. Cada entidad se convierte en una tabla.

**Atributo:** Las características o propiedades que describen a una entidad. Cada atributo se convierte en una columna de la tabla.

**Ejemplo:**
- **Entidad:** Cliente
- **Atributos:** cliente_id, nombre, email, teléfono, fecha_registro

#### Tipos de Relaciones entre Entidades

**1. Uno a Uno (1:1)**
Una entidad A se relaciona con exactamente una entidad B, y viceversa.

*Ejemplo:* Un empleado tiene exactamente un número de seguridad social, y cada número pertenece a un solo empleado.

**2. Uno a Muchos (1:N)**
Una entidad A puede relacionarse con múltiples entidades B, pero cada B se relaciona solo con una A.

*Ejemplo:* Un cliente puede tener múltiples pedidos, pero cada pedido pertenece a un solo cliente.

**3. Muchos a Muchos (N:M)**
Múltiples entidades A pueden relacionarse con múltiples entidades B.

*Ejemplo:* Los estudiantes pueden inscribirse en múltiples cursos, y cada curso puede tener múltiples estudiantes.

**Nota importante:** Las relaciones muchos a muchos requieren una tabla intermedia (tabla de unión).

#### Ejemplo Práctico: Sistema de Biblioteca

Vamos a modelar un sistema de biblioteca simple identificando entidades, atributos y relaciones:

**Entidades identificadas:**
- Libros
- Autores  
- Miembros
- Préstamos

**Diseño de tablas:**

```sql
-- Tabla Autores
CREATE TABLE Autores (
    autor_id INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    fecha_nacimiento DATE
);

-- Tabla Libros
CREATE TABLE Libros (
    libro_id INT PRIMARY KEY,
    titulo VARCHAR(200),
    isbn VARCHAR(13),
    año_publicacion INT,
    editorial VARCHAR(100)
);

-- Tabla Miembros
CREATE TABLE Miembros (
    miembro_id INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    email VARCHAR(100),
    fecha_registro DATE
);

-- Tabla de relación Muchos a Muchos: Libros-Autores
CREATE TABLE Libro_Autores (
    libro_id INT,
    autor_id INT,
    PRIMARY KEY (libro_id, autor_id),
    FOREIGN KEY (libro_id) REFERENCES Libros(libro_id),
    FOREIGN KEY (autor_id) REFERENCES Autores(autor_id)
);

-- Tabla Préstamos (relación entre Miembros y Libros)
CREATE TABLE Prestamos (
    prestamo_id INT PRIMARY KEY,
    miembro_id INT,
    libro_id INT,
    fecha_prestamo DATE,
    fecha_devolucion_esperada DATE,
    fecha_devolucion_real DATE,
    FOREIGN KEY (miembro_id) REFERENCES Miembros(miembro_id),
    FOREIGN KEY (libro_id) REFERENCES Libros(libro_id)
);
```

**Relaciones en este modelo:**
- **Autores ↔ Libros:** Muchos a muchos (un libro puede tener varios autores, un autor puede escribir varios libros)
- **Miembros ↔ Libros:** Muchos a muchos a través de Préstamos (un miembro puede pedir prestados varios libros, un libro puede ser prestado a varios miembros en diferentes momentos)

### 1.5 Limitaciones de las Bases de Datos Relacionales

A pesar de sus ventajas, las bases de datos SQL presentan algunas limitaciones:

**Esquemas rígidos:** Cada tabla debe seguir un esquema predefinido. Todas las filas deben tener las mismas columnas.

**Dificultad para modelar datos heterogéneos:** Consideremos un caso de un e-commerce que vende productos muy diferentes:

- Un vino tiene atributos como bodega, año, variedad
- Un televisor tiene atributos como pulgadas, resolución, tecnología de pantalla
- Un libro tiene autor, editorial, ISBN

Tratar de encajar todos estos productos en una única estructura relacional puede resultar en:
1. Una tabla con muchas columnas nulas
2. Un diseño excesivamente complejo con múltiples tablas
3. Dificultad para añadir nuevos tipos de productos
