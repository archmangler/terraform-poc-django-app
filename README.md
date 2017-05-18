# terraform-poc-django-app

Overview:
=========

A django application on HA infrastructure in AWS to demonstrate infrastructure as code with Terraform:

- 1 x multi-AZ ELB for redundancy, failover and decoupling.
- 1 x ASG with 2-3 web nodes running centos7, nginx and a basic Django application 
- 1 x multi-AZ RDS mysql DB providing the schema backend for the app
- 1 x route53 zone and zone entry to front the ELB hostname for user-friendly access (www.prod.midnight.one)

I've built an AMI with the web application "baked in" and all the data is basically stored in the RDS DB. 
The autoscaling group uses this AMI to replace failed web nodes on the ELB.
When new nodes are launched due to the launch configuration, the user-data script runs after boot and pulls the latest changes to the Django site configuration files. 

CI/CD mechanism:
================

We use this as a simple CI/CD mechanism: a script runs five-minutely (on the web servers) polling for changes in the GitHub repo - if there are changes, the script updates the site code for Django. 
Alternaitvely, we "throw away" the server by just shutting down nginx service and forcing the autoscaling group to replace it with a new, updated instance - this has the benefit of keeping in priciple with stateless, disposable and immutable infrastructure. 
An even smoother way of deploying updated site configuration would be to firewall out connections to port 80 on a node when changes are detected in the site git repo.
This would result in in-progress connections 'draining' while new connections to the web node are timed out from ELB. 
The elb healthcheck will timeout, fail and the ASG will trigger a replacement of the node. So, here we rely on the replacement mechanisms, monitoring of the ELB and autoscaling service to provide intelligent instance update.

This is the idea behind  "update_deploy.py" which is cronned in the web server ami and checks every 2 minutes for changes to key django site files in github using the pythongit module. It then firewalls port 80 from the ELB healtchecks - effectively scheduling the ec2 instance for replacement with a new fresh update. It initially updates the django web application files when a new ec2 webserver instance is created by the asg. The approach here is not to update content and code on the server during run time, but to throw the entire server away and replace it with a whole new artifact, including new code. I believe over time this leads to more resilient and agile platforms.

Caveats:
========

NOTE1: This mechanism is only a good idea if your webservers are truly stateless, state must be stored somewhere else and the webserver itself is simply a "dumb" worker node. In our PoC most of the site content and data resides in the mysql (RDS) database, and that's where state is kept.

NOTE2: Improvements in security and Django web server could be made: putting the web nodes in a private subnet, putting an SG between web nodes and RDS node (making the RDS node internal to the VPC only) 
