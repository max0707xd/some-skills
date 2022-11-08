FROM openjdk:8-jre-alpine3.9


ADD ./application.properties /target/

WORKDIR /target
ADD ./target /target

ENTRYPOINT ["java", "-jar", "/target/embedash-1.1-SNAPSHOT.jar", "--spring.config.location=/target/application.properties"]
