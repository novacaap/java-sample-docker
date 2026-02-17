# Maven build stage - Amazon Corretto 21
FROM maven:3.9.6-amazoncorretto-21-debian AS maven_build

COPY pom.xml /tmp/
# OCI-downloaded or empty m2-repo (workflow ensures directory exists). Option B: copy always so local build with empty m2-repo works.
COPY m2-repo/ /root/.m2/repository/

WORKDIR /tmp/
# Resolve dependencies only; layer cached separately so code-only changes skip this.
RUN mvn dependency:go-offline -B

COPY src /tmp/src/
RUN mvn package -DskipTests -B

# Runtime stage - Amazon Corretto 21
FROM amazoncorretto:21-alpine-jdk

EXPOSE 8080

COPY --from=maven_build /tmp/target/java-sample-app-1.0.0.jar /app/app.jar
# OCI config bucket: workflow may populate app-config/ (e.g. application.properties); optional so empty dir is fine
COPY app-config/ /app/config/

ENTRYPOINT ["java", "-Dspring.config.additional-location=optional:file:/app/config/", "-jar", "/app/app.jar"]
