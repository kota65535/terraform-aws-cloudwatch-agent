resource "aws_iam_role" "task" {
  name               = "${local.service_name}-ecs-tasks-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  inline_policy {
    name   = "ECSReadOnlyAccess"
    policy = data.aws_iam_policy_document.ecs_read_only_access.json
  }
}

resource "aws_iam_role_policy_attachment" "task_ssm" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "task_server" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role" "execution" {
  name               = "${local.service_name}-ecs-tasks-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_read_only_access" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecs:ListAttributes",
      "ecs:DescribeTaskSets",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeClusters",
      "ecs:ListServices",
      "ecs:ListAccountSettings",
      "ecs:DescribeCapacityProviders",
      "ecs:ListTagsForResource",
      "ecs:ListTasks",
      "ecs:ListTaskDefinitionFamilies",
      "ecs:DescribeServices",
      "ecs:ListContainerInstances",
      "ecs:DescribeContainerInstances",
      "ecs:DescribeTasks",
      "ecs:ListTaskDefinitions",
      "ecs:ListClusters",
    ]
  }
}
