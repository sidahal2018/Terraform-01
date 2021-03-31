terraform {
    backend "s3" {
        key = "tfstate.tfstate"
        bucket = "tooling-2021"
        region = "us-east-2"
    }
}