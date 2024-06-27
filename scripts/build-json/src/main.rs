use clap::Parser;
use std::io::BufRead;
use serde_json::Value;
use std::io;
use std::process::Command;
use std::process::Stdio;
use serde::{Serialize, Deserialize};

fn main() {
    let args = CommandLineArgs::parse();
    let source_json: Value = to_json(read_file(args.path));

    let result: String = generate_json(source_json);
    println!("{}", result);
}

fn to_json(string: String) -> Value {
    serde_json::from_str(&string).expect("Failed to parse JSON")
}

fn read_file(path: String) -> String {
    std::fs::read_to_string(&path).expect("Failed to read file")
}

fn generate_json(context: Value) -> String {
    String::from("[]")
}

#[derive(Debug, Parser)]
struct CommandLineArgs {
    path: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct ReturnJson {
    deno: Vec<DenoVersion>,
}

#[derive(Debug, Serialize, Deserialize)]
struct DenoVersion {
    version: String,
    url: String,
    nix_hash: String,
}
