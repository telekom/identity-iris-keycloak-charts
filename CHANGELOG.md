**Table of contents**

[[_TOC_]]

## 1.7.0-RC.3
  - (remove when release) Removed memory for autoscaling
  - (remove when release) Scale down behaviour

## 1.7.0-RC2
  - Added possibility for horizontal pod autoscaling
  - InitContainer resources set

## 1.7.0-RC
  - Image pull policy toggle
  - Pull policy IfNotPresent as default
  - PodAntiAffinity for node distribution

## 1.6.0
 - Added TargetLabels to ServiceMonitor
 - Identity provider configuration option added (e.g. ADFS)
 - Default IDP option for automatic redirect on login
 - Enabled shared cache between iris pods which enables scaling 
 
## 1.5.1
 - Added ConfigMap for pipeline meta data

## 1.5.0
 - Add generic way to define realms with clients via Helm values
 - Added ServiceMonitor which is now enabled by default. PodMonitor is now disabled by default

## 1.4.1
 - No default realm deployment
 - Made podmonitor selector configurable
 - Made initialDelaySeconds, periodSeconds and failureThreshold configurable and set them to reasonable defaults

## 1.4.0
 - DHEI-2617: Added realm managment
 - Hotfix: Use "Recreate" strategy for database deployment

## 1.3.0
 - Fixed security issues by using Kubernetes secrets for (database) passphrases
 - Made CPU, RAM and persistence resources configurable
 - Made the securityContext configurable
 - Adjusted resource request and limit defaults
 - Support for environments that prohibit writing to the root file system (like CaaS)

## 1.2.0
 - Global ingress annotations setting
 - Global labels settings with a default fluentd label
 - Label deployments with chart version
 - DHEI-2398: External database encryption 
 - DHEI-2377: Configurable frontendUrl (or alt. "hostname" SPI configuration)

## 1.1.0
- DHEI-1138: Provide default metric for Keycloak towards Prometheus

## 1.0.0
- DHEI-1567: Rename subchart from "rhsso" to "keycloak"
- DHEI-1430: Custom annotations for rhsso ingress
- DHEI-1430: New URL creation aligned with TIF-Deployer standard

## 1.0.0_alpha3

This patch solves the issue #5 once again

- TLS secret options renamed and moved to the right place ("global.tls_secret: ..." ==> "tls.secret: ...)

## 1.0.0_alpha2

> Released 04.04.2020

This patch solves the issues #1, #2 and #5.

Issue #4 was rejected (works as expected).

### Changes

- default value for setting of `global.externalDnsTarget` added.
- the usage of `global.tls_secret:` corrected and settings `global.(internal|external).tls_secret` added
- there is an additional setting `keycloak.image.tag_openshift` for the keycloak image tag used on openshift. The default value is "9.0.0_openshift".
- in default configuration keycloak images are retrieved from [MTR repository tif-public](https://mtr.external.otc.telekomcloud.com/repository/tif-public/keycloak) with tag **stable**
- in default configuration postgress image is retrieved from [MTR repository tif-public](https://mtr.external.otc.telekomcloud.com/repository/tif-public/postgres) with tag **stable**
- ingress annotations corrected, as required for our AWS setup.
- command modified to copy the standalone-ha.xml file from config map to a sub-folder
- livenessProbe/redinessProbe and configmap checksums included
- internal changes: some generic templates renamed and moved to another file. 

## 1.0.0_alpha1

First testable release candidate of this chart.
