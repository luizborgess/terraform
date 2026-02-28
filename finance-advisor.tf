data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}



resource "aws_lambda_function" "finance_advisor" {
  filename      = "finance-advisor/lambda-handler.zip"
  function_name = "finance-advisor"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "bootstrap"
  architectures = ["arm64"]
  runtime       = "provided.al2023"
  timeout       = 60
}

# Permissão para logs CloudWatch
resource "aws_iam_role_policy" "lambda_logging" {
  name = "lambda_logging"
  role = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_scheduler_schedule" "finance_advisor_schedule" {
  name                         = "finance-advisor-schedule"
  group_name                   = "default"
  schedule_expression_timezone = "America/Sao_Paulo"        # GMT-3
  schedule_expression          = "cron(0 20 ? * MON-FRI *)"
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.finance_advisor.arn
    role_arn = aws_iam_role.eventbridge_invoke_lambda.arn
  }
}

resource "aws_iam_role" "eventbridge_invoke_lambda" {
  name = "eventbridge_invoke_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "invoke_lambda_policy" {
  name = "invoke_lambda"
  role = aws_iam_role.eventbridge_invoke_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = aws_lambda_function.finance_advisor.arn
      }
    ]
  })
}