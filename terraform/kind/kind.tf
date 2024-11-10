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

// this is just a helpful for comprehension, obvs dont use kind in production
// NB: oidc module uses 3rd party library salrashid123/http-full for client cert support


resource "kind_cluster" "cluster" {
  name       = var.cluster_name
  node_image = var.kind_node_image

  kubeconfig_path = "${path.root}/.tmp/kube/${var.cluster_name}"

  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    feature_gates = {
      KubeletInUserNamespace : "true"
    }
  }
}

module "oidc" {
  source = "github.com/GoogleCloudPlatform/anthos-samples/anthos-attached-clusters/kind/oidc"

  endpoint               = kind_cluster.cluster.endpoint
  cluster_ca_certificate = kind_cluster.cluster.cluster_ca_certificate
  client_certificate     = kind_cluster.cluster.client_certificate
  client_key             = kind_cluster.cluster.client_key
}