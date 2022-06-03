terraform {
  backend "s3" {
    bucket         = "s3statestore-vpctf"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
