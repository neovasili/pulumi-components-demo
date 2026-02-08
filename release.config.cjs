module.exports = {
  branches: ["main"],
  plugins: [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    ["@semantic-release/changelog", { changelogFile: "CHANGELOG.md" }],
    [
      "@semantic-release/exec",
      {
        prepareCmd: "node scripts/prepare-release.mjs ${nextRelease.version}",
        publishCmd:
          "cd sdk/nodejs && npm publish --provenance --access public --tag ${nextRelease.channel || 'latest'}",
      },
    ],
    [
      "@semantic-release/git",
      {
        assets: [
          "CHANGELOG.md",
          "package.json",
          "PulumiPlugin.yaml",
          "schema/schema.json",
          "dist/**",
          "sdk/**",
          "components/**",
          "pnpm-lock.yaml",
        ],
        message:
          "chore(release): ${nextRelease.version}\n\n${nextRelease.notes}",
      },
    ],
    [
      "@semantic-release/github",
      {
        failComment: false,
        labels: false,
        assets: ["release-artifacts/*.tar.gz"],
      },
    ],
  ],
};
