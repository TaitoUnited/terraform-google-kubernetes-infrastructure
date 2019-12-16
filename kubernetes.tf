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

module "kubernetes" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version = "6.1.1"

  project_id                     = (
    var.first_run
      ? data.external.service_wait.result.project_id
      : var.project_id
  )
  name                           = var.kubernetes_name
  region                         = var.region
  regional                       = length(var.kubernetes_zones) == 0
  zones                          = var.kubernetes_zones
  network                        = (
    var.first_run
      ? data.external.network_wait.result.network_name
      : module.network.network_name
  )
  subnetwork                     = module.network.subnets_names[0]
  ip_range_pods                  = local.pods_range_name
  ip_range_services              = local.svc_range_name
  # compute_engine_service_account = var.compute_engine_service_account
  master_ipv4_cidr_block         = local.kubernetes_master_cidr

  master_authorized_networks = [
    for cidr in var.kubernetes_authorized_networks:
    {
      cidr_block   = cidr
      display_name = cidr
    }
  ]

  database_encryption = [{
    state    = var.kubernetes_db_encryption ? "ENCRYPTED" : "DECRYPTED"
    key_name = (
      var.kubernetes_db_encryption
        ? google_kms_crypto_key.kubernetes_key[0].self_link
        : ""
    )
  }]

  create_service_account          = true
  grant_registry_access           = true
  # TODO: registry project param
  registry_project_id             = var.project_id

  enable_private_endpoint         = false
  enable_private_nodes            = var.kubernetes_private_nodes
  network_policy                  = var.kubernetes_network_policy
  # network_policy_provider         = "CALICO"
  enable_shielded_nodes           = var.kubernetes_shielded_nodes
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling      = true
  http_load_balancing             = true
  logging_service                 = "logging.googleapis.com/kubernetes"
  monitoring_service              = "monitoring.googleapis.com/kubernetes"
  istio                           = var.kubernetes_istio
  cloudrun                        = var.kubernetes_cloudrun

  pod_security_policy_config = var.kubernetes_pod_security_policy ? [{
    "enabled" = true
  }] : []

  release_channel           = var.kubernetes_release_channel
  maintenance_start_time    = "02:00"

  # TODO: resource_usage_export_dataset_id

  # TODO: Workload identity
  # identity_namespace        = "${data.google_project.zone.project_id}.svc.id.goog"
  # node_metadata             = "GKE_METADATA_SERVER"

  remove_default_node_pool  = true
  initial_node_count        = 1

  node_pools = [
    {
      name                  = "${var.kubernetes_name}-default"
      # service_account     = var.compute_engine_service_account
      initial_node_count    = var.kubernetes_min_node_count
      min_count             = var.kubernetes_min_node_count
      max_count             = var.kubernetes_max_node_count
      autoscaling           = var.kubernetes_min_node_count < var.kubernetes_max_node_count
      auto_repair           = true
      auto_upgrade          = true
      disk_size_gb          = var.kubernetes_disk_size_gb
      # TODO: image_type            = "COS_CONTAINERD"
      machine_type          = var.kubernetes_machine_type

      # TODO: these are ignored
      # node_metadata               = "GKE_METADATA_SERVER"
      # enable_secure_boot          = var.kubernetes_shielded_nodes
      # enable_integrity_monitoring = var.kubernetes_shielded_nodes
    }
  ]

  # TODO: prevent destroy -> https://github.com/hashicorp/terraform/issues/18367
}

# TODO: Obsolete?
# data "google_client_config" "default" {
# }
