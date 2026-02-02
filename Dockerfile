FROM tomcat:9.0-jdk8-openjdk-slim

# Instalamos curl y jq para que el script de población funcione
RUN apt-get update && apt-get install -y curl jq && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat

# Copiamos todo el contenido del repositorio al contenedor
COPY . .

# 1. Configurar la WebApp de Tomcat
# Mueve tu contenido web al lugar donde Tomcat lo sirve
RUN mkdir -p webapps/ROOT && \
    cp -r NOL2425/src/main/webapp/* webapps/ROOT/

# 2. Compilación manual de tus Servlets
# Usamos las librerías en WEB-INF/lib para compilar el código de src
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

# 3. Truco de compatibilidad para el script .sh de la API
# Creamos la ruta de la universidad para que el .sh original no falle
RUN mkdir -p /home/dew/CentroEducativo/ && \
    cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/

# 4. Crear el script de arranque (Start Script)
# Lanza la API, espera a que cargue, puebla datos y arranca Tomcat
RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    echo '#!/bin/bash\n\
./lanzaCentroEducativo.sh &\n\
echo "Esperando 30s a que la API levante..."\n\
sleep 30\n\
./poblar_centro_educativo.sh\n\
echo "Población completada. Iniciando Servidor Web..."\n\
catalina.sh run' > start.sh && \
    chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]