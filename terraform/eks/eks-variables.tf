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

// only required item is the name, should have rand string to disambiguate
variable "cluster_name" {
  type = string
}


// vpc vars

variable "vpc_cidr_block" {
  description = "CIDR block to use for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "List of tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks to use for public subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]
}


// eks variables

variable "aws_region" {
  default = "us-west-1"
}

variable "aws_eks_k8s_version" {
  default = "1.29"
}

variable "aws_eks_instance_types" {
  default = ["t3.large"]
}

variable "aws_eks_node_count" {
  default = 3
}
