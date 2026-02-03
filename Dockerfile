FROM tomcat:9.0-jdk8-openjdk-slim

# 1. Instalación de herramientas necesarias
RUN apt-get update && apt-get install -y curl jq wget socat procps && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

# 2. Copiar archivos del repositorio
COPY . .

# 3. Preparar Servlets y Compilar (Java 8)
RUN mkdir -p webapps/ROOT && cp -r NOL2425/src/main/webapp/* webapps/ROOT/
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

# 4. Asegurar ubicación del JAR de la API
RUN mkdir -p /home/dew/CentroEducativo/ && \
    cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/ || true

# 5. Generar script de arranque start.sh
RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash' > start.sh && \
    # Validación de integridad por si vuelve a fallar LFS
    echo 'FILE="es.upv.etsinf.ti.centroeducativo-0.2.0.jar"' >> start.sh && \
    echo 'SIZE=$(stat -c%s "$FILE" 2>/dev/null || echo 0)' >> start.sh && \
    echo 'if [ "$SIZE" -lt 1000000 ]; then echo "ERROR: JAR CORRUPTO (LFS)"; exit 1; fi' >> start.sh && \
    # Puerto falso para Koyeb
    echo 'socat TCP-LISTEN:8080,fork,reuseaddr PIPE &' >> start.sh && \
    echo 'SOCAT_PID=$!' >> start.sh && \
    # Usuarios para AuthFiltro
    echo 'cat <<EOF > conf/tomcat-users.xml' >> start.sh && \
    echo '<?xml version="1.0" encoding="UTF-8"?>' >> start.sh && \
    echo '<tomcat-users>' >> start.sh && \
    echo '  <role rolename="rolalu"/> <role rolename="rolpro"/> <role rolename="admin"/>' >> start.sh && \
    echo '  <user username="111111111" password="654321" roles="admin,rolalu,rolpro"/>' >> start.sh && \
    echo '  <user username="69696969J" password="hola1234" roles="rolpro"/>' >> start.sh && \
    echo '  <user username="11223344A" password="batman" roles="rolalu"/>' >> start.sh && \
    echo '</tomcat-users>' >> start.sh && \
    echo 'EOF' >> start.sh && \
    # Lanzar API (En Java 8 no necesitamos los parches JAXB externos)
    echo 'echo "Lanzando API en Java 8..."' >> start.sh && \
    echo 'java -Xms128m -Xmx128m -XX:+UseSerialGC -jar "$FILE" > api_log.txt 2>&1 &' >> start.sh && \
    echo 'API_PID=$!' >> start.sh && \
    echo 'sleep 8' >> start.sh && \
    echo 'if ! ps -p $API_PID > /dev/null; then echo "API MURIO"; cat api_log.txt; exit 1; fi' >> start.sh && \
    # Espera y Población
    echo 'count=0' >> start.sh && \
    echo 'while ! curl -s http://localhost:9090/CentroEducativo/login > /dev/null; do' >> start.sh && \
    echo '  count=$((count + 1)); echo "Esperando API (Hibernate)... intento $count"; sleep 15' >> start.sh && \
    echo '  if [ $count -ge 60 ]; then cat api_log.txt; exit 1; fi' >> start.sh && \
    echo 'done' >> start.sh && \
    echo 'echo "API LISTA! Poblando datos..."' >> start.sh && \
    echo './poblar_centro_educativo.sh' >> start.sh && \
    echo 'kill $SOCAT_PID' >> start.sh && \
    echo 'export CATALINA_OPTS="-Xms128m -Xmx160m -XX:+UseSerialGC -Djava.security.egd=file:/dev/./urandom"' >> start.sh && \
    echo 'catalina.sh run' >> start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]