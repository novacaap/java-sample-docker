# Java 21 Spring Boot Sample App

A sample Java 21 Spring Boot 3 web application with REST APIs and Swagger UI.

## About Project

This project is a reference microservice for building, containerizing, and deploying Java applications with Oracle Cloud Infrastructure (OCI) integration. It demonstrates:

- **Application:** A Spring Boot 3.2 web app on Java 21 with REST endpoints, health check, and OpenAPI/Swagger UI.
- **Build & image:** Maven build, multi-stage Dockerfile (Amazon Corretto 21), and optional use of private Maven dependencies from OCI Object Storage.
- **Configuration:** Optional loading of property files at build time from a dedicated OCI config bucket (one folder per repo); the workflow updates `src/main/resources/application.properties` before the build so the JAR is built with those values.
- **CI/CD:** GitHub Actions workflow that validates variables and secrets, downloads M2 and/or config from OCI when enabled, builds and pushes the image to Docker Hub, and can notify Microsoft Teams.

Use it as a template for microservices that need OCI-backed Maven repos, centralized config in OCI, and Docker Hub publishing via GitHub Actions.

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

Then open http://localhost:8080 and http://localhost:8080/swagger-ui.html

## GitHub Actions: Workflow overview

The **Docker Build & Push to Docker Hub** workflow (`.github/workflows/docker-build-push-artifact-registry.yaml`) builds the app image and pushes it to Docker Hub.

- **Triggers:** Push to branches `dev`, `qa`, or `prod`; push of any tag; or manual run via **Actions → Workflow dispatch**.
- **Tag format:** Branch builds use `<ref>-<YYMMDDHH>-<short-sha>-<run_number>` (e.g. `dev-25021214-a1b2c3d-4`); tag builds use `<tag-name>-<short-sha>`.
- **Jobs:**
  1. **Pre-validate:** Checks `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`, then logs in to Docker Hub.
  2. **Build and push:** Checkout, optional M2 download from OCI Object Storage, optional config (property files) download from a separate OCI config bucket, Docker build, then push to Docker Hub.
  3. **Notify Teams:** If `TEAMS_WEBHOOK_URL` is set, sends a MessageCard with status, ref, commit, image tag, commit list (one per line), and a link to the run.

Optional **OCI M2:** When `USE_OCI_M2=true`, the workflow uses the [Oracle OCI CLI GitHub Action](https://github.com/marketplace/actions/run-an-oracle-cloud-infrastructure-oci-cli-command) to download Maven dependencies from an OCI bucket into `m2-repo/` before the Docker build. You must set the OCI variables and five OCI secrets below.

Optional **OCI config bucket:** When `USE_OCI_CONFIG=true`, the workflow downloads property files from a **separate** OCI bucket and updates `src/main/resources/application.properties` (and any `application-*.properties`) before the Docker/Maven build, so the JAR is built with those values. See **OCI config bucket (property files)** below.

## GitHub Actions: Variables and Secrets

Configure these in the repo **Settings → Secrets and variables → Actions**. The workflow pushes images to **Docker Hub** only.

### Variables

| Variable               | Required             | Description                                                                                                                                              |
| ---------------------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `DOCKERHUB_USERNAME`   | Yes                  | Docker Hub username. The image is pushed as `DOCKERHUB_USERNAME/<IMAGE_NAME>:<tag>`. The default `IMAGE_NAME` is set in the workflow (`env.IMAGE_NAME`). |
| `OCI_BUCKET_NAMESPACE` | When USE_OCI_M2=true | OCI Object Storage namespace (tenancy namespace). Find it in OCI Console under your tenancy or in `~/.oci/config` if you use the OCI CLI.                |
| `OCI_BUCKET_NAME`      | When USE_OCI_M2=true | Name of the bucket that holds your Maven M2 artifacts (e.g. JARs).                                                                                       |
| `OCI_M2_PREFIX`        | No                   | Object prefix (folder) inside the bucket. Use e.g. `m2-repo/` to download only objects under that prefix, or leave empty to use the bucket root.         |
| `USE_OCI_M2`           | No (default: false)  | Set to `true` to enable downloading M2 dependencies from OCI before the Docker build. Requires the OCI variables and five OCI secrets below.             |
| `USE_OCI_CONFIG`       | No (default: false)  | Set to `true` to enable downloading property files from a separate OCI config bucket (one folder per repo). Requires OCI config bucket variables and the same OCI secrets. |
| `OCI_CONFIG_BUCKET_NAMESPACE` | When USE_OCI_CONFIG=true | OCI Object Storage namespace for the **config** bucket (separate from M2 bucket). |
| `OCI_CONFIG_BUCKET_NAME`      | When USE_OCI_CONFIG=true | Name of the bucket that holds microservice property files (e.g. `application.properties`), with one folder per repo. |
| `OCI_CONFIG_PREFIX`    | No                   | Object prefix (folder) inside the config bucket, e.g. `config/` or `microservices/`. Download path is `<prefix><repo-name>/` or `<prefix><repo-name>/<profile>/`. Leave empty to use the bucket root. |
| `OCI_CONFIG_PROFILE`   | No                   | Optional Spring profile name (e.g. `prod`, `qa`). When set, config is downloaded from `<prefix><repo-name>/<profile>/`; use for profile-specific property files. |

### Secrets

| Secret                | Required             | Description                                                                                                                                                                                                                                                                                                       |
| --------------------- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `DOCKERHUB_TOKEN`     | Yes                  | Docker Hub personal access token (PAT). Create at [Docker Hub → Account Settings → Security → New Access Token](https://hub.docker.com/settings/security). Use **Read, Write, Delete** (or at least **Read & Write**). If you get "insufficient scopes" or 401 on push, create a new token with write permission. |
| `TEAMS_WEBHOOK_URL`   | No                   | Microsoft Teams incoming webhook URL. When set, the workflow sends a notification (success or failure) with status, ref, commit SHA, image tag, commit list (each commit on its own line), and a link to the workflow run. Create in Teams: channel → Connectors → Incoming Webhook.                              |
| `OCI_CLI_USER`        | When USE_OCI_M2 or USE_OCI_CONFIG=true | User OCID from your OCI config (`[DEFAULT]` → `user=`).                                                                                                                                                                                                                                                           |
| `OCI_CLI_TENANCY`     | When USE_OCI_M2 or USE_OCI_CONFIG=true | Tenancy OCID from config (`tenancy=`).                                                                                                                                                                                                                                                                            |
| `OCI_CLI_FINGERPRINT` | When USE_OCI_M2 or USE_OCI_CONFIG=true | API key fingerprint from config (`fingerprint=`).                                                                                                                                                                                                                                                                 |
| `OCI_CLI_KEY_CONTENT` | When USE_OCI_M2 or USE_OCI_CONFIG=true | Full private key PEM: entire contents of the key file (including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`).                                                                                                                                                                                  |
| `OCI_CLI_REGION`      | When USE_OCI_M2 or USE_OCI_CONFIG=true | Region identifier from config (`region=`), e.g. `ap-mumbai-1`, `us-ashburn-1`.                                                                                                                                                                                                                                    |
| `OCI_CLI_PASSPHRASE`  | No (when key encrypted) | Passphrase for the OCI API signing key. Set this secret only when your private key is encrypted (passphrase-protected). The workflow uses the `OCI_CLI_PASSPHRASE` environment variable expected by the OCI CLI. Leave unset if the key is not encrypted.                                                          |

### OCI setup (when using USE_OCI_M2)

1. Install the OCI CLI and run `oci setup config` locally, or use an existing `~/.oci/config` and API key.
2. From `~/.oci/config` under `[DEFAULT]`, copy:
   - `user` → secret **OCI_CLI_USER**
   - `tenancy` → secret **OCI_CLI_TENANCY**
   - `fingerprint` → secret **OCI_CLI_FINGERPRINT**
   - `region` → secret **OCI_CLI_REGION**
3. Paste the full key file (the PEM referenced by `key_file` in config) into secret **OCI_CLI_KEY_CONTENT**. If your key is encrypted (passphrase-protected), also set secret **OCI_CLI_PASSPHRASE** to the key’s passphrase.
4. Set variables **OCI_BUCKET_NAMESPACE** and **OCI_BUCKET_NAME** to your bucket. Optionally set **OCI_M2_PREFIX** (e.g. `m2-repo/`) to limit the download to a prefix.
5. Set variable **USE_OCI_M2** to `true`.

The workflow uses the official [Oracle OCI CLI GitHub Action](https://github.com/marketplace/actions/run-an-oracle-cloud-infrastructure-oci-cli-command), which installs and caches the OCI CLI and runs the list and bulk-download commands.

### Sample directory structures

#### M2 bucket (Maven dependencies)

The workflow downloads objects from your M2 bucket into `m2-repo/` in **Maven repository layout** (group/artifact/version). Use **OCI_M2_PREFIX** to scope which objects are downloaded.

**Option 1: No prefix (bucket root)**  
Set `OCI_M2_PREFIX` empty. Objects at bucket root:

```
bucket: my-m2-bucket
├── com/
│   └── company/
│       └── my-lib/
│           └── 1.0.0/
│               ├── my-lib-1.0.0.jar
│               └── my-lib-1.0.0.pom
└── ...
```

After download → local `m2-repo/com/company/my-lib/1.0.0/` (Maven finds it as `com.company:my-lib:1.0.0`).

**Option 2: With prefix**  
Set `OCI_M2_PREFIX` to e.g. `m2-repo/` or `artifacts/`. Only objects under that prefix are downloaded:

```
bucket: my-m2-bucket
└── m2-repo/
    └── com/
        └── company/
            └── my-lib/
                └── 1.0.0/
                    ├── my-lib-1.0.0.jar
                    └── my-lib-1.0.0.pom
```

After download → local `m2-repo/com/company/my-lib/1.0.0/` (same layout; prefix is stripped by bulk-download path).

**Option 3: Multiple teams/repos under one bucket**  
Use a prefix per team or repo, e.g. `OCI_M2_PREFIX=team-a/` so only `team-a/...` is downloaded from the same bucket.

---

#### Config bucket (property files)

The workflow downloads objects from your **config** bucket into `config-repo/` and copies `application.properties` and `application-*.properties` into `src/main/resources/` before the build, so the JAR contains them. Path is built from **OCI_CONFIG_PREFIX** (optional), **repo name**, and **OCI_CONFIG_PROFILE** (optional).

**Option 1: No prefix, no profile**  
`OCI_CONFIG_PREFIX` and `OCI_CONFIG_PROFILE` empty. One folder per repo at bucket root:

```
bucket: microservice-config
└── java-sample-docker/
    ├── application.properties
    └── application-prod.properties   (optional, same folder)
```

**Option 2: No prefix, with profile**  
Set `OCI_CONFIG_PROFILE=prod`. Config is under `<repo-name>/<profile>/`:

```
bucket: microservice-config
└── java-sample-docker/
    ├── application.properties       (default, optional)
    └── prod/
        ├── application.properties
        └── application-prod.properties
```

**Option 3: With prefix, no profile**  
Set `OCI_CONFIG_PREFIX=config/`. All repo folders under that prefix:

```
bucket: microservice-config
└── config/
    ├── java-sample-docker/
    │   ├── application.properties
    │   └── logback-spring.xml
    └── other-service/
        └── application.properties
```

**Option 4: With prefix and profile**  
Set `OCI_CONFIG_PREFIX=config/` and `OCI_CONFIG_PROFILE=prod`:

```
bucket: microservice-config
└── config/
    └── java-sample-docker/
        ├── application.properties   (default)
        └── prod/
            ├── application.properties
            └── application-prod.properties
```

In all cases, the workflow copies `application.properties` and `application-*.properties` from the chosen folder into `src/main/resources/` before the Maven/Docker build, so the JAR is built with those properties.

### OCI config bucket (property files)

A **separate** OCI bucket can hold Java property files for all microservices: one folder per repository (folder name = repo name, e.g. `java-sample-docker`). The workflow downloads objects under that folder at build time and **updates `src/main/resources/application.properties`** (and any `application-*.properties`) before the Docker/Maven build, so the JAR is built with those values.

1. Create an OCI Object Storage bucket (e.g. `microservice-config`) for config only (not the M2 bucket).
2. For each microservice repo, create a folder in the bucket with the **repository name** (e.g. `java-sample-docker`). If you set **OCI_CONFIG_PREFIX** (e.g. `config/`), objects live under that prefix (e.g. `config/java-sample-docker/application.properties`). With **OCI_CONFIG_PROFILE** (e.g. `prod`), use a profile subfolder (e.g. `config/java-sample-docker/prod/application.properties`). Upload `application.properties` (and optionally profile-specific files) into the repo folder (or repo/profile folder).
3. Configure OCI CLI secrets as in **OCI setup (when using USE_OCI_M2)** above (same secrets work for both M2 and config bucket).
4. Set variables **OCI_CONFIG_BUCKET_NAMESPACE** and **OCI_CONFIG_BUCKET_NAME** to your config bucket’s namespace and name. Optionally set **OCI_CONFIG_PREFIX** (e.g. `config/`) and **OCI_CONFIG_PROFILE** (e.g. `prod`).
5. Set variable **USE_OCI_CONFIG** to `true`.

The built JAR will then contain the updated properties from the OCI config bucket.
