#!/usr/bin/env -S deno run --allow-read --allow-write

type SourceEntry = {
  version: string;
};

type Sources = Record<string, SourceEntry[]>;

const README_HEADER = `# deno-overlay

A Deno overlay for Nix package manager.

## Usage

\`\`\`nix
let
  deno_overlay = import (fetchTarball https://github.com/haruki7049/deno-overlay/archive/7a6d6faa0f3bbc4aafb6ee7306a88e800f4dc5d8.tar.gz);
  pkgs = import <nixpkgs> {
    overlays = [
      deno_overlay
    ];
  };
  denoVersion = "1.42.0";
in
pkgs.mkShell {
  packages = with pkgs; [
    deno.\${denoVersion}
  ];
}
\`\`\`

## Architectures

- x86_64-linux

## A list of versions this overlay can support
`;

function getVersions(sources: Sources): string[] {
  return Object.values(sources).flatMap((entries) =>
    entries.map((entry) => entry.version)
  );
}

async function main(): Promise<void> {
  const rawSources = await Deno.readTextFile("sources.json");
  const sources = JSON.parse(rawSources) as Sources;
  const versions = getVersions(sources);
  const versionsText = versions.map((version) => `- ${version}`).join("\n");

  await Deno.writeTextFile("README.md", `${README_HEADER}\n${versionsText}\n`);
}

if (import.meta.main) {
  await main();
}
