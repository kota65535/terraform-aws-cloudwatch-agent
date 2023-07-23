locals {
  service_name = "${var.ecs_cluster.name}-cwagent"

  sd_result_file_path = "/tmp/cwagent_ecs_auto_sd.yaml"

  // cf. https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html
  cwagent_config = {
    logs = {
      metrics_collected = {
        // cf. https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus-Setup-configure-ECS.html
        prometheus = {
          cluster_name           = var.ecs_cluster.name
          log_group_name         = var.log_group_name
          prometheus_config_path = "env:PROMETHEUS_CONFIG_CONTENT"
          ecs_service_discovery = {
            sd_result_file = local.sd_result_file_path
            docker_label = {
              sd_metrics_path_label = "ECS_PROMETHEUS_METRICS_PATH"
              sd_port_label         = "ECS_PROMETHEUS_EXPORTER_PORT"
              sd_job_name_label     = "ECS_PROMETHEUS_JOB_NAME"
            }
          },
          emf_processor = var.emf_processor_config
        }
      }
    }
  }

  // cf. https://prometheus.io/docs/prometheus/latest/configuration/configuration/
  prometheus_config = {
    scrape_configs = [
      {
        job_name = "cwagent-ecs-file-sd-config"
        file_sd_configs = [
          {
            files = [local.sd_result_file_path]
          }
        ]
      }
    ]
  }
}

data "aws_caller_identity" "self" {}

data "aws_region" "self" {}
