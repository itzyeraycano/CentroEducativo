# Cambiamos a Tomcat 10.1, que es el que soporta el paquete 'jakarta.servlet'
FROM tomcat:10.1-jdk17-openjdk-slim

# Instalamos curl y jq para el script de población
RUN apt-get update && apt-get install -y curl jq && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

# Copiamos todo el repositorio
COPY . .

# 1. Configurar la WebApp de Tomcat
RUN mkdir -p webapps/ROOT && \
    cp -r NOL2425/src/main/webapp/* webapps/ROOT/

# 2. Compilación manual de los Servlets
# Añadimos las librerías de Tomcat 10 al classpath para que encuentre jakarta.servlet
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

# 3. Preparar el motor de la API (.jar)
# Mantenemos la ruta de la universidad por compatibilidad
RUN mkdir -p /home/dew/CentroEducativo/ && \
    cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/ || true

# 4. Script de arranque
RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash\n\
./lanzaCentroEducativo.sh &\n\
echo "Esperando 30s a que la API levante..."\n\
sleep 30\n\
./poblar_centro_educativo.sh\n\
echo "Población completada. Iniciando Servidor Web..."\n\
catalina.sh run' > start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]