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


module "eks" {
  source       = "./eks"
  cluster_name = local.cluster_name
}


provider "helm" {
  alias = "bootstrap_installer"
  kubernetes {
    host                   = module.eks.host
    cluster_ca_certificate = module.eks.cluster_ca_certificate
    token                  = module.eks.token
  }
}

module "attached_install_manifest" {
  source = "github.com/GoogleCloudPlatform/anthos-samples/anthos-attached-clusters/modules/attached-install-manifest"

  attached_cluster_name          = local.cluster_name
  attached_cluster_fleet_project = var.fleet_project
  gcp_location                   = var.attached_location
  platform_version               = var.attached_platform_version
  providers = {
    helm = helm.bootstrap_installer
  }
  # Ensure the node group and route are destroyed after we uninstall the manifest.
  # `terraform destroy` will fail if the module can't access the cluster to clean up.
  depends_on = [
    module.eks
  ]
}

data "google_project" "fleet_project" {
  project_id = var.fleet_project
}


resource "google_container_attached_cluster" "primary" {
  name             = local.cluster_name
  project          = var.fleet_project
  location         = var.attached_location
  description      = "attached cluster example"
  distribution     = module.eks.distribution
  platform_version = var.attached_platform_version
  oidc_config {
    issuer_url = module.eks.oidc_issuer_url
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
    admin_groups = var.cluster_admin_groups
  }

  depends_on = [
    module.attached_install_manifest
  ]
}

resource "google_gke_hub_membership_binding" "team_scope_cluster_bindings" {
  project               = var.fleet_project
  membership_binding_id = google_container_attached_cluster.primary.name
  scope                 = google_gke_hub_scope.acme_scope.name
 # the attaached name we provided is used as the membership name
  membership_id         = local.cluster_name  
  # even though the attached resource is in a region, the membership is
  # in the global region for all attached resources at this time.
  location              = "global" 
}