🎓 Sistema de Gestión CentroEducativo (Cloud Edition)
🌟 Sobre el Proyecto

Este proyecto es una evolución técnica de una plataforma académica desarrollada originalmente en 3º de carrera. Lo que nació como una aplicación dependiente de entornos locales (Eclipse, Tomcat manual y APIs virtuales), ha sido transformado en una solución de Infraestructura como Código (IaC) totalmente autónoma y desplegada en la nube.

He logrado que un stack tecnológico complejo (Servlets Jakarta + Spring Boot API + Hibernate) conviva de forma estable en un entorno limitado de 512MB de RAM mediante optimización de la JVM y contenerización con Docker.

👥 Usuarios de Prueba y Funcionalidades

Para probar la robustez del sistema de autenticación, la gestión de cookies y la comunicación con la API, puedes utilizar las siguientes credenciales:

    Rol	DNI (Usuario)	Contraseña	Funciones principales
    Administrador	111111111	654321	Control total: Es el único perfil con permisos para matricular alumnos en nuevas asignaturas. Consulta global de datos.
    Profesor	69696969J	hola1234	Gestión académica: Acceso a las actas de sus asignaturas. Puede modificar notas (PUT) en tiempo real.
    Alumno (Wick)	33445566X	cuidadin	Consulta personal: Visualización de expediente actualizado y descarga de certificado PDF.
    Alumno (Wayne)	11223344A	batman	Consulta personal: Acceso a notas de sus asignaturas matriculadas.

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