<!--
SPDX-FileCopyrightText: 2025 Deutsche Telekom AG

SPDX-License-Identifier: CC0-1.0    
-->

# Changelog

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

