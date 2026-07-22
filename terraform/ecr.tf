resource "aws_ecr_repository" "order_service" {
  name                 = "order-service"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}