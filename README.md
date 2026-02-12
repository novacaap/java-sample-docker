# Java 21 Spring Boot Sample App

A sample Java 21 Spring Boot 3 web application with REST APIs and Swagger UI.

## Features

- **Java 21** with **Spring Boot 3.2**
- **Sample REST API**
  - `GET /` – Welcome message
  - `GET /api/hello?name=...` – Greeting (default: "World")
  - `GET /api/health` – Health check
  - `GET /api/items` – List items
  - `GET /api/items/{id}` – Get item by ID
  - `POST /api/items` – Create item (JSON: `{"name":"...","description":"..."}`)
  - `DELETE /api/items/{id}` – Delete item
- **Swagger UI** at [/swagger-ui.html](http://localhost:8080/swagger-ui.html)
- **OpenAPI 3** spec at [/v3/api-docs](http://localhost:8080/v3/api-docs)

## Build & run locally

Requires **Java 21** and **Maven 3.8+**.

```bash
mvn clean package
java -jar target/java-sample-app-1.0.0.jar
```

Then open:

- http://localhost:8080
- http://localhost:8080/swagger-ui.html

## Run with Docker

```bash
docker build -t java-sample-app .
docker run -p 8080:8080 java-sample-app
```

## Run with Docker Compose (local build and run)

Build the image and start the app:

```bash
docker compose up --build
```

Run in the background:

```bash
docker compose up --build -d
```

Stop:

```bash
docker compose down
```

Then open http://localhost:8080 and http://localhost:8080/swagger-ui.html

## Run tests

```bash
mvn test
```
