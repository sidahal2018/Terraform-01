
#  create Bastion-Security group
resource "aws_security_group" "bastion_sg" {
    vpc_id = aws_vpc.main.id
    name = "vpc_web_sg"

   dynamic "ingress"{
  for_each = var.ingress_rules_bastion
  content {
  from_port         = ingress.value.from_port
  to_port           = ingress.value.to_port
  protocol          = ingress.value.protocol
  description       = ingress.value.description
  cidr_blocks       = var.allow_myip
  }
  }
dynamic "egress"{
  for_each = var.egressrules
    content {
    from_port = egress.value
    to_port = egress.value
    protocol= var.egress-rule-protocol
    cidr_blocks = var.egress_cidr_blocks
    }
  }

    tags = {
        Name = "Bastion-SG"
        Environment = var.environment
    }
}

# create Load Balancer security group

resource "aws_security_group" "lb_security_groups" {
  vpc_id = aws_vpc.myvpc.id
  dynamic "ingress"{
  for_each = var.ingress_rules_lb
  content {
  from_port         = ingress.value.from_port
  to_port           = ingress.value.to_port
  protocol          = ingress.value.protocol
  description       = ingress.value.description
  cidr_blocks       = var.cidr_all_traffic
  }
  }
   dynamic "egress"{
  for_each = var.egressrules
    content {
    from_port = egress.value
    to_port = egress.value
    protocol= var.egress-rule-protocol
    cidr_blocks = var.egress_cidr_blocks
    }
   }
  tags ={
    Name = var.lb_sg_name
  }
}

resource "aws_security_group" "webtraffic" {
  vpc_id = aws_vpc.myvpc.id
  dynamic "ingress" {
  iterator = port
  for_each = var.ingressrules
  content {
   from_port = port.value
   to_port = port.value
   protocol = var.sg-protocol
  security_groups = [aws_security_group.bastion_security_groups.id, aws_security_group.lb_security_groups.id]
  }
  }
  dynamic "egress"{
  iterator = port
  for_each = var.egressrules
    content {
    from_port = port.value
    to_port = port.value
    protocol= var.egress-rule-protocol
    cidr_blocks = var.egress_cidr_blocks
    }
  }
  tags = {
    Name = var.webserver_sg_name
  }
}
 resource "aws_security_group" "databasetraffic" {
   vpc_id = aws_vpc.myvpc.id
  dynamic "ingress" {
  iterator = port
  for_each = var.ingressrules
  content {
     from_port = port.value
     to_port = port.value
     protocol = var.sg-protocol
    security_groups = [aws_security_group.webtraffic.id, aws_security_group.bastion_security_groups.id]
   }
  }
   dynamic "egress"{
  iterator = port
  for_each = var.egressrules
    content {
    from_port = port.value
    to_port = port.value
    protocol= var.egress-rule-protocol
    cidr_blocks = var.egress_cidr_blocks
    }
  }
  tags = {
    Name = var.DB_sg_name
  }
}