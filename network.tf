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

module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.5.0"

  depends_on   = [ null_resource.service_wait ]
  count        = try(local.network.create, false) ? 1 : 0

  project_id   = var.project_id
  network_name = local.network_name

  subnets = [
    {
      subnet_name   = local.subnet_name
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${local.subnet_name}" = [
      {
        range_name    = local.pods_range_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = local.svc_range_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }

  # TODO: prevent destroy -> https://github.com/hashicorp/terraform/issues/18367
}

# Provide network name only after network has been created
# TODO: Is this still required or can it be replaced with
# 'module.network[0].network_self_link'?
data "external" "network_wait" {
  depends_on = [
    module.network,
    google_service_networking_connection.private_vpc_connection
  ]

  program = ["sh", "-c", "sleep 15; echo '{ \"network_name\": \"${module.network[0].network_name}\", \"network_self_link\": \"${module.network.network_self_link}\" }'"]
}

/* NAT */

resource "google_compute_router" "nat_router" {
  depends_on = [google_project_service.compute]
  count   = try(local.network.natEnabled, false) ? 1 : 0

  name    = "nat-router"
  region  = var.region
  network = module.network[0].network_name
  bgp {
    asn = 64514
  }
}

module "cloud-nat" {
  depends_on = [google_project_service.compute]
  count      = try(local.network.natEnabled, false) ? 1 : 0

  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 1.3"
  project_id = var.project_id
  region     = var.region
  router     = google_compute_router.nat_router[0].name
}

/* Private peering network for accessing Google services (Cloud SQL, etc.) */

resource "google_compute_global_address" "private_ip_address" {
  depends_on    = [google_project_service.servicenetworking]
  count         = local.network.privateGoogleServicesEnabled ? 1 : 0

  provider      = google-beta
  project       = data.google_project.zone.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.network[0].network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  depends_on    = [google_project_service.servicenetworking]
  count         = local.network.privateGoogleServicesEnabled ? 1 : 0

  provider                = google-beta
  network                 = module.network[0].network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address[0].name]
}

/* Static IP address for Kubernetes ingress load balancer */

resource "google_compute_address" "kubernetes_ingress" {
  depends_on  = [google_project_service.compute]
  count       = try(local.kubernetes.name, "") != "" ? 1 : 0
  name        = "${local.kubernetes.name}-ingress"
  description = "Kubernetes ingress public static IP address"
}
