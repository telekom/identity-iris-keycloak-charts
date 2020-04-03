# Table of Contents

- [1.0.0_alpha2](#100_alpha2)
- [1.0.0_alpha1 and prior](#100_alpha1)

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
