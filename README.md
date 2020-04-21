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
- rhsso (*Note: in this version the keycloak subchart is called "rhsso" for backward compatibility, in the next release it will be renamed to keycloak*)
- postgres

Issues and questions can be reported to the [issues list](../issues)

# Details

## License

Neither keycloak nor postgres requires a license. All used images are copies of public images from docker-hub.

## Version

|                                  | Version Info       |    
|----------------------------------|--------------------|
| Chart Version                    |  1.0.0-beta.1      |
| Chart Status                     |  release-candidate |
| **installed software versions:** |                    |
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

**configurable chart options**

> **Tip**: You can use the default [values.yaml](values.yaml)

The following table lists the configurable parameters of this chart.

| Parameter                             | Description                                                    | Default                            |
|---------------------------------------|----------------------------------------------------------------|------------------------------------|
| `global.platform`                     | Platform (openshift or kubernetes)                             | `stable`                           |
| `global.project_prefix`               | Project prefix                                                 | `tif-`                             |
| `global.storageclass`                 | Storage class for PersistenVolumeClaims                        | `gp2`                              |
| `global.externalDnsTarget`            | [AMS] DNS target used in ingress annotations for [External-DNS]| `nil` **mandatory for AWS**        |
| `global.domain`                       | Base cluster URL reachable from Telekom network                | `nil`                              |
| `global.use_external_database`        | Should the setup use an external database?                     | `false`                            |
| `rhsso.image.registry`                | Docker registry (with keycloak image)                          | `mtr.external.otc.telekomcloud.com`|
| `rhsso.image.repository`              | Docker repository                                              | `tif-public/keycloak`              |
| `rhsso.image.tag`                     | Selected image tag                                             | `stable`                           |
| `rhsso.image.db_client_registry`      | Docker registry (with keycloak-init image)                     | `mtr.external.otc.telekomcloud.com`|
| `rhsso.image.db_client_repository`    | Docker repository                                              | `tif-public/postgres`              |
| `rhsso.image.db_client_tag`           | Selected image tag                                             | `stable`                           |
| `rhsso.tls.secret`                    | TLS secret name                                                |                                    |
| `rhsso.admin_username`                | Name of the admin user                                         | `admin`                            |
| `rhsso.admin_password`                | Password of the admin user (usually from secret)               |                                    |
| `rhsso.access_token_lifespan`         | Lifespan of a token                                            | `300`                              |
| `rhsso.replicas`                      | Number of replicas                                             | `1`                                |
| `rhsso.resources.requests.memory`     | Memory request for keycloak pod                                | `2Gi`                              |
| `rhsso.resources.requests.cpu`        | CPU request for keycloak pod                                   | `200m`                             |
| `rhsso.resources.limit.memory`        | Memory limit for keycloak pod                                  | `2Gi`                              |
| `rhsso.resources.limit.cpu`           | CPU limit for keycloak pod                                     | `2000m`                            |
| `ingress.enabled`                     | Create ingress for external access                             | `true`                             |
| `ingress.hostname`                    | Set dedicated hostname for ingress/route, overwrites global URL| `nil`                              |
| `ingress.tlsSecret`                   | Set secret name                                                | `nil`                              |
| `ingress.annotations`                 | Custom annotations for ingress                                 | `nil`                              |
| `postgresql.image.registry`           | Docker registry (containing postgresql image)                  | `mtr.external.otc.telekomcloud.com`|
| `postgresql.image.repository`         | Docker repository                                              | `tif-public/postgres`              |
| `postgresql.image.tag`                | Selected image tag                                             | `stable`                           |
| `postgresql.replicas`                 | Number of replicas                                             | `1`                                |
| `postgresql.resources.requests.memory`| Memory request for postgresql pod                              | `250M`                             |
| `postgresql.resources.requests.cpu`   | CPU request for postgresql pod                                 | `50m`                              |
| `postgresql.resources.limit.memory`   | Memory limit for postgresql pod                                | `2G`                               |
| `postgresql.resources.limit.cpu`      | CPU limit for postgresql pod                                   | `2000m`                            |

## Secrets

Confidential informations should be stored as a sops-encrypted secret. \
Instruction how to create a secrets and scripts provided by the TIF-team are [here](https://codeshare.workbench.telekom.de/gitlab/TIF-Collaboration/tools/tif-infrastructure-secrets-util): 

## Labels

This charts sets following labels on all deployed kubernetes resources:
```
app: tif-{{ .Release.Name }}
component: {{ .Chart.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
```

# Deployment to Production

Default settings in this template are prepared for dev and test environments.

The database is used for storing ephemeral data (usualy tokens with a lifespan of a few minutes). For production environment however it should be considered whether the container based solution or rather a dedicated database should be used.

Please note also, that the IDP is an important component of the security concept. For this reason, all communication must be adequate encrypted and certificates shold be properly verified.

[External-DNS]: https://github.com/kubernetes-sigs/external-dns
