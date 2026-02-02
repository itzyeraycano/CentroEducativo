FROM tomcat:10.1-jdk11-openjdk-slim

RUN apt-get update && apt-get install -y curl jq wget && \
    wget https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.1/jaxb-impl-2.3.1.jar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

COPY . .

RUN mkdir -p webapps/ROOT && \
    cp -r NOL2425/src/main/webapp/* webapps/ROOT/

RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

RUN mkdir -p /home/dew/CentroEducativo/ && \
    cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/ || true

RUN sed -i 's/<JarScanner>/<JarScanner scanManifest="false"\/>/g' conf/context.xml

RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash\n\
# Subimos la API a 160MB para que Hibernate no se bloquee\n\
java -Xmx160m -cp "es.upv.etsinf.ti.centroeducativo-0.2.0.jar:jaxb-api-2.3.1.jar:jaxb-core-2.3.0.1.jar:jaxb-impl-2.3.1.jar" \
     org.springframework.boot.loader.JarLauncher > api_log.txt 2>&1 &\n\
echo "Esperando a que la API responda (max 3 min)..."\n\
for i in {1..40}; do\n\
    if curl -s http://localhost:9090/CentroEducativo/login > /dev/null; then\n\
        echo "API LISTA!"; ./poblar_centro_educativo.sh; break\n\
    fi\n\
    echo "Cargando ($i/40)..."; sleep 5\n\
done\n\
# Limitamos Tomcat para compensar el aumento de la API\n\
export CATALINA_OPTS="$CATALINA_OPTS -Xms128m -Xmx160m -Djava.security.egd=file:/dev/./urandom"\n\
catalina.sh run' > start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]