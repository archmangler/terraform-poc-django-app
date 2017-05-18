region = "us-east-1"
environment = "prod"
default_subnet = "subnet-201c4e1c"
vpc_id = "vpc-b5f609cc"
zone_id = ""
env = prod"

rds_mysql_node = {
  count = 1
}

aws_security_group_id = {
  sg_id = ["sg-757a030b"]
}
