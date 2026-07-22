data "aws_iam_policy_document" "ci_ecr_push" {
  statement {
    sid       = "ECRAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = [aws_ecr_repository.order_service.arn]
  }
}

resource "aws_iam_user" "ci" {
  name = "resolve-demo-ci"
}

resource "aws_iam_user_policy" "ci_ecr_push" {
  name   = "ci-ecr-push-only"
  user   = aws_iam_user.ci.name
  policy = data.aws_iam_policy_document.ci_ecr_push.json
}