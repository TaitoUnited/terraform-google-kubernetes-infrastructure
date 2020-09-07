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

resource "helm_release" "postgres_proxy" {
  depends_on = [module.kubernetes, module.helm_apps]

  count      = local.helmEnabled ? length(local.postgresClusters) : 0
  name       = local.postgresClusters[count.index].name
  namespace  = "db-proxy"
  chart      = "${path.module}/sql-proxy"

  set {
    name     = "dbInstance"
    value    = "${var.name}:${var.region}:${local.postgresClusters[count.index].name}"
  }

  set {
    name     = "dbPort"
    value    = "5432"
  }

  set {
    name     = "podSecurityPolicyEnabled"
    value    = local.kubernetes.podSecurityPolicyEnabled
  }
}

resource "helm_release" "mysql_proxy" {
  depends_on = [module.kubernetes, helm_release.postgres_proxy]

  count      = local.helmEnabled ? length(local.mysqlClusters) : 0
  name       = local.mysqlClusters[count.index].name
  namespace  = "db-proxy"
  chart      = "${path.module}/sql-proxy"

  set {
    name     = "dbInstance"
    value    = "${var.name}:${var.region}:${local.mysqlClusters[count.index].name}"
  }

  set {
    name     = "dbPort"
    value    = "3306"
  }

  set {
    name     = "podSecurityPolicyEnabled"
    value    = local.kubernetes.podSecurityPolicyEnabled
  }
}
