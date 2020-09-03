# Kubernetes infrastructure for Google Cloud

Kubernetes infrastructure module designed to get you up and running in no time. Provides all the necessary components for running your projects: Kubernetes, NGINX ingress, cert-manager, container registry, databases, database proxies, networking, monitoring, and permissions. Use it either as a module, or as an example for your own customized infrastructure.

This module is used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/). See the [gcp template](https://github.com/TaitoUnited/taito-templates/tree/master/infrastructure/gcp/terraform) as an example on how to use this module.

Example YAML for variables:

```
#--------------------------------------------------------------------
# Permissions
#--------------------------------------------------------------------

permissions:
  owners:
    - user:john.owner@mydomain.com
  viewers:
    - user:john.viewer@mydomain.com
  statusviewers:
    - user:john.statusviewer@mydomain.com
  dataviewers:
    - user:jane.external@anotherdomain.com
  developers:
    - user:john.developer@mydomain.com
  externals:
    - user:jane.external@anotherdomain.com

#--------------------------------------------------------------------
# DNS
#--------------------------------------------------------------------

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
# Network
#--------------------------------------------------------------------

network:
  create: true
  natEnabled: true # Required if kubernetes.privateNodesEnabled is true
  privateGoogleServicesEnabled: true

#--------------------------------------------------------------------
# Alerts
#--------------------------------------------------------------------

# NOTE: This module does not currently create notification channels.
# You have to create them manually (e.g. the 'monitoring' channel shown below).

alerts:
  - name: kubernetes-container-errors
    type: log
    channels: [ "monitoring" ]
    rule: >
      resource.type="k8s_container"
      severity>=ERROR

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
  istioEnabled: false
  cloudrunEnabled: false
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
        block-cidrs:
        block-user-agents:
        block-referers:
      # Map TCP/UDP connections to services
      tcpServices:
        3000: my-namespace/my-tcp-service:9000
      udpServices:
        3001: my-namespace/my-udp-service:9001
  # TODO: Kafka, Jaeger, Jenkins X, and Tekton installation not supported yet
  kafka:
    enabled: false
  jaeger:
    enabled: false
  jenkinsx:
    enabled: false
  tekton:
    enabled: false

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
    # NOTE: All postgres users can see each other usernames. Use scrambled
    # usernames if this is a problem.
    users:
      - username: john.doe

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
    users:
      - username: john.doe

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
