# Kubernetes infrastructure for Google Cloud

Kubernetes based cloud-native infrastructure module designed to get you up and running in no time. You can use it either as a module, or as an example for your own customized infrastructure. The module provides all the necessary components for running your projects: Kubernetes, container registry, database clusters, database proxies, networking, monitoring, and IAM. Optionally you can install also additional infrastructure components like [NGINX ingress](https://kubernetes.github.io/ingress-nginx/), [cert-manager](https://cert-manager.io/), [Falco](https://falco.org/), [Jaeger](https://www.jaegertracing.io/), [Sentry](https://sentry.io/welcome/), [Jenkins X](https://jenkins-x.io/), [Istio](https://istio.io/), and [Knative (Cloud Run)](https://knative.dev/).

Example usage:

```
module "my_zone" {
  source                     = "TaitoUnited/kubernetes-infrastructure/google"
  version                    = "2.0.0"

  # Labeling
  name                       = "my-zone"

  # Google Provider
  project_id                 = "my-gcp-project"
  region                     = "europe-west1"
  zone                       = "europe-west1-b"

  # Helm
  # NOTE: On the first run helm_enabled should be set to false. You can turn
  # helm_enabled to true once the Kubenetes cluster exists and you have
  # authenticated to it.
  helm_enabled               = false

  # Settings
  enable_google_services         = true
  global_cloud_deploy_privileges = true
  create_database_proxy_account  = true
  create_cicd_testing_account    = true
  email                          = "devops@mydomain.com"

  # Resources
  resources                  = yamldecode(file("${path.root}/../my-zone.yaml"))
}
```

Example YAML for resources:

```
#--------------------------------------------------------------------
# Network
#--------------------------------------------------------------------

network:
  create: true
  natEnabled: true # Required if kubernetes.privateNodesEnabled is true
  privateGoogleServicesEnabled: true

#--------------------------------------------------------------------
# Kubernetes
#--------------------------------------------------------------------

# For Kubernetes setting descriptions, see
# https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/
kubernetes:
  name: zone1-common-kube1
  context: zone1
  releaseChannel: STABLE
  maintenanceStartTime: 02:00
  registryProjectId:
  authenticatorSecurityGroup: # gke-security-groups@yourdomain.com
  rbacSecurityGroup:
  clusterFirewallRulesEnabled: false
  masterPrivateEndpointEnabled: false
  masterGlobalAccessEnabled: true
  privateNodesEnabled: true
  shieldedNodesEnabled: true
  networkPolicyEnabled: true
  dbEncryptionEnabled: true
  podSecurityPolicyEnabled: true
  verticalPodAutoscalingEnabled: true
  dnsCacheEnabled: true
  pdCsiDriverEnabled: true
  resourceConsumptionExportEnabled: true
  resourceConsumptionExportDatasetId:
  networkEgressExportEnabled: false
  binaryAuthorizationEnabled: false
  intranodeVisibilityEnabled: false
  configConnectorEnabled: false
  # zones: # NOTE: Provide zones only if kubernes is ZONAL instead of REGIONAL
  masterAuthorizedNetworks:
    - 0.0.0.0/0
  nodePools:
    - name: pool-1
      machineType: n1-standard-1
      acceleratorType:
      acceleratorCount: 0
      secureBootEnabled: true
      diskSizeGb: 100
      locations: # Leave empty or specify zones: us-central1-b,us-central1-c
      # NOTE: On Google Cloud total number of nodes = node_count * num_of_zones
      minNodeCount: 1
      maxNodeCount: 1
    - name: gpu-pool-1
      machineType: n1-standard-1
      acceleratorType: NVIDIA_TESLA_T4
      acceleratorCount: 1
      secureBootEnabled: true
      diskSizeGb: 100
      locations: # Leave empty or specify zones: us-central1-b,us-central1-c
      # NOTE: On Google Cloud total number of nodes = node_count * num_of_zones
      minNodeCount: 1
      maxNodeCount: 1
  # Ingress controllers
  nginxIngressControllers:
    - class: nginx
      replicas: 3
      metricsEnabled: true
      maxmindLicenseKey: # For GeoIP
      # See https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
      configMap:
        enable-modsecurity: true
        enable-owasp-modsecurity-crs: true
        use-geoip: false
        use-geoip2: true
        enable-real-ip: false
        enable-opentracing: false
        whitelist-source-range:
        # Block malicious IPs. See https://www.projecthoneypot.org/list_of_ips.php
        block-cidrs:
        block-user-agents:
        block-referers:
      # Map TCP/UDP connections to services
      tcpServices:
        3000: my-namespace/my-tcp-service:9000
      udpServices:
        3001: my-namespace/my-udp-service:9001
  # Certificate managers
  certManager:
    enabled: false
  # Platforms
  istio:
    enabled: false
  knative:         # Using Google Cloud Run
    enabled: false
  # Logging, monitoring, and tracing
  falco:
    enabled: false # NOTE: Not supported yet
  jaeger:
    enabled: false # NOTE: Not supported yet
  sentry:
    enabled: false # NOTE: Not supported yet
  # CI/CD
  jenkinsx:
    enabled: false # NOTE: Not supported yet

#--------------------------------------------------------------------
# Databases
#--------------------------------------------------------------------

postgresClusters:
  - name: zone1-common-postgres
    version: POSTGRES_11
    tier: db-f1-micro
    maintenanceDay: 2
    maintenanceHour: 2
    backupStartTime: 05:00
    pointInTimeRecoveryEnabled: false
    highAvailabilityEnabled: true
    publicIpEnabled: false
    authorizedNetworks:
      - 127.127.127.127/32
    flags:
      log_min_duration_statement: 1000
    adminUsername: admin

mysqlClusters:
  - name: zone1-common-mysql
    version: MYSQL_5_7
    tier: db-f1-micro
    maintenanceDay: 2
    maintenanceHour: 2
    backupStartTime: 05:00
    pointInTimeRecoveryEnabled: false
    highAvailabilityEnabled: true
    publicIpEnabled: false
    authorizedNetworks:
      - 127.127.127.127/32
    adminUsername: admin

#--------------------------------------------------------------------
# Storage buckets
#--------------------------------------------------------------------

storageBuckets:
  - name: zone1-state
    purpose: state
    location: europe-west1
    storageClass: REGIONAL
    versioningEnabled: true
    versioningRetainDays: 90
  - name: zone1-projects
    purpose: projects
    location: europe-west1
    storageClass: REGIONAL
    versioningEnabled: true
    versioningRetainDays: 90
  - name: zone1-public
    purpose: public
    location: europe-west1
    storageClass: REGIONAL
    versioningEnabled: true
    versioningRetainDays: 90
    cors:
      - origin: ["*"]
    cdnDomain: cdn.mydomain.com
  - name: zone1-temp
    purpose: temporary
    location: europe-west1
    storageClass: REGIONAL
    versioningEnabled: false
    autoDeletionRetainDays: 90
  - name: zone1-archive
    purpose: archive
    location: europe-west1
    storageClass: REGIONAL
    versioningEnabled: true
    transitionRetainDays: 90
    transitionStorageClass: ARCHIVE
```

When combined with additional Terraform modules, you get also DNS, alerts, and access management:

```
#--------------------------------------------------------------------
# DNS
#--------------------------------------------------------------------

# TODO: module link
dnsZones:
  - name: my-domain
    dnsName: mydomain.com.
    visibility: public
    dnsSec:
      state: on
    recordSets:
      - dnsName: www.mydomain.com.
        type: A
        ttl: 3600
        values: ["127.127.127.127"]
      - dnsName: myapp.mydomain.com.
        type: CNAME
        ttl: 43200
        values: ["myapp.otherdomain.com."]

#--------------------------------------------------------------------
# Alerts
#--------------------------------------------------------------------

# NOTE: This module does not currently create notification channels.
# You have to create them manually (e.g. the 'monitoring' channel shown below).

# TODO: module link
alerts:
  - name: kubernetes-container-errors
    type: log
    channels: [ "monitoring" ]
    rule: >
      resource.type="k8s_container"
      severity>=ERROR

#--------------------------------------------------------------------
# Access management
#--------------------------------------------------------------------

permissions:
  # TODO: module link
  zone:
    owners:
      - group:devops@mydomain.com
    viewers:
      - user:john.viewer@mydomain.com
    statusViewers:
      - group:staff@mydomain.com
    developers:
      - group:developers@mydomain.com
    limitedDevelopers:
      - user:jane.external@anotherdomain.com
    limitedDataViewers:
      - user:jane.external@anotherdomain.com

  # TODO: module link
  kubernetes:
    cluster:
      'taito:iam-admin':
        - group:devops@mydomain.com
      'taito:status-viewer':
        - group:staff@mydomain.com
    namespaces:
      db-proxy:
        'taito:pod-portforwarder':
          - user:jane.external@anotherdomain.com
      my-namespace:
        'taito:status-viewer':
          - user:jane.external@anotherdomain.com
      another-namespace:
        'taito:developer':
          - user:jane.external@anotherdomain.com

  # TODO: module link
  databases:
    zone1-common-postgres:
      roles:
        - name: my_project_admin
          permissions:
            - database: my_project_database
              schema: public
              type: table
              privileges: ["ALL"]
            - database: my_project_database
              schema: public
              type: sequence
              privileges: ["ALL"]
        - name: my_project_support
          permissions:
            - database: my_project_database
              schema: public
              type: table
              privileges: ["SELECT", "UPDATE"]
      users:
        - name: john.doe
          roles: [ "my_project_support" ]
          permissions:
            - database: another_database
              schema: public
              type: table
              privileges: ["SELECT"]
    zone1-common-mysql:
      users:
        - username: john.doe
          view: [ "my-database" ]
          edit: [ "another-database" ]
```

Similar YAML format is supported by the following modules:

- [Kubernetes infrastructure for AWS](https://registry.terraform.io/modules/TaitoUnited/kubernetes-infrastructure/aws)
- [Kubernetes infrastructure for Azure](https://registry.terraform.io/modules/TaitoUnited/kubernetes-infrastructure/azurerm)
- [Kubernetes infrastructure for Google](https://registry.terraform.io/modules/TaitoUnited/kubernetes-infrastructure/google)
- [Kubernetes infrastructure for DigitalOcean](https://registry.terraform.io/modules/TaitoUnited/kubernetes-infrastructure/digitalocean)

The aforementioned modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/).

See also [Google Cloud project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/google), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!
