# Iris Helm Chart

**Table of contents**

[[_TOC_]]

# Overview

This chart installs [Keycloak](https://www.keycloak.org/documentation.html). \
It is suitable for installations on OTC and AWS EKS.

# Details

## License

Neither Iris nor Postgres require a license. All images uses are copies of public images from docker-hub.  
Iris is a Keycloak-based image that has been extended to integrate with logging solutions such as Prometheus.

## Version

| Installed software versions | Version Info            |    
|-----------------------------|-------------------------|
| Keycloak                    | 21.1.2                  |
| Java                        | 11 (deprecated with 21) |
| PostgreSQL                  | 12.3                    |

## Description

**Important links:**

- Keycloak
    - [Keycloak documentation](https://www.keycloak.org/docs/latest/release_notes/index.html#keycloak-21-1-2)
    - [Docker image documentation](https://hub.docker.com/r/jboss/keycloak/)
    - [Github repository](https://github.com/keycloak/keycloak)
- PostgreSQL
    - [Docker image documentation](https://hub.docker.com/_/postgres)

After a successful installation the component can be reached at the
URL: `keycloak-internal-<namespace>.<domain.internal.url>`

## Upgrade Advice

### To 5.x.x

Since we have removed the serviceAccount from the deployment and the chart, this requires manual interaction in the
cluster. \
Unfortunately Helm does not remove the configured serviceAccount from the deployment resource itself. Because the
serviceAccount resource is removed, there is a remaining invalid reference. \
Therefore, you must remove these references on the cluster itself.

## Configuration

### Platform

You can select a platform to use predefined settings (e.g. securityContext) specifically dedicated to the
platform. \
Note that you can overwrite platform specific values in the values.yaml. \
To add a new platform specific values.yaml, add the required values as `platforName.yaml` to the `platforms` folder.

**Note:** Assigning platform-specific values to the sub-chart through the platform-specific `platformName.yaml` of your
main chart will not be effective, as the sub-chart's platform settings take precedence.

### HAProxy and Multiple Replicas

For multiple replicas set the following ingress annotations:

```yaml
nginx.ingress.kubernetes.io/affinity: "cookie"
nginx.ingress.kubernetes.io/session-cookie-change-on-failure: "true"
```

**Configuration Files**

Keycloak is configured by a xml file. The default installation contains some typical configuration files.
This chart contains a copy of the standalone-haproxy.xml stored in a config map. At start, this file is copied to the
proper location and used as a configuration file.

**Realm**

According to the documentation, the master realm should be used only for administrative purposes. Therefore, this chart
allows for the configuration of additional realms and using the `realms.*` parameters. If no realms are configured only
the master realm will be created.

It is also possible to configure more identity providers to Keycloak.
An [Active Directory](https://seal-oidc.docs.sealsystems.de/windows/ad_integration/connect_ad.html) is here the prime
example.

**Database**

To modify the behavior of database deployment, you can adjust the value of `database.location` to switch between "local"
and "external". When set to "local", the deployment will utilize the PostgreSQL chart located within the charts
directory to store Keycloak data. Conversely, if set to "external", you must include the `externalDatabase.host`
parameter, directing it towards the designated database. Additionally, you need to provide the essential user data and
database schema within the database field in the values.yaml file, enabling Keycloak to establish a connection.

**Prometheus Integration**

Due to internal circumstances the metrics can be accessed under Keycloak REST endpoint */auth/realms/master/metrics*.
Since this endpoint is exposed due to the nature of the Keycloak API, we made this endpoint require an authentication
token which must be set via header `X-Metrics-Auth-Token`.  
We made the metrics accessible under the container's `:9542/metrics` endpoint which will redirects the traffic to
*/auth/realms/master/metrics* and will do the token-authentication automatically. The pods will be annotated with
Prometheus metadata information so that Prometheus knows where to scrape the metrics.

**Configurable Chart Options**

> **Tip**: You can use the default [values.yaml](values.yaml)

The following table lists the configurable parameters of this chart.

| Parameter                                         | Description                                                                                      | Default                             |
|---------------------------------------------------|--------------------------------------------------------------------------------------------------|-------------------------------------|
| `global.platform`                                 | Platform                                                                                         | `stable`                            |
| `global.storageClassName`                         | Overwrites the setting determined by the platform                                                | `gp2`                               |
| `global.domain`                                   | Base cluster URL reachable from Telekom network                                                  | `nil`                               |
| `global.labels`                                   | Define global labels                                                                             | `tardis.telekom.de/group`           |
| `global.ingress`                                  | Set ingress parameters for all ingress, can be extended by ingress specific ones                 | `nil`                               |
| `global.database.location`                        | Specify if you want to deploy a PostgreSQL or use an external database                           | `local`                             |
| `global.database.port`                            | Port of the database                                                                             | `5432`                              |
| `global.database.database`                        | Name of the database                                                                             | `kong`                              |
| `global.database.schema`                          | Name of the schema                                                                               | `public`                            |
| `global.database.user`                            | Username for accessing the database                                                              | `kong`                              |
| `global.database.password`                        | The users password                                                                               | `changeme`                          |
| `truststore`                                      | Truststore in Base64                                                                             | `nil`                               |
| `truststorePassword`                              | Password to access the truststore                                                                | `password`                          |
| `global.hostnameVerificationPolicy`               | Choose a hostname verification policy                                                            | `WILDCARD`                          |
| `image.repository`                                | MTR repository                                                                                   | `http://<your-server/`              |
| `image.organization`                              | MTR organization                                                                                 | `tardis-common`                     |
| `image.name`                                      | Docker image name in MTR                                                                         | `iris`                              |
| `image.tag`                                       | Selected image tag                                                                               | `1.0.0`                             |
| `tls.secret`                                      | TLS secret name                                                                                  |                                     |
| `admin_username`                                  | Name of the Keycloak admin user                                                                  | `admin`                             |
| `admin_password`                                  | Password of the Keycloak admin user                                                              |                                     |
| `replicas`                                        | Number of replicas                                                                               | `1`                                 |
| `autoscaling.enabled`                             | Enables Pod Autoscaling with Target CPU usage                                                    | `false`                             |
| `autoscaling.minReplicas`                         | Minimum number of replicas if autoscaling is enabled                                             | `3`                                 |
| `autoscaling.maxReplicas`                         | Maximum number of replicas if autoscaling is enabled                                             | `6`                                 |
| `autoscaling.cpuUtilizationPercentage`            | Number of target CPU Utilization                                                                 | `80`                                |
| `resources.requests.memory`                       | Memory request for Keycloak pod                                                                  | `2Gi`                               |
| `resources.requests.cpu`                          | CPU request for Keycloak pod                                                                     | `200m`                              |
| `resources.limit.memory`                          | Memory limit for Keycloak pod                                                                    | `2Gi`                               |
| `resources.limit.cpu`                             | CPU limit for Keycloak pod                                                                       | `2000m`                             |
| `ingress.enabled`                                 | Create ingress for external access                                                               | `true`                              |
| `ingress.hostname`                                | Set dedicated hostname for ingress/route, overwrites global URL                                  | `nil`                               |
| `ingress.tlsSecret`                               | Set secret name                                                                                  | `nil`                               |
| `ingress.annotations`                             | Merges specific into global ingress annotations                                                  | `nil`                               |
| `customConfig.frontendUrl`                        | Allows to configure another frontend URL                                                         | `${keycloak.frontendUrl:}`          |
| `customConfig.spi.hostname`                       | Allows to overwrite the complete <spi name="hostname"> config incl. frontendUrl                  | s. configmap-config.yml for details |
| `prometheus.enabled`                              | Controls whether to annotate pods with prometheus scraping information or not                    | `true`                              |
| `prometheus.authToken`                            | Authentication token that is used in order to secure the exposed metrics endpoint                | `changeme`                          |
| `prometheus.port`                                 | Sets the port at which metrics can be accessed                                                   | `9542`                              |
| `prometheus.path`                                 | Sets the endpoint at which at which metrics can be accessed                                      | `/metrics`                          |
| `prometheus.podMonitor.enabled`                   | Enables a pod-monitor which can be used by the prometheus operator to collect metrics            | `false`                             |
| `prometheus.podMonitor.scheme`                    | HTTP scheme to use for scraping                                                                  | `http`                              |
| `prometheus.podMonitor.interval`                  | Interval at which metrics should be scraped                                                      | `15s`                               |
| `prometheus.podMonitor.scrapeTimeout`             | Timeout after which the scrape of prometheus is ended                                            | `3s`                                |
| `prometheus.podMonitor.honorLabels`               | HonorLabels chooses the metric’s labels on collisions with target labels                         | `true`                              |
| `prometheus.serviceMonitor.enabled`               | Enables a service-monitor which can be used by the prometheus operator to collect metrics        | `true`                              |
| `prometheus.serviceMonitor.scheme`                | HTTP scheme to use for scraping                                                                  | `http`                              |
| `prometheus.serviceMonitor.interval`              | Interval at which metrics should be scraped                                                      | `15s`                               |
| `prometheus.serviceMonitor.scrapeTimeout`         | Timeout after which the scrape of prometheus is ended                                            | `3s`                                |
| `prometheus.serviceMonitor.honorLabels`           | HonorLabels chooses the metric’s labels on collisions with target labels                         | `true`                              |
| `realms`                                          | Configure realms                                                                                 |                                     |
| `realms.name`                                     | Realm name                                                                                       | `nil`                               |
| `realms.access_token_lifespan`                    | Lifespan of a token                                                                              | `nil`                               |
| `realms.defaultProvider`                          | The alias of the default IDP to redirect to when logging in                                      | `nil`                               |
| `realms.clients`                                  | An array of configured clients                                                                   | `nil`                               |
| `realms.clients.name`                             | Client name                                                                                      | `nil`                               |
| `realms.clients.redirectUris`                     | Allowed redirect URIs for the client (after authorization)                                       | `nil`                               |
| `realms.clients.webOrigins`                       | Web origins accepted for authorization requests                                                  | `nil`                               |
| `realms.identityProviders`                        | An array of identity providers for this realm                                                    | `nil`                               |
| `realms.identityProviders.name`                   | An alias name of the IDP                                                                         | `nil`                               |
| `realms.identityProviders.displayName`            | The name shown when logging in via this IDP                                                      | `nil`                               |
| `realms.identityProviders.signingCertificate`     | The signing certificate of the IDP                                                               | `nil`                               |
| `realms.identityProviders.singleLogoutServiceUrl` | The single logout service URL of the IDP                                                         | `nil`                               |
| `realms.identityProviders.singleSignOnServiceUrl` | The single sign on service URL of the IDP                                                        | `nil`                               |
| `realms.identityProviders.encryptionPublicKey`    | The encryption public key of the IDP                                                             | `nil`                               |
| `realms.identityProviders.mappers`                | An array of mappers for the SAML data received from the IDP after a login                        | `nil`                               |
| `realms.identityProviders.mappers.type`           | Choose between predefined mappers (`adfs-email` and `adfs-group`) or `custom` to define your own | `nil`                               |
| `realms.identityProviders.mappers.name`           | The name of the mapper (only type `custom`)                                                      | `nil`                               |
| `realms.identityProviders.mappers.attributeName`  | The attribute name in the IDP response (only type `custom`)                                      | `nil`                               |
| `realms.identityProviders.mappers.category`       | The category of the mapper (only type `custom`)                                                  | `nil`                               |
| `realms.identityProviders.mappers.userAttribute`  | The Keycloak user attribute to map the value to (only type `custom`)                             | `nil`                               |
| `postgresql.image`                                | Specify the PostgreSQL image                                                                     | `postgres-12.3-debian`              |
| `postgresql.securityContext`                      | Specify the security context                                                                     | `nil`                               |
| `postgresql.resources`                            | Assign resources, e.g. limits, for Postgres                                                      | `Memory limits`                     |
| `externalDatabase.host`                           | If an external database is used, this is the url of the database instance                        | `nil`                               |
| `externalDatabase.ssl`                            | Use ssl for connection                                                                           | `false`                             |
| `externalDatabase.sslVerify`                      | Use the provided certificate                                                                     | `false`                             |
| `externalDatabase.luaSslTrustedCertificate`       | Provide certificate                                                                              | `nil`                               |

# Deployment to Production

Default settings in this template are prepared for dev and test environments.

The database is used for storing ephemeral data (usually tokens with a lifespan of a few minutes). For production
environment however it should be considered whether the container based solution or rather a dedicated database should
be used.

Please note also, that the IDP is an important component of the security concept. For this reason, all communication
must be adequate encrypted and certificates should be properly verified.

[External-DNS]: https://github.com/kubernetes-sigs/external-dns

## Compatibility

| Environment | Compatible |
|-------------|------------|
| OTC         | Yes        |
| AWS EKS     | Yes        |

# Changes from Wildfly based Keycloak to Quarkus based

## Build time Configuration with Quarkus

Keycloak on Quarkus is using a two staged approach where the command `kc.sh build` creates the specific configuration
and `kc.sh start` runs the preconfigured Keycloak.
Because of this following settings are already set in Docker image of iris:

- Metrics enabled
- Health enabled
- Caching mode: Infinispan
- clustering detection kubernetes

These configurations can't be overridden in the chart.

## Prometheus / Metrics-SPI

The Metrics-SPI can be used as before in keycloak. It is added in the keycloak Docker image.

The Wildfly redirection from /auth/realms/master/metrics to /metric does not work anymore. This functionality is now
done within ha-proxy.
Ha-Proxy provides (in the chart default configuration) and frontend at port 9542 where requests that are send to the
path /metrics are forwarded to the metrics path of Keycloak.
All other requests to this port are blocked and result in an 503 http error.

The path /auth/realms/master/metrics is also blocked for port 8080 on Keycloak because it's not secured by any
authentication.

## JGroups

For detecting instances that should build a cache-cluster (formerly known as ha-mode) Quarkus uses the DNS_PING
functionality of JGroups. By providing a headless service (a service without ports) for the
Keycloak pods there is a Kubernetes internal dns address that allows JGroups to find all pod that shall form a cluster.
The DNS address which should be used is set with the environment variable `jgroups.dns.query` on the Keycloak container.

## Infinispan clustering

To configure the infinispan caches (mainly number of owners per cache) the file `eni-infinispan.xml` is mounted to the
Keycloak pod.
