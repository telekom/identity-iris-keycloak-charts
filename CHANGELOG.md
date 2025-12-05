<!--
SPDX-FileCopyrightText: 2025 Deutsche Telekom AG

SPDX-License-Identifier: CC0-1.0    
-->

## [1.4.1](https://github.com/telekom/identity-iris-keycloak-charts/compare/1.4.0...1.4.1) (2025-12-05)


### Bug Fixes

* correct indentation of monitor resources ([481fba2](https://github.com/telekom/identity-iris-keycloak-charts/commit/481fba2f08423cd28a0447f3f2578cdfb655cdf3))
* install helm plugin for release workflow ([ad13b9f](https://github.com/telekom/identity-iris-keycloak-charts/commit/ad13b9f213883dc79f66d2afbbd37df960cab289))

# [1.4.0](https://github.com/telekom/identity-iris-keycloak-charts/compare/1.3.1...1.4.0) (2025-11-28)


### Bug Fixes

* handle imagePullSecrets consitently ([#37](https://github.com/telekom/identity-iris-keycloak-charts/issues/37)) ([744a708](https://github.com/telekom/identity-iris-keycloak-charts/commit/744a7080f9f88d1fef8c3600b071a3ebf4ae9286))


### Features

* added metricRelabelings for monitoring resources ([#40](https://github.com/telekom/identity-iris-keycloak-charts/issues/40)) ([f35cf51](https://github.com/telekom/identity-iris-keycloak-charts/commit/f35cf51275d51f6fa4d90a283331548fda8ba4e7))
* support for builtin metrics ([#41](https://github.com/telekom/identity-iris-keycloak-charts/issues/41)) ([880c52b](https://github.com/telekom/identity-iris-keycloak-charts/commit/880c52becb60890ef5e55c771af1f0068cb3e5cb))
* update iris keycloak image to 1.1.3 ([#44](https://github.com/telekom/identity-iris-keycloak-charts/issues/44)) ([483f26f](https://github.com/telekom/identity-iris-keycloak-charts/commit/483f26f5fa9d1c3a7e2f3a0bb2cec86a797a5e6b))
* use postgres image instead of bitnami ([#36](https://github.com/telekom/identity-iris-keycloak-charts/issues/36)) ([cc5daf2](https://github.com/telekom/identity-iris-keycloak-charts/commit/cc5daf276e57b9345e866218880702a1d5ba089b))

## [1.3.1]
### Fixed
- Proper handling and documentation of the ssl mode of the db connection string
- Use release name for KEDA resource

## [1.3.0]
### Changed
- Autoscaling support based on KEDA instead of HPA

## [1.2.12]
### Fixed
- Specified global label values as objects in schemas

## [1.2.11]
### Fixed
- Add `PGPORT` env variable to make it configurable dynamically and check db init container
- Harmonize chart image tags with the corresponding repository of Iris images (from dash-based to dot-based names)

## [1.2.10]
### Fixed
- Make health endpoints routing backward compatible with images version <= 1.1.1

## [1.2.9]
### Fixed
- Fixed ports in probe config
- Updated probe values to be yaml instead of string

## [1.2.8]
### Fixed
- Route health endpoints to Keycloak management port (9000) via haproxy

## [1.2.7]
### Fixed
- Corrected `startup`, `readiness`, and `liveness` probe paths in `values.yaml` to match actual Keycloak health check endpoints.

## [1.2.6]
### Fixed
- Updated `values.yaml` to use a fixed Docker image tag for Keycloak instead of `latest`, improving reproducibility and clarity.

## [1.2.5]
### Refactored
- Replaced deprecated `JDBC_PARAMS` with `KC_DB_URL_PROPERTIES` for Keycloak external database SSL configuration

## [1.2.4]
### Refactored
- Removed platform-specific values files, refactored template configuration

## [1.2.3]
### Fixed
- Resolved issue with `401 Unauthorized` errors when running multiple Keycloak replicas:
    - Added `--cache-stack=kubernetes` to support JGroups-based Infinispan discovery in Kubernetes.

## [1.2.2]
### Changed
- Refactored Ingress TLS configuration to support flexible hostname management:
    - Introduced `ingress.tls.enabled`, `ingress.tls.hosts`, and `ingress.tls.secret` fields in `values.yaml`.
    - Deprecated `ingress.tlsSecret` in favor of `ingress.tls.secret`.
    - Updated templates to reflect new structure for improved flexibility and consistency.

## [1.2.1]
### Changed
- Updated deprecated environment variable `KEYCLOAK_ADMIN` to `KC_BOOTSTRAP_ADMIN_USERNAME`.
- Updated deprecated environment variable `KEYCLOAK_ADMIN_PASSWORD` to `KC_BOOTSTRAP_ADMIN_PASSWORD`.

## [1.2.0]
### Added
- Configuration for **HorizontalPodAutoscaler**.
- Support for **realm import** configuration.
- Generalized cache configuration for better flexibility.
- **Prometheus** support enhancements.
- Added common labels to the **PostgreSQL** template.
- Support for **AVP annotations** in templates.

### Changed
- Cleaned up redundant values in `values.yaml`, improved structure, and added comments.
- Updated **image definition** to reflect new best practices.

### Fixed
- Validated `apiVersion` in rendered templates to prevent compatibility issues.

### Removed
- Removed truststore-related functionality (not relevant for M2M authentication).

## [1.1.0]
### Added
- SecurityContext option to each container's template.

### Changed
- Updated password for PostgreSQL.
- Standardized Infinispan configuration.
- Enhanced Keycloak environment variables for compatibility with version 26.0.8.

### Fixed
- Corrected `check-database` init container image value reference.

### Removed
- Deprecated import of H2M realms (functionality was incomplete and not relevant).
- Removed AWS-specific `storageClassName` from general templates.

## [1.0.0] - Init
