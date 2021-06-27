output "lambda-task-registration-role-arn" {
  value = aws_iam_role.lambda-task-registration-role.arn
}

output "task-registration-dynamoDb" {
  value = aws_dynamodb_table.task-registration
}