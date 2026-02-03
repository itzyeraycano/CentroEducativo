FROM tomcat:10.1-jdk11-openjdk-slim

RUN apt-get update && apt-get install -y curl jq wget socat procps && \
    wget https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.1/jaxb-impl-2.3.1.jar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat
COPY . .

RUN mkdir -p webapps/ROOT && cp -r NOL2425/src/main/webapp/* webapps/ROOT/
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

RUN mkdir -p /home/dew/CentroEducativo/ && cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/ || true

# Creamos el start.sh línea a línea para evitar errores de escape de caracteres
RUN echo '#!/bin/bash' > start.sh && \
    echo 'socat TCP-LISTEN:8080,fork,reuseaddr PIPE &' >> start.sh && \
    echo 'SOCAT_PID=$!' >> start.sh && \
    echo 'cat <<EOF > conf/tomcat-users.xml' >> start.sh && \
    echo '<?xml version="1.0" encoding="UTF-8"?>' >> start.sh && \
    echo '<tomcat-users>' >> start.sh && \
    echo '  <role rolename="rolalu"/> <role rolename="rolpro"/>' >> start.sh && \
    echo '  <user username="11223344A" password="batman" roles="rolalu"/>' >> start.sh && \
    echo '  <user username="69696969J" password="hola1234" roles="rolpro"/>' >> start.sh && \
    echo '  <user username="33445566X" password="cuidadin" roles="rolalu"/>' >> start.sh && \
    echo '</tomcat-users>' >> start.sh && \
    echo 'EOF' >> start.sh && \
    echo 'echo "Lanzando API..."' >> start.sh && \
    echo 'java -Xms128m -Xmx128m -XX:+UseSerialGC -cp "es.upv.etsinf.ti.centroeducativo-0.2.0.jar:jaxb-api-2.3.1.jar:jaxb-core-2.3.0.1.jar:jaxb-impl-2.3.1.jar" org.springframework.boot.loader.JarLauncher > api_log.txt 2>&1 &' >> start.sh && \
    echo 'API_PID=$!' >> start.sh && \
    echo 'sleep 5' >> start.sh && \
    echo 'if ! ps -p $API_PID > /dev/null; then' >> start.sh && \
    echo '    echo "=== ERROR CRÍTICO INICIAL: LA API NO HA PODIDO ARRANCAR ==="' >> start.sh && \
    echo '    cat api_log.txt' >> start.sh && \
    echo '    exit 1' >> start.sh && \
    echo 'fi' >> start.sh && \
    echo 'echo "API en ejecucion. Esperando respuesta HTTP..."' >> start.sh && \
    echo 'count=0' >> start.sh && \
    echo 'while ! curl -s http://localhost:9090/CentroEducativo/login > /dev/null; do' >> start.sh && \
    echo '    count=$((count + 1))' >> start.sh && \
    echo '    echo "API cargando... intento $count de 40"' >> start.sh && \
    echo '    sleep 15' >> start.sh && \
    echo '    if [ $count -ge 40 ]; then echo "TIEMPO AGOTADO"; cat api_log.txt; exit 1; fi' >> start.sh && \
    echo 'done' >> start.sh && \
    echo 'echo "API LISTA! Poblando..."' >> start.sh && \
    echo './poblar_centro_educativo.sh' >> start.sh && \
    echo 'kill $SOCAT_PID' >> start.sh && \
    echo 'export CATALINA_OPTS="-Xms128m -Xmx160m -XX:+UseSerialGC -Djava.security.egd=file:/dev/./urandom"' >> start.sh && \
    echo 'catalina.sh run' >> start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]