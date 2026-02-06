🎓 Sistema de Gestión CentroEducativo (Cloud Edition)
🌟 Sobre el Proyecto

Este proyecto es una evolución técnica de una plataforma académica desarrollada originalmente en 3º de carrera. Lo que nació como una aplicación dependiente de entornos locales (Eclipse, Tomcat manual y APIs virtuales), ha sido transformado en una solución de Infraestructura como Código (IaC) totalmente autónoma y desplegada en la nube.

He logrado que un stack tecnológico complejo (Servlets Jakarta + Spring Boot API + Hibernate) conviva de forma estable en un entorno limitado de 512MB de RAM mediante optimización de la JVM y contenerización con Docker.

👥 Perfiles de Acceso y Casos de Prueba

Para probar la robustez del sistema de autenticación, la gestión de cookies y la comunicación con la API, puedes utilizar las siguientes credenciales:
🔑 Perfil: Administrador

    DNI (Usuario): 111111111

    Contraseña: 654321

    Responsabilidades: Posee el nivel de acceso más alto. Es el único perfil con permisos para realizar la Matriculación de alumnos en nuevas asignaturas.

    Caso de prueba: Úsalo para gestionar las actas globales y verificar que solo este rol tiene acceso a las funciones de escritura de matrículas.

👨‍🏫 Perfil: Profesor

    DNI (Usuario): 69696969J (Pablo Martines)

    Contraseña: hola1234

    Responsabilidades: Gestión académica de sus asignaturas asignadas. Tiene permisos para modificar notas mediante peticiones HTTP PUT.

    Caso de prueba: Entra en una de sus asignaturas (como DEW), cambia una nota y verifica el mensaje de confirmación de la API.

👨‍🎓 Perfil: Alumno (Estándar)

    DNI (Usuario): 33445566X (John Wick)

    Contraseña: cuidadin
    
    DNI (Usuario): 11223344A (Bruce Wayne)

    Contraseña: batman
    

    Responsabilidades: Consulta de expediente personal y generación de certificados académicos en PDF.

    Caso de prueba: Loguéate para ver cómo las notas modificadas por el profesor se reflejan instantáneamente en tu expediente y descarga el certificado para validar los datos.

    --------------------------------------------------------------------------------------------------------------------------------------



🛠️ Arquitectura y Seguridad

La aplicación se basa en un flujo de seguridad y datos desacoplado:

    Autenticación: Al iniciar sesión, el sistema valida contra un Tomcat Realm. Si es correcto, genera una cookie JSESSIONID que mantiene el contexto durante la navegación.

    Seguridad por Filtros: Un AuthFiltro intercepta las peticiones para asegurar que solo usuarios con el token adecuado accedan a la API.

    Persistencia: Las modificaciones realizadas (como el cambio de notas del profesor) se envían mediante peticiones HTTP PUT a una API de Spring Boot que persiste los datos en una DB H2.

    Optimización: El despliegue incluye parches manuales de JAXB para garantizar la compatibilidad entre Java 8 y Java 11 sin sacrificar rendimiento.

🚀 Cómo utilizar la App

    Entrada: Accede a la URL y selecciona el rol deseado.

    Persistencia: Una vez logueado, puedes volver al "Inicio" y verás que sigues dentro gracias a la gestión de cookies.

    Cierre de Sesión: Es fundamental usar el botón "Cerrar sesión" para ejecutar un session.invalidate(). Esto destruye el token y permite ingresar con un usuario distinto de forma limpia.

🧪 Notas de Despliegue

El proyecto se auto-gestiona mediante un script orquestador en el contenedor que:

    Levanta la API y espera a que la base de datos esté lista.

    Realiza un seedeo automático de los alumnos y profesores mediante comandos curl.

    Despliega la web en la raíz (/) de Tomcat para URLs simplificadas.

Proyecto desarrollado para la asignatura de Desarrollo de Entornos Web (DEW).