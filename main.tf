#---------------------------------------------------------------------
# GitHub Action with AWS Integration via OIDC
#
# Version      Date        Info
# 1.0          2025        Initial Version
#
# Made by Denis Astahov ADV-IT Copyleft (c) 2025
#---------------------------------------------------------------------
locals {
  github_account_name = "adv4000" # GitHub Account name or GitHub Organization Name
  github_permissions  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  tags           = { Owner = "Denis Astahov" }
}


resource "aws_iam_role" "github" {
  name = "github-aws-integration-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Principal" : {
          "Federated" : "${aws_iam_openid_connect_provider.github.arn}"
        },
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : [
              "sts.amazonaws.com"
            ]
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : [
              "repo:${local.github_account_name}/*"
            ]
          }
        }
      }
    ]
  })
  tags = { Owner = "Denis Astahov" }
}

resource "aws_iam_role_policy_attachment" "github_admin" {
  for_each   = toset(local.github_permissions)
  role       = aws_iam_role.github.name
  policy_arn = each.value
}

