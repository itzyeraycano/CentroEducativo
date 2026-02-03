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


# ... (Todo lo anterior igual hasta el printf del start.sh)

RUN chmod +x lanzaCentroEducativo.sh poblar_centro_educativo.sh && \
    printf '#!/bin/bash\n\
socat TCP-LISTEN:8080,fork,reuseaddr PIPE & \n\
SOCAT_PID=$!\n\
\n\
# 1. Inyectar usuarios para AuthFiltro\n\
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
# 2. Lanzar API usando el JAR directamente (forma más compatible)\n\
# Forzamos que los JARS de JAXB estén en el classpath\n\
java -Xms128m -Xmx128m -XX:+UseSerialGC \\\n\
     -cp "es.upv.etsinf.ti.centroeducativo-0.2.0.jar:jaxb-api-2.3.1.jar:jaxb-core-2.3.0.1.jar:jaxb-impl-2.3.1.jar" \\\n\
     org.springframework.boot.loader.JarLauncher > api_log.txt 2>&1 & \n\
\n\
# Si el anterior falla, intentamos el plan B (ejecución directa por manifest)\n\
if ! ps -p $! > /dev/null; then\n\
    java -Xms128m -Xmx128m -XX:+UseSerialGC -jar es.upv.etsinf.ti.centroeducativo-0.2.0.jar > api_log.txt 2>&1 &\n\
fi\n\
\n\
echo "Esperando a la API..."\n\
count=0\n\
while ! curl -s http://localhost:9090/CentroEducativo/login > /dev/null; do\n\
    echo "API cargando... reintentando en 20s ($count/30)"\n\
    sleep 20\n\
    ((count++))\n\
    if [ $count -gt 30 ]; then\n\
        echo "=== LOGS DE LA API (api_log.txt) ==="\n\
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
export CATALINA_OPTS="-Xms128m -Xmx160m -XX:+UseSerialGC -Djava.security.egd=file:/dev/./urandom"\n\
catalina.sh run' > start.sh && chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]

EXPOSE 8080
CMD ["./start.sh"]