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

resource "helm_release" "google_kubernetes" {
  depends_on = [module.kubernetes]

  count      = var.helm_enabled ? 1 : 0

  name       = "google-kubernetes"
  namespace  = "google"
  chart      = "${path.module}/google-kubernetes"

  set {
    name     = "email"
    value    = var.email
  }
}
