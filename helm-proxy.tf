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
  repository = "https://kubernetes-charts.storage.googleapis.com/"
  chart      = "socat-tunneller"
  version    = local.socat_tunneler_version
  wait       = false

  set {
    name  = "tunnel.host"
    value = google_sql_database_instance.postgres[count.index].private_ip_address
  }

  set {
    name  = "tunnel.port"
    value = 5432
  }
}

resource "helm_release" "mysql_proxy" {
  depends_on = [module.kubernetes, helm_release.postgres_proxy]

  count      = local.helmEnabled ? length(local.mysqlClusters) : 0
  name       = local.mysqlClusters[count.index].name
  namespace  = "db-proxy"
  repository = "https://kubernetes-charts.storage.googleapis.com/"
  chart      = "socat-tunneller"
  version    = local.socat_tunneler_version
  wait       = false

  set {
    name  = "tunnel.host"
    value = google_sql_database_instance.mysql[count.index].private_ip_address
  }

  set {
    name  = "tunnel.port"
    value = 3306
  }
}
