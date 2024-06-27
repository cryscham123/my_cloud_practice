resource "aws_elb" "elb" {
    name               = "main-elb"
    subnets           = [aws_subnet.public-1.id, aws_subnet.public-2.id]
    security_groups    = [aws_security_group.main.id]
    cross_zone_load_balancing = true
    connection_draining = true
    connection_draining_timeout = 400

    listener {
        instance_port     = 80
        instance_protocol = "HTTP"
        lb_port           = 80
        lb_protocol       = "HTTP"
    }
    health_check {
        target              = "HTTP:80/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
    tags = {
        Name = "main-elb"
    }
}