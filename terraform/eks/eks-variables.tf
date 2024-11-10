
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
