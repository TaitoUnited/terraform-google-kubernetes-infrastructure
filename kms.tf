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

resource "google_kms_key_ring" "zone_key_ring" {
  depends_on = [ null_resource.service_wait ]

  count      = local.kubernetes.dbEncryptionEnabled ? 1 : 0
  name       = "${var.name}-key-ring"
  project    = var.project_id
  location   = var.region
}

resource "google_kms_crypto_key" "kubernetes_key" {
  depends_on = [ null_resource.service_wait ]

  count           = (local.kubernetes.dbEncryptionEnabled ? 1 : 0) * (local.kubernetes.name != "" ? 1 : 0)
  name            = "${local.kubernetes.name}-key"
  key_ring        = google_kms_key_ring.zone_key_ring[0].self_link
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}
