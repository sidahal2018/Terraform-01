# Automate Infrastructure With IAC using Terraform Part 2
<p>In the previous Part we were able to to provision a VPC with public subnet </p>

<p>In this Part we are going to finalize all of the infrastructure</p>
![](./Images/AWS-Tooling-Website.PNG)
---
## Create Private Subnets

* According to the architecture we need to create 2 private subnets lets create the first one.  

In the `main.tf` file which we create before please add the following code

```
resource "aws_subnet" "private_1" {
  count = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4 , count.index + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
}
```
As we did before with public subnet we are doing the same with private subnet 
- Defined a variable in `Variables.tf` file called  `preferred_number_of_private_subnets_1`
```
  variable "preferred_number_of_private_subnets_1" {
      default = null
}
```
- Added the value to `terraform.tfvars`: 
`preferred_number_of_private_subnets_1 = 2`

---

**NOTE:**

We are going to create lots of resources so we need to <b>Tag </b> all resources we will create. Tags enable you to categorize your AWS resources in different ways, for example, by purpose, owner, or environment. This is useful when you have many resources of the same type

---
Update your private subnet resource to be as the following 

```
resource "aws_subnet" "private" {
  count = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4 , count.index + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "PrivateSubnet"
  }
}
```
All we did is just adding tags block to be  able to create the tag we want.

---

**NOTE:**  we can add multible tags easily to be as the following 
```
  tags = {
    Name = "PrivateSubnet"
    Environment = var.environment
  }
```
we added a variable called Environment to add our environment name to all resources which we create to help us in case if we have multiple environments.

`variables.tf`
```
variable "environment" {
      default = null
}
```
`terraform.tfvars`: `environment = "test"`
---
**Note:** Add the same tags to all resources which we created now and will create later but take care there are some resources don't accpet tags  

---
Full `main.tf` file after adding tags will be as following
```
# Get list of availability zones
data "aws_availability_zones" "available" {
state = "available"
}

provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block                     = var.vpc_cidr
  enable_dns_support             = var.enable_dns_support 
  enable_dns_hostnames           = var.enable_dns_support
  enable_classiclink             = var.enable_classiclink
  enable_classiclink_dns_support = var.enable_classiclink
  tags = {
    Name = "PublicSubnet"
    Environment = var.environment
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
  vpc_id = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4 , count.index +3)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  
}
resource "aws_subnet" "private" {
  count = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4 , count.index + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "PrivateSubnet"
    Environment = var.environment

  }
}

```
Now lets do `terraform plan`.

we will find that it is going to change the current vpc and public subnet to add to them tags and will add the new private subnet with tags 

![alt text](images/tags.png)

and if we did `terraform apply` 

we will find that aws updated with new subnets

![alt text](images/subnets.png)
---
## Introducing `format` Function 
`format` produces a string by formatting a number of other values according to a specification string. It is similar to the printf function in C, and other similar functions in other programming languages.
`format(spec, values...)`.

We create everything with `multi AZ` so we need to differentiate between them. This will help us to create good tagging sting by adding for example the count of the resource.
```
tags = {
    Name        =  format("PrivateSubnet-%s", count.index)
    Environment = var.environment
  }
  ```
now if you did a `terraform apply` again you will find that tag will be changed as the following: 

```
Terraform will perform the following actions:
  ~ update in-place

  # aws_subnet.private[0] will be updated in-place
  ~ resource "aws_subnet" "private" {
        id                              = "subnet-0926bfdb8329b35e5"
      ~ tags                            = {
          ~ "Name"        = "PrivateSubnet" -> "PrivateSubnet-0"
            # (1 unchanged element hidden)
        }
        # (8 unchanged attributes hidden)
    }

  # aws_subnet.private[1] will be updated in-place
  ~ resource "aws_subnet" "private" {
        id                              = "subnet-0f9d7e55b639f0281"
      ~ tags                            = {
          ~ "Name"        = "PrivateSubnet" -> "PrivateSubnet-1"
            # (1 unchanged element hidden)
        }
        # (8 unchanged attributes hidden)
    }

```
## Replicate What did we do for the other private subnet 
- make sure to update `variables.tf` file and `terraform.tfvars` file and then add the following code to `main.tf`
```
resource "aws_subnet" "private_2" {
  count = var.preferred_number_of_private_subnets_2 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4 , count.index + 7)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name =  format("PrivateSubnet2-%s", count.index )
    Environment = var.environment
  }
}
```
---
**NOTE:** The main aim of using terraform of using terraforn is to convert our infrastructure to code and this gives us the opportunity to organize our resources and one of the best practices that terraform gives. <b>It gives us the power to organize our resources in seprate files.</b>

