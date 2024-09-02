terraform {
    backend "s3" {
        bucket = "short-video-tf-state"
        key    = "backend/short-video-demo.tfstate"
        region = "eu-north-1"
        dynamodb_table = "remote-tf-backend"
    }
}