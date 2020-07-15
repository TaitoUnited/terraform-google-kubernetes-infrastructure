# Kubernetes infrastructure for Google Cloud

Kubernetes infrastructure module designed to get you up and running in no time. Provides all the necessary components for running your projects: Kubernetes, NGINX ingress, cert-manager, container registry, databases, database proxies, networking, monitoring, and permissions. Use it either as a module, or as an example for your own customized infrastructure.

This module is used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/). See the [gcp template](https://github.com/TaitoUnited/taito-templates/tree/master/infrastructure/gcp/terraform) as an example on how to use this module.

Example YAML for variables:

```
settings:
  owners:
    - user:john.owner@mydomain.com
  editors:
    - user:jane.editor@mydomain.com
  viewers:
    - domain:mydomain.com
  developers:
    - user:john.developer@mydomain.com
  externals:
    - user:jane.external@anotherdomain.com

  kubernetes:
    name: zone1-common-kube
    context: zone1
    releaseChannel: STABLE
    rbacSecurityGroup:
    privateNodesEnabled: true
    shieldedNodesEnabled: true
    networkPolicyEnabled: false
    dbEncryptionEnabled: false
    podSecurityPolicyEnabled: false # NOTE: not supported yet
    istioEnabled: false
    cloudEnabled: false
    # zones: # NOTE: Provide zones only if kubernes is ZONAL instead of REGIONAL
    masterAuthorizedNetworks:
      - 0.0.0.0/0
    nodePools:
      - name: pool-1
        machineType: n1-standard-1
        diskSizeGb: 100
        # NOTE: On Google Cloud total number of nodes = node_count * num_of_zones
        minNodeCount: 1
        maxNodeCount: 1
    nginxIngressControllers:
      - class: nginx
        replicas: 3

  postgresClusters:
    - name: ${taito_zone}-common-postgres
      version: POSTGRES_11
      tier: db-f1-micro
      # size: 20 # TODO: support for initial size?
      highAvailabilityEnabled: true
      publicIpEnabled: false
      authorizedNetworks:
        - 127.127.127.127/32
      adminUsername: admin
      # TODO: support for db users
      users:
        - username: john.doe
          read:
            - my-project-prod
          write:
            - another-project-prod

  mysqlClusters:
    - name: ${taito_zone}-common-mysql
      version: MYSQL_5_7
      tier: db-f1-micro
      size: 20 # TODO: support for initial size?
      highAvailabilityEnabled: true # TODO: HA support for mysql
      publicIpEnabled: false
      authorizedNetworks:
        - 127.127.127.127/32
      adminUsername: admin
      # TODO: support for db users
      users:
        - username: john.doe
          read:
            - my-project-prod
          write:
            - another-project-prod
```
