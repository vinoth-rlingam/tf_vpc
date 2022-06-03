terraform {
  backend "s3" {}
}

data "terraform_remote_state" "remotestate" {
  backend = "s3"

  config = {
    bucket = "s3statestore-vpctf"
    region = "us-east-1"
    key    = "terraform.tfstate"
  }
}