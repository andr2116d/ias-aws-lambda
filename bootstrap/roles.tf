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

resource "aws_iam_role_policy_attachment" "deploy_power_user" {
  for_each = aws_iam_role.deploy

  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

data "aws_iam_policy_document" "deploy_permissions" {
  for_each = toset(var.environments)

  statement {
    sid    = "GestionarRolesYPoliticasDelEntorno"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
      "iam:UpdateAssumeRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:ListRoleTags",
      "iam:PutRolePolicy",
      "iam:GetRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:ListRolePolicies",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:TagPolicy",
      "iam:UntagPolicy",
      "iam:ListPolicyTags",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/${var.resource_prefix}-${each.key}-*",
      "arn:aws:iam::${local.account_id}:policy/${var.resource_prefix}-${each.key}-*",
    ]
  }

  statement {
    sid       = "PasarRolesDelEntornoSoloALambda"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.account_id}:role/${var.resource_prefix}-${each.key}-*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["lambda.amazonaws.com"]
    }
  }

  statement {
    sid       = "CrearRolesVinculadosAServicios"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]
  }

  statement {
    sid     = "DenegarStateDeOtrosEntornos"
    effect  = "Deny"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = concat(
      [for env in var.environments : "${aws_s3_bucket.tfstate.arn}/${env}/*" if env != each.key],
      ["${aws_s3_bucket.tfstate.arn}/bootstrap/*"],
    )
  }

  statement {
    sid    = "ProtegerConfiguracionDelBucketDelState"
    effect = "Deny"
    actions = [
      "s3:DeleteBucket",
      "s3:PutBucketPolicy",
      "s3:DeleteBucketPolicy",
      "s3:PutBucketVersioning",
      "s3:PutLifecycleConfiguration",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketOwnershipControls",
      "s3:PutEncryptionConfiguration",
    ]
    resources = [aws_s3_bucket.tfstate.arn]
  }
}

resource "aws_iam_role_policy" "deploy" {
  for_each = aws_iam_role.deploy

  name   = "permisos-despliegue-${each.key}"
  role   = each.value.id
  policy = data.aws_iam_policy_document.deploy_permissions[each.key].json
}
