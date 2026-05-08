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
const HASH_CONCURRENCY = 8;

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

function isX86_64LinuxLink(link: string): boolean {
  return link.includes("deno-x86_64-unknown-linux-gnu") &&
    !link.includes("sha256sum");
}

function filterX86_64LinuxLinks(urls: string[]): string[] {
  return urls.filter(isX86_64LinuxLink);
}

function genListOfVersions(releases: GitHubRelease[]): string[] {
  return releases.map((version) => version.tag_name);
}

async function genReleasesList(
  versions: string[],
  x86_64LinuxUrls: string[],
): Promise<SourceEntry[]> {
  const result: SourceEntry[] = [];
  const knownVersions = new Set(versions);
  console.log("Number of versions:", versions.length);

  for (
    let batchStartIndex = 0;
    batchStartIndex < x86_64LinuxUrls.length;
    batchStartIndex += HASH_CONCURRENCY
  ) {
    const batch = x86_64LinuxUrls.slice(
      batchStartIndex,
      batchStartIndex + HASH_CONCURRENCY,
    );
    const batchEntries = await Promise.all(
      batch.map(async (url): Promise<SourceEntry | null> => {
        const version = extractVersionFromUrl(url);
        if (!version) {
          console.warn(
            "Skipping URL because version could not be extracted:",
            url,
          );
          return null;
        }

        if (!knownVersions.has(version)) {
          console.warn(
            "Skipping URL because extracted version is unknown:",
            url,
          );
          return null;
        }

        console.log("Generating nix hash for", url);
        const sha256 = await genNixHash(url);
        return {
          version: version.replace("v", ""),
          url,
          arch: "x86_64-linux",
          sha256,
        };
      }),
    );
    result.push(
      ...batchEntries.filter((entry): entry is SourceEntry => entry !== null),
    );
  }

  return result;
}

async function main(): Promise<void> {
  const denoInfo = await getAllReleases(OWNER, REPO);
  const versions = genListOfVersions(denoInfo);
  const urls = genListOfDownloadLinks(denoInfo);
  const x86_64LinuxUrls = filterX86_64LinuxLinks(urls);
  const releasesList = await genReleasesList(versions, x86_64LinuxUrls);
  await saveToJson({ deno: releasesList }, DESTINATION);
  console.log("Done!");
}

if (import.meta.main) {
  await main();
}
