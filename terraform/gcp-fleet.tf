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
      config_sync {
        source_format = "unstructured"
        git {
          sync_repo   = "https://github.com/linde/gkee-fleet-tenacy-examples.git"
          sync_branch = "main"
          secret_type = "none"
          policy_dir  = "fleet-tenancy-with-defaults/k8s-policy-dir/policy"
        }
      }
    }
  }
}

resource "google_gke_hub_scope" "acme_scope" {
  project  = var.fleet_project
  scope_id = var.team_id
}


resource "google_gke_hub_namespace" "acme_scope_namespaces" {
  for_each = toset(var.namespace_names)

  project            = var.fleet_project
  scope_namespace_id = each.key
  scope_id           = google_gke_hub_scope.acme_scope.scope_id
  scope              = google_gke_hub_scope.acme_scope.id
}


