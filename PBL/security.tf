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
# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "test-attach" {
    role       = aws_iam_role.test_role.name
    policy_arn = aws_iam_policy.policy.arn
}
# Create Instance Profile and interpolate the IAM role
resource "aws_iam_instance_profile" "ip" {
    name = "aws_instance_profile_test"
    role =  aws_iam_role.test_role.name
}