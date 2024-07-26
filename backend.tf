terraform {
  backend "s3" {
    bucket         = "kktfstatefile"
    key            = "terraform/state/myproject/2023-07-23/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kktfstateddb"
    encrypt        = true
  }
}
