/**
 * Copyright 2020 Taito United
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

/* Helm */

variable "helm_enabled" {
  type        = bool
  default     = "false"
  description = "Installs helm apps if set to true. Should be set to true only after Kubernetes cluster already exists."
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

variable "cicd_cloud_deploy_enabled" {
  type        = bool
  default     = true
  description = "If true, cloudbuild service account is given deployment permissions."
}

variable "cicd_testing_enabled" {
  type        = bool
  default     = true
  description = "If true, testing service account is created and given necessary permissions for db access."
}

variable "database_proxy_enabled" {
  type        = bool
  default     = true
  description = "If true, database proxy service account is created and given necessary permissions for db access."
}

variable "email" {
  type = string
  description = "Email address for DevOps support."
}
