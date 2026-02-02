# Cambiamos a Tomcat 10 con Java 11 para máxima compatibilidad
FROM tomcat:10.1-jdk11-openjdk-slim

RUN apt-get update && apt-get install -y curl jq && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

COPY . .

# 1. Configurar la WebApp
RUN mkdir -p webapps/ROOT && \
    cp -r NOL2425/src/main/webapp/* webapps/ROOT/

# 2. Compilar
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

# 3. Preparar la API
RUN mkdir -p /home/dew/CentroEducativo/ && \
    cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/ || true

# 4. Script de arranque
# Nota: En Java 11 no solemos necesitar tantas banderas de "opens" como en Java 17
RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash\n\
java -jar es.upv.etsinf.ti.centroeducativo-0.2.0.jar &\n\
echo "Esperando 30s a que la API levante..."\n\
sleep 30\n\
./poblar_centro_educativo.sh\n\
catalina.sh run' > start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]