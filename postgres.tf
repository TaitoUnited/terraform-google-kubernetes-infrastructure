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

resource "google_sql_database_instance" "postgres" {
  # TODO: not required?
  # depends_on = [google_service_networking_connection.private_vpc_connection]
  depends_on = [google_project_service.compute]

  count = length(local.postgresClusters)
  name  = local.postgresClusters[count.index].name

  database_version = local.postgresClusters[count.index].version
  region           = var.region

  settings {
    tier              = local.postgresClusters[count.index].tier
    availability_type = local.postgresClusters[count.index].highAvailabilityEnabled ? "REGIONAL" : "ZONAL"

    location_preference {
      zone = var.zone
    }

    ip_configuration {
      ipv4_enabled    = local.postgresClusters[count.index].publicIpEnabled ? true : false
      private_network = (
        var.first_run
          ? data.external.network_wait.result.network_self_link
          : module.network.network_self_link
      )
      require_ssl     = "true"

      dynamic "authorized_networks" {
        for_each = local.postgresClusters[count.index].authorizedNetworks
        content {
          value = authorized_networks.value
        }
      }
    }

    maintenance_window {
      day          = 2
      hour         = 2
      update_track = "stable"
    }

    backup_configuration {
      enabled    = "true"
      start_time = "05:00"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
