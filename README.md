# terraform-poc-django-app

A django application on HA infrastructure in AWS to demonstrate infrastructure as code with Terraform:

- 1 x multi-AZ ELB for redundancy, failover and decoupling.
- 1 x ASG with 2-3 web nodes running centos7, nginx and a basic Django application 
- 1 x multi-AZ RDS mysql DB providing the schema backend for the app
- 1 x route53 zone and zone entry to front the ELB hostname for user-friendliness (www.prod.midnight.one)

I've built an AMI with the web application baked in and all the data is basically stored in the RDS DB.
The autoscaling group uses this AMI to replace failed web nodes on the ELB.
Improvements in security and Django web server could be made: putting the web nodes in a private subnet, 
putting an SG between web nodes and RDS node (making the RDS node internal to the VPC only) 
