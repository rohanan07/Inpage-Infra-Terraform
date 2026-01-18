terraform {
  backend "s3" {
    bucket = "terraform-state-file-rohan-1234"
    key = "inpage/terraform.tfstate"
    encrypt = true
    use_lockfile = true
    region = "ap-south-1"
  }
}