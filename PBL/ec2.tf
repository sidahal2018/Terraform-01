# create Bastion hosts

resource "aws_instance" "bastion" {  # lookup(map, key, [default]) - Performs a dynamic lookup into a map variable based on the region
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
  ami = lookup(var.ec2_ami, var.region)
  instance_type= var.instance_type
  subnet_id = element(aws_subnet.public.*.id, count.index)
  security_groups = [aws_security_group.bastion_security_groups.id]
  key_name = aws_key_pair.keypair.key_name
  tags = {
    Name = var.Bastion_name
  }
}
 # create webservers
 resource "aws_instance" "web" {
  count = var.required_number_of_publicsubnets == null ? length(data.aws_availability_zones.available.names) :var.required_number_of_publicsubnets
  ami = lookup(var.ec2_ami, var.region)
  instance_type= var.instance_type
  subnet_id = element(aws_subnet.public.*.id, count.index)
  security_groups = [aws_security_group.bastion_security_groups.id]
  user_data = file("script.sh")                         # file function reads the scripts from the script.sh file 
  key_name = aws_key_pair.keypair.key_name
  tags = {
  Name = "Webserver-${count.index+1}"
  }
}