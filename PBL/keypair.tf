resource "aws_key_pair" "keypair" {
  key_name = var.my_key_pair_name
  public_key = file("c:/Users/Siki/.ssh/id_rsa.pub")
}