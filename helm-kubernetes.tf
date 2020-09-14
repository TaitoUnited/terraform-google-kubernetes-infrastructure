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
    name     = "permissions"
    value    = local.permissions.kubernetes
  }

  set {
    name     = "cicd.deployServiceAccount"
    value    = var.global_cloud_deploy_privileges ? "serviceAccount:${data.google_project.zone.number}@cloudbuild.gserviceaccount.com" : ""
  }

  set {
    name     = "cicd.testingServiceAccount"
    value    = var.create_cicd_testing_account ? "serviceAccount:${google_service_account.cicd_tester[0].email}" : ""
  }

  set {
    name     = "dbProxyNamespace"
    value    = "db-proxy"
  }

}
