# Inicialize com:
#   terraform init \
#     -backend-config="bucket=SEU_BUCKET" \
#     -backend-config="key=observability/phase1/prod/terraform.tfstate" \
#     -backend-config="region=SEU_REGION"

terraform {
  backend "s3" {
    bucket       = "avonale-terraformstate"
    key          = "statefiles/observability/prod/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = false
  }
}
