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

// gcp variables

variable "fleet_project" {
  default = "stevenlinde-eks-2024-11-01"
}

variable "acme_scope_id" {
  default = "acme"
}

variable "acme_scope_namespace_names" {
  default = ["acme-anvils", "acme-explosives"]
}

variable "acme_scope_viewers" {
  default = ["attached-demo-acme-admin@google.com"]
}


variable "disable_services_on_destroy" {
  default = false
}

variable "attached_location" {
  description = "GCP location to create the attached resource in"
  type        = string
  default     = "us-west1"
}

variable "attached_platform_version" {
  description = "Attached cluster platform resource, needs to correspond to var.aws_eks_k8s_version"
  type        = string
  default     = "1.30.0-gke.3"
}

variable "cluster_admin_groups" {
  default = ["attached-demo-acme-admin@google.com"]
}

variable "name_prefix" {
  default = "attached-eks"
}


/// commonly used local

resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  cluster_name = "${var.name_prefix}-${random_id.suffix.hex}"
}


