//  SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
//
//  SPDX-License-Identifier: Apache-2.0

export default {
    branches: ['main'],
    tagFormat: '${version}',
    repositoryUrl: 'git@github.com:telekom/identity-iris-keycloak-charts.git',
    plugins: [
        '@semantic-release/commit-analyzer',
        'semantic-release-export-data',
        '@semantic-release/release-notes-generator',
        '@semantic-release/changelog',
        '@semantic-release/github'
    ]
};