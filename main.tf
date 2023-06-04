
locals {
  aws_account_ids = ["accountId"] #"AWS Account IDs who can easily view your data(CloudWatch metrics, dashboards, logs widgets)"
  names = [
    "CloudWatchReadOnlyAccess",
    "CloudWatchAutomaticDashboardsAccess"
    #"AWSXrayReadOnlyAccess"
  ]
}

data "aws_iam_policy" "this" {
  for_each = toset(local.names)
  name     = each.value
}

data "aws_iam_policy_document" "assume_accounts" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = local.aws_account_ids
    }
  }
}

resource "aws_iam_role" "cloudwatch_cross_account" {
  name = "CloudWatch-CrossAccountSharingRole"

  assume_role_policy = data.aws_iam_policy_document.assume_accounts.json
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset(local.names)

  policy_arn = data.aws_iam_policy.this[each.key].arn
  role       = aws_iam_role.cloudwatch_cross_account.name
}

