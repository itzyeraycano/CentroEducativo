FROM tomcat:10.1-jdk11-openjdk-slim

# 1. Instalación de dependencias
RUN apt-get update && apt-get install -y curl jq wget socat procps && \
    wget https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.1/jaxb-impl-2.3.1.jar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

# 2. Copiar archivos
COPY . .

# 3. Preparar Servlets y Compilar
RUN mkdir -p webapps/ROOT && cp -r NOL2425/src/main/webapp/* webapps/ROOT/
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

RUN mkdir -p /home/dew/CentroEducativo/ && \
    cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/ || true

# 4. Generar start.sh con detección de errores mejorada
RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash' > start.sh && \
    echo 'socat TCP-LISTEN:8080,fork,reuseaddr PIPE &' >> start.sh && \
    echo 'SOCAT_PID=$!' >> start.sh && \
    echo 'cat <<EOF > conf/tomcat-users.xml' >> start.sh && \
    echo '<?xml version="1.0" encoding="UTF-8"?>' >> start.sh && \
    echo '<tomcat-users>' >> start.sh && \
    echo '  <role rolename="rolalu"/> <role rolename="rolpro"/> <role rolename="admin"/>' >> start.sh && \
    echo '  <user username="111111111" password="654321" roles="admin,rolalu,rolpro"/>' >> start.sh && \
    echo '  <user username="69696969J" password="hola1234" roles="rolpro"/>' >> start.sh && \
    echo '  <user username="11223344A" password="batman" roles="rolalu"/>' >> start.sh && \
    echo '</tomcat-users>' >> start.sh && \
    echo 'EOF' >> start.sh && \
    echo 'echo "Lanzando API (Metodo -jar)..."' >> start.sh && \
    # CAMBIO CLAVE: Usamos -jar y añadimos las librerías al classpath de carga
    echo 'java -Xms128m -Xmx128m -XX:+UseSerialGC -cp "es.upv.etsinf.ti.centroeducativo-0.2.0.jar:jaxb-api-2.3.1.jar:jaxb-core-2.3.0.1.jar:jaxb-impl-2.3.1.jar" -jar es.upv.etsinf.ti.centroeducativo-0.2.0.jar > api_log.txt 2>&1 &' >> start.sh && \
    echo 'API_PID=$!' >> start.sh && \
    echo 'sleep 5' >> start.sh && \
    echo 'if ! ps -p $API_PID > /dev/null; then' >> start.sh && \
    echo '    echo "=== ERROR CRITICO: El modo -jar fallo. Contenido del JAR: ==="' >> start.sh && \
    echo '    jar -tf es.upv.etsinf.ti.centroeducativo-0.2.0.jar | grep .class | head -n 20' >> start.sh && \
    echo '    cat api_log.txt' >> start.sh && \
    echo '    exit 1' >> start.sh && \
    echo 'fi' >> start.sh && \
    echo 'echo "API arrancada. Esperando a Hibernate..."' >> start.sh && \
    echo 'count=0' >> start.sh && \
    echo 'while ! curl -s http://localhost:9090/CentroEducativo/login > /dev/null; do' >> start.sh && \
    echo '    count=$((count + 1))' >> start.sh && \
    echo '    echo "API cargando... intento $count de 60"' >> start.sh && \
    echo '    sleep 15' >> start.sh && \
    echo '    if [ $count -ge 60 ]; then echo "TIMEOUT"; cat api_log.txt; exit 1; fi' >> start.sh && \
    echo 'done' >> start.sh && \
    echo 'echo "API LISTA! Ejecutando poblacion..."' >> start.sh && \
    echo './poblar_centro_educativo.sh' >> start.sh && \
    echo 'kill $SOCAT_PID' >> start.sh && \
    echo 'export CATALINA_OPTS="-Xms128m -Xmx160m -XX:+UseSerialGC -Djava.security.egd=file:/dev/./urandom"' >> start.sh && \
    echo 'catalina.sh run' >> start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]