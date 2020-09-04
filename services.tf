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

resource "google_project_service" "compute" {
  service    = "compute.googleapis.com"
  count      = var.enable_google_services ? 1 : 0
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "servicenetworking" {
  depends_on = [
    google_project_service.compute,
    google_project_iam_binding.owner,
  ]
  count      = var.enable_google_services ? 1 : 0
  service    = "servicenetworking.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "cloudbuild" {
  depends_on = [google_project_service.compute]

  count      = var.enable_google_services ? 1 : 0
  service    = "cloudbuild.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "container" {
  depends_on = [google_project_service.compute]

  count      = var.enable_google_services ? 1 : 0
  service    = "container.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "containerregistry" {
  depends_on = [google_project_service.compute]

  count      = var.enable_google_services ? 1 : 0
  service    = "containerregistry.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "cloudkms" {
  depends_on = [google_project_service.compute]

  count      = var.enable_google_services ? 1 : 0
  service    = "cloudkms.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "pubsub" {
  depends_on = [google_project_service.compute]

  count      = var.enable_google_services ? 1 : 0
  service    = "pubsub.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "sql" {
  depends_on = [google_project_service.compute]

  count      = var.enable_google_services ? 1 : 0
  service    = "sql-component.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "sqladmin" {
  depends_on = [google_project_service.compute]

  count      = var.enable_google_services ? 1 : 0
  service    = "sqladmin.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

resource "google_project_service" "monitoring" {
  depends_on = [google_project_service.compute]

  count      = var.enable_google_services ? 1 : 0
  service    = "monitoring.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = false
}

# On the first run, wait for the most important google project services
resource "null_resource" "service_wait" {
  depends_on = [
    google_project_service.compute,
    google_project_service.servicenetworking,
    google_project_service.container,
    google_project_service.cloudkms,
    google_project_service.cloudbuild,
  ]

  triggers = {
    name                   = var.name
    enable_google_services = var.enable_google_services
    kubernetes_name        = try(local.kubernetes.name, "")
  }

  provisioner "local-exec" {
    command = "sleep 15"
  }
}
