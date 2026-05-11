#!/usr/bin/env -S deno run --allow-net --allow-run --allow-write --allow-env

import { Logger } from "./logger.ts";

type GitHubReleaseAsset = {
  browser_download_url: string;
};

type GitHubRelease = {
  tag_name: string;
  assets: GitHubReleaseAsset[];
};

type SourceEntry = {
  version: string;
  url: string;
  arch: "x86_64-linux" | "aarch64-linux" | "aarch64-darwin";
  sha256: string;
};

const OWNER = "denoland";
const REPO = "deno";
const DESTINATION = "sources.json";

const RELEASE_VERSION_URL_PATTERN =
  /releases\/download\/(v\d+\.\d+\.\d+(?:-rc\d+)?)\/deno-/;

async function getAllReleases(
  owner: string,
  repo: string,
): Promise<GitHubRelease[]> {
  const releases: GitHubRelease[] = [];
  let page = 1;

  while (true) {
    const url =
      `https://api.github.com/repos/${owner}/${repo}/releases?page=${page}`;

    // Define headers
    const headers: HeadersInit = {};
    const token = Deno.env.get("GITHUB_TOKEN");

    // Add Authorization header if token exists
    if (token) {
      headers["Authorization"] = `Bearer ${token}`;
    }

    const response = await fetch(url, { headers });

    if (!response.ok) {
      const body = await response.text();
      throw new Error(`Failed to fetch releases: ${response.status} - ${body}`);
    }

    const releasesPage = (await response.json()) as GitHubRelease[];
    if (releasesPage.length === 0) {
      break;
    }

    releases.push(...releasesPage);
    page += 1;
  }

  return releases;
}

function saveToJson(
  sources: { deno: SourceEntry[] },
  destination: string,
): Promise<void> {
  return Deno.writeTextFile(destination, JSON.stringify(sources, null, 2));
}

async function genNixHash(url: string): Promise<string> {
  const command = new Deno.Command("nix-prefetch-url", {
    args: [url],
    stdout: "piped",
    stderr: "piped",
  });

  const { code, stdout, stderr } = await command.output();
  if (code !== 0) {
    const message = new TextDecoder().decode(stderr).trim();
    throw new Error(`Failed to generate nix hash for ${url}: ${message}`);
  }

  return new TextDecoder().decode(stdout).trim();
}

function extractVersionFromUrl(url: string): string | null {
  const releaseMatch = url.match(RELEASE_VERSION_URL_PATTERN);
  if (releaseMatch?.[1]) {
    return releaseMatch[1];
  }

  return null;
}

function genListOfDownloadLinks(releases: GitHubRelease[]): string[] {
  return releases.flatMap((version) =>
    version.assets.map((asset) => asset.browser_download_url)
  );
}

const SUPPORTED_ARCHITECTURES = [
  {
    releaseArtifact: "deno-x86_64-unknown-linux-gnu",
    nixArch: "x86_64-linux" as const,
  },
  {
    releaseArtifact: "deno-aarch64-unknown-linux-gnu",
    nixArch: "aarch64-linux" as const,
  },
  {
    releaseArtifact: "deno-aarch64-apple-darwin",
    nixArch: "aarch64-darwin" as const,
  },
];

function isSupportedReleaseLink(link: string): boolean {
  return SUPPORTED_ARCHITECTURES.some((architecture) =>
    link.includes(architecture.releaseArtifact)
  ) &&
    !link.includes("sha256sum") &&
    !link.includes(".bsdiff");
}

function filterSupportedReleaseLinks(urls: string[]): string[] {
  return urls.filter(isSupportedReleaseLink);
}

function getArchFromLink(link: string): SourceEntry["arch"] | null {
  const architecture = SUPPORTED_ARCHITECTURES.find((target) =>
    link.includes(target.releaseArtifact)
  );
  return architecture?.nixArch ?? null;
}

function genListOfVersions(releases: GitHubRelease[]): string[] {
  return releases.map((version) => version.tag_name);
}

async function sourceEntryfromUrl(
  url: string,
  knownVersions: Set<string>,
): Promise<SourceEntry | null> {
  const version = extractVersionFromUrl(url);
  if (!version) {
    Logger.debug(`The version could not be extracted: ${url}`);
    Logger.debug(`Skipping ${url} ...`);
    return null;
  }

  if (!knownVersions.has(version)) {
    throw Error(`The extracted version is unknown: ${url}`);
  }

  const arch = getArchFromLink(url);
  if (!arch) {
    throw Error(`The architecture could not be extracted: ${url}`);
  }

  Logger.debug(`Generating nix hash for: ${url}`);
  const sha256 = await genNixHash(url);
  return {
    version: version.replace("v", ""),
    url,
    arch,
    sha256,
  };
}

async function genReleasesList(
  versions: string[],
  releaseUrls: string[],
): Promise<SourceEntry[]> {
  const results: SourceEntry[] = [];
  const knownVersions = new Set(versions);
  Logger.debug(`Number of versions: ${knownVersions.size}`);

  for (const url of releaseUrls) {
    const sourceEntry = await sourceEntryfromUrl(url, knownVersions);
    if (sourceEntry !== null) {
      results.push(sourceEntry);
    }
  }

  return results;
}

async function main(): Promise<void> {
  const denoInfo = await getAllReleases(OWNER, REPO);
  const versions = genListOfVersions(denoInfo);
  const urls = genListOfDownloadLinks(denoInfo);
  const releaseUrls = filterSupportedReleaseLinks(urls);
  const releasesList = await genReleasesList(versions, releaseUrls);
  await saveToJson({ deno: releasesList }, DESTINATION);
  Logger.info("Done!");
}

if (import.meta.main) {
  await main();
}
