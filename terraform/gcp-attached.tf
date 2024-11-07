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

provider "helm" {
  alias = "bootstrap_installer"
  kubernetes {
    host                   = aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "attached_install_manifest" {
  source = "github.com/GoogleCloudPlatform/anthos-samples/anthos-attached-clusters/modules/attached-install-manifest"


  attached_cluster_name          = aws_eks_cluster.eks.name
  attached_cluster_fleet_project = var.fleet_project
  gcp_location                   = var.gcp_location
  platform_version               = var.attached_platform_version
  providers = {
    helm = helm.bootstrap_installer
  }
  # Ensure the node group and route are destroyed after we uninstall the manifest.
  # `terraform destroy` will fail if the module can't access the cluster to clean up.
  depends_on = [
    aws_eks_node_group.node,
    aws_route.public_internet_gateway,
    aws_route_table_association.public,
  ]
}

data "google_project" "fleet_project" {
  project_id = var.fleet_project
}


resource "google_container_attached_cluster" "primary" {
  name             = aws_eks_cluster.eks.name
  project          = var.fleet_project
  location         = var.gcp_location
  description      = "EKS attached cluster example"
  distribution     = "eks"
  platform_version = var.attached_platform_version
  oidc_config {
    issuer_url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  }
  fleet {
    project = "projects/${data.google_project.fleet_project.number}"
  }

  # Optional:
  logging_config {
    component_config {
      enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
    }
  }

  # Optional:
  monitoring_config {
    managed_prometheus_config {
      enabled = true
    }
  }

  # Optional:
  authorization {
    # admin_users = ["user1@example.com", "user2@example.com"]
    admin_groups = [var.admin_groups]
  }

  depends_on = [
    module.attached_install_manifest
  ]
}