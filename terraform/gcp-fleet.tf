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


// make the fleet project number available
data "google_project" "fleet_project" {
  project_id = var.fleet_project
}


resource "google_project_service" "services" {
  project = var.fleet_project
  for_each = toset([
    "container.googleapis.com",
    "anthos.googleapis.com",
    "gkehub.googleapis.com",
    "gkeconnect.googleapis.com",
    "connectgateway.googleapis.com",
    "anthosconfigmanagement.googleapis.com",
    "gkemulticloud.googleapis.com",
    "logging.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = var.disable_services_on_destroy
}


// config package defaults
resource "google_gke_hub_feature" "fleet_config_defaults" {
  project  = var.fleet_project
  location = "global"
  name     = "configmanagement"
  fleet_default_member_config {
    configmanagement {
      version = "1.19.2"
      config_sync {
        source_format = "unstructured"
        git {
          sync_repo   = "https://github.com/linde/gkee-fleet-attached.git"
          sync_branch = "main"
          secret_type = "none"
          policy_dir  = "k8s-config/"
        }
      }
    }
  }
}

// Team One stuff

// TODO rename acme_scope to team_one_scope
resource "google_gke_hub_scope" "acme_scope" {
  project  = var.fleet_project
  scope_id = var.acme_scope_id
}

// TODO rename acme_scope_namespaces to team_one_scope_namespaces
resource "google_gke_hub_namespace" "acme_scope_namespaces" {
  for_each = toset(var.acme_scope_namespace_names)

  project            = var.fleet_project
  scope_namespace_id = each.key
  scope_id           = google_gke_hub_scope.acme_scope.scope_id
  scope              = google_gke_hub_scope.acme_scope.id
}

module "acme_scope_admin_permissions" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/fleet-app-operator-permissions"

  fleet_project_id = var.fleet_project
  scope_id         = google_gke_hub_scope.acme_scope.scope_id
  groups           = var.cluster_admin_groups
  role             = "ADMIN"
}

module "acme_scope_viewer_permissions" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/fleet-app-operator-permissions"

  fleet_project_id = var.fleet_project
  scope_id         = google_gke_hub_scope.acme_scope.scope_id
  users            = var.acme_scope_viewers
  role             = "VIEW"
}


