# Practice Tour Guide — Infrastructure

DevOps infrastructure for the Flutter Tour Guide App.

## Architecture

```
Flutter App → Cloud Run (FastAPI) → Firestore
                 ↓
          Secret Manager (API keys)
```

**Three environments**, each a separate GCP project:

| Environment | GCP Project | Branch | Auto-deploys on push |
|-------------|-------------|--------|---------------------|
| Dev | `practice-tour-dev` | `dev` | Yes |
| Staging | `practice-tour-staging` | `staging` | Yes |
| Production | `project-e03d9435-10f2-445b-943` | `main` | Yes |

## Prerequisites

- [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated
- [Docker](https://docs.docker.com/get-docker/) (for local testing)
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- Git + GitHub SSH access to `Hedeanly/practice-tour-infra`

## Getting Started

```bash
# 1. Clone the repo
git clone git@github.com:Hedeanly/practice-tour-infra.git
cd practice-tour-infra

# 2. Authenticate with GCP (use your team Google account)
gcloud auth login
gcloud config set project practice-tour-dev

# 3. Switch to the dev branch for day-to-day work
git checkout dev
```

## Branch Strategy

```
dev → staging → main
 ↓       ↓       ↓
Dev   Staging   Prod
```

1. Do your work on `dev` (or feature branches merged into `dev`)
2. When ready to test, merge `dev` → `staging`
3. When approved, merge `staging` → `main` for production release

**Never push directly to `main`.** Always go through `dev` → `staging` → `main`.

## Project Structure

```
practice-tour-infra/
├── .github/workflows/
│   ├── deploy-dev.yml       # CI/CD: dev branch → dev project
│   ├── deploy-staging.yml   # CI/CD: staging branch → staging project
│   └── deploy-prod.yml      # CI/CD: main branch → prod project
├── hello-service/
│   ├── main.py              # FastAPI app
│   └── Dockerfile           # Container definition
├── main.tf                  # Terraform — API enablement
├── variables.tf             # Terraform — input variables
├── provider.tf              # Terraform — Google Cloud provider
├── versions.tf              # Terraform — version constraints
└── .gitignore               # Ignores secrets, state files, configs
```

## CI/CD Pipeline

Every push triggers automatic deployment:

1. GitHub Actions authenticates to GCP via **Workload Identity Federation** (no JSON keys)
2. **Cloud Build** builds the Docker image and pushes to **Artifact Registry**
3. Image is tagged with the **git commit SHA** for traceability
4. **Cloud Run** deploys the new image

## Service Accounts

Each backend service runs with its own least-privilege service account:

| Service Account | Purpose | Permissions |
|----------------|---------|-------------|
| `sa-api-service` | API backend | Firestore read/write |
| `sa-maps-service` | Maps integration | Read secrets (Maps API key) |
| `sa-llm-service` | LLM inference | Read secrets + Firestore read/write |
| `sa-github-actions` | CI/CD pipeline | Cloud Build, Artifact Registry, Cloud Run |

## Secrets

Managed via **GCP Secret Manager** (never in code or .env files):

- `GOOGLE_MAPS_API_KEY` — Maps/Places API
- `LLM_API_KEY` — Llama inference
- `APP_SECRET_KEY` — JWT signing

To view secret names (not values):
```bash
gcloud secrets list --project practice-tour-dev
```

## Useful Commands

```bash
# Check Cloud Run service status
gcloud run services list --region asia-southeast1

# View Cloud Run logs
gcloud run services logs read hello-service --region asia-southeast1 --limit 50

# Check recent CI/CD runs
gh run list --limit 5

# Build and deploy manually (dev example)
gcloud builds submit --tag asia-southeast1-docker.pkg.dev/practice-tour-dev/practice-tour-repo/hello-service:manual ./hello-service
```

## Security Rules

- No secrets in code — use Secret Manager
- No JSON service account keys — use Workload Identity Federation
- Each service gets its own service account (least privilege)
- Firebase Auth handles user authentication
- Branch protection on `main` (no direct pushes)
