# Iris Helm Chart

**Table of contents**

[[_TOC_]]

# Target Audience

This chart installs [Keycloak](https://www.keycloak.org/documentation.html). \
It is suitable for installations on OTC, AWS EKS, AppAgile and CaaS.

# TL;DR;

Content:
- this chart deploys [jboss/keycloak](https://hub.docker.com/r/jboss/keycloak/)
- in default configuration [postgres](https://hub.docker.com/_/postgres) container is used as a database
- by setting `use_external_database: true` an external database can be used instead of the postgres container

Subcharts:
- postgres

Issues and questions can be reported to the [issues list](../issues)

# Details

## License

Neither Iris nor Postgres requires a license. All used images are copies of public images from docker-hub.  
Iris is a Keycloak based image that has been extended to integrate with logging solutions like Prometheus.  

## Version

| Installed software versions      | Version Info       |    
|----------------------------------|--------------------|
| Keycloak                         |  16.1.1            |
| - java                           |  11.0.14           |
| - wildfly                        |  26.0.6            |
| PostgreSQL                       |  12.3              |

## Description

**Important internal links:**
 - [this repository](https://ceiser-wbench.psst.t-online.corp/nexus3/#browse/browse:tif-public-raw:tif%2Finfr%2Fcharts%2Firis)
 - [chart in nexus](https://ceiser-wbench.psst.t-online.corp/nexus3/#browse/browse:tif-public-raw:tif%2Finfr%2Fcharts%2F2Firis)
 - [mtr-repo "common"](https://mtr.devops.telekom.de/repository/tardis-common/keycloak)

**Important external links:**
- Keycloak
  - [version 9.0 documentation](https://www.keycloak.org/docs/9.0/getting_started/index.html)
  - [docker image documentation](https://hub.docker.com/r/jboss/keycloak/)
  - [github repository](https://github.com/keycloak/)
- PostgreSQL
  - [docker image documentation](https://hub.docker.com/_/postgres)

After a succesfull installation the component can be reached at the URL: `keycloak-internal-<namespace>.<domain.internal.url>`

## Configuration

### HA and multiple replicas

For multiple replicas set the following ingress annotations:
```yaml
nginx.ingress.kubernetes.io/affinity: "cookie"
nginx.ingress.kubernetes.io/session-cookie-change-on-failure: "true"
```

**configuration file**

Keycloak is configured by an xml file. The default installation contains some typical configuration files.
This chart contains a copy of the standalone-ha.xml stored in a config map. At start, this file is copied to the proper location and used as a configuration file.

**realm**

According to the documentation, the master realm should be used only for administrative purposes. Therefore, this chart allows for the configuration of additional realms and using the `realms.*` parameters. If no realms are configured only the master realm will be created.

Identity providers (e.g. ADFS) can also be configured. ADFS keys, certificates and URLs can be found in the `federationmetadata.xml` (`https://ADFS_SERVER/FederationMetadata/2007-06/FederationMetadata.xml`)

> **Note**: When configuring ADFS as an Identity Provider you should also make a Change Request at ADFS to register the new Iris instance with their system. You will need to provide the XML Descriptor usually found under `https://IRIS_URL/auth/realms/{realms.name}/broker/{realms.identityProvider.name}/endpoint/descriptor`.

**database**

There are two options for the database: either a postgresql database run in a container or an external database.
In case of the postgress-container the data is stored in a pvc-mount in a folder `data`.

**prometheus integration**

Due to internal circumstances the metrics can be accessed under Keycloak REST endpoint */auth/realms/master/metrics*.
Since this endpoint is exposed due to the nature of the Keycloak API, we made this endpoint require an authentication token which must be set via header ``X-Metrics-Auth-Token``.  
We made the metrics accessible under the container's ``:9542/metrics`` endpoint which will redirects the traffic to */auth/realms/master/metrics* and will do the token-authentication automatically. The pods will be annotated with Prometheus meta data information so that Prometheus knows where to scrape the metrics.  

**configurable chart options**

> **Tip**: You can use the default [values.yaml](values.yaml)

The following table lists the configurable parameters of this chart.

| Parameter                             | Description                                                                       | Default                            |
|---------------------------------------|-----------------------------------------------------------------------------------|------------------------------------|
| `global.platform`                     | Platform (openshift or kubernetes)                                                | `stable`                           |
| `global.storageclass`                 | Storage class for PersistenVolumeClaims                                           | `gp2`                              |
| `global.domain`                       | Base cluster URL reachable from Telekom network                                   | `nil`                              |
| `global.labels`                       | Define global labels                                                              | `tif.telekom.de/group`             |
| `global.ingress`                      | Set ingress parameters for all ingress, can be extended by ingress specific ones  | `nil`                              |
| `global.externalDatabase.enabled`     | Should the setup use an external database?                                        | `false`                            |
| `global.externalDatabase.host`        | Hostname of the external database                                                 | `nil`                              |
| `global.externalDatabase.ssl`         | Encrypt the database connection                                                   | `false`                            |
| `global.externalDatabase.sslCert`     | Client certificate, set for mTLS                                                  | `nil`                              |
| `global.externalDatabase.sslKey`      | Client key, set for mTLS                                                          | `nil`                              |
| `global.externalDatabase.sslRootCert` | Root certificate                                                                  | `nil`                              |
| `image.repository`                    | MTR repository                                                                    | `mtr.devops.telekom.de/repository/`|
| `image.organization`                  | MTR organization                                                                  | `tardis-common`                    |
| `image.name`                          | Docker image name in MTR                                                          | `iris`                             |
| `image.tag`                           | Selected image tag                                                                | `1.0.0`                            |
| `tls.secret`                          | TLS secret name                                                                   |                                    |
| `admin_username`                      | Name of the Keycloak admin user                                                   | `admin`                            |
| `admin_password`                      | Password of the Keycloak admin user                                               |                                    |
| `replicas`                            | Number of replicas                                                                | `1`                                |
| `autoscaling.enabled`                 | Enables Pod Autoscaling with Target CPU usage                                     | `false`                            |
| `autoscaling.minReplicas`             | Minimum number of replicas if autoscaling is enabled                              | `3`                                |
| `autoscaling.maxReplicas`             | Maximum number of replicas if autoscaling is enabled                              | `6`                                |
| `autoscaling.cpuUtilizationPercentage`| Number of target CPU Utilization                                                  | `80`                               |
| `resources.requests.memory`           | Memory request for Keycloak pod                                                   | `2Gi`                              |
| `resources.requests.cpu`              | CPU request for Keycloak pod                                                      | `200m`                             |
| `resources.limit.memory`              | Memory limit for Keycloak pod                                                     | `2Gi`                              |
| `resources.limit.cpu`                 | CPU limit for Keycloak pod                                                        | `2000m`                            |
| `ingress.enabled`                     | Create ingress for external access                                                | `true`                             |
| `ingress.hostname`                    | Set dedicated hostname for ingress/route, overwrites global URL                   | `nil`                              |
| `ingress.tlsSecret`                   | Set secret name                                                                   | `nil`                              |
| `ingress.annotations`                 | Merges specific into global ingress annotations                                   | `nil`                              |
| `customConfig.frontendUrl`            | Allows to configure another frontend URL                                          | `${keycloak.frontendUrl:}`         |
| `customConfig.spi.hostname`           | Allows to overwrite the complete <spi name="hostname"> config incl. frontendUrl   | s. configmap-config.yml for details |
| `prometheus.enabled`                 | Controls whether to annotate pods with prometheus scraping information or not  | `true`           |
| `prometheus.authToken`                | Authentication token that is used in order to secure the exposed metrics endpoint | `changeme`                         |
| `prometheus.port`                     | Sets the port at which metrics can be accessed                                    | `9542`                             |
| `prometheus.path`                     | Sets the endpoint at which at which metrics can be accessed                       | `/metrics`                         |
| `prometheus.podMonitor.enabled`        | Enables a podmonitor which can be used by the prometheus operator to collect metrics    | `false`          |
| `prometheus.podMonitor.scheme`         | HTTP scheme to use for scraping                                                         | `http`           |
| `prometheus.podMonitor.interval`       | Interval at which metrics should be scraped                                             | `15s`            |
| `prometheus.podMonitor.scrapeTimeout`  | Timeout after which the scrape of prometheus is ended                                   | `3s`             |
| `prometheus.podMonitor.honorLabels`    | HonorLabels chooses the metric’s labels on collisions with target labels                | `true`           |
| `prometheus.serviceMonitor.enabled`        | Enables a servicemonitor which can be used by the prometheus operator to collect metrics    | `true`          |
| `prometheus.serviceMonitor.scheme`         | HTTP scheme to use for scraping                                                         | `http`           |
| `prometheus.serviceMonitor.interval`       | Interval at which metrics should be scraped                                             | `15s`            |
| `prometheus.serviceMonitor.scrapeTimeout`  | Timeout after which the scrape of prometheus is ended                                   | `3s`             |
| `prometheus.serviceMonitor.honorLabels`    | HonorLabels chooses the metric’s labels on collisions with target labels                | `true`           |
| **realms**                            | Configure realms                                                                  |                                    |
| `realms.name`                         | Realm name                                                                        | `nil`                              |
| `realms.access_token_lifespan`        | Lifespan of a token                                                               | `nil`                              |
| `realms.defaultProvider`              | The alias of the default IDP to redirect to when logging in                       | `nil`                              |
| `realms.clients`                      | An array of configured clients                                                    | `nil`                              |
| `realms.clients.name`                 | Client name                                                                       | `nil`                              |
| `realms.clients.redirectUris`         | Allowed redirect URIs for the client (after authorization)                        | `nil`                              |
| `realms.clients.webOrigins`           | Web origins accepted for authorization requests                                   | `nil`                              |
| `realms.identityProviders`            | An array of identity providers for this realm                                     | `nil`                              |
| `realms.identityProviders.name`       | An alias name of the IDP                                                          | `nil`                              |
| `realms.identityProviders.displayName`| The name shown when logging in via this IDP                                       | `nil`                              |
| `realms.identityProviders.signingCertificate`     | The signing certificate of the IDP                                    | `nil`                              |
| `realms.identityProviders.singleLogoutServiceUrl` | The single logout service URL of the IDP                              | `nil`                              |
| `realms.identityProviders.singleSignOnServiceUrl` | The single sign on service URL of the IDP                             | `nil`                              |
| `realms.identityProviders.encryptionPublicKey`    | The encryption public key of the IDP                                  | `nil`                              |
| `realms.identityProviders.mappers`                | An array of mappers for the SAML data received from the IDP after a login|  `nil`                          |
| `realms.identityProviders.mappers.type`           | Choose between predefined mappers (`adfs-email` and `adfs-group`) or `custom` to define your own | `nil`   |
| `realms.identityProviders.mappers.name`           | The name of the mapper (only type `custom`)                           | `nil`                              |
| `realms.identityProviders.mappers.attributeName`  | The attribute name in the IDP response (only type `custom`)           | `nil`                              |
| `realms.identityProviders.mappers.category`       | The category of the mapper (only type `custom`)                       | `nil`                              |
| `realms.identityProviders.mappers.userAttribute`  | The Keycloak user attribute to map the value to (only type `custom`)  | `nil`                              |
| **postgresql**                        |                                                                                   |                                    |
| `postgresql.image.repository`         | MTR repository                                                                    | `mtr.external.otc.telekomcloud.com`|
| `postgresql.image.organization`       | MTR organization                                                                  | `tif-public`                       |
| `postgresql.image.name`               | Docker image name in MTR                                                          | `postgres`                         |
| `postgresql.image.tag`                | Selected image tag                                                                | `12.3-debian`                      |
| `postgresql.replicas`                 | Number of replicas                                                                | `1`                                |
| `postgresql.resources.requests.memory`| Memory request for postgresql pod                                                 | `200Mi`                            |
| `postgresql.resources.requests.cpu`   | CPU request for postgresql pod                                                    | `20m`                              |
| `postgresql.resources.limit.memory`   | Memory limit for postgresql pod                                                   | `500Mi`                            |
| `postgresql.resources.limit.cpu`      | CPU limit for postgresql pod                                                      | `100m`                             |
| `postgresql.persistence.resources.requests.storage`| Volume storage space for postgresql                                  | `1Gi`                              |

## Secrets

Confidential informations should be stored as a sops-encrypted secret. \
Instruction how to create a secrets and scripts provided by the TIF-team are [here](https://codeshare.workbench.telekom.de/gitlab/TIF-Collaboration/tools/tif-infrastructure-secrets-util): 

# Deployment to production

Default settings in this template are prepared for dev and test environments.

The database is used for storing ephemeral data (usualy tokens with a lifespan of a few minutes). For production environment however it should be considered whether the container based solution or rather a dedicated database should be used.

Please note also, that the IDP is an important component of the security concept. For this reason, all communication must be adequate encrypted and certificates shold be properly verified.

[External-DNS]: https://github.com/kubernetes-sigs/external-dns

## Compatibility

| Environment | Compatible |
|-------------|------------|
| OTC         | Yes        |
| AppAgile    | Yes        |
| AWS EKS     | Yes        |
| CaaS        | Yes        |
