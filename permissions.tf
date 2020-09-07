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

resource "google_kms_key_ring_iam_member" "kms_encrypter" {
  depends_on = [ null_resource.service_wait ]

  count       = try(local.kubernetes.dbEncryptionEnabled, false) ? 1 : 0
  key_ring_id = google_kms_key_ring.zone_key_ring[0].self_link
  role        = "roles/cloudkms.cryptoKeyEncrypter"

  member = "serviceAccount:service-${data.google_project.zone.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_key_ring_iam_member" "kms_decrypter" {
  depends_on = [ null_resource.service_wait ]

  count       = try(local.kubernetes.dbEncryptionEnabled, false) ? 1 : 0
  key_ring_id = google_kms_key_ring.zone_key_ring[0].self_link
  role        = "roles/cloudkms.cryptoKeyDecrypter"

  member = "serviceAccount:service-${data.google_project.zone.number}@container-engine-robot.iam.gserviceaccount.com"
}

# ----------------------------------------------------------------------

resource "google_project_iam_binding" "owner" {
  depends_on = [google_project_service.compute]
  role       = "roles/owner"
  members    = local.owners
}

resource "google_project_iam_binding" "viewer" {
  depends_on = [google_project_service.compute]
  role       = "roles/viewer"
  members    = local.viewers
}

resource "google_project_iam_binding" "container_developer" {
  depends_on = [null_resource.service_wait, google_service_account.cicd_tester]
  role       = "roles/container.developer"
  members = concat(
    local.developers,

    var.cicd_cloud_deploy_enabled ? [
      # TODO: Give cloudbuild only such permissions it really requires.
      # -> Optionally prevent also (Cluster)Role/(Cluster)RoleBinding modifications.
      "serviceAccount:${data.google_project.zone.number}@cloudbuild.gserviceaccount.com",
    ] : [],

    var.cicd_testing_enabled ? [
      # TODO: limit tester access (connects to db proxy container and reads project specific db secrets)
      "serviceAccount:${google_service_account.cicd_tester[0].email}"
    ] : [],
  )
}

resource "google_project_iam_binding" "container_cluster_viewer" {
  depends_on = [null_resource.service_wait]
  role       = "roles/container.clusterViewer"
  members = concat(
    local.viewers,
    local.statusViewers,
    local.limitedDevelopers,
  )
}

resource "google_project_iam_binding" "cloudsql_client" {
  depends_on = [google_project_service.compute, google_service_account.database_proxy]
  role       = "roles/cloudsql.client"
  members = concat(
    local.viewers,
    local.statusViewers,
    local.limitedDataViewers,
    local.developers,
    local.limitedDevelopers,

    var.database_proxy_enabled ? [
      "serviceAccount:${google_service_account.database_proxy[0].email}"
    ] : [],

    var.cicd_testing_enabled ? [
      "serviceAccount:${google_service_account.cicd_tester[0].email}"
    ] : [],
  )
}

resource "google_project_iam_binding" "serviceusage_consumer" {
  depends_on = [google_project_service.compute]
  role       = "roles/serviceusage.serviceUsageConsumer"
  members    = local.developers
}

resource "google_project_iam_binding" "cloudbuild_builds_editor" {
  depends_on = [google_project_service.compute]
  role       = "roles/cloudbuild.builds.editor"
  members    = local.developers
}

resource "google_project_iam_binding" "cloudbuild_builds_viewer" {
  depends_on = [google_project_service.compute]
  role       = "roles/cloudbuild.builds.viewer"
  members    = local.statusViewers
}

resource "google_project_iam_binding" "errorreporting_user" {
  depends_on = [google_project_service.compute]
  role       = "roles/errorreporting.user"
  members    = local.developers
}

resource "google_project_iam_binding" "source_admin" {
  depends_on = [google_project_service.compute]
  role       = "roles/source.admin"
  members    = local.developers
}

resource "google_project_iam_binding" "monitoring_editor" {
  depends_on = [google_project_service.compute]
  role       = "roles/monitoring.editor"
  members    = local.developers
}

resource "google_project_iam_binding" "monitoring_viewer" {
  depends_on = [google_project_service.compute]
  role       = "roles/monitoring.viewer"
  members    = local.statusViewers
}