---

## Create internet gateway
- create a file called `internet_gateway.tf` and the follwoing code to it 
```
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = format("%s-%s!",aws_vpc.main.id,"IG")
    Environment = var.environment
  }
}
```
## Create aws Natgateway
create a new file called `natgateway.tf` and the following code to it 
```
resource "aws_eip" "nat_eip" {
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
  tags = {
    Name        =  format("EIP-%s",var.environment)
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat" {
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        =  format("Nat-%s",var.environment)
    Environment = var.environment
  }
}
```
## Crearte aws routes 
### Create aws routes for public subnet
Create a file called `route_tables.tf` add the following code to it 

```
resource "aws_route_table" "public" {
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = format("Public-RT-%s", var.environment)
    Environment = var.environment
  }
}
resource "aws_route" "public" {
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table_association" "public" {
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

```
### Create aws routes for first private subnet
add to the same file `route_tables.tf` add the following code to it 
```
resource "aws_route_table" "private" {
  count = var.preferred_number_of_private_subnets_2 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_2
  vpc_id = aws_vpc.main.id
    tags = {
    Name        =  format("Private-RT, %s!",var.environment)
    Environment = var.environment
  }
}

resource "aws_route" "private" {
  count = var.preferred_number_of_private_subnets_2 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_2
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private" {
  count = var.preferred_number_of_private_subnets_2 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
```  
### Create aws routes for second private subnet
add to the same file `route_tables.tf` add the following code to it 
```
resource "aws_route_table" "private_2" {
  count = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1
  vpc_id = aws_vpc.main.id
    tags = {
    Name        =  format("private_2-RT, %s!",var.environment)
    Environment = var.environment
  }
}

resource "aws_route" "private_2" {
  count = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1
  route_table_id         = aws_route_table.private_2[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private_2" {
  count = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1
  subnet_id      = aws_subnet.private_2[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
```
Now if you did `terraform plan` and `terraform apply` it will add the following in `multi az`:
- Our main vpc 
- 2 public subnets 
- 4 private subnets 
- 2 internet gateway 
- 2 natgateway
- 2 EIPS
- 6 routetables

All of them are tagged resources as we set in `format` function 

---
## Introducing Backend on S3 
Each Terraform configuration can specify a backend, which defines where and how operations are performed, where state snapshots are stored, etc.

- If you are still learning how to use Terraform, we recommend using the default `local backend`, which requires no configuration.

- If you and your team are using Terraform to manage meaningful infrastructure, you will need to create terraform backend to save your state file at the cloud 

Add the foolowing configs to a file called `backend.tf`
1. We need to provision S3 to save our statefile there 
```
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-test-lab"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
```
2. We need to provision Dynamo DB to check state locking and consistency checking
```
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```
3. Do `terraform apply` to provision resources 
4. Create the Backend block
```
terraform {
  backend "s3" {
    bucket         = "terraform-state-test-lab"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```
5. Do a terraform init to initialize the new backend 

    This will initialize our new backend after confirming by typing `yes` 

6. Test it now 

    Before doing anything if you opened aws now to see what heppened you shoud be able to see the following:
    - tfstatefile is now inside the S3 bucket 
    ![alt text](images/tfstat_s3.png)
    - dynamodb table which we create has an entry includes state file status 
    ![alt text](images/tfstat_beforelock.png)
    - run now `terraform plan` and quickly go and watch what happened to dynamodb table 
      and how it is locked 
      ![alt text](images/tfstat_locked.png)
    - wait until `terraform plan` is finished and refresh dynamo db table, you be able to see that is back to their state 
      ![alt text](images/tfstat_afterfinishingplan.png)


### conclusion

Terraform will automatically pull the latest state from this S3 bucket before running a command, and automatically push the latest state to the S3 bucket after running a command. To see this in action, add the following output variables:
```
output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}
```
and then do `terraform apply`

Now, head over to the S3 console again, refresh the page, and click the gray “Show” button next to “Versions.” You should now see several versions of your terraform.tfstate file in the S3 bucket:
 ![alt text](images/tfstate_vesrsions.png)

