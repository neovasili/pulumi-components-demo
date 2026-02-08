import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

const version = process.argv[2];
if (!version) {
  console.error("Usage: node scripts/prepare-release.mjs <version>");
  process.exit(1);
}

const repoRoot = process.cwd();

function updateJson(filePath, update) {
  const raw = fs.readFileSync(filePath, "utf8");
  const data = JSON.parse(raw);
  update(data);
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + "\n");
}

function updateYamlVersion(filePath, nextVersion) {
  const raw = fs.readFileSync(filePath, "utf8");
  const updated = raw.replace(
    /^version:\s*.*$/m,
    `version: ${nextVersion}`,
  );
  if (raw === updated) {
    throw new Error(`Failed to update version in ${filePath}`);
  }
  fs.writeFileSync(filePath, updated);
}

updateJson(path.join(repoRoot, "package.json"), (data) => {
  data.version = version;
});

updateJson(
  path.join(repoRoot, "components", "azure-storage", "package.json"),
  (data) => {
    data.version = version;
  },
);

updateYamlVersion(path.join(repoRoot, "PulumiPlugin.yaml"), version);

execFileSync("pnpm", ["gen"], { stdio: "inherit" });
execFileSync("bash", ["scripts/build_plugin_tarballs.sh"], { stdio: "inherit" });
