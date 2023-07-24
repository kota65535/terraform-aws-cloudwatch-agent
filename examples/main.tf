module "cloudwatch_agent" {
  source = "../"

  ecs_cluster = aws_ecs_cluster.main
  subnet_ids = [
    "subnet-0abaada26acb8894f"
  ]
  security_group_ids = [
    "sg-00c7b719903e499ea"
  ]
  log_group_name = "/sample/cwagent"

  metric_namespace = "Prometheus"
  metric_declaration = [
    {
      source_labels = [
        "container_name",
        "action",
        "cause"
      ],
      label_matcher = "^app",
      dimensions = [
        [
          "ClusterName",
          "TaskDefinitionFamily",
          "action",
          "cause"
        ]
      ],
      metric_selectors = [
        "jvm_gc_pause_seconds_count",
        "jvm_gc_pause_seconds_max",
        "jvm_gc_pause_seconds_sum"
      ]
    }
  ]
  metric_unit = {
    jvm_gc_pause_seconds_count = "count",
    jvm_gc_pause_seconds_max   = "seconds",
    jvm_gc_pause_seconds_sum   = "seconds",
  }
}
