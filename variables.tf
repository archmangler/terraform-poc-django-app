### Variables ###

variable "generic_instance_count" {
  description = "Number of server nodes to launch [min 3]"
  default = 2
}

variable "instance_type" {
 default = "t2.medium"
}

variable "access_key" {
  description = "AWS access key"
  default="AKIAJGSC5HYHUBT4P7DQ"
}

variable "secret_key" {
  description = "AWS secret key"
  default="d6RuyQZaj/8s6HFgfXlLctF93EeMlvKEYq0nX2+z"
}

variable "region" {
  default = "us-east-1"
}

variable "azs" {
    default = {
        # use "aws ec2 describe-availability-zones --region us-east-1"
        # to figure out the name of the AZs on every region
        "eu-central-1" = "eu-central-1a,eu-central-1b"
        "us-west-2" = "us-west-2a,us-west-2b,us-west-2c"
        "us-east-1" = "us-east-1a,us-east-1b,us-east-1c,us-east-1e"
        "eu-west-1" = "eu-west-1a,eu-west-1b,eu-west-1c"
    }
}

variable "route53_zone_id" {
  description = "Zone ID for the Route 53 zone "
  default = "Z355MAQUNEJUOV"
}

# AMIs for CentOS

variable "amis" {
  default = {
    eu-central-1 = "ami-fd1cc092"
    eu-west-1 = "ami-7abd0209"
    us-west-2 = "ami-d2c924b2"
    #us-east-1 = "ami-6d1c2007"
    #us-east-1 = "ami-a8a2dabe"
    #us-east-1 = "ami-0dd8a01b"
    #us-east-1 = "ami-fbd5aded"
    us-east-1 = "ami-00374c16"
  }
}

variable "ami" {
  default = {
    eu-central-1 = "ami-fd1cc092"
    eu-west-1 = "ami-7abd0209"
    us-west-2 = "ami-d2c924b2"
    #us-east-1 = "ami-a8a2dabe"
    #us-east-1 = "ami-0dd8a01b"
    #us-east-1 = "ami-fbd5aded"
    us-east-1 = "ami-00374c16"
  }
} 

variable "subnet_range" {
  description = "Subnet IP range"
  default = "172.31.0.0/16"
}

variable "subnet_dns" {
  description = "Subnet DNS"
  default = "172.31.0.2"
}

variable "generic_profile_name" {
 default="generic_profile"
}

variable "generic_subnet_id" {
 #default=["subnet-b1192cd4","subnet-79a66955","subnet-266fd76e","subnet-52e42108","subnet-201c4e1c"] 
 default=["subnet-79a66955","subnet-52e42108","subnet-201c4e1c","subnet-b1192cd4","subnet-266fd76e"]
}

variable "internal_sg_id" {
 default="sg-757a030b"
}


variable "admin_sg_id" {
 default="sg-757a030b"
}

variable "admin_ip" {
  default = ["0.0.0.0/0"]
}

variable "key_name" {
  description = "Name of existing AWS key pair to use"
  default="traiano"
}

variable "prefix" {
  description = "Used for naming instances in AWS (e.g. test)"
}

variable "owner" {
  description = "AWS tag of the owner (e.g. Slack username)"
  default = "traiano"
}

variable "expiration" {
  description = "AWS tag of the expiration time"
  default = "8hours"
}

variable "generic_vpc" {
 description = "VPC to deploy DCOS into"
 default = "vpc-b5f609cc"
}
