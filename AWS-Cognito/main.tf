provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
resource "aws_cognito_user_pool" "user_pool" {
  name="my-user-pool"
  username_attributes=["email"]
  schema{
    attribute_data_type = "String"
    name = "email"
    required = true
  }
  password_policy {
    minimum_length = 8
    require_lowercase = true
    require_numbers = true
    require_symbols = true
    require_uppercase = true
  }
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}