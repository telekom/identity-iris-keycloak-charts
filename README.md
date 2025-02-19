<!--
SPDX-FileCopyrightText: 2025 Deutsche Telekom AG

SPDX-License-Identifier: CC0-1.0    
-->

# Iris Keycloak Charts

## Overview

This chart installs [Keycloak](https://www.keycloak.org/documentation.html). \
It is suitable for installations on AWS EKS. Recommended to use with customized keycloak docker \
image (see the links section). \
Default settings in this template are prepared for non-prod environments.

## Version

| Installed software versions | Version Info |    
|-----------------------------|--------------|
| Keycloak                    | 26.0.8       |
| java                        | 17.0.9       |
| PostgreSQL                  | 12.3         |

## Description

**Important links:**

- Keycloak
  - [Keycloak documentation](https://www.keycloak.org/docs/latest/release_notes/index.html#keycloak-26-0-0)
    - [Docker image documentation](https://hub.docker.com/r/jboss/keycloak/)
    - [GitHub repository](https://github.com/keycloak/keycloak)
    - [Iris keycloak image (IKI)](https://github.com/telekom/iris-image)
- PostgreSQL
    - [Docker image documentation](https://hub.docker.com/_/postgres)

## Configuration

### Platform

You can select a platform to use predefined settings specifically dedicated to the platform. \
Note that you can overwrite platform specific values in the values.yaml. \
To add a new platform specific values.yaml, add the required values as `platformName.yaml` to the `platforms` folder.

**Note:** Assigning platform-specific values to the sub-chart through the platform-specific `platformName.yaml` \
of your main chart will not be effective, as the sub-chart's platform settings take precedence.

### Configuration Files

Keycloak infinispan caches (mainly number of owners per cache) is configured in the `infinispan.xml` file. \
At start, this file is copied to the proper location and used as a configuration file. \
To configure the is mounted to the Keycloak pod.

### Database

To modify the behavior of database deployment, you can adjust the value of `database.location` to switch between "local"
and "external". When set to "local", the deployment will utilize the PostgreSQL chart located within the charts
directory to store Keycloak data. Conversely, if set to "external", you must include the `externalDatabase.host`
parameter, directing it towards the designated database. Additionally, you need to provide the essential user data and
database schema within the database field in the values.yaml file, enabling Keycloak to establish a connection.

## Build time Configuration with Quarkus

Keycloak on Quarkus is using a two staged approach where the command `kc.sh build` creates the specific configuration
and `kc.sh start` runs the preconfigured Keycloak. \
Because of this following settings are already set in [IKI](https://github.com/telekom/iris-image):

- Metrics enabled
- Health enabled
- Caching mode: Infinispan
- clustering detection: kubernetes

These configurations can't be overridden in the chart.

## Prometheus / Metrics-SPI

The Metrics-SPI can be used as before in keycloak. It is added in IKI.

The Wildfly redirection from /auth/realms/master/metrics to /metric does not work anymore. This functionality is now
done within ha-proxy.
Ha-Proxy provides (in the chart default configuration) and frontend at port 9542 where requests that are send to the
path /metrics are forwarded to the metrics path of Keycloak.
All other requests to this port are blocked and result in an 503 http error.

The path /auth/realms/master/metrics is also blocked for port 8080 on Keycloak because it's not secured by any
authentication.

## Local launch with Kind, Docker and Helm

1. Setup all the required tools: Docker, Kind and Helm \
2. Use CKI and pull it to your machine (see the useful links).
3. Add to the Kind images using `kind load docker-image` command  to add also ha-proxy and postgres images
4. Archive the chart using command `tar cfvz <archive-name>.tgz <chart-folder>`
5. use helm install with providing values.yaml files for postgres and custom keycloak charts \
   e.g. `helm install <chart-name> <archive-name.tgz> --values .\<iris_keycloak_chart_folder>\values.yaml --values .\<iris_keycloak_chart_folder>\charts\postgresql\values.yaml`

## Code of Conduct

This project has adopted the [Contributor Covenant](https://www.contributor-covenant.org/) in version 2.1 as our code of conduct. Please see the details in our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). All contributors must abide by the code of conduct.

By participating in this project, you agree to abide by its [Code of Conduct](./CODE_OF_CONDUCT.md) at all times.

## Licensing

This project follows the [REUSE standard for software licensing](https://reuse.software/).
Each file contains copyright and license information, and license texts can be found in the [./LICENSES](./LICENSES) folder. For more information visit https://reuse.software/.

### REUSE

The [reuse tool](https://github.com/fsfe/reuse-tool) can be used to verify and establish compliance when new files are added. 

For more information on the reuse tool visit https://github.com/fsfe/reuse-tool.

**Check for incompliant files (= not properly licensed)**

Run `pipx run reuse lint`

**Get an SPDX file with all licensing information for this project (not for dependencies!)**

Run `pipx run reuse spdx`

**Add licensing and copyright statements to a new file**

Run `pipx run reuse annotate -c="<COPYRIGHT>" -l="<LICENSE-SPDX-IDENTIFIER>" <file>`

Replace `<COPYRIGHT>` with the copyright holder, e.g "Deutsche Telekom AG", and `<LICENSE-SPDX-IDENTIFIER>` with the ID of the license the file should be under. For possible IDs see https://spdx.org/licenses/.

**Add a new license text**

Run `pipx run reuse download --all` to add license texts for all licenses detected in the project.