FROM openjdk:22-rc-oracle

LABEL maintainer ="verohernandezfco@gmail.com"

VOLUME /tmp

EXPOSE 8080

ARG JAR_FILE=target/demoVero-0.0.1-SNAPSHOT.jar
ADD ${JAR_FILE} antlr-api.jar

ENTRYPOINT ["java", "-Djava.security.edg=file:/dev/./urandom", "-jar", "/antlr-api.jar"]
