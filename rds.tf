resource "aws_db_subnet_group" "poc" {
  name       = "poc"
  subnet_ids = module.vpc.intra_subnets
}


resource "aws_security_group" "rds" {
  name   = "poc_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.poc_instance.id]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.poc_instance.id]
  }
}

resource "aws_db_instance" "rds_poc" {
  identifier             = "rds-poc"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  engine                 = "mariadb"
  engine_version         = "10.11.6"
  username               = var.db.username
  password               = var.db.password
  db_subnet_group_name   = aws_db_subnet_group.poc.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false
}

output "rds_endpoint" {
  value = aws_db_instance.rds_poc.endpoint
}
