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

resource "google_sql_database_instance" "mysql" {
  # TODO: not required?
  # depends_on = [google_service_networking_connection.private_vpc_connection]
  depends_on = [google_project_service.compute]

  count = length(var.mysql_instances)
  name  = var.mysql_instances[count.index]

  database_version = var.mysql_versions[count.index]
  region           = var.region

  # TODO: How to enable high availability for mysql?

  settings {
    tier              = var.mysql_tiers[count.index]

    location_preference {
      zone = var.zone
    }

    ip_configuration {
      ipv4_enabled    = var.mysql_public_ip
      private_network = (
        var.first_run
          ? data.external.network_wait.result.network_self_link
          : module.network.network_self_link
      )
      require_ssl     = "true"

      dynamic "authorized_networks" {
        for_each = var.mysql_authorized_networks
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
      start_time = "04:00"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_string" "mysql_admin_password" {
  count    = length(var.mysql_instances)

  length  = 32
  special = false
  upper   = true

  keepers = {
    mysql_instance = var.mysql_instances[count.index]
    mysql_admin    = var.mysql_admins[count.index]
  }
}

resource "google_sql_user" "mysql_admin" {
  count    = length(var.mysql_instances)
  name     = var.mysql_admins[count.index]
  host     = "%"
  instance = google_sql_database_instance.mysql[count.index].name
  password = random_string.mysql_admin_password[count.index].result
}
