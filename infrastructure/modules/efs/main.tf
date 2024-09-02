resource "aws_efs_file_system" "short-video-db" {
  creation_token = "short-video-demo"

  lifecycle_policy {
    transition_to_ia = var.lifecycle_policy
  }
}

resource "local_file" "efs_id" {
    content  = aws_efs_file_system.short-video-db.id
    filename = "${path.module}/efs_id"
}