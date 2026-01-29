output "user_words_table_arn" {
  value = aws_dynamodb_table.user_words_table.arn
}

output "user_words_table_name" {
  value = aws_dynamodb_table.user_words_table.name
}