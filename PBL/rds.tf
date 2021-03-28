
# create DB subnet group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.private_2[0].id, aws_subnet.private_2[1].id]
  tags = {
    Name = "rds_subnet_group"
  }
}
resource "aws_db_instance" "rds" {
  name = "RDS-instance"
  identifier = "my-rds"
  username = "siki"
  password = "siki-db"
  instance_class = "db.t2.micro"
  storage_type = "gp2"
  instance_storge = "20 GB"
  engine = "mysql"
  engine_version= 12.0
  allocated_storage = 10
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  skip_final_snapshot = True
  
}