use serde::Deserialize;
use serde_json::from_reader;
use clap::Parser;
use std::fs::File;
use std::io::BufReader;

const README_BASE: &str = "# deno-overlay

A Deno overlay for Nix package manager.

# Usage

```nix
let
  deno_overlay = import (fetchTarball https://github.com/haruki7049/deno-overlay/archive/7a6d6faa0f3bbc4aafb6ee7306a88e800f4dc5d8.tar.gz);
  pkgs = import <nixpkgs> {
    overlays = [
      deno_overlay
    ];
  };
  denoVersion = \"1.42.0\";
in
pkgs.mkShell {
  packages = with pkgs; [
    deno.${denoVersion}
  ];
}
```

## Architectures

- x86_64-linux

## A list of versions this overlay can support
";

#[derive(Deserialize, Debug)]
struct Sources {
  deno: Vec<Release>,
}

#[derive(Deserialize, Debug)]
struct Archs {
    x86_64_linux: Vec<Release>,
    aarch64_linux: Vec<Release>,
}

#[derive(Deserialize, Debug)]
struct Release {
    version: String,
    url: String,
    sha256: String,
    arch: String,
}

#[derive(Parser)]
struct CLIArgs {
    /// JSON Data which contains GitHub Releases' information.
    filepath: String,
}

fn main() {
    let args: CLIArgs = CLIArgs::parse();

    let file: Result<File, std::io::Error> = File::open(args.filepath);
    let file: File = match file {
        Ok(o) => o,
        Err(e) => {
            panic!("FATAL ERROR: {}", e);
        },
    };

    let reader: BufReader<File> = BufReader::new(file);

    let sources: Result<Sources, serde_json::Error> = from_reader::<BufReader<File>, Sources>(reader);
    let sources = match sources {
        Ok(o) => o,
        Err(e) => {
            panic!("JSON PARSE ERROR: {}", e);
        },
    };

    let releases: Vec<Release> = sources.deno;
    let versions_list: Vec<String> = releases.iter().map(|value| value.version.clone()).collect();
    let versions: String = {
        let mut result: String = String::new();
        for version in versions_list.iter() {
            result.push_str(&(format!("{}\n", version)));
        };

        result
    };

    println!("{}\n{}", README_BASE, versions);
}
