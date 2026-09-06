Abdul Rafay ML API — CI/CD, Docker & MLOps Assignment
1. Project Overview
student-ml-api is a small FastAPI machine-learning inference API used to demonstrate a professional Git/GitHub workflow, automated testing, Docker containerization, GitHub Actions CI/CD, semantic versioning, GitHub Container Registry (GHCR), OCI image metadata, Docker build caching, and rollback to a known-good artifact.

The application exposes a health endpoint and a prediction endpoint.
API endpoints
GET /health — reports application health and version information.
POST /predict — accepts a numeric value and returns the prediction.

Example:

curl http://localhost:5000/health

curl -X POST http://localhost:5000/predict \

-H "Content-Type: application/json" \

-d '{"value":10}'

Observed prediction result:

{"input":10.0,"prediction":20.0}


2. Required Repository Structure
The repository contains the required assignment components:

app.py

requirements.txt

Dockerfile

.dockerignore

VERSION

tests/

.github/

└── workflows/

    ├── ci.yml

    └── release.yml

Additional evidence is stored under:

evidence/

├── docker-cache.txt

├── git-history.txt

├── oci-metadata.txt

└── sha-image.txt


3. Git Branching and Pull Requests
Development was performed through feature/fix branches and Pull Requests rather than normal development work being intentionally merged directly into main.

Relevant history includes:

PR #1 — feature/prediction-api
PR #3 — feature/model-metadata
PR #4 — feature/version-1.1.0
PR #5 — feature/fix-release-workflow
PR #6 — fix/ghcr-lowercase-image
PR #7 — fix/docker-version-tags
PR #8 — fix/manual-release-version

The repository also has branch protection requiring the test-and-build status check. PR #7 showed a successful required CI check:

CI / test-and-build (pull_request)

Successful in 19s

Required


4. Continuous Integration
The CI workflow is:

.github/workflows/ci.yml

Its purpose is to automatically verify changes before they are merged.

The successful PR validation demonstrated:

CI / test-and-build

PASS

The assignment also requires evidence of one failed CI execution. That failed execution should be referenced from the GitHub Actions history when presenting the project.


5. Docker Containerization
The application is packaged using:

Dockerfile

The image exposes port 5000 and starts the FastAPI application using Uvicorn.

Example:

docker run -d --name student-ml-api-release \

-p 5000:5000 \

ghcr.io/rafayashfaq/abdulrafay-ml-api:1.1.0

The container was successfully tested using:

curl http://localhost:5000/health

Observed version 1.1.0 result:

{

  "status": "healthy",

  "application": "student-ml-api",

  "application_version": "1.1.0",

  "model_version": "model-1"

}


6. Docker Build Cache Evidence
Two builds of the same application were measured.

Build
Time
Cold build
40.210 seconds
Cached build
2.537 seconds


Approximate improvement:

15.9x faster

The second build reused cached Docker layers, including the Python dependency installation layer.

This demonstrates why Dockerfile layer ordering matters in CI/CD: relatively stable dependency installation can be cached instead of being repeated for every source-code change.


7. OCI Image Metadata
The Dockerfile was enhanced with OCI-compatible labels populated through build arguments.

Observed metadata:

org.opencontainers.image.created

    2026-09-06T12:37:56Z

org.opencontainers.image.description

    Student ML inference API

org.opencontainers.image.revision

    58fb6431263bdef553a6f0fb74664a5f21b9b3b3

org.opencontainers.image.source

    https://github.com/rafayashfaq/AbdulRafay-ml-api

org.opencontainers.image.title

    student-ml-api

org.opencontainers.image.version

    1.1.0

The revision value provides traceability from a Docker image back to the source-code commit that produced it.


8. Semantic Versioning
Git release tags:

v1.0.0

v1.1.0

Docker/registry tags:

1.0.0

1.1.0

latest

The v prefix is used for Git release tags, while the Docker image uses the semantic version without the v prefix.

For example:

Git tag:

v1.1.0

Docker image:

ghcr.io/rafayashfaq/abdulrafay-ml-api:1.1.0


9. GitHub Container Registry
The release workflow publishes images automatically to GHCR.

Registry:

ghcr.io/rafayashfaq/abdulrafay-ml-api

Required artifacts:

1.0.0    present

1.1.0    present

latest   present

The 1.0.0 artifact was published using the GitHub Actions manual release workflow while checking out the historical v1.0.0 tag. This avoids manually uploading the Docker image.


10. Release Workflow
The release workflow is:

.github/workflows/release.yml

Automatic releases are triggered by Git tags matching:

v*.*.*

The workflow:

Checks out the source.
Logs into GHCR using GITHUB_TOKEN.
Determines the semantic image version.
Builds the Docker image.
Supplies OCI metadata build arguments.
Pushes the versioned image.
Updates the latest tag.

The workflow also supports a manual release so that a historical Git tag can be reproduced as a registry artifact.


11. Release Verification
For version 1.0.0:

docker pull ghcr.io/rafayashfaq/abdulrafay-ml-api:1.0.0

The image was successfully pulled after the GitHub Actions release completed.

For version 1.1.0:

docker pull ghcr.io/rafayashfaq/abdulrafay-ml-api:1.1.0

The image was successfully pulled.

For latest:

docker pull ghcr.io/rafayashfaq/abdulrafay-ml-api:latest

The image was successfully pulled and corresponded to the 1.1.0 release artifact.


12. Rollback Demonstration
Rollback was demonstrated from version 1.1.0 to the known-good 1.0.0 Docker artifact.
Version 1.1.0
The running 1.1.0 container returned:

{

  "status": "healthy",

  "application": "student-ml-api",

  "application_version": "1.1.0",

  "model_version": "model-1"

}
Rollback
The 1.1.0 container was stopped and removed:

docker stop student-ml-api-release

docker rm student-ml-api-release

Then the immutable 1.0.0 image was started:

docker run -d \

--name student-ml-api-rollback \

-p 5000:5000 \

ghcr.io/rafayashfaq/abdulrafay-ml-api:1.0.0

Health verification returned:

{"status":"healthy","application":"student-ml-api","version":"1.0.0"}

Prediction verification returned:

{"input":10.0,"prediction":20.0}

Therefore the rollback successfully restored the 1.0.0 artifact.


13. Reproducibility and Traceability
The project demonstrates artifact traceability using:

Git commit

    ↓

Git tag

    ↓

GitHub Actions release

    ↓

Docker image

    ↓

GHCR

    ↓

Container

The 1.1.0 Docker image contains OCI revision metadata identifying commit:

58fb6431263bdef553a6f0fb74664a5f21b9b3b3

This is preferable to relying only on latest, because immutable version tags identify the intended artifact.


14. CI vs Release Workflow
CI workflow
Purpose:

Validate proposed source-code changes

Typical flow:

Feature branch

    ↓

Pull Request

    ↓

CI

    ↓

Tests + Docker build check

    ↓

Review

    ↓

Merge
Release workflow
Purpose:

Turn an approved version into a distributable Docker artifact

Flow:

Git tag

    ↓

Release workflow

    ↓

Docker build

    ↓

GHCR

    ↓

Versioned image + latest


15. Why Direct Pushes to Main Are Restricted
Direct development pushes to main are undesirable because they bypass review and the normal validation workflow.

Pull Requests provide:

code review
CI validation
change discussion
traceable history
controlled integration into main

Branch protection was configured to require the test-and-build check.


16. Why latest Is Not Enough
latest does not uniquely identify a release.

For production traceability, use:

1.0.0

1.1.0

rather than relying only on:

latest

A versioned image can be reproduced, compared, deployed, and rolled back without ambiguity.


17. Same Artifact Promotion
The preferred release principle is:

Build once

    ↓

Test

    ↓

Publish

    ↓

Promote the same artifact

Rebuilding the image for every environment can produce a different artifact. Using an immutable image tag allows the exact tested artifact to be promoted consistently.


18. MLOps Consideration
Application and model versions may evolve independently.

This project exposes:

application_version

model_version

in the newer health response.

In a larger MLOps system, traceability should identify both:

Application version

+

Model version

+

Source commit

+

Docker image digest

This prevents ambiguity when application code changes while the model remains the same, or when a new model is deployed without changing the application.


19. Final Assignment Pipeline
Developer

   ↓

Feature Branch

   ↓

Commit + Push

   ↓

Pull Request

   ↓

GitHub Actions CI

   ├── Tests

   └── Docker Build Check

   ↓

Review + Merge

   ↓

main

   ↓

Semantic Version Tag

   ↓

Release Workflow

   ├── Test

   ├── Docker Build

   ├── Registry Login

   ├── Image Tagging

   └── Image Push

   ↓

GitHub Container Registry

   ├── 1.0.0

   ├── 1.1.0

   └── latest
20. Demonstration Checklist
Clone repository
Inspect Git history
Inspect Pull Requests
Inspect GitHub Actions
Pull versioned Docker image
Run container
Test /health
Test /predict
Demonstrate rollback
Verify Git tags v1.0.0 and v1.1.0
Verify registry artifacts 1.0.0, 1.1.0, and latest
Demonstrate Docker build caching
Demonstrate OCI metadata and source traceability
21. Core Principle
Git manages the evolution of source code. Pull Requests control how changes enter the main branch. CI verifies those changes. Docker converts approved source code into a reproducible artifact. The container registry stores and distributes versioned artifacts that can later be delivered consistently to staging and production.