---

**Note:**

With a remote backend and locking, collaboration is no longer a problem. However, there is still one more problem remaining: isolation. When you first start using Terraform, you may be tempted to define all of your infrastructure in a single Terraform file or a single set of Terraform files in one folder. The problem with this approach is that all of your Terraform state is now stored in a single file, too, and a mistake anywhere could break everything.

So the best solution for this should be state Isolation.

There are two ways you could isolate state files:
1. Isolation via workspaces: useful for quick, isolated tests on the same configuration.
2. Isolation via file layout: useful for production use-cases where you need strong separation between environments.

---

##  Creating an instance profile 
We want to pass an IAM role our EC2s to give them access on some specic resources so will need to do the following: 
1. Create Assume Role 
    
    Returns a set of temporary security credentials that you can use to access AWS resources that you might not normally have access to. These temporary credentials consist of an access key ID, a secret access key, and a security token. Typically, you use AssumeRole within your account or for cross-account access.
    
    Add the following code to a new file named  `security.tf`
    
    ```
    resource "aws_iam_role" "test_role" {
    name = "test_role"
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    }
    EOF
    tags = {
        Name = "aws assume role"
        Environment = var.environment
        }
    }
    ```
    In this code we are creating assume role with assume role policy. IT allows an entity [ec2 here] permission to assume the role. 

2. Create Iam policy to this role 
    This is where we need to define the required policy (i.e. permissions) according to the necessities. For example, allowing the IAM role to describe the ec2
    ```
    resource "aws_iam_policy" "policy" {
        name        = "test-policy"
        description = "A test policy"
        policy = <<EOF
        {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": [
                "ec2:Describe*"
            ],
            "Effect": "Allow",
            "Resource": "*"
            }
        ]
        }
        EOF
        tags = {
            Name = "aws assume policy"
            Environment = var.environment
        }
    }
    ```
3. Attach thie Policy to this role 
    
    This is where, we’ll be attaching the policy which we wrote above, to the role we created in the first step.
    ```    
    resource "aws_iam_role_policy_attachment" "test-attach" {
        role       = aws_iam_role.test_role.name
        policy_arn = aws_iam_policy.policy.arn
    }
    ```

4. Create Instance Profile and interpolate the IAM role
    ```
    resource "aws_iam_instance_profile" "ip" {
        name = "aws_instance_profile_test"
        role =  aws_iam_role.test_role.name
    }
    ```

## Create resources inside public subnet
As per our architecture we need to create the following resources inside the public subnet:

1. Upload the ssh key to keypairs 
2. 2 Bastion Ec2s with security groups
2. ALB 
3. Auto Scaling Group    

### Upload SSH key-pair to aws keypairs 
In order to be able to ssh to your machines you need to upload your ssh-key to aws keypair 
to generate yours just run the following command: `ssh-keygen` and just follow the instructions and save your public and private key.

To Upload your public key to aws keypair add the following code to `keypair.tf` file
```
resource "aws_key_pair" "Dare" {
  key_name   = "Dare"
  public_key = file("C:/Users/Dare/.ssh/id_rsa.pub")
}
``` 
### Create EC2 instances
In order to create EC2 we need first to Create security group to allow the 80, 443 and 22 ports 

To do it create a `security_group.tf` file  and add the following code to it:
```
resource "aws_security_group" "bastion_sg" {
    name = "vpc_web_sg"
    description = "Allow incoming HTTP connections."

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.main.id

    tags = {
        Name = "Bastion-SG"
        Environment = var.environment
    }
}
```
Add the EC2 configuration to `ec2.tf` file as follows:
```
resource "aws_instance" "bastion" {
    count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
    key_name      = aws_key_pair.Dare.key_name
    ami           = var.ami
    instance_type = "t2.micro"
    vpc_security_group_ids = [
        aws_security_group.bastion_sg.id
    ]
    iam_instance_profile = aws_iam_instance_profile.ip.name
    subnet_id = element(aws_subnet.public.*.id,count.index)
    associate_public_ip_address = true
    source_dest_check = false
    user_data = << EOF
		  #! /bin/bash
      echo "Hello from the other side"
	EOF
    tags = {
        Name = "Bastion-Test${count.index}"
    }
}
```
This creates 2 EC2s one in each subnet using the instance profile which we created before
 
---

**NOTE:**


