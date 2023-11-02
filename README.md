# Overview

This chart installs [Keycloak](https://www.keycloak.org/documentation.html). \
It is suitable for installations on OTC and AWS EKS. Recommended to use with customized keycloak docker image.

# Details

## License

Neither Keycloak nor Postgres require a license. All images uses are copies of public images from docker-hub.  
Custom Keycloak image has been extended to integrate with logging solutions such as Prometheus.

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

## Configuration

### Platform

You can select a platform to use predefined settings (e.g. securityContext) specifically dedicated to the
platform. \
Note that you can overwrite platform specific values in the values.yaml. \
To add a new platform specific values.yaml, add the required values as `platformName.yaml` to the `platforms` folder.

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
Because of this following settings are already set in Docker image of custom_keycloak:

[//]: # (TODO PROVIDE LINK TO GITHUB REPO)
- Metrics enabled
- Health enabled
- Caching mode: Infinispan
- clustering detection: kubernetes

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

To configure the infinispan caches (mainly number of owners per cache) the file `infinispan.xml` is mounted to the
Keycloak pod.
