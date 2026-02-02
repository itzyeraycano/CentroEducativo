# Usamos Tomcat 10 para que tu código (Jakarta) compile correctamente
FROM tomcat:10.1-jdk11-openjdk-slim

# Instalamos curl, jq y descargamos las librerías XML que le faltan a Java 11
RUN apt-get update && apt-get install -y curl jq wget && \
    wget https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.1/jaxb-impl-2.3.1.jar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

COPY . .

# 1. Configurar la WebApp
RUN mkdir -p webapps/ROOT && \
    cp -r NOL2425/src/main/webapp/* webapps/ROOT/

# 2. Compilación (Ahora con Tomcat 10 encontrará jakarta.servlet)
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

# 3. Preparar la API
RUN mkdir -p /home/dew/CentroEducativo/ && \
    cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/ || true

# 4. Script de arranque con PARCHE XML para la API
# Incluimos los .jar descargados en el classpath de la API
RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash\n\
java -Xmx128m -cp "es.upv.etsinf.ti.centroeducativo-0.2.0.jar:jaxb-api-2.3.1.jar:jaxb-core-2.3.0.1.jar:jaxb-impl-2.3.1.jar" \
     org.springframework.boot.loader.JarLauncher > api_log.txt 2>&1 &\n\
echo "Levantando API... esta vez esperamos 85s para asegurar la base de datos..."\n\
sleep 85\n\
./poblar_centro_educativo.sh\n\
export CATALINA_OPTS="$CATALINA_OPTS -Xms128m -Xmx192m"\n\
catalina.sh run' > start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]