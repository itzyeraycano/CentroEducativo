FROM tomcat:10.1-jdk11-openjdk-slim

# 1. Instalación de dependencias y parches JAXB
RUN apt-get update && apt-get install -y curl jq wget procps && \
    wget https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.1/jaxb-impl-2.3.1.jar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

# 2. Copiar archivos del repositorio
COPY . .

# 3. Preparar estructura de la web y compilar
RUN mkdir -p webapps/ROOT && cp -r NOL2425/src/main/webapp/* webapps/ROOT/
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

# 4. Asegurar ubicación del JAR de la API
RUN mkdir -p /home/dew/CentroEducativo/ && \
    cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/ || true

# 5. Generar script de arranque start.sh (SIN LIMITACIONES)
RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash' > start.sh && \
    # Configuración de usuarios para el Realm de Tomcat
    echo 'cat <<EOF > conf/tomcat-users.xml' >> start.sh && \
    echo '<?xml version="1.0" encoding="UTF-8"?>' >> start.sh && \
    echo '<tomcat-users>' >> start.sh && \
    echo '  <role rolename="rolalu"/> <role rolename="rolpro"/> <role rolename="admin"/>' >> start.sh && \
    echo '  <user username="111111111" password="654321" roles="admin,rolalu,rolpro"/>' >> start.sh && \
    echo '  <user username="33445566X" password="cuidadin" roles="rolalu"/>' >> start.sh && \
    echo '  <user username="69696969J" password="hola1234" roles="rolpro"/>' >> start.sh && \
    echo '  <user username="11223344A" password="batman" roles="rolalu"/>' >> start.sh && \
    echo '</tomcat-users>' >> start.sh && \
    echo 'EOF' >> start.sh && \
    # Configuración de credenciales para tu AuthFiltro
    echo 'mkdir -p webapps/ROOT/WEB-INF/' >> start.sh && \
    echo 'cat <<EOF > webapps/ROOT/WEB-INF/credenciales' >> start.sh && \
    echo '111111111=654321' >> start.sh && \
    echo '33445566X=cuidadin' >> start.sh && \
    echo '69696969J=hola1234' >> start.sh && \
    echo '11223344A=batman' >> start.sh && \
    echo 'EOF' >> start.sh && \
    # LANZAMIENTO SIN RESTRICCIONES (-Xms/-Xmx eliminados para que use la RAM del PC)
    echo 'java -cp "es.upv.etsinf.ti.centroeducativo-0.2.0.jar:jaxb-api-2.3.1.jar:jaxb-core-2.3.0.1.jar:jaxb-impl-2.3.1.jar" org.springframework.boot.loader.JarLauncher > api_log.txt 2>&1 &' >> start.sh && \
    # Espera a que la API responda
    echo 'while ! curl -s http://localhost:9090/CentroEducativo/login > /dev/null; do sleep 2; done' >> start.sh && \
    # Población de datos
    echo './poblar_centro_educativo.sh' >> start.sh && \
    # Iniciar Tomcat real con toda la potencia
    echo 'catalina.sh run' >> start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]