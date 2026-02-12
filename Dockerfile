FROM tomcat:10.1-jdk11-openjdk-slim

# 1. Instalación de dependencias y parches JAXB (URLs corregidas)
RUN apt-get update && apt-get install -y curl jq wget procps && \
    wget https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar && \
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

# 5. Generar script de arranque start.sh
RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash' > start.sh && \
    # Lanzamiento con optimización de entropía para acelerar el inicio de la JVM
    echo 'java -Djava.security.egd=file:/dev/./urandom -cp "es.upv.etsinf.ti.centroeducativo-0.2.0.jar:jaxb-api-2.3.1.jar:jaxb-core-2.3.0.1.jar:jaxb-impl-2.3.1.jar" org.springframework.boot.loader.JarLauncher > api_log.txt 2>&1 &' >> start.sh && \
    # Bucle de espera agresivo (reintenta cada 0.5 segundos en lugar de 2)
    echo 'echo "Arrancando ..."' >> start.sh && \
    echo 'until curl -s -f http://localhost:9090/CentroEducativo/login > /dev/null; do' >> start.sh && \
    echo '  sleep 0.5' >> start.sh && \
    echo 'done' >> start.sh && \
    # Población inmediata
    echo 'echo "API Online. Poblando datos..."' >> start.sh && \
    echo './poblar_centro_educativo.sh' >> start.sh && \
    # Tomcat con parámetros de rendimiento para local
    echo 'echo " Lanzando Tomcat..."' >> start.sh && \
    echo 'export CATALINA_OPTS="-Djava.security.egd=file:/dev/./urandom"' >> start.sh && \
    echo 'catalina.sh run' >> start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]