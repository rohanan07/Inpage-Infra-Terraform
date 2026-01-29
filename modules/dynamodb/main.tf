resource "aws_dynamodb_table" "user_words_table" {
  name = "${var.project}-user-words"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "userId"
  range_key = "sk"

  #partition key
  attribute {
    name = "userId"
    type = "S"
  }

  #sort key
  attribute {
    name = "sk"
    type = "S"
  }
  
  tags = {
    name = "${var.project}-user-words-table"
  }
}