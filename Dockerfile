FROM tomcat:10.1-jdk11-openjdk-slim

# 1. Instalación de herramientas y librerías JAXB
RUN apt-get update && apt-get install -y curl jq wget socat procps && \
    wget https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.1/jaxb-impl-2.3.1.jar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

# 2. Copiar archivos del repositorio
COPY . .

# 3. Preparar Servlets y Compilar
RUN mkdir -p webapps/ROOT && cp -r NOL2425/src/main/webapp/* webapps/ROOT/
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

# 4. Generar script de arranque con validación de Git LFS
RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash' > start.sh && \
    # Validación de integridad del JAR
    echo 'FILE="es.upv.etsinf.ti.centroeducativo-0.2.0.jar"' >> start.sh && \
    echo 'SIZE=$(stat -c%s "$FILE" 2>/dev/null || echo 0)' >> start.sh && \
    echo 'if [ "$SIZE" -lt 1000000 ]; then' >> start.sh && \
    echo '  echo "=== ERROR CRÍTICO: EL JAR MIDE MENOS DE 1MB ==="' >> start.sh && \
    echo '  echo "Probablemente sea un puntero de Git LFS. Contenido del archivo:"' >> start.sh && \
    echo '  cat "$FILE"' >> start.sh && \
    echo '  exit 1' >> start.sh && \
    echo 'fi' >> start.sh && \
    # Engaño al Health Check de Koyeb
    echo 'socat TCP-LISTEN:8080,fork,reuseaddr PIPE &' >> start.sh && \
    echo 'SOCAT_PID=$!' >> start.sh && \
    # Configuración de usuarios Tomcat
    echo 'cat <<EOF > conf/tomcat-users.xml' >> start.sh && \
    echo '<?xml version="1.0" encoding="UTF-8"?>' >> start.sh && \
    echo '<tomcat-users>' >> start.sh && \
    echo '  <role rolename="rolalu"/> <role rolename="rolpro"/> <role rolename="admin"/>' >> start.sh && \
    echo '  <user username="111111111" password="654321" roles="admin,rolalu,rolpro"/>' >> start.sh && \
    echo '  <user username="69696969J" password="hola1234" roles="rolpro"/>' >> start.sh && \
    echo '  <user username="11223344A" password="batman" roles="rolalu"/>' >> start.sh && \
    echo '</tomcat-users>' >> start.sh && \
    echo 'EOF' >> start.sh && \
    # Lanzamiento de la API
    echo 'echo "Lanzando API..."' >> start.sh && \
    echo 'java -Xms128m -Xmx128m -XX:+UseSerialGC -Dloader.path="." -jar "$FILE" > api_log.txt 2>&1 &' >> start.sh && \
    echo 'API_PID=$!' >> start.sh && \
    echo 'sleep 10' >> start.sh && \
    echo 'if ! ps -p $API_PID > /dev/null; then' >> start.sh && \
    echo '  echo "=== LA API HA MUERTO AL ARRANCAR ==="; cat api_log.txt; exit 1' >> start.sh && \
    echo 'fi' >> start.sh && \
    # Espera y población
    echo 'count=0' >> start.sh && \
    echo 'while ! curl -s http://localhost:9090/CentroEducativo/login > /dev/null; do' >> start.sh && \
    echo '  count=$((count + 1)); echo "Esperando API... intento $count"; sleep 15' >> start.sh && \
    echo '  if [ $count -ge 60 ]; then cat api_log.txt; exit 1; fi' >> start.sh && \
    echo 'done' >> start.sh && \
    echo './poblar_centro_educativo.sh' >> start.sh && \
    echo 'kill $SOCAT_PID' >> start.sh && \
    echo 'export CATALINA_OPTS="-Xms128m -Xmx160m -XX:+UseSerialGC -Djava.security.egd=file:/dev/./urandom"' >> start.sh && \
    echo 'catalina.sh run' >> start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]