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

output "postgres_private_ip_addresses" {
  description = "PostgreSQL private IP addresses"
  value = google_sql_database_instance.postgres.*.private_ip_address
}

output "mysql_private_ip_addresses" {
  description = "MySQL private IP addresses"
  value = google_sql_database_instance.mysql.*.private_ip_address
}

output "network_name" {
  description = "Network name"
  value = module.network.*.network_name
}

output "network_subnet_names" {
  description = "Network subnet names"
  value = module.network.*.subnets_names[*]
}

/* TODO: not working anymore
output "logs_writer_identity" {
  description = "TODO"
  value = google_logging_project_sink.logs.*.writer_identity
}
*/