In the above code inside `ec2.tf` you can find something called `user_data`. 

In many cases we might want to pass commands to the machine once it has been created, `user_data` helps us to do that. We can pass to file path or inline bash script  

---

**NOTE:** 

We are using the ami id multiple times in ASG and ec2 so we need to create it as variable so you need to add it to your variables.tf file 

```
variable "ami" {
  default = "ami-06255644cfdfdb869"
}
```
---
### Create ALB 

Create a file called `alb.tf`

First of all we need to create a security group for this ALB in `security_groups.tf`

```
resource "aws_security_group" "my-alb-sg" {
  name   = "my-alb-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.my-alb-sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.my-alb-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
```

We need to Create ALB to work as load balancer between EC2s 
```
resource "aws_lb" "my-aws-alb" {
  name     = "my-test-alb"
  internal = false
  security_groups = [
    aws_security_group.my-alb-sg.id,
  ]
  subnets = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]
  tags = {
    Name = "my-test-alb"
  }
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}
```

To be able to let the ALB routes to  the EC2s we need to create <b>Target Group</b> to know its target 

```
resource "aws_lb_target_group" "my-target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "my-test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}
```
Then we will need to Create Listner to this target Group
```
resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-target-group.arn
  }
}
```

Add the following outputs to `output.tf` to print them on screen  
```
output "alb_dns_name" {
  value = aws_lb.my-aws-alb.dns_name
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.my-target-group.arn
}
```
### Create ASG (Auto Scaling Group)

here we need to configure our ASG to be able to scale the EC2s Up and down depends on the application trrafic

1. As every new resource lets create resources group in `security_groups.tf`
```

resource "aws_security_group" "my-asg-sg" {
  name   = "my-asg-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "inbound_ssh-asg" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http-asg" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all-asg" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
```

2. we need to create the lunch configuration of this asg in `asg.tf` .  # Ask the students to refactor this code to use Launch templates.

```
resource "aws_launch_configuration" "my-test-launch-config" {
  image_id        = var.ami
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.my-asg-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello, from Terraform" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}
```
3. Lets create the ASG itself in `asg.tf`
```
resource "aws_autoscaling_group" "public_asg" {
  launch_configuration = aws_launch_configuration.my-test-launch-config.name
  vpc_zone_identifier  = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]
  target_group_arns    = [aws_lb_target_group.my-target-group.arn]
  health_check_type    = "EC2"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "my-test-asg"
    propagate_at_launch = true
  }
}
```

## Repeat all of the creation of EC2, ALB, ASG for private subnet

As per our architecture we need to create the following resources inside the private subnet:

1. 2 Ec2s with security groups
2. ALB 
3. Auto Scaling Group

---
**Note:** 

We are goinf to use some created resources we created while creating resources in public subnet as there resources are genreic and doesn't request specifec subnet 

---
### Create 2 EC2s

as we did before inside the public subnet we will create 2 ec2s with security groups

lets add the following code to `security_groups.tf`

```
resource "aws_security_group" "private_sg" {
    name = "vpc_private"
    description = "Allow incoming HTTP connections."

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    vpc_id = aws_vpc.main.id

    tags = {
        Name = "private-sg"
    }
}

```

Then we will be able to create the 2 EC2s by adding the following code to `ec2.tf`

```
resource "aws_instance" "private" {
    count  = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1   
    key_name      = aws_key_pair.Dare.key_name
    ami           = var.ami
    instance_type = "t2.micro"
    vpc_security_group_ids = [
        aws_security_group.private_sg.id
    ]
    subnet_id = element(aws_subnet.private.*.id,count.index)
    associate_public_ip_address = false
    source_dest_check = false
    tags = {
        Name = "private-Test${count.index}"
    }
}
```

### Create ALB 

As we did beofre in public subnet we will create new ALB but it will be private one add the following code to `alb.tf` file 

```
resource "aws_lb" "my-aws-alb-private" {
  name     = "my-test-alb-privare"
  internal = true
  security_groups = [
    aws_security_group.my-alb-sg.id,
  ]
  subnets = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id
  ]
  tags = {
    Name = "my-test-alb-private"
  }
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}
```
We used here the same security froup that we used for the public subnet one and for sure we can create new one 

We need to Create listner to this ALB and we will use same target group we used in public subnet, Add the following code to `alb.tf`

