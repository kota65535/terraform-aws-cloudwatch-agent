resource "aws_ecs_service" "main" {
  name                               = local.service_name
  cluster                            = var.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_ecs_task_definition" "main" {
  family             = local.service_name
  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.execution.arn
  container_definitions = jsonencode([
    {
      name                   = "cwagent",
      image                  = "public.ecr.aws/cloudwatch-agent/cloudwatch-agent:${var.image_tag}",
      essential              = true,
      readonlyRootFilesystem = true
      cpu                    = 1
      environment = [
        {
          "name"  = "CW_CONFIG_CONTENT",
          "value" = jsonencode(merge(local.cwagent_config, var.additional_cwagent_config))
        },
        {
          "name" : "PROMETHEUS_CONFIG_CONTENT",
          "value" : yamlencode(merge(local.prometheus_config, var.additional_prometheus_config))
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.name
          awslogs-region        = data.aws_region.self.name
          awslogs-stream-prefix = var.ecs_cluster.name
        }
      }
      mountPoints = [
        {
          "sourceVolume" : "config_file"
          "containerPath" : "/opt/aws/amazon-cloudwatch-agent/etc"
          "readOnly" : false
        },
        {
          "sourceVolume" : "tmp_dir"
          "containerPath" : "/tmp"
          "readOnly" : false
        },
        {
          "sourceVolume" : "pid_file"
          "containerPath" : "/opt/aws/amazon-cloudwatch-agent/logs"
          "readOnly" : false
        }
      ]
    }
  ])
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  volume {
    name = "config_file"
  }
  volume {
    name = "tmp_dir"
  }
  volume {
    name = "pid_file"
  }
}

resource "aws_cloudwatch_log_group" "main" {
  name = var.log_group_name
}
