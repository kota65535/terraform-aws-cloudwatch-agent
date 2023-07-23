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

variable "emf_processor_config" {
  description = "Embedded metric format processor configuration"
  type        = any
}

variable "additional_cwagent_config" {
  description = "Additional cloudwatch agent config which is merged with the base config"
  type    = any
  default = {}
}

variable "additional_prometheus_config" {
  description = "Additional prometheus config which is merged with the base config"
  type    = any
  default = {}
}
