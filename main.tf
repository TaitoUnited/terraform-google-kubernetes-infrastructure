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
  version = "~> 3.37.0"
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  version = "~> 3.37.0"
}

provider "helm" {
  kubernetes {
    config_context = local.kubernetes.context != "" ? local.kubernetes.context : var.name
  }
  version = "~> 1.3.0"
}

data "google_project" "zone" {
  project_id = var.project_id
}

locals {
  nginx_ingress_version    = "2.12.1"
  cert_manager_version     = "1.0.0-beta.0"
  socat_tunneler_version   = "0.1.0"

  network_name             = "${var.name}-network"
  subnet_name              = "${var.name}-subnet"
  master_auth_subnetwork   = "${var.name}-master-subnet"
  pods_range_name          = "${var.name}-ip-range-pods"
  svc_range_name           = "${var.name}-ip-range-svc"
  kubernetes_master_cidr   = "172.16.0.0/28"

  # Permissions

  permissions = try(
    var.resources.permissions != null ? var.resources.permissions : [], []
  )

  # DNS

  dnsZones = try(
    var.resources.dnsZones != null
    ? var.resources.dnsZones
    : [],
    []
  )

  dnsZoneRecordSets = flatten([
    for dnsZone in keys(local.dnsZones) : [
      for dnsRecordSet in dnsZone.recordSets : merge(dnsRecordSet, {
        dnsZone = dnsZone
      })
    ]
  ])

  # Network

  network = try(var.resources.network, null)

  # Alerts

  origAlerts = try(
    var.resources.alerts != null
    ? var.resources.alerts
    : [],
    []
  )

  alertChannelNames = flatten([
    for alert in local.origAlerts:
    try(alert.channels, [])
  ])

  alerts = flatten([
    for alert in local.origAlerts:
    merge(alert, {
      channelIndices = [
        for channel in alert.channels:
        index(local.alertChannelNames, channel)
      ]
    })
  ])

  logAlerts = flatten([
    for alert in local.alerts:
    try(alert.type, "") == "log" ? [ alert ] : []
  ])

  # Kubernetes

  kubernetes = try(var.resources.kubernetes, null)

  nodePools = try(
    local.kubernetes.nodePools != null
    ? local.kubernetes.nodePools
    : [],
    []
  )

  nginxIngressControllers = try(
    local.kubernetes.nginxIngressControllers != null
    ? local.kubernetes.nginxIngressControllers
    : [],
    []
  )

  helmEnabled = var.helm_enabled && local.kubernetes != null

  # Databases

  postgresClusters = try(
    var.resources.postgresClusters != null
    ? var.resources.postgresClusters
    : [],
    []
  )

  mysqlClusters = try(
    var.resources.mysqlClusters != null
    ? var.resources.mysqlClusters
    : [],
    []
  )

  # Storage buckets

  storageBuckets = try(
    var.resources.storageBuckets != null
    ? var.resources.storageBuckets
    : [],
    []
  )

  cdnStorageBuckets = flatten([
    for bucket in keys(local.storageBuckets):
    try(bucket.cdnDomain, "") != "" ? [ bucket ] : []
  ])

}
