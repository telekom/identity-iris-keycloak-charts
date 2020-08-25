**Table of contents**

[[_TOC_]]

# Target Audience

This chart installs [Keycloak](https://www.keycloak.org/documentation.html). \
It is suitable for installations on plain kubernetes (eg. AWS EKS) where RedHat-support is not available. \
For OpenShift environments (eg. AppAgile) the chart "rhsso-broker" should be preferred.

# TL;DR;

Content:
- this chart deploys [jboss/keycloak](https://hub.docker.com/r/jboss/keycloak/)
- in default configuration [postgres](https://hub.docker.com/_/postgres) container is used as a database
- by setting `use_external_database: true` an external database can be used instead of the postgres container

Subcharts:
- keycloak
- postgres

Issues and questions can be reported to the [issues list](../issues)

# Details

## License

Neither keycloak nor postgres requires a license. All used images are copies of public images from docker-hub.

## Version

| Installed software versions      | Version Info       |    
|----------------------------------|--------------------|
| keycloak                         |  9.0.0             |
| - java                           |  11.0.6            |
| postgress                        |  9.6               |

## Description

**Important internal links:**
 - [this repository](https://ceiser-wbench.psst.t-online.corp/nexus3/#browse/browse:tif-public-raw:tif%2Finfr%2Fcharts%2Ftif-keycloak)
 - [chart in nexus](https://ceiser-wbench.psst.t-online.corp/nexus3/#browse/browse:tif-public-raw:tif%2Finfr%2Fcharts%2Ftif-keycloak)
 - [mtr-repo "tif-public"](https://mtr.external.otc.telekomcloud.com/organization/tif-public)

**Important external links:**
- Keycloak
  - [version 9.0 documentation](https://www.keycloak.org/docs/9.0/getting_started/index.html)
  - [docker image documentation](https://hub.docker.com/r/jboss/keycloak/)
  - [github repository](https://github.com/keycloak/)
- PostgreSQL
  - [docker image documentation](https://hub.docker.com/_/postgres)

After a succesfull installation the component can be reached at the URL: `keycloak-internal-<namespace>.<domain.internal.url>`

## Configuration

**configuration file**

Keycloak is configured by an xml file. The default installation contains some typical configuration files.
This chart contains a copy of the standalone-ha.xml stored in a config map. At start, this file is copied to the proper location and used as a configuration file.

**realm**

According to the documentation, the master realm should be used only for administrative purposes. This chart initialize keycloak with an additional realm called "tif".  
This tif-realm.json file is stored in a separate config file and mounted to the pod container.

> **Note**: Current version of the chart does not contain any flags to replace the default config maps. Modifing the config maps must be done manually.  

**database**

There are two options for the database: either a postgresql database run in a container or an external database.
In case of the postgress-container the data is stored in a pvc-mount in a folder `data`.

**prometheus integration**

Due to internal circumstances the metrics can be accessed under keycloak REST endpoint */auth/realms/master/metrics*.
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
| `global.ingress.annotations`          | Set annotations for all ingress, can be extended by ingress specific ones         | `nil`                              |
| `global.externalDatabase.enabled`     | Should the setup use an external database?                                        | `false`                            |
| `global.externalDatabase.host`        | Hostname of the external database                                                 | `nil`                              |
| `global.externalDatabase.ssl`         | Encrypt the database connection                                                   | `false`                            |
| `global.externalDatabase.sslCert`     | Client certificate, set for mTLS                                                  | `nil`                              |
| `global.externalDatabase.sslKey`      | Client key, set for mTLS                                                          | `nil`                              |
| `global.externalDatabase.sslRootCert` | Root certificate                                                                  | `nil`                              |
| `image.repository`                    | MTR repository                                                                    | `mtr.external.otc.telekomcloud.com`|
| `image.organization`                  | MTR organization                                                                  | `tif-public`                       |
| `image.name`                          | Docker image name in MTR                                                          | `tif-keycloak`                     |
| `image.tag`                           | Selected image tag                                                                | `1.0.0`                            |
| `tls.secret`                          | TLS secret name                                                                   |                                    |
| `admin_username`                      | Name of the Keycloak admin user                                                   | `admin`                            |
| `admin_password`                      | Password of the Keycloak admin user                                               |                                    |
| `access_token_lifespan`               | Lifespan of a token                                                               | `300`                              |
| `replicas`                            | Number of replicas                                                                | `1`                                |
| `resources.requests.memory`           | Memory request for keycloak pod                                                   | `2Gi`                              |
| `resources.requests.cpu`              | CPU request for keycloak pod                                                      | `200m`                             |
| `resources.limit.memory`              | Memory limit for keycloak pod                                                     | `2Gi`                              |
| `resources.limit.cpu`                 | CPU limit for keycloak pod                                                        | `2000m`                            |
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
| AppAgile    | Unverified |
| AWS EKS     | Yes        |
| CaaS        | Yes        |