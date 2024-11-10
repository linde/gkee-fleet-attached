/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "client_certificate" {
  value = null # n/a for eks
}

output "client_key" {
  value = null # n/a for eks
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

output "oidc_jwks" {
  value = null # n/a for eks distribution
}


output "distribution" {
  value = "eks"
}

output "cluster_name" {
  value = aws_eks_cluster.eks.name
}