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

resource "helm_release" "kubernetes" {
  depends_on = [module.kubernetes]

  count      = local.helmEnabled ? 1 : 0

  name       = "kubernetes"
  namespace  = "google"
  chart      = "${path.module}/kubernetes"

  set {
    name     = "dbProxyNamespace"
    value    = "db-proxy"
  }

  set {
    name     = "dbProxyAccessors"
    value    = concat(local.viewers, local.statusViewers, local.limitedDevelopers)
  }

  set {
    name     = "globalStatusViewers"
    value    = concat(local.viewers, local.statusViewers)
  }

}
