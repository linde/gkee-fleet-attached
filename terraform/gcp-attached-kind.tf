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


// a KIND cluster example

module "target_cluster_kind" {
  source       = "./kind"
  cluster_name = "${local.cluster_name}-kind"

  depends_on = [ google_project_service.services ]
}

# // use this with a kind target_cluster
provider "helm" {
  alias = "kind_bootstrap_installer"
  kubernetes {
    host                   = module.target_cluster_kind.endpoint
    cluster_ca_certificate = module.target_cluster_kind.cluster_ca_certificate
    client_certificate     = module.target_cluster_kind.client_certificate
    client_key             = module.target_cluster_kind.client_key
  }
}


module "attached_install_manifest_kind" {
  source = "github.com/GoogleCloudPlatform/anthos-samples/anthos-attached-clusters/modules/attached-install-manifest"

  attached_cluster_name          = module.target_cluster_kind.cluster_name
  attached_cluster_fleet_project = var.fleet_project
  gcp_location                   = var.attached_location
  platform_version               = var.attached_platform_version
  providers = {
    helm = helm.kind_bootstrap_installer
  }
  # Ensure the node group and route are destroyed after we uninstall the manifest.
  # `terraform destroy` will fail if the module can't access the cluster to clean up.
  depends_on = [
    module.target_cluster_kind
  ]
}


resource "google_container_attached_cluster" "kind" {
  name             = module.target_cluster_kind.cluster_name
  project          = var.fleet_project
  location         = var.attached_location
  description      = "attached cluster example"
  distribution     = module.target_cluster_kind.distribution
  platform_version = var.attached_platform_version
  oidc_config {
    issuer_url = module.target_cluster_kind.oidc_issuer_url
    jwks       = module.target_cluster_kind.oidc_jwks
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
    module.attached_install_manifest_kind
  ]
}

resource "google_gke_hub_membership_binding" "team_scope_kind_bindings" {
  project               = var.fleet_project
  membership_binding_id = google_container_attached_cluster.kind.name
  scope                 = google_gke_hub_scope.acme_scope.name
  # the attaached name we provided is used as the membership name
  membership_id = google_container_attached_cluster.kind.name
  # even though the attached resource is in a region, the membership is
  # in the global region for all attached resources at this time.
  location = "global"
}