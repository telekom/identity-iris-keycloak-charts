<!--
SPDX-FileCopyrightText: 2025 Deutsche Telekom AG

SPDX-License-Identifier: CC0-1.0    
-->

# Changelog

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

