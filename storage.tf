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

resource "google_storage_bucket" "bucket" {
  depends_on    = [google_project_service.compute]

  count         = length(local.storageBuckets)
  name          = local.storageBuckets[count.index].name
  location      = local.storageBuckets[count.index].location
  storage_class = local.storageBuckets[count.index].storageClass

  labels = {
    project   = var.project_id
    purpose   = local.storageBuckets[count.index].purpose
  }

  cors {
    origin = [
      for cors in local.storageBuckets[count.index].cors:
      cors.domain
    ]
    method = ["GET"]
  }

  dynamic "cors" {
    for_each = try(local.storageBuckets[count.index].cors, null) != null ? [local.storageBuckets[count.index].cors] : []
    content {
      origin = cors.origin
      method = try(cors.method, ["GET"])
      response_header = try(cors.responseHeader, ["*"])
      max_age_seconds = try(cors.maxAgeSeconds, 5)
    }
  }

  versioning {
    enabled = local.storageBuckets[count.index].versioningEnabled
  }

  # transition
  dynamic "lifecycle_rule" {
    for_each = try(local.storageBuckets[count.index].transitionRetainDays, null) != null ? [1] : []
    content {
      condition {
        age = local.storageBuckets[count.index].transitionRetainDays
      }
      action {
        type = "SetStorageClass"
        storage_class = local.storageBuckets[count.index].transitionStorageClass
      }
    }
  }

  # versioning
  dynamic "lifecycle_rule" {
    for_each = try(local.storageBuckets[count.index].versioningRetainDays, null) != null ? [1] : []
    content {
      condition {
        age = local.storageBuckets[count.index].versioningRetainDays
        with_state = "ARCHIVED"
      }
      action {
        type = "Delete"
      }
    }
  }

  # autoDeletion
  dynamic "lifecycle_rule" {
    for_each = try(local.storageBuckets[count.index].autoDeletionRetainDays, null) != null ? [1] : []
    content {
      condition {
        age = local.storageBuckets[count.index].autoDeletionRetainDays
        with_state = "ANY"
      }
      action {
        type = "Delete"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
