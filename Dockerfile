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
# 1. Generamos el tomcat-users.xml con TUS credenciales\n\
cat <<EOF > conf/tomcat-users.xml\n\
<?xml version="1.0" encoding="UTF-8"?>\n\
<tomcat-users xmlns="http://tomcat.apache.org/xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd" version="1.0">\n\
  <role rolename="admin"/> <role rolename="profesor"/> <role rolename="alumno"/>\n\
  <user username="111111111" password="654321" roles="admin,profesor,alumno"/>\n\
  <user username="12345678W" password="123456" roles="alumno"/>\n\
  <user username="23456387R" password="123456" roles="alumno"/>\n\
  <user username="34567891F" password="123456" roles="alumno"/>\n\
  <user username="93847525G" password="123456" roles="alumno"/>\n\
  <user username="37264096W" password="123456" roles="alumno"/>\n\
  <user username="23456733H" password="123456" roles="profesor"/>\n\
  <user username="10293756L" password="123456" roles="profesor"/>\n\
  <user username="06374291A" password="123456" roles="profesor"/>\n\
  <user username="65748923M" password="123456" roles="profesor"/>\n\
  <user username="69696969J" password="hola1234" roles="profesor"/>\n\
  <user username="11223344A" password="batman" roles="alumno"/>\n\
  <user username="55667788B" password="superman" roles="alumno"/>\n\
  <user username="33445566X" password="cuidadin" roles="alumno"/>\n\
</tomcat-users>\n\
EOF\n\
\n\
# 2. Lanzamos la API\n\
java -Xmx160m -cp "es.upv.etsinf.ti.centroeducativo-0.2.0.jar:jaxb-api-2.3.1.jar:jaxb-core-2.3.0.1.jar:jaxb-impl-2.3.1.jar" \
     org.springframework.boot.loader.JarLauncher > api_log.txt 2>&1 &\n\
\n\
echo "Esperando a la API..."\n\
while ! curl -s http://localhost:9090/CentroEducativo/login > /dev/null; do sleep 10; done\n\
\n\
# 3. Poblamos la base de datos de la API\n\
./poblar_centro_educativo.sh\n\
\n\
# 4. Arrancamos Tomcat\n\
export CATALINA_OPTS="-Xms128m -Xmx160m -Djava.security.egd=file:/dev/./urandom"\n\
catalina.sh run' > start.sh && chmod +x start.sh

EXPOSE 8080
CMD ["./start.sh"]