variable "image_tag" {
  description = "Cloudwatch agent docker image tag"
  type        = string
  default     = "latest"
}

variable "ecs_cluster" {
  description = "ECS cluster"
  type = object({
    id   = string
    name = string
  })
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}

variable "metric_namespace" {
  description = <<EOT
Metric namespace.
See [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-PrometheusEC2.html) for more details.
EOT
  type        = string
}

variable "metric_declaration" {
  description = <<EOT
Metric declaration.
See [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-PrometheusEC2.html) for more details.
EOT
  type        = list(any)
}

variable "metric_unit" {
  description = <<EOT
Metric unit.
See [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-PrometheusEC2.html) for more details.
EOT
  type        = map(string)
  default     = {}
}

variable "additional_cwagent_config" {
  description = <<EOT
Additional cloudwatch agent config which is merged with the base config.
See [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html) for more details.
EOT
  type        = any
  default     = {}
}

variable "additional_prometheus_config" {
  description = <<EOT
Additional prometheus config which is merged with the base config.
See [here](https://prometheus.io/docs/prometheus/latest/configuration/configuration/) for more details.
EOT
  type        = any
  default     = {}
}
