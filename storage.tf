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

resource "google_storage_bucket" "state" {
  depends_on = [google_project_service.compute]

  count         = var.state_bucket != "" ? 1 : 0
  name          = var.state_bucket
  storage_class = "REGIONAL"
  location      = var.region

  labels = {
    project = var.project_id
    purpose = "state"
  }

  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      with_state = "ARCHIVED"
      age        = var.archive_day_limit
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket" "projects" {
  depends_on = [google_project_service.compute]

  count         = var.projects_bucket != "" ? 1 : 0
  name          = var.projects_bucket
  storage_class = "REGIONAL"
  location      = var.region

  labels = {
    project = var.project_id
    purpose = "projects"
  }

  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      with_state = "ARCHIVED"
      age        = var.archive_day_limit
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket" "assets" {
  depends_on = [google_project_service.compute]

  count         = var.assets_bucket != "" ? 1 : 0
  name          = var.assets_bucket
  storage_class = "REGIONAL"
  location      = var.region

  labels = {
    project = var.project_id
    purpose = "assets"
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
  }

  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      with_state = "ARCHIVED"
      age        = var.archive_day_limit
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
