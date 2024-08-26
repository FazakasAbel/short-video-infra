## Generate PEM (and OpenSSH) formatted private key.
resource "tls_private_key" "host-key-pair" {
  algorithm = "RSA"
  rsa_bits = 4096
}
## Create the file for Public Key
resource "local_file" "host-public-key" {
  depends_on = [ tls_private_key.host-key-pair ]
  content = tls_private_key.host-key-pair.public_key_openssh
  filename = var.public-key-path
}

## Create the sensitive file for Private Key
resource "local_sensitive_file" "host-private-key" {
  depends_on = [ tls_private_key.host-key-pair ]
  content = tls_private_key.host-key-pair.private_key_pem
  filename = var.private-key-path
  file_permission = "0600"
}

## AWS SSH Key Pair
resource "aws_key_pair" "client-key" {
  depends_on = [ local_file.host-public-key ]
  key_name = "client_key"
  public_key = tls_private_key.host-key-pair.public_key_openssh
}
