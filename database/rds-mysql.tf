provider "aws" {
  region  = "${var.region}"
  profile = "${var.env}"
  access_key = "YOURKEYIDHERE"
  secret_key = "YOURSECRETHERE"
}

resource "aws_db_instance" "rdsmysqldb" {
  count = 1
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.6.27"
  instance_class       = "db.t2.large"
  name                 = "midnight"
  username             = "nightowl"
  password             = "the-db-pasword"
  publicly_accessible  = true
  multi_az = true 
  parameter_group_name = "default.mysql5.6"
 tags = "${merge(map(
    "Name", format("%s-%d.%s", "traiano" ,1, var.generic_vpc),
    "created_by", "terraform",
    "Index", 1,
    "Env", var.env,
    "VPC", var.generic_vpc), var.tags)}"
}
