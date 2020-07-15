/**
 * Copyright 2019 Taito United
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

/* First run variable for setting "module dependency wait" */

variable "first_run" {
  type        = bool
  description = "Should be set to true on the first run, and false on all subsequent executions. This is temporary hack to cope with Terraform not supporting depends_on for modules."
}

/* Labeling */

variable "name" {
  type        = string
  description = "Name that groups all the created resources together. Preferably globally unique to avoid naming conflicts."
}

/* Google provider */

variable "project_id" {
  type        = string
  description = "Google Cloud project id. The project should already exist."
}

variable "region" {
  type        = string
  description = "Google Cloud region."
}

variable "zone" {
  type        = string
  description = "Google Cloud zone."
}

/* Users */

variable "owners" {
  type        = list(string)
  default     = []
  description = "Project owners (e.g. [ \"user:john.doe@gmail.com\" ])."
}

variable "editors" {
  type        = list(string)
  default     = []
  description = "Project editors (e.g. [ \"user:john.doe@gmail.com\" ])."
}

variable "viewers" {
  type        = list(string)
  default     = []
  description = "Project viewers (e.g. [ \"user:john.doe@gmail.com\" ])."
}

variable "developers" {
  type        = list(string)
  default     = []
  description = "Developers (e.g. [ \"user:john.doe@gmail.com\" ])."
}

variable "externals" {
  type        = list(string)
  default     = []
  description = "External developers (e.g. [ \"user:john.doe@gmail.com\" ])."
}

/* Settings */

variable "enable_google_services" {
  type        = bool
  default     = true
  description = "If true, required google services are enabled by this module."
}

variable "enable_private_google_services" {
  type        = bool
  default     = true
  description = "If true, private peering network is created to access Google services."
}

variable "cicd_deploy_enabled" {
  type        = bool
  default     = true
  description = "If true, cloudbuild service account is given deployment permissions."
}

variable "email" {
  type = string
  description = "Email address for DevOps support."
}

variable "archive_day_limit" {
  type        = number
  description = "Defines how long storage bucket files should be kept in archive after they have been deleted."
}

/* Buckets */

variable "state_bucket" {
  type    = string
  default = ""
  description = "Name of storage bucket used for storing remote Terraform state."
}

variable "projects_bucket" {
  type    = string
  default = ""
  description = "Name of storage bucket used for storing function packages, etc."
}

variable "public_bucket" {
  type    = string
  default = ""
  description = "Name of storage bucket used for storing static assets."
}

/* Helm */

variable "helm_enabled" {
  type        = bool
  default     = "false"
  description = "Installs helm apps if set to true. Should be set to true only after Kubernetes cluster already exists."
}

variable "helm_nginx_ingress_classes" {
  type        = list(string)
  default     = []
  description = "NGINX ingress class for each NGINX ingress installation. Provide multiple if you want to install multiple NGINX ingresses."
}

variable "helm_nginx_ingress_replica_counts" {
  type    = list(string)
  default = []
  description = "Replica count for each NGINX ingress installation. Provide multiple if you want to install multiple NGINX ingresses."
}

/* Kubernetes settings */

variable "kubernetes_name" {
  type        = string
  description = "Name for the Kubernetes cluster."
}

variable "kubernetes_context" {
  type        = string
  default     = ""
  description = "Kubernetes context. Value of var.name is used by default."
}

variable "kubernetes_zones" {
  type    = list(string)
  default = []
  description = "Kubernetes zones."
}

variable "kubernetes_authorized_networks" {
  type        = list(string)
  description = "CIDRs that are authorized to access the Kubernetes master API."
}

variable "kubernetes_release_channel" {
  type        = string
  default     = "STABLE"
  description = "Kubernetes release channel."
}

variable "kubernetes_machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "Machine type for Kubernetes nodes."
}

variable "kubernetes_disk_size_gb" {
  type        = number
  default     = "100"
  description = "Disk size for Kubernetes nodes."
}

variable "kubernetes_min_node_count" {
  type        = number
  default     = 1
  description = "Mimimum amount of Kubernetes nodes."
}

variable "kubernetes_max_node_count" {
  type        = number
  default     = 1
  description = "Maximum amount of Kubernetes nodes."
}

variable "kubernetes_rbac_security_group" {
  type        = string
  default     = ""
  description = "Kubernetes RBAC security group."
}

variable "kubernetes_private_nodes" {
  type        = bool
  default     = true
  description = "Determines if Kubernetes nodes should have private IP only."
}

variable "kubernetes_shielded_nodes" {
  type        = bool
  default     = true
  description = "Determines if Kubernetes nodes should be shielded."
}

variable "kubernetes_network_policy" {
  type    = bool
  default = false
  description = "Determines if network policies should be enabled."
}

variable "kubernetes_db_encryption" {
  type        = bool
  default     = false
  description = "Determines if database encryption (KMS) should be enabled."
}

variable "kubernetes_pod_security_policy" {
  type        = bool
  default     = false
  description = "Determines if pod security policies should be enabled."
}

variable "kubernetes_istio" {
  type        = bool
  default     = false
  description = "Determines if Istio addon should be enabled."
}

variable "kubernetes_cloudrun" {
  type        = bool
  default     = false
  description = "Determines if Cloudrun addon should be enabled."
}

/* Postgres settings */

variable "postgres_instances" {
  type    = list(string)
  default = []
  description = "Name for each PostgreSQL cluster. Provide multiple if you require multiple PostgreSQL clusters."
}

variable "postgres_versions" {
  type    = list(string)
  default = []
  description = "Version for each PostgreSQL cluster. Provide multiple if you require multiple PostgreSQL clusters."
}

variable "postgres_tiers" {
  type    = list(string)
  default = []
  description = "Tier for each PostgreSQL cluster. Provide multiple if you require multiple clusters."
}

variable "postgres_high_availability" {
  type    = bool
  default = false
  description = "High availability boolean flag for each PostgreSQL cluster. Provide multiple if you require multiple clusters."
}

variable "postgres_public_ip" {
  type        = bool
  default     = false
  description = "Determines if PostgreSQL clusters should have a public IP address."
}

variable "postgres_authorized_networks" {
  type    = list(string)
  default = []
  description = "CIDRs that are authorized to access the PostgreSQL clusters by their public IP."
}

/* Mysql settings */

variable "mysql_instances" {
  type    = list(string)
  default = []
  description = "Name for each MySQL cluster. Provide multiple if you require multiple clusters."
}

variable "mysql_versions" {
  type    = list(string)
  default = []
  description = "Version for each MySQL cluster. Provide multiple if you require multiple clusters."
}

variable "mysql_tiers" {
  type    = list(string)
  default = []
  description = "Tier for each MySQL cluster. Provide multiple if you require multiple clusters."
}

variable "mysql_admins" {
  type    = list(string)
  default = []
  description = "Admin username for each MySQL cluster. Provide multiple if you require multiple clusters."
}

variable "mysql_public_ip" {
  type    = bool
  default = false
  description = "Determines if MySQL clusters should have a public IP address."
}

variable "mysql_authorized_networks" {
  type    = list(string)
  default = []
  description = "CIDRs that are authorized to access the MySQL clusters by their public IP."
}

/* Loggins sinks */

/* TODO
variable "logging_sinks" {
  type    = list(string)
  default = []
}

variable "logging_companies" {
  type    = list(string)
  default = []
}
*/
