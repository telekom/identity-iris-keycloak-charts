# Table of Contents

- [Table of Contents](#table-of-contents)
  - [[0.0.0]](#000)
    - [Changes](#changes)
  - [[1.0.0_alpha3]](#100alpha3)
    - [Changes](#changes-1)
  - [[1.0.0_alpha2]](#100alpha2)
    - [Changes](#changes-2)
  - [[1.0.0_alpha1]](#100alpha1)

## [0.0.0]

### Changes

- DHEI-1430: Custom annotations for rhsso ingress
- DHEI-1430: New URL creation aligend with TIF-Deployer standard

## [1.0.0_alpha3]

This patch solves the issue #5 once again

### Changes

- TLS secret options renamed and moved to the right place ("global.tls_secret: ..." ==> "tls.secret: ...)

## [1.0.0_alpha2]

> Released 04.04.2020

This patch solves the issues #1, #2 and #5.

Issue #4 was rejected (works as expected).

### Changes

- default value for setting of `global.externalDnsTarget` added.
- the usage of `global.tls_secret:` corrected and settings `global.(internal|external).tls_secret` added
- there is an additional setting `rhsso.image.tag_openshift` for the keycloak image tag used on openshift. The default value is "9.0.0_openshift".
- in default configuration keycloak images are retrieved from [MTR repository tif-public](https://mtr.external.otc.telekomcloud.com/repository/tif-public/keycloak) with tag **stable**
- in default configuration postgress image is retrieved from [MTR repository tif-public](https://mtr.external.otc.telekomcloud.com/repository/tif-public/postgres) with tag **stable**
- ingress annotations corrected, as required for our AWS setup.
- command modified to copy the standalone-ha.xml file from config map to a sub-folder
- livenessProbe/redinessProbe and configmap checksums included
- internal changes: some generic templates renamed and moved to another file. 

## [1.0.0_alpha1]

First testable release candidate of this chart.
