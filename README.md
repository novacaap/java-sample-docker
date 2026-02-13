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

Configure these in the repo **Settings → Secrets and variables → Actions** for the Docker build-and-push workflow.

### Variables

| Variable | Required | Sample / description |
|----------|----------|----------------------|
| `GCP_PROJECT_ID` | Yes | `my-gcp-project` |
| `GCP_REGION` | No (default: asia-south1) | `asia-south1`, `us-central1` |
| `ARTIFACT_REGISTRY_REPO` | No (default: uvb-apps) | `uvb-apps`, `docker-repo` |
| `OCI_BUCKET_NAMESPACE` | When USE_OCI_M2=true | `axabcdefghij` (tenancy namespace) |
| `OCI_BUCKET_NAME` | When USE_OCI_M2=true | `maven-m2-bucket` |
| `OCI_M2_PREFIX` | No | `m2-repo/` or leave empty for bucket root |
| `USE_OCI_M2` | No (default: false) | `true` to download M2 JARs from OCI before build |

### Secrets

| Secret | Required | Sample / description |
|--------|----------|----------------------|
| `GCP_SA_KEY` | Yes | JSON key of the GCP service account (full file content). Used to push images to Artifact Registry. |
| `OCI_CLI_CONFIG` | When USE_OCI_M2=true | Full content of `~/.oci/config`. Example: |
| `OCI_CLI_KEY` | When USE_OCI_M2=true | Private key PEM for the OCI user in config. Example: |

**Example `OCI_CLI_CONFIG` (secret value):**

```ini
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaa...
fingerprint=aa:bb:cc:dd:...
tenancy=ocid1.tenancy.oc1..aaaaaaaa...
region=ap-mumbai-1
key_file=~/.oci/key.pem
```

**Example `OCI_CLI_KEY` (secret value):** Paste the entire PEM file, e.g.:

```
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASC...
...
-----END PRIVATE KEY-----
```

## Run tests

```bash
mvn test
```
