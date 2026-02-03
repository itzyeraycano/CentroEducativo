FROM tomcat:10.1-jdk11-openjdk-slim

# Instalamos socat para mantener el puerto 8080 abierto "falsamente" durante la carga
RUN apt-get update && apt-get install -y curl jq wget socat && \
    wget https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar && \
    wget https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.1/jaxb-impl-2.3.1.jar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat
COPY . .

# Compilación
RUN mkdir -p webapps/ROOT && cp -r NOL2425/src/main/webapp/* webapps/ROOT/
RUN mkdir -p webapps/ROOT/WEB-INF/classes && \
    javac -d webapps/ROOT/WEB-INF/classes \
    -cp "NOL2425/src/main/webapp/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
    $(find NOL2425/src/main/java -name "*.java")

RUN mkdir -p /home/dew/CentroEducativo/ && cp es.upv.etsinf.ti.centroeducativo-0.2.0.jar /home/dew/CentroEducativo/ || true


RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    printf '#!/bin/bash\n\
socat TCP-LISTEN:8080,fork,reuseaddr PIPE & \n\
SOCAT_PID=$!\n\
\n\
# 1. Inyectar usuarios\n\
cat <<EOF > conf/tomcat-users.xml\n\
<?xml version="1.0" encoding="UTF-8"?>\n\
<tomcat-users>\n\
  <role rolename="rolalu"/> <role rolename="rolpro"/>\n\
  <user username="11223344A" password="batman" roles="rolalu"/>\n\
  <user username="69696969J" password="hola1234" roles="rolpro"/>\n\
  <user username="33445566X" password="cuidadin" roles="rolalu"/>\n\
</tomcat-users>\n\
EOF\n\
\n\
# 2. Lanzar API con parámetros de memoria EXTREMOS para 512MB\n\
# Reducimos a 128MB y forzamos el uso de memoria serie para ahorrar CPU\n\
java -Xms128m -Xmx128m -XX:+UseSerialGC -cp "es.upv.etsinf.ti.centroeducativo-0.2.0.jar:jaxb-api-2.3.1.jar:jaxb-core-2.3.0.1.jar:jaxb-impl-2.3.1.jar" org.springframework.boot.loader.JarLauncher > api_log.txt 2>&1 &\n\
\n\
echo "Esperando a la API (Máximo 10 min)..."\n\
count=0\n\
while ! curl -s http://localhost:9090/CentroEducativo/login > /dev/null; do\n\
    echo "API cargando... reintentando en 20s ($count/30)"\n\
    sleep 20\n\
    ((count++))\n\
    if [ $count -gt 30 ]; then\n\
        echo "=== ERROR: LA API NO ARRANCA. MOSTRANDO LOGS DE SPRING ==="\n\
        cat api_log.txt\n\
        exit 1\n\
    fi\n\
done\n\
\n\
echo "API LISTA! Poblando..."\n\
./poblar_centro_educativo.sh\n\
\n\
kill $SOCAT_PID\n\
sleep 2\n\
\n\
# 3. Tomcat con memoria ajustada\n\
export CATALINA_OPTS="-Xms128m -Xmx128m -XX:+UseSerialGC -Djava.security.egd=file:/dev/./urandom"\n\
catalina.sh run' > start.sh && chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]