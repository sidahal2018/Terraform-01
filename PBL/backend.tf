terraform {
    backend "s3" {
        key = "terraform/tfstate.tfstate"
        bucket = "siki-remote-backend-2020"
        region = "us-east-2"
    }
}