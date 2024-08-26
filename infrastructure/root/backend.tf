terraform {
    backend "s3" {
        bucket = "short-video-demo"
        key    = "backend/short-video-demo.tfstate"
        region = "us-east-1"
        dynamodb_table = "remote-backend"
    }
}