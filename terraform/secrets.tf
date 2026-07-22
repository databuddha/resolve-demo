resource "aws_secretsmanager_secret" "order_service_api_key" {
  name = "resolve-demo/order-service-api-key"
}

resource "aws_secretsmanager_secret_version" "order_service_api_key" {
  secret_id     = aws_secretsmanager_secret.order_service_api_key.id
  secret_string = "demo-fake-api-key-not-real-12345"
}