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

/* TODO: not working anymore
resource "google_logging_project_sink" "logs" {
  depends_on = [google_project_service.compute]

  count = length(var.logging_sinks)
  name  = var.logging_sinks[count.index]

  # Can export to pubsub, cloud storage, or bigtable
  destination = "bigquery.googleapis.com/projects/${var.logging_sinks[count.index]}/datasets/logs"

  # Log all WARN or higher severity messages relating to instances
  filter = "resource.type=container AND resource.jsonPayload.labels.company=${var.logging_companies[count.index]}"

  # Use a unique writer (creates a unique service account used for writing)
  unique_writer_identity = true
}
*/
