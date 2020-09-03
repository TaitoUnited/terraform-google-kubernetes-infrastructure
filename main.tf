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
  version = "~> 3.36.0"
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  version = "~> 3.36.0"
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
  nginx_ingress_version      = "2.12.1"
  cert_manager_version       = "1.0.0-beta.0"

  network_name           = "${var.name}-network"
  subnet_name            = "${var.name}-subnet"
  master_auth_subnetwork = "${var.name}-master-subnet"
  pods_range_name        = "${var.name}-ip-range-pods"
  svc_range_name         = "${var.name}-ip-range-svc"
  kubernetes_master_cidr = "172.16.0.0/28"

  owners = try(
    var.variables.owners != null ? var.variables.owners : [], []
  )

  viewers = try(
    var.variables.viewers != null ? var.variables.viewers : [], []
  )

  developers = try(
    var.variables.developers != null ? var.variables.developers : [], []
  )

  statusviewers = try(
    var.variables.statusviewers != null ? var.variables.statusviewers : [], []
  )

  externals = try(
    var.variables.externals != null ? var.variables.externals : [], []
  )

  dataviewers = try(
    var.variables.dataviewers != null ? var.variables.dataviewers : [], []
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

  postgresUsers = flatten([
    for postgres in keys(local.postgresClusters) : [
      for user in postgres.users : {
        postgresName = postgres.name
        username     = user.username
      }
    ]
  ])

  mysqlUsers = flatten([
    for mysql in keys(local.mysqlClusters) : [
      for user in mysql.users : {
        mysqlName = mysql.name
        username    = user.username
      }
    ]
  ])

  storageBuckets = try(
    var.variables.storageBuckets != null
    ? var.variables.storageBuckets
    : [],
    []
  )

  cdnStorageBuckets = flatten([
    for bucket in keys(local.storageBuckets):
    try(bucket.cdnDomain, "") != "" ? [ bucket ] : []
  ])

}
