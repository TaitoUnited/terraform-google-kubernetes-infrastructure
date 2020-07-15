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

module "kubernetes" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version = "6.1.1"

  project_id                     = (
    var.first_run
      ? data.external.service_wait.result.project_id
      : var.project_id
  )
  name                           = local.kubernetes.name
  region                         = var.region
  regional                       = length(local.kubernetes.zones) == 0
  zones                          = local.kubernetes.zones
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
    for cidr in local.kubernetes.masterAuthorizedNetworks:
    {
      cidr_block   = cidr
      display_name = cidr
    }
  ]

  database_encryption = [{
    state    = local.kubernetes.dbEncryptionEnabled ? "ENCRYPTED" : "DECRYPTED"
    key_name = (
      local.kubernetes.dbEncryptionEnabled
        ? google_kms_crypto_key.kubernetes_key[0].self_link
        : ""
    )
  }]

  create_service_account          = true
  grant_registry_access           = true
  # TODO: registry project param
  registry_project_id             = var.project_id

  enable_private_endpoint         = false
  enable_private_nodes            = local.kubernetes.privateNodesEnabled
  network_policy                  = local.kubernetes.networkPolicyEnabled
  # network_policy_provider         = "CALICO"
  enable_shielded_nodes           = local.kubernetes.shieldedNodesEnabled
  enable_vertical_pod_autoscaling = true
  horizontal_pod_autoscaling      = true
  http_load_balancing             = true
  logging_service                 = "logging.googleapis.com/kubernetes"
  monitoring_service              = "monitoring.googleapis.com/kubernetes"
  istio                           = local.kubernetes.istioEnabled
  cloudrun                        = local.kubernetes.cloudrunEnabled

  pod_security_policy_config = local.kubernetes.podSecurityPolicyEnabled ? [{
    "enabled" = true
  }] : []

  kubernetes_version        = null
    # was: local.kubernetes.releaseChannel == "STABLE" ? "1.13.11-gke.14" : "latest"
  release_channel           = local.kubernetes.releaseChannel
  maintenance_start_time    = "02:00"

  # TODO: resource_usage_export_dataset_id

  # TODO: Workload identity
  # identity_namespace        = "${data.google_project.zone.project_id}.svc.id.goog"
  # node_metadata             = "GKE_METADATA_SERVER"

  remove_default_node_pool  = true
  initial_node_count        = 1

  node_pools = (
    for nodePool in local.kubernetes.nodePools
    [
      {
        name                  = "${local.kubernetes.name}-default"
        # service_account     = var.compute_engine_service_account
        initial_node_count    = nodePool.minNodeCount
        min_count             = nodePool.minNodeCount
        max_count             = nodePool.maxNodeCount
        autoscaling           = nodePool.minNodeCount < nodePool.maxNodeCount
        auto_repair           = true
        auto_upgrade          = true
        disk_size_gb          = nodePool.diskSizeGb
        # TODO: image_type    = "COS_CONTAINERD"
        machine_type          = nodePool.machineType

        # TODO: these are ignored
        # node_metadata               = "GKE_METADATA_SERVER"
        # enable_secure_boot          = local.kubernetes.shieldedNodesEnabled
        # enable_integrity_monitoring = local.kubernetes.shieldedNodesEnabled
      }
    ]
  )

  # TODO: prevent destroy -> https://github.com/hashicorp/terraform/issues/18367
}

# TODO: Obsolete?
# data "google_client_config" "default" {
# }
