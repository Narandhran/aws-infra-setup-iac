terraform {
  backend "s3" {
    bucket = "bckt-tf-state-b1os"    # Replace with your bucket name
    key    = "dev/terraform.tfstate" # Path inside the bucket
    region = "eu-west-1"             # Enable encryption
  }
}
