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
        [
            '@semantic-release/changelog',
            {
                "changelogFile": 'CHANGELOG.md',
                "changelogTitle": `<!--
SPDX-FileCopyrightText: 2025 Deutsche Telekom AG

SPDX-License-Identifier: CC0-1.0    
-->`
            }
        ],
        [
            '@semantic-release/git',
            {
                "assets": ["CHANGELOG.md"],
                "message": "chore(release): ${nextRelease.version} [skip actions]\n\n${nextRelease.notes}"
            }
        ],
        '@semantic-release/github'
    ]
};