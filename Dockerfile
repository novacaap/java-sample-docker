# Maven build stage - Amazon Corretto 21
FROM maven:3.9.6-amazoncorretto-21-debian AS maven_build

COPY pom.xml /tmp/
COPY src /tmp/src/

WORKDIR /tmp/
RUN mvn package -DskipTests

# Runtime stage - Amazon Corretto 21
FROM amazoncorretto:21-alpine-jdk

EXPOSE 8080

COPY --from=maven_build /tmp/target/java-sample-app-1.0.0.jar /app/app.jar

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
