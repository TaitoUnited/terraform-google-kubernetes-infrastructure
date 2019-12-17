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

resource "helm_release" "nginx_ingress" {
  depends_on = [module.kubernetes]

  count = var.helm_enabled ? length(var.helm_nginx_ingress_classes) : 0

  name       = "nginx-ingress"
  namespace  = "nginx-ingress"
  repository = "https://kubernetes-charts.storage.googleapis.com/"
  chart      = "nginx-ingress"
  version    = "1.26.2"
  wait       = false

  set {
    name     = "podSecurityPolicy.enabled"
    value    = var.kubernetes_pod_security_policy
  }

  set {
    name     = "rbac.create"
    value    = "true"
  }

  set {
    name     = "serviceAccount.create"
    value    = "true"
  }

  set {
    name     = "controller.ingressClass"
    value    = var.helm_nginx_ingress_classes[count.index]
  }

  set {
    name     = "controller.replicaCount"
    value    = var.helm_nginx_ingress_replica_counts[count.index]
  }

  set_string {
    name     = "controller.service.loadBalancerIP"
    value    = google_compute_address.kubernetes_ingress[0].address
  }

  set {
    name     = "controller.service.externalTrafficPolicy"
    value    = "Local"
  }

  /* TODO
  set {
    name     = "controller.metrics.enabled"
    value    = "true"
  }

  set {
    name     = "controller.stats.enabled"
    value    = "true"
  }
  */
}

resource "helm_release" "cert_manager_crd" {
  depends_on = [module.kubernetes, helm_release.nginx_ingress]

  count = var.helm_enabled ? 1 : 0

  name       = "cert-manager-crd"
  namespace  = "cert-manager-crd"
  repository = "https://taitounited.github.io/taito-charts/"
  chart      = "cert-manager-crd"
  version    = "0.11.0"
}

resource "null_resource" "cert_manager_crd_wait" {
  depends_on = [helm_release.cert_manager_crd]

  triggers = {
    helm_enabled = var.helm_enabled
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "helm_release" "cert_manager" {
  depends_on = [module.kubernetes, null_resource.cert_manager_crd_wait]

  count      = var.helm_enabled ? 1 : 0

  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io/"
  chart      = "cert-manager"
  version    = "0.11.0"

  set {
    name     = "global.rbac.create"
    value    = "true"
  }

  set {
    name     = "global.podSecurityPolicy.enabled"
    value    = var.kubernetes_pod_security_policy
  }

  set {
    name     = "securityContext.enabled"
    value    = "true"
  }

  set {
    name     = "serviceAccount.create"
    value    = "true"
  }

  # TODO: https://cert-manager.io/docs/installation/compatibility/
  set {
    name     = "webhook.enabled"
    value    = var.kubernetes_private_nodes ? "false" : "true"
  }
}

resource "helm_release" "letsencrypt_issuer" {
  depends_on = [module.kubernetes, helm_release.cert_manager]

  count      = var.helm_enabled ? 1 : 0

  name       = "letsencrypt-issuer"
  namespace  = "cert-manager"
  chart      = "${path.module}/letsencrypt-issuer"

  set {
    name     = "email"
    value    = var.email
  }
}
