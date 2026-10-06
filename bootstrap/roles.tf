locals {
  github_repo_sub = "repo:${var.github_owner}/${var.github_repo}"
}

data "aws_iam_policy_document" "deploy_trust" {
  for_each = toset(var.environments)

  statement {
    sid     = "SoloGitHubActionsDesdeSuEnvironment"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["${local.github_repo_sub}:environment:${each.key}"]
    }
  }
}

resource "aws_iam_role" "deploy" {
  for_each = toset(var.environments)

  name                 = "${var.project}-gha-deploy-${each.key}"
  description          = "El que asumirá GitHub Actions para desplegar el entorno ${each.key}."
  assume_role_policy   = data.aws_iam_policy_document.deploy_trust[each.key].json
  max_session_duration = 3600

  tags = {
    Environment = each.key
  }
}
