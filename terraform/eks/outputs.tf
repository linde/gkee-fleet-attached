


output "host" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_ca_certificate" {
  value = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
}

output "token" {
  value = data.aws_eks_cluster_auth.eks.token
}

output "oidc_issuer_url" {
  value = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "distribution" {
  value = "eks"
}