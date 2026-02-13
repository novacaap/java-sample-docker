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

The Dockerfile expects an `m2-repo/` directory in the build context (used for optional Maven dependencies from OCI Object Storage). If you don't need private dependencies, create an empty directory so the build succeeds:

```bash
mkdir -p m2-repo
docker build -t java-sample-app .
docker run -p 8080:8080 java-sample-app
```

If you need dependencies from an OCI bucket, populate `m2-repo/` in Maven repository layout (e.g. `m2-repo/com/company/artifact/1.0/artifact-1.0.jar`) before building—for example by running the OCI CLI bulk-download step locally with your OCI config, or by using the same workflow (CI sets `USE_OCI_M2=true` and secrets).

## Run with Docker Compose (local build and run)

Ensure `m2-repo/` exists (e.g. `mkdir -p m2-repo`) so the build context is valid. Then build the image and start the app:

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

## GitHub Actions: Variables and Secrets

Configure these in the repo **Settings → Secrets and variables → Actions** for the Docker build-and-push workflow. The workflow pushes images to **Docker Hub** only.

### Variables

| Variable               | Required             | Sample / description                                                                   |
| ---------------------- | -------------------- | -------------------------------------------------------------------------------------- |
| `DOCKERHUB_USERNAME`   | Yes                  | Docker Hub username, e.g. `myuser`. Image is pushed as `myuser/java-sample-app:<tag>`. |
| `OCI_BUCKET_NAMESPACE` | When USE_OCI_M2=true | `axabcdefghij` (tenancy namespace)                                                     |
| `OCI_BUCKET_NAME`      | When USE_OCI_M2=true | `maven-m2-bucket`                                                                      |
| `OCI_M2_PREFIX`        | No                   | `m2-repo/` or leave empty for bucket root                                              |
| `USE_OCI_M2`           | No (default: false)  | `true` to download M2 JARs from OCI before build                                       |

### Secrets

| Secret              | Required             | Sample / description                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `DOCKERHUB_TOKEN`   | Yes                  | Docker Hub personal access token (PAT). Create at [Docker Hub → Account Settings → Security → New Access Token](https://hub.docker.com/settings/security). **Access permissions:** set to **Read, Write, Delete** (or at least **Read & Write**). If you see "access token has insufficient scopes" or 401 Unauthorized on push, create a new token with write/push permission. Email is not required for the workflow—username + PAT is enough. |
| `TEAMS_WEBHOOK_URL`  | No                   | Microsoft Teams incoming webhook URL. When set, the workflow sends a notification (success/failure) with status, ref, commit, image tag, and link to the run. Create in Teams: channel → Connectors → Incoming Webhook.                                                                                                                                                                                                                          |
| `OCI_CLI_USER`       | When USE_OCI_M2=true | User OCID from OCI config `[DEFAULT]` `user=`.                                                                                                                                                                                                                                                                                                                                                                                                    |
| `OCI_CLI_TENANCY`    | When USE_OCI_M2=true | Tenancy OCID from config `tenancy=`.                                                                                                                                                                                                                                                                                                                                                                                                             |
| `OCI_CLI_FINGERPRINT`| When USE_OCI_M2=true | API key fingerprint from config `fingerprint=`.                                                                                                                                                                                                                                                                                                                                                                                                  |
| `OCI_CLI_KEY_CONTENT`| When USE_OCI_M2=true | Full private key PEM (entire key file content).                                                                                                                                                                                                                                                                                                                                                                                                  |
| `OCI_CLI_REGION`     | When USE_OCI_M2=true | Region identifier, e.g. `ap-mumbai-1`, from config `region=`.                                                                                                                                                                                                                                                                                                                                                                                    |

**OCI secrets:** Values come from your `~/.oci/config` and the key PEM: copy `user`, `tenancy`, `fingerprint`, and `region` into the four named secrets, and paste the full PEM (including `-----BEGIN PRIVATE KEY-----` / `-----END PRIVATE KEY-----`) into `OCI_CLI_KEY_CONTENT`.
