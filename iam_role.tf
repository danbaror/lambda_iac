# ─────────────────────────────────────────────────────────────
# IAM Role for Lambda
# ─────────────────────────────────────────────────────────────
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# IAM Policy for Lambda (Allow Access to SQS)
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "${var.lambda_role_name}-policy"
  description = "Allows Lambda to read from SQS and write to DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action   = ["sqs:CreateQueue", "sqs:ReceiveMessage", "sqs:SendMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Effect   = "Allow"
        Resource = aws_sqs_queue.api_queue.arn
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:eu-central-1:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = "arn:aws:secretsmanager:eu-central-1:*:*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:CreateNetworkInterface","ec2:DescribeNetworkInterfaces","ec2:DeleteNetworkInterface"]
        Resource = "*"
      }
    ]
  })
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}
