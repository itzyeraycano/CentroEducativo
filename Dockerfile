# Volvemos a Java 8 para que el .jar tenga todas sus librerías nativas
FROM tomcat:9.0-jdk8-openjdk-slim

RUN apt-get update && apt-get install -y curl jq && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

COPY . .

# 1. Configurar la WebApp
# Tomcat 9 usa el paquete 'javax', que es el que suele acompañar a Java 8
RUN mkdir -p webapps/ROOT && \
    cp -r NOL2425/src/main/webapp/* webapps/ROOT/

# 2. Compilación
# Nota: Si tu código usa 'jakarta', este paso fallará. 
# Si falla, cambia la primera línea a 'FROM tomcat:10.1-jdk11-openjdk-slim'
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

# 3. Preparar la API
RUN mkdir -p /home/dew/CentroEducativo/ && \
    cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/ || true

# 4. Script de arranque con límites de memoria estrictos
RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash\n\
java -Xmx128m -jar es.upv.etsinf.ti.centroeducativo-0.2.0.jar &\n\
echo "Levantando API en entorno Java 8..."\n\
sleep 45\n\
./poblar_centro_educativo.sh\n\
export CATALINA_OPTS="$CATALINA_OPTS -Xms128m -Xmx192m"\n\
catalina.sh run' > start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]