# keycloak charts

This charts installs Keycloak version 9.0 without backward compatibility to Giga RHSSO 7.3 setup.

It is suitable for installations on plain kubernetes (eg. AWS EKS) where RedHat-support is not available.
For OpenShift environments (eg. AppAgile) the chart "rhsso-broker" should be preferred.

> Note: for compatibility reasons some variables and settings are called "rhsso" or "sso" in both packages.
