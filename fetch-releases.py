#! /usr/bin/env nix-shell
#! nix-shell -i python3.11 -p python311 python311Packages.requests nix

import requests
import subprocess
import json


def get_all_releases(owner: str, repo: str) -> list:
    """
    Get all releases of a repository

    Parameters
    ----------
    owner : str
        Owner of the repository
    repo : str
        Name of the repository

    Returns
    -------
    releases : list
        List of releases of the repository
    """
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


def save_to_json(json: dict, filename: str):
    """
    Save json to a file

    Parameters
    ----------
    json : dict
        JSON data which will be saved to a file
    filename : str
        File name to save the JSON data
    """
    with open(filename, "w") as file:
        json.dump(json, file, indent=2)


def gen_nix_hash(url: str) -> str:
    """
    Generate nix-hash from url by using nix-prefetch-url

    Parameters
    ----------
    url : str
        URL of the file to fetch

    Returns
    -------
    hash : str
        Nix hash of the file

    >>> gen_nix_hash("https://github.com/denoland/deno/releases/download/v1.42.0/deno-x86_64-unknown-linux-gnu.zip")
    0brv6v98jx2b2mwhx8wpv2sqr0zp2bfpiyv4ayziay0029rxldny
    """
    result = subprocess.run(["nix-prefetch-url", url], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result.stdout


#if __name__ == "__main__":
#    owner = "denoland"  # リポジトリの所有者のユーザー名または組織名
#    repo = "deno"  # リポジトリ名
#
#    releases = get_all_releases(owner, repo)
#    if releases:
#        save_to_json(releases, "sources.json")
#        print(f"Releases of {repo} saved to sources.json!!")
#
