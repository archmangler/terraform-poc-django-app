# terraform-poc-django-app

A django application on HA infrastructure in AWS to demonstrate infrastructure as code with Terraform:

- 1 x multi-AZ ELB for redundancy, failover and decoupling.
- 1 x ASG with 2-3 web nodes running centos7, nginx and a basic Django application 
- 1 x multi-AZ RDS mysql DB providing the schema backend for the app
- 1 x route53 zone and zone entry to front the ELB hostname for user-friendly access (www.prod.midnight.one)

I've built an AMI with the web application "baked in" and all the data is basically stored in the RDS DB. 
The autoscaling group uses this AMI to replace failed web nodes on the ELB.
When new nodes are launched due to the launch configuration, the user-data script runs after boot and pulls the latest changes to the Django site configuration files. 
We use this as a simple CI/CD mechanism: a script runs five-minutely (on the web servers) polling for changes in the GitHub repo - if there are changes, the script updates the site code for Django. 
Alternaitvely, we "throw away" the server by just shutting down nginx service and forcing the autoscaling group to replace it with a new, updated instance - this has the benefit of keeping in priciple with stateless, disposable and immutable infrastructure. 
An even smoother way of deploying updated site configuration would be to firewall out connections to port 80 on a node when changes are detected in the site git repo.
This would result in in-progress connections 'draining' while new connections to the web node are timed out from ELB. 
The elb healthcheck will timeout, fail and the ASG will trigger a replacement of the node. So, here we rely on the replacement mechanisms, monitoring of the ELB and autoscaling service to provide intelligent instance update.

NOTE1: This mechanism is only a good idea if your webservers are truly stateless, state must be stored somewhere else and the webserver itself is simply a "dumb" worker node.

NOTE2: Improvements in security and Django web server could be made: putting the web nodes in a private subnet, putting an SG between web nodes and RDS node (making the RDS node internal to the VPC only) 

