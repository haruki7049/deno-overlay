#! /usr/bin/env nix-shell
#! nix-shell -i python3.11 -p python311 python311Packages.requests nix

import requests
import subprocess
import json


def get_all_releases(owner, repo):
    url = f"https://api.github.com/repos/{owner}/{repo}/releases"
    releases = []
    page = 1

    while True:
        response = requests.get(url, params={"page": page})
        if response.status_code == 200:
            releases_page = json.loads(response.text)
            if not releases_page:
                break  # ページが空の場合、ループを終了します。
            releases.extend(releases_page)
            page += 1
        else:
            print(f"Failed to fetch releases: {response.status_code} - {response.text}")
            break

    return releases


def save_to_json(json, filename):
    with open(filename, "w") as file:
        json.dump(json, file, indent=2)


def gen_json(sources_json: str):
    pass


#if __name__ == "__main__":
#    owner = "denoland"  # リポジトリの所有者のユーザー名または組織名
#    repo = "deno"  # リポジトリ名
#
#    releases = get_all_releases(owner, repo)
#    if releases:
#        save_to_json(releases, "sources.json")
#        print(f"Releases of {repo} saved to sources.json!!")
#
#result = subprocess.run(["nix-prefetch-url", "https://github.com/denoland/deno/releases/download/v1.42.0/deno-x86_64-unknown-linux-gnu.zip"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
#print(result.stdout)
