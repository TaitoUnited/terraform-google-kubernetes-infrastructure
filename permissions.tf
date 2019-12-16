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

resource "google_kms_key_ring_iam_member" "kms_encrypter" {
  depends_on = [ null_resource.service_wait ]

  count       = var.kubernetes_db_encryption ? 1 : 0
  key_ring_id = google_kms_key_ring.zone_key_ring[0].self_link
  role        = "roles/cloudkms.cryptoKeyEncrypter"

  member = "serviceAccount:service-${data.google_project.zone.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_kms_key_ring_iam_member" "kms_decrypter" {
  depends_on = [ null_resource.service_wait ]

  count       = var.kubernetes_db_encryption ? 1 : 0
  key_ring_id = google_kms_key_ring.zone_key_ring[0].self_link
  role        = "roles/cloudkms.cryptoKeyDecrypter"

  member = "serviceAccount:service-${data.google_project.zone.number}@container-engine-robot.iam.gserviceaccount.com"
}

# ----------------------------------------------------------------------

resource "google_project_iam_binding" "owner" {
  depends_on = [google_project_service.compute]
  role       = "roles/owner"
  members    = var.owners
}

resource "google_project_iam_binding" "editor" {
  depends_on = [google_project_service.compute, google_project_service.containerregistry]
  role       = "roles/editor"
  members    = concat(var.editors, [
    # keep the existing cloudservices service account editor permission
    "serviceAccount:${data.google_project.zone.number}@cloudservices.gserviceaccount.com",
    # keep the existing containerregistry service account editor permission
    "serviceAccount:service-${data.google_project.zone.number}@containerregistry.iam.gserviceaccount.com"
  ])
}

resource "google_project_iam_binding" "viewer" {
  depends_on = [google_project_service.compute]
  role       = "roles/viewer"
  members = concat(
    var.viewers,
  )
}

resource "google_project_iam_binding" "cloudsql_client" {
  depends_on = [google_project_service.compute, google_service_account.database_proxy]
  role       = "roles/cloudsql.client"
  members = concat(
    [ "serviceAccount:${google_service_account.database_proxy.email}" ],
  )
}

resource "google_project_iam_binding" "container_developer" {
  depends_on = [null_resource.service_wait, google_service_account.cicd_tester]
  role       = "roles/container.developer"
  members = concat(
    var.developers,
    var.externals,
    var.cicd_deploy_enabled ? [
      "serviceAccount:${data.google_project.zone.number}@cloudbuild.gserviceaccount.com",
      "serviceAccount:${google_service_account.cicd_tester.email}"
    ] : [],
  )
}

/* TODO: Perhaps roles/container.admin suffices?
resource "google_project_iam_binding" "container_cluster_admin" {
  depends_on = [null_resource.service_wait]
  role       = "roles/container.clusterAdmin"
  members = [
    # TODO: Avoid giving clusterAdmin role for cloudbuild
    "serviceAccount:${data.google_project.zone.number}@cloudbuild.gserviceaccount.com"
  ]
}
*/

resource "google_project_iam_binding" "container_admin" {
  depends_on = [null_resource.service_wait]
  role       = "roles/container.admin"
  members = [
    # TODO: Avoid giving admin role for cloudbuild
    "serviceAccount:${data.google_project.zone.number}@cloudbuild.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "serviceusage_consumer" {
  depends_on = [google_project_service.compute]
  role       = "roles/serviceusage.serviceUsageConsumer"
  members    = var.developers
}

resource "google_project_iam_binding" "cloudbuild_builds_editor" {
  depends_on = [google_project_service.compute]
  role       = "roles/cloudbuild.builds.editor"
  members    = var.developers
}

resource "google_project_iam_binding" "errorreporting_user" {
  depends_on = [google_project_service.compute]
  role       = "roles/errorreporting.user"
  members    = var.developers
}

resource "google_project_iam_binding" "source_admin" {
  depends_on = [google_project_service.compute]
  role       = "roles/source.admin"
  members    = var.developers
}

resource "google_project_iam_binding" "monitoring_editor" {
  depends_on = [google_project_service.compute]
  role       = "roles/monitoring.editor"
  members    = var.developers
}
