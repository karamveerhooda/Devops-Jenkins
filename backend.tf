terraform {
  backend "s3" {
    bucket         = "kktfstatefile"
    key            = "terraform/state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kktfstateddb"
    encrypt        = true
  }
}
