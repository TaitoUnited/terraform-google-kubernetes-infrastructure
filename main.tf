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

/* Provider */

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  version = "~> 2.18.0"
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  version = "~> 2.18.0"
}

provider "helm" {
  install_tiller = false
  max_history    = 20
  kubernetes {
    config_context = local.kubernetes.context != "" ? local.kubernetes.context : var.name
  }
}

data "google_project" "zone" {
  project_id = var.project_id
}

locals {
  nginx_ingress_version      = "1.26.2"
  cert_manager_version       = "0.11.0"

  network_name           = "${var.name}-network"
  subnet_name            = "${var.name}-subnet"
  master_auth_subnetwork = "${var.name}-master-subnet"
  pods_range_name        = "${var.name}-ip-range-pods"
  svc_range_name         = "${var.name}-ip-range-svc"
  kubernetes_master_cidr = "172.16.0.0/28"

  owners = try(
    var.variables.owners != null ? var.variables.owners : [], []
  )

  editors = try(
    var.variables.editors != null ? var.variables.editors : [], []
  )

  viewers = try(
    var.variables.viewers != null ? var.variables.viewers : [], []
  )

  developers = try(
    var.variables.developers != null ? var.variables.developers : [], []
  )

  externals = try(
    var.variables.externals != null ? var.variables.externals : [], []
  )

  kubernetes = var.variables.kubernetes

  nodePools = try(
    var.variables.kubernetes.nodePools != null
    ? var.variables.kubernetes.nodePools
    : [],
    []
  )

  nginxIngressControllers = try(
    var.variables.kubernetes.nginxIngressControllers != null
    ? var.variables.kubernetes.nginxIngressControllers
    : [],
    []
  )

  postgresClusters = try(
    var.variables.postgresClusters != null
    ? var.variables.postgresClusters
    : [],
    []
  )

  mysqlClusters = try(
    var.variables.mysqlClusters != null
    ? var.variables.mysqlClusters
    : [],
    []
  )

}
