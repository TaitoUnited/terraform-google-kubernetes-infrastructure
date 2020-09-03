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

resource "google_sql_database_instance" "mysql" {
  # TODO: not required?
  # depends_on = [google_service_networking_connection.private_vpc_connection]
  depends_on = [google_project_service.compute]

  count = length(local.mysqlClusters)
  name  = local.mysqlClusters[count.index].name

  database_version = local.mysqlClusters[count.index].version
  region           = var.region

  settings {
    tier              = local.mysqlClusters[count.index].tier
    availability_type = local.postgresClusters[count.index].highAvailabilityEnabled ? "REGIONAL" : "ZONAL"

    location_preference {
      zone = var.zone
    }

    ip_configuration {
      ipv4_enabled    = local.mysqlClusters[count.index].publicIpEnabled
      private_network = data.external.network_wait.result.network_self_link
      require_ssl     = "true"

      dynamic "authorized_networks" {
        for_each = local.mysqlClusters[count.index].authorizedNetworks
        content {
          value = authorized_networks.value
        }
      }
    }

    maintenance_window {
      day          = local.mysqlClusters[count.index].maintenanceDay
      hour         = local.mysqlClusters[count.index].maintenanceHour
      update_track = "stable"
    }

    backup_configuration {
      enabled            = "true"
      binary_log_enabled = "true"
      start_time = local.mysqlClusters[count.index].backupStartTime
      point_in_time_recovery_enabled = local.mysqlClusters[count.index].pointInTimeRecoveryEnabled
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_string" "mysql_admin_password" {
  count    = length(local.mysqlClusters)

  length  = 32
  special = false
  upper   = true

  keepers = {
    mysql_instance = local.mysqlClusters[count.index].name
    mysql_admin    = local.mysqlClusters[count.index].adminUsername
  }
}

resource "google_sql_user" "mysql_admin" {
  count    = length(local.mysqlClusters)
  name     = local.mysqlClusters[count.index].adminUsername
  host     = "%"
  instance = google_sql_database_instance.mysql[count.index].name
  password = random_string.mysql_admin_password[count.index].result
}

resource "random_string" "mysql_user_password" {
  count    = length(local.mysqlUsers)

  length  = 32
  special = false
  upper   = true

  keepers = {
    mysql_instance = local.mysqlUsers[count.index].mysqlName
    username       = local.mysqlUsers[count.index].username
  }
}

resource "google_sql_user" "mysql_user" {
  count    = length(local.mysqlUsers)
  name     = local.mysqlUsers[count.index].username
  host     = "%"
  instance = local.mysqlUsers[count.index].mysqlName
  password = random_string.mysql_user_password[count.index].result
}
