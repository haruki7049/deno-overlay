#!/usr/bin/env -S deno run --allow-net --allow-run --allow-write

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
  arch: "x86_64-linux";
  sha256: string;
};

const OWNER = "denoland";
const REPO = "deno";
const DESTINATION = "sources.json";

const VERSION_URL_PATTERN = /releases\/download\/(v\d+\.\d+\.\d+)\/deno-/;
const RC_VERSION_URL_PATTERN = /releases\/download\/(v\d+\.\d+\.\d+-rc\d+)\/deno-/;

async function getAllReleases(owner: string, repo: string): Promise<GitHubRelease[]> {
  const releases: GitHubRelease[] = [];
  let page = 1;

  while (true) {
    const url = `https://api.github.com/repos/${owner}/${repo}/releases?page=${page}`;
    const response = await fetch(url);

    if (!response.ok) {
      const body = await response.text();
      console.error(`Failed to fetch releases: ${response.status} - ${body}`);
      break;
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

function saveToJson(sources: { deno: SourceEntry[] }, destination: string): Promise<void> {
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

function genListOfDownloadLinks(sources: GitHubRelease[]): string[] {
  return sources.flatMap((version) => version.assets.map((asset) => asset.browser_download_url));
}

function isX86_64LinuxLink(link: string): boolean {
  return link.includes("deno-x86_64-unknown-linux-gnu") && !link.includes("sha256sum");
}

function filterX86_64LinuxLink(urls: string[]): string[] {
  return urls.filter(isX86_64LinuxLink);
}

function genListOfVersions(sources: GitHubRelease[]): string[] {
  return sources.map((version) => version.tag_name);
}

function isCorrectVersionUrl(version: string, url: string): boolean {
  const match = url.match(VERSION_URL_PATTERN);
  return match?.[1] === version;
}

function isCorrectRcVersionUrl(version: string, url: string): boolean {
  const match = url.match(RC_VERSION_URL_PATTERN);
  return match?.[1] === version;
}

async function genReleasesList(versions: string[], x86_64LinuxUrls: string[]): Promise<SourceEntry[]> {
  const result: SourceEntry[] = [];
  console.log("Number of versions:", versions.length);

  for (const url of x86_64LinuxUrls) {
    for (const version of versions) {
      if (isCorrectVersionUrl(version, url) || isCorrectRcVersionUrl(version, url)) {
        console.log("Generating nix hash for", url);
        const sha256 = await genNixHash(url);
        result.push({
          version: version.replace("v", ""),
          url,
          arch: "x86_64-linux",
          sha256,
        });
      }
    }
  }

  return result;
}

async function main(): Promise<void> {
  const denoInfo = await getAllReleases(OWNER, REPO);
  const versions = genListOfVersions(denoInfo);
  const urls = genListOfDownloadLinks(denoInfo);
  const x86_64LinuxUrls = filterX86_64LinuxLink(urls);
  const releasesList = await genReleasesList(versions, x86_64LinuxUrls);
  await saveToJson({ deno: releasesList }, DESTINATION);
  console.log("Done!");
}

if (import.meta.main) {
  await main();
}
