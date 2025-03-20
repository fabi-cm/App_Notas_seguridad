# app notas_ucb, insegura

Proyecto de hacer notas en android

# **Informe de Seguridad - Aplicación de Notas Insegura**

## **1. Introducción**

Este informe detalla las vulnerabilidades de seguridad encontradas en la "Aplicación de Notas Insegura". El objetivo es demostrar prácticas deficientes en el desarrollo de aplicaciones móviles, evaluarlas frente a los requisitos de la norma **ISO/IEC 27001** y explicar cómo estas debilidades comprometen la **confidencialidad**, **integridad** y **disponibilidad** de los datos.

---

## **2. Vulnerabilidades Identificadas**

### 📌 2.1. Copia Insegura de la Base de Datos
- **Problema:** La aplicación permite copiar la base de datos SQLite al almacenamiento público del dispositivo.
- **Impacto:** Cualquier usuario con acceso al sistema de archivos puede leer las notas almacenadas.

🔍 **Riesgos para la ISO/IEC 27001:**
- **A.8.2.1 - Clasificación de la información:** No hay protección adecuada para la información sensible.
- **A.9.4.2 - Control de acceso a programas:** No se restringe el acceso al contenido de la base de datos.

---

### 📌 2.2. Manejo Inseguro de Sesiones
- **Problema:** La aplicación no valida ni expira correctamente las sesiones.
- **Impacto:** Un atacante puede acceder a las notas de otros usuarios si obtiene acceso físico o lógico al dispositivo.

🔍 **Riesgos para la ISO/IEC 27001:**
- **A.9.4.1 - Control de acceso a sistemas y aplicaciones:** No se verifican adecuadamente las credenciales de sesión.
- **A.12.4.1 - Registro de actividades:** Falta de registros para rastrear sesiones.

---

### 📌 2.3. Falta de Autorización Adecuada
- **Problema:** No existe una validación estricta para garantizar que un usuario solo acceda a sus propias notas.
- **Impacto:** Un usuario autenticado puede acceder o manipular las notas de otros usuarios.

🔍 **Riesgos para la ISO/IEC 27001:**
- **A.9.2.5 - Separación de funciones:** No se asegura que los usuarios accedan solo a sus datos.
- **A.14.1.2 - Validación de transacciones:** Falta de control para restringir el acceso cruzado de información.

---

### 📌 2.4. Clave de Acceso Predecible
- **Problema:** La aplicación permite omitir el inicio de sesión con una clave predecible o expuesta.
- **Impacto:** Cualquier usuario que conozca o descubra la clave puede acceder sin restricciones.

🔍 **Riesgos para la ISO/IEC 27001:**
- **A.9.4.3 - Gestión de contraseñas:** Uso de credenciales inseguras.
- **A.9.2.4 - Control de acceso basado en roles:** No se aplica un control estricto a las credenciales.

---

### 📌 2.5. Inyección SQL
- **Problema:** Las consultas SQL no están parametrizadas, permitiendo que un atacante inyecte código malicioso.
- **Impacto:** Un atacante puede manipular o borrar información dentro de la base de datos.

🔍 **Riesgos para la ISO/IEC 27001:**
- **A.14.2.5 - Principios de programación segura:** No se siguen las mejores prácticas para proteger contra inyecciones.
- **A.12.2.1 - Controles contra código malicioso:** No hay validación ni sanitización de entradas de usuario.

---

## **3. Análisis de la Triada de Seguridad**

| **Principio**         | **Impacto en la Aplicación**                                 |
|-----------------------|-----------------------------------------------------------------|
| **Confidencialidad**  | - Cualquier usuario puede acceder a la base de datos copiada.    |
|                       | - Las sesiones no se validan ni protegen correctamente.         |
| **Integridad**        | - La falta de validación permite manipular datos mediante SQLi. |
|                       | - No hay protección para evitar modificaciones no autorizadas.  |
| **Disponibilidad**    | - El atacante puede borrar o alterar información crítica.       |
|                       | - No se realizan copias de seguridad o validaciones apropiadas.  |

---

## **4. Pruebas Realizadas**

### ✅ Copia Insegura de la Base de Datos
**Comando utilizado:**
```bash
adb shell
cd /storage/emulated/0/Download/
ls -lh insecure_notes.db
```
**Resultado:**
Base de datos SQLite expuesta públicamente.

### ✅ Inyección SQL
Ejemplo de payload para acceder a todas las notas:
```sql
' OR 1=1 --
```
**Resultado:**
Se listaron todas las notas de la base de datos.

### ✅ Saltar Autenticación con Clave
En el código, una clave predefinida permite acceso sin credenciales.

**Comando utilizado:**
```bash
adb logcat | grep 'LoginBypass'
```
**Resultado:**
Se pudo acceder sin verificación real.

---

## **5. Recomendaciones de Seguridad**

- **Implementar cifrado en la base de datos**: Usar SQLCipher para proteger los datos sensibles.
- **Validar entradas SQL**: Usar `sqflite` con consultas parametrizadas para prevenir inyecciones.
- **Controlar accesos de usuario**: Implementar un sistema de roles y validaciones rigurosas.
- **Refinar el manejo de sesiones**: Usar tokens de sesión seguros con tiempo de expiración.
- **Auditoría y monitoreo**: Mejorar el sistema de logs y registrar acciones críticas.

---

## **6. Conclusión**

La "Aplicación de Notas Insegura" presenta múltiples vulnerabilidades que comprometen la seguridad de los datos. Este informe destaca las principales debilidades y su relación con la norma ISO/IEC 27001, subrayando la necesidad de aplicar controles efectivos para garantizar la seguridad de la información.