```
resource "aws_lb_listener" "my-test-alb-listner-private" {
  load_balancer_arn = aws_lb.my-aws-alb-private.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-target-group.arn
  }
}
```

### Create ASG 
As we did for the public one we will do the same for private one add the following code to `asg.tf`
```
resource "aws_autoscaling_group" "private_asg" {
  launch_configuration = aws_launch_configuration.my-test-launch-config.name
  vpc_zone_identifier  = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id
  ]
  target_group_arns    = [aws_lb_target_group.my-target-group.arn]
  health_check_type    = "EC2"
  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "private_asg"
    propagate_at_launch = true
  }
}

```



## Create EFS

Inorder to create EFS you need to create KMS key.
AWS Key Management Service (KMS) makes it easy for you to create and manage cryptographic keys and control their use across a wide range of AWS services and in your applications.
Add the following code to `kms.tf`
```
resource "aws_kms_key" "kms" {
  description = "KMS key "
  policy = <<EOF
  {
  "Version": "2012-10-17",
  "Id": "kms-key-policy",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::${var.account_no}:root"},
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_kms_alias" "alias" {
  name          = "alias/kms"
  target_key_id = aws_kms_key.kms.key_id
}
```
lets create EFS security group as every resource inside `security_groups.tf`

```
resource "aws_security_group" "SG" {
  vpc_id      = aws_vpc.main.id
  name        = "SG"
  description = "Allow Inbound Traffic"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # ingress {
  #   from_port   = 0
  #   to_port     = 65535
  #   protocol    = "tcp"
  #   cidr_blocks = ["${var.vpc_cidr}"]
  # }
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "2049"
    to_port     = "2049"
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port = 587
    to_port = 587
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags =  {
    Name = "efs-SG"
  }


}
```

Lets create EFS, add the following code to `efs.tf`

```
resource "aws_efs_file_system" "efs" {
  tags =  {
    Name = "efs"
  }
  encrypted = true
  kms_key_id = "${var.kms_arn}${aws_kms_key.kms.key_id}"
}
```

Then we need to create a mount volume. We will add two mount volumes 1 per availability zone

```
resource "aws_efs_mount_target" "mounta" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_2[0].id
  security_groups = [aws_security_group.SG.id]
}

resource "aws_efs_mount_target" "mountb" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_2[1].id
  security_groups = [aws_security_group.SG.id]
}

```
## Create RDS 

lets add RDS security Groups to `security_groups.tf`

```
resource "aws_security_group" "myapp_mysql_rds" {
  name        = "secuirty_group_web_mysqlserver"
  description = "Allow access to MySQL RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "rds_secuirty_group"
  }

}

resource "aws_security_group_rule" "security_rule" {
  security_group_id = aws_security_group.myapp_mysql_rds.id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"

  cidr_blocks = [
    var.vpc_cidr,
  ]
}
```
lets add RDS subnet groups to configure the high availabilty in out to AZ to `rds.tf` 

```
resource "aws_security_group" "myapp_mysql_rds" {
  name        = "secuirty_group_web_mysqlserver"
  description = "Allow access to MySQL RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "rds_secuirty_group"
  }

}
```
Lets Create the RDS, Add the following code to `rds.tf`

```
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "admin1234"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  skip_final_snapshot  = true
  multi_az             = "true"
}
```

5.  Create an AMI from the Console 
    1. Select the EC2 Instance to create an AMI ![](../images/Project17/Create-Ec2-AMI.png)
    2. Navigate to the AMi menu ![](../images/Project17/Navigate-To-AMI-Menu.png)
    3. Name the AMI ![](../images/Project17/Name-the-AMI.png)
    4. Copy the AMI ID ![](../images/Project17/Copy-AMI-ID.png)
11. Create launch template for bastion host - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
    1.  Introduce userdata 
12. NLB and public facing ALB
13. Target groups 
14. Create bastion-asg.tf and nginx-tg.tf to configure the ASG respectively
15. Repeat the process for private subnets (Internal ALB, autoscaling for webservers)
16. Create EFS and RDS in the 3rd private subnet
17. Ensure security groups are configured to allow respective connectivities.
                --------Required updates to the diagram 
                1. Introduce Tooling applications - More servers within the private subnet
                1. Jenkins 
                2. Sonarqube
                3. Artifactory
18. Add more resources (HA is not considered here)
    1.  Jenkins Ec2
    2.  Sonarqube
    3.  Artifactory


