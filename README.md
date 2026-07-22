\# order-service — cloud-native DevSecOps demo



A small Flask API deployed to Kubernetes, with AWS infrastructure provisioned

entirely through Terraform, an automated CI/CD pipeline, hardened Kubernetes

manifests, and OpenTelemetry tracing.



\## Architecture



\- \*\*Local\*\*: app source (Flask) is containerized with Docker and deployed to

&#x20; a local Kubernetes cluster (`kind`) as a Deployment (2 replicas) + Service.

\- \*\*AWS (us-east-1)\*\*: Terraform provisions an S3 bucket + DynamoDB table for

&#x20; remote Terraform state, an ECR repository (image scanning + immutable tags),

&#x20; an AWS Secrets Manager secret, and a dedicated IAM identity for CI scoped to

&#x20; push/pull on exactly one ECR repository.

\- \*\*CI/CD\*\*: GitHub Actions builds the image on every push, scans it with

&#x20; Trivy (fails the build on critical/high vulnerabilities), and pushes to ECR

&#x20; — authenticated as the scoped CI identity, never an admin credential.

\- \*\*Observability\*\*: the app is instrumented with OpenTelemetry, emitting a

&#x20; nested span (`fetch-orders-from-db`) inside every request trace.



\## Security \& compliance practices implemented



\- Least-privilege IAM: a dedicated CI identity limited to one action set on

&#x20; one ECR repository ARN, separate from the admin identity used to bootstrap

&#x20; infrastructure.

\- Terraform remote state (S3 + DynamoDB locking) instead of local/unversioned

&#x20; state.

\- Container image scanning (Trivy) gating every CI build.

\- Immutable ECR image tags — no silent overwrite of a shipped version.

\- Kubernetes pod hardening: non-root user, read-only root filesystem, all

&#x20; Linux capabilities dropped, no privilege escalation.

\- Resource requests/limits on every container (no `BestEffort` QoS).

\- No Kubernetes API token mounted (`automountServiceAccountToken: false`) —

&#x20; this workload has no legitimate need to call the API.

\- Default-deny NetworkPolicy with one explicit allow rule for the app's own

&#x20; port, plus DNS.

\- Secrets referenced by name (`secretKeyRef`) — never hardcoded in YAML or

&#x20; committed to git. A parallel copy lives in AWS Secrets Manager, with the

&#x20; local-cluster gap (no IRSA on `kind`) documented rather than glossed over.



\## 90-second demo script



"This is a small order service, but it's wired up the way I'd want a real

production service wired up. The app itself is unremarkable — a couple of

REST endpoints — but everything around it demonstrates the practices this

role needs.



Infrastructure is 100% code: Terraform provisions the AWS side — an ECR

repo, remote state storage, and IAM — and Kubernetes manifests define the

runtime. Nothing was clicked into existence in a console.



Every code push triggers CI: it builds a fresh image, scans it for known

vulnerabilities with Trivy, and only pushes to ECR if that scan passes —

authenticated with a credential that can do exactly one thing: push to this

one repository. It can't touch anything else in the AWS account.



The Kubernetes side is hardened, not defaulted: containers run as non-root

with a read-only filesystem, have no more CPU or memory than they need, have

no Kubernetes API access at all since they don't need it, and sit behind a

default-deny network policy with one narrow exception.



And the app is instrumented with OpenTelemetry — so when a request is slow,

I don't just know it was slow, the trace tells me exactly which internal

operation caused it. That's the same category of signal a tool like this

company's product is built to reason about automatically."



\## Known limitations (deliberate scope decisions)



\- Runs on `kind` locally, not a real EKS cluster — chosen to iterate for

&#x20; free during learning; the same manifests apply to EKS with minimal changes.

\- NetworkPolicies are applied but not enforced by `kind`'s default CNI

&#x20; (kindnet); would be enforced on EKS with Calized or the VPC CNI's policy

&#x20; mode enabled.

\- Secrets Manager secret isn't auto-synced into the cluster (would need

&#x20; IRSA + External Secrets Operator on real EKS); Kubernetes-native Secret

&#x20; used instead for this environment, with the gap stated explicitly.

