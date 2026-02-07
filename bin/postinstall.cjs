#!/usr/bin/env node
/* eslint-disable no-console */
"use strict";

const fs = require("fs");
const path = require("path");
const os = require("os");

function ensureDir(p) {
  fs.mkdirSync(p, { recursive: true });
}

function linkOrCopy(src, dst) {
  try {
    if (fs.existsSync(dst)) fs.unlinkSync(dst);
    fs.symlinkSync(src, dst);
    fs.chmodSync(dst, 0o755);
  } catch {
    // Fallback (e.g., if symlinks are restricted)
    fs.copyFileSync(src, dst);
    fs.chmodSync(dst, 0o755);
  }
}

function main() {
  const pulumiHome = process.env.PULUMI_HOME || path.join(os.homedir(), ".pulumi");
  const pulumiBin = path.join(pulumiHome, "bin");

  const pkgRoot = path.resolve(__dirname, "..");
  const pluginName = "pulumi-resource-pulumi-components-demo";

  const pluginSrc = path.join(pkgRoot, "bin", pluginName);
  const pluginDst = path.join(pulumiBin, pluginName);

  ensureDir(pulumiBin);

  try { fs.chmodSync(pluginSrc, 0o755); } catch {}

  linkOrCopy(pluginSrc, pluginDst);

  console.log(`[pulumi-components-demo] installed ${pluginName} -> ${pluginDst}`);
}

main();
