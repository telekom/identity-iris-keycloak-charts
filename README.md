<!--
SPDX-FileCopyrightText: 2025 Deutsche Telekom AG

SPDX-License-Identifier: CC0-1.0
-->

# Iris Keycloak Charts

## Overview

This chart installs [Keycloak](https://www.keycloak.org/documentation.html).
Recommended to use with customized keycloak docker
identity-iris-keycloak image version >= 1.1.2 (see [Important links](#description)).
Default settings in this template are prepared for non-prod environments.

## Version

| Installed software versions | Version Info |
|-----------------------------|--------------|
| Keycloak                    | 26.7.2       |
| PostgreSQL                  | 18.6         |

## Description

**Important links:**

- Keycloak
    - [Keycloak documentation](https://www.keycloak.org/docs/latest/release_notes/index.html#keycloak-26-7-2)
    - [Docker image (Quay.io)](https://quay.io/repository/keycloak/keycloak)
    - [GitHub repository](https://github.com/keycloak/keycloak)
    - [Iris keycloak image (IKI)](https://github.com/telekom/identity-iris-keycloak-image)
- PostgreSQL
    - [Docker image documentation](https://hub.docker.com/_/postgres)

## Configuration

We prefer configuration over environment variables, which can be defined in `values.yaml` under `.keycloakExtraEnvVars`.

### Database

To modify the behavior of database deployment, you can adjust the value of `postgresql.enabled` to switch between `true`
and `false`. When set to `true`, the deployment will utilize the PostgreSQL chart located within the charts
directory to store Keycloak data. Conversely, if set to `false`, you must include the `externalDatabase.host`
parameter, directing it towards the designated database. Additionally, you need to provide the essential user data and
database schema within the database field in the values.yaml file, enabling Keycloak to establish a connection.

## Build time Configuration with Quarkus

Keycloak on Quarkus is using a two staged approach where the command `kc.sh build` creates the specific configuration
and `kc.sh start` runs the preconfigured Keycloak.
Because of this, the following settings are already set in [IKI](https://github.com/telekom/identity-iris-keycloak-image):

- Metrics enabled
- Health enabled
- Caching mode: Infinispan
- Clustering detection: ispn

These configurations can't be overridden in the chart.

## Metrics

This chart uses Keycloak's built-in metrics. For configuration details, see the
[Keycloak metrics documentation](https://www.keycloak.org/observability/configuration-metrics).

## Local launch with Kind, Docker and Helm

1. Setup all the required tools: Docker, Kind and Helm.
1. Use CKI and pull it to your machine (see the useful links).
1. Add to the Kind images using `kind load docker-image` command to add also postgres images.
1. Archive the chart using command `tar cfvz <archive-name>.tgz <chart-folder>`.
1. Use helm install with providing values.yaml files for postgres and custom keycloak charts,
    e.g. `helm install <chart-name> <archive-name.tgz> --values ./<iris_keycloak_chart_folder>/values.yaml --values ./<iris_keycloak_chart_folder>/charts/postgresql/values.yaml`

## Code of Conduct

This project has adopted the [Contributor Covenant](https://www.contributor-covenant.org/) in version 2.1 as our code of conduct. Please see the details in our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). All contributors must abide by the code of conduct.

By participating in this project, you agree to abide by its [Code of Conduct](./CODE_OF_CONDUCT.md) at all times.

## Licensing

This project follows the [REUSE standard for software licensing](https://reuse.software/).
Each file contains copyright and license information, and license texts can be found in the [./LICENSES](./LICENSES) folder. For more information visit [reuse.software](https://reuse.software/).

## Conventional Commits

This project enforces [Conventional Commits](https://www.conventionalcommits.org/) for all commits.
**All commit messages must follow the Conventional Commits specification.**
This is automatically checked in CI for both pushes and pull requests.

## Upgrade to Helm chart to 4.0.0

The release upgrades PostgreSQL from version 17 to version 18.
If you are using a deployment with `postgresql.enabled: true` that
uses the PostgreSQL instance deployed by this Helm chart, you must
migrate the database before deploying the new chart version.
This migration requires system downtime. Deployments that use an
external database are not affected.

### Migration Approach

The recommended migration strategy is based on a backup and restore process. Please note that this procedure requires system downtime.

The steps outlined below serve as a general guideline. Depending on your environment, tooling, and deployment specifics, certain steps may vary slightly.

### Migration Steps

1. Scale down Iris Keycloak to 0 replicas.
1. Create a backup of the Keycloak database using `pg_dump`.
1. Scale down PostgreSQL to 0 replicas.
1. Delete the existing PostgreSQL Persistent Volume Claim (PVC).
1. Provision a new PostgreSQL PVC.
1. Configure PostgreSQL to use the newly created PVC.
1. Upgrade the Helm chart to deploy the updated versions of Keycloak and PostgreSQL.

    > Note: Ensure that Keycloak remains scaled to 0 replicas during this step.

1. Wait for the PostgreSQL instance to complete its initialization.
1. Restore the database backup.
1. Scale Iris Keycloak back up to the desired number of replicas.
1. Verify that the system is functioning as expected.

## REUSE

The [reuse tool](https://github.com/fsfe/reuse-tool) can be used to verify and establish compliance when new files are added.

For more information on the reuse tool visit the [reuse-tool repository](https://github.com/fsfe/reuse-tool).

**Check for incompliant files (= not properly licensed)**

Run `pipx run reuse lint`

**Get an SPDX file with all licensing information for this project (not for dependencies!)**

Run `pipx run reuse spdx`

**Add licensing and copyright statements to a new file**

Run `pipx run reuse annotate -c="<COPYRIGHT>" -l="<LICENSE-SPDX-IDENTIFIER>" <file>`

Replace `<COPYRIGHT>` with the copyright holder, e.g "Deutsche Telekom AG", and `<LICENSE-SPDX-IDENTIFIER>` with the ID of the license the file should be under. For possible IDs see the [SPDX License List](https://spdx.org/licenses/).

**Add a new license text**

Run `pipx run reuse download --all` to add license texts for all licenses detected in the project.
