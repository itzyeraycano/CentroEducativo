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
    # 1. Lanzamos la API en segundo plano
    echo 'java -cp "es.upv.etsinf.ti.centroeducativo-0.2.0.jar:jaxb-api-2.3.1.jar:jaxb-core-2.3.0.1.jar:jaxb-impl-2.3.1.jar" org.springframework.boot.loader.JarLauncher > api_log.txt 2>&1 &' >> start.sh && \
    # 2. BLOQUEO: No seguimos hasta que la API responda 200 OK en el login
    echo 'echo "Esperando a que la API despierte..."' >> start.sh && \
    echo 'until curl -s -f http://localhost:9090/CentroEducativo/login > /dev/null; do' >> start.sh && \
    echo '  sleep 2' >> start.sh && \
    echo '  echo "API aún cargando... reintentando..."' >> start.sh && \
    echo 'done' >> start.sh && \
    # 3. Una vez que la API responde, poblamos los datos
    echo 'echo "API lista. Poblando base de datos..."' >> start.sh && \
    echo './poblar_centro_educativo.sh' >> start.sh && \
    # 4. SOLO AHORA lanzamos Tomcat
    echo 'echo "Iniciando Tomcat..."' >> start.sh && \
    echo 'catalina.sh run' >> start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]