########################
# iam.tf
# IAM role + instance profile for monitoring server (Prometheus/Grafana)
########################

# ---- IAM Role for Grafana/CloudWatch/Prometheus discovery ----
resource "aws_iam_role" "grafana_role" {
  name = "grafana-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# ---- Attach AWS managed policy for CloudWatch read-only (existing) ----
resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_attach" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

# ---- Instance Profile to attach role to EC2 ----
resource "aws_iam_instance_profile" "grafana_profile" {
  name = "grafana-cloudwatch-profile-v1"
  role = aws_iam_role.grafana_role.name
}

# ---- Inline policy to allow Prometheus EC2 service discovery ----
# Grants minimal read permissions needed for ec2_sd_configs to work
resource "aws_iam_role_policy" "prom_ec2_sd" {
  name = "prometheus-ec2-sd-policy"
  role = aws_iam_role.grafana_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeIamInstanceProfileAssociations"
        ]
        Resource = "*"
      }
    ]
  })
}

# ---- (optional) If you prefer a managed, broader policy instead of inline JSON ----
# Uncomment and use this to attach AmazonEC2ReadOnlyAccess (broader than needed)
# resource "aws_iam_role_policy_attachment" "grafana_ec2_readonly_attach" {
#   role       = aws_iam_role.grafana_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
# }

