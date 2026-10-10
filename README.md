# ias-aws-lambda

Procesador de imágenes serverless en AWS. Recibe imágenes por `POST /upload`, las guarda en S3 y genera un recorte circular PNG de 40x40 px mediante una Lambda disparada por SQS. La infraestructura se define con Terraform y se despliega con GitHub Actions en tres entornos: dev, qa y prod.

## Arquitectura

```mermaid
flowchart LR
  C[Cliente] -->|POST /upload| A[API Gateway HTTP]
  A --> U[upload-lambda]
  U -->|PutObject uploads/| S[(S3 imágenes)]
  S -->|ObjectCreated| Q[SQS image-queue]
  Q -->|batch 5| R[crop-lambda]
  R -->|PutObject processed/| S
  Q -->|3 fallos| D[SQS DLQ]
  D --> AL[Alarma CloudWatch] --> SN[SNS]
```

Las Lambdas corren en subredes privadas de dos zonas de disponibilidad y acceden a S3 y SQS mediante VPC endpoints, sin salir a internet.

| Componente | Configuración |
|---|---|
| Red | VPC 10.0.0.0/16, subredes públicas 10.0.1.0/24 y 10.0.2.0/24, privadas 10.0.11.0/24 y 10.0.12.0/24, un NAT Gateway por zona |
| VPC endpoints | S3 Gateway limitado al bucket de imágenes, SQS Interface con DNS privado |
| API Gateway | HTTP API v2, ruta POST /upload, payload 2.0, CORS, throttling 10,000 rps, access logs JSON |
| upload-lambda | Node.js 20, 256 MB, 30 s. Acepta multipart o JSON base64, jpg/png/gif/webp, máximo 10 MB |
| crop-lambda | Node.js 20, 512 MB, 60 s, sharp 0.33. Recorte 40x40 con máscara circular y fondo transparente |
| S3 | AES-256, versionado, acceso privado. uploads/ expira a los 30 días y processed/ a los 90 |
| SQS | Cola Standard con visibility timeout de 360 s, retención de 1 día y long polling de 20 s. DLQ con retención de 14 días tras 3 fallos |
| IAM | Un rol por Lambda con mínimo privilegio |
| Observabilidad | Log groups con 14 días de retención y alarma sobre mensajes visibles en la DLQ |

## Estructura del repositorio

```
bootstrap/   Estado remoto, OIDC, roles de despliegue y presupuesto (se aplica una sola vez)
modules/     Un módulo Terraform por componente: network, storage, messaging, iam,
             observability, lambda-upload, lambda-crop, apigw
envs/        Composición de los módulos por entorno: dev, qa, prod
src/         Código de las Lambdas: upload-lambda, crop-lambda
scripts/     Validación de estructura usada por el pipeline y el hook local
.githooks/   Hook pre-push
.github/     Workflows, CODEOWNERS y plantilla de pull request
```

## Entornos

| Entorno | Rama | Despliegue |
|---|---|---|
| DEV | `dev` | Automático al mergear una PR |
| QA | `qa` | Automático al mergear la promoción desde `dev` |
| PROD | `main` | Al mergear la promoción desde `qa`, con aprobación del responsable |

Cada entorno tiene su propio estado en S3 y su propio rol de despliegue. Los recursos se nombran con el prefijo `image-processor-<entorno>`.

## Pipeline

```mermaid
flowchart LR
  B[Rama de trabajo] --> P[Pull request]
  P --> C[pr-checks]
  C --> R[4 aprobaciones con comentario]
  R --> M[Merge automático]
  M --> D[deploy]
```

| Workflow | Función |
|---|---|
| `pr-checks` | Conflictos, convenciones de commits y ramas, estructura de módulos y entornos, `fmt`, `validate` y `plan` publicado en la PR |
| `review-gate` | Exige 4 aprobaciones sobre el último commit, cada una con comentario, y mergea la PR |
| `deploy` | Instala las dependencias de las Lambdas y ejecuta `init`, `plan` y `apply` en el entorno de la rama |
| `conflict-sweep` | Cierra las PRs que quedan en conflicto después de un merge |
| `destroy` | Destruye un entorno. Solo lo ejecuta el responsable |
| `nightly-destroy` | Destruye dev y qa cada noche para controlar costos |

El acceso a AWS usa OIDC: GitHub obtiene credenciales temporales y el repositorio no guarda access keys. Las pull requests usan un rol de solo lectura.

## Reglas de trabajo

- Ramas `tipo/scope-nombre`, creadas desde `dev`.
- Commits con formato `tipo(scope): descripción`, en minúscula y sin punto final.
- Sin push directo a `dev`, `qa` ni `main`.
- Hook local: `git config core.hooksPath .githooks`.
