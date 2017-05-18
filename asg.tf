# Specify the provider and access details
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

#define a launch configuration
resource "aws_launch_configuration" "agent-lconf" {
    name_prefix = "agent-lconf-"
    image_id = "${lookup(var.amis, var.region)}"
    instance_type = "${var.instance_type}"
    security_groups = ["${var.internal_sg_id}", "${var.admin_sg_id}"]
    user_data = "${file("agent.sh")}"
    #spot_price    = "0.01"
    key_name="traiano"
    lifecycle {
        create_before_destroy = true
    }
    root_block_device {
        volume_type = "gp2"
        volume_size = "50"
    }
}

#get AZ data for the region
data "aws_availability_zones" "allzones" {}

#define an autoscaling group
resource "aws_autoscaling_group" "generic-nodes" {
    #availability_zones = "${split(",", lookup(var.azs, var.region))}"
    availability_zones = ["${data.aws_availability_zones.allzones.names}"]
    vpc_zone_identifier= "${var.generic_subnet_id}"
    name = "generic-nodes"
    max_size = "3"
    min_size = "1"
    health_check_grace_period = 300
    health_check_type = "ELB"
    load_balancers= ["${aws_elb.mywebelb.id}"]
    desired_capacity = 2
    force_delete = true
    launch_configuration = "${aws_launch_configuration.agent-lconf.name}"
    tag {
        key = "Name"
        value = "node.generic.prod"
        propagate_at_launch = true
    }
}

#define autoscaling policy for scale UP
resource "aws_autoscaling_policy" "generic-nodes-scale-up" {
    name = "generic-nodes-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.generic-nodes.name}"
}

#define autoscaling policy for scale DOWN
resource "aws_autoscaling_policy" "generic-nodes-scale-down" {
    name = "generic-nodes-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.generic-nodes.name}"
}

#define cloudwatch metrics alarms to drive scaling
resource "aws_cloudwatch_metric_alarm" "node-cpu-high" {
    alarm_name = "cpu-util-high-nodes"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "80"
    alarm_description = "This metric monitors ec2 CPU for high utilization on generic agent hosts"
    alarm_actions = [
     "${aws_autoscaling_policy.generic-nodes-scale-up.arn}"
    ]
    dimensions {
     AutoScalingGroupName = "${aws_autoscaling_group.generic-nodes.name}"
    }
}

resource "aws_cloudwatch_metric_alarm" "node-cpu-low" {
    alarm_name = "cpu-util-low-nodes"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "0.1"
    alarm_description = "This metric monitors ec2 cpu for low utilization on hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.generic-nodes-scale-down.arn}"
    ]
    dimensions {
       AutoScalingGroupName = "${aws_autoscaling_group.generic-nodes.name}"
  }
}

resource "aws_security_group" "elbsg" {
 name = "elb_sg"
 ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
   from_port = 0
   to_port = 0
    protocol = "-1"
   cidr_blocks = ["${var.subnet_range}"]
 }

 egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_elb" "mywebelb" {
 name = "terraform-elb"
 availability_zones = ["${data.aws_availability_zones.allzones.names}"]
 #until we figure out what's going on here:
 #security_groups = ["${aws_security_group.elbsg.id}"]
 security_groups = ["${var.internal_sg_id}"]
 #later:
 #access_logs {
 # bucket = "traiano-terraform"
 # bucket_prefix = "elb"
 # interval = 5
 #}
 listener {
  instance_port = 80
  instance_protocol = "http"
  lb_port = 80
  lb_protocol = "http"
 }
 health_check {
  healthy_threshold = 2 
  unhealthy_threshold = 5
  timeout = 10
  target = "TCP:80"
  interval = 15
 }
}

#convenience URL to reach the site ELB
resource "aws_route53_record" "wwwendpoint" {
  zone_id = "${var.route53_zone_id}"
  name = "www.prod.midnight.one"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.mywebelb.dns_name}"]
}

