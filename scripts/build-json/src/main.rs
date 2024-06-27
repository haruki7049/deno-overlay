use clap::Parser;
use std::io::BufRead;
use serde_json::Value;
use std::io;
use std::process::Command;
use std::process::Stdio;

fn main() {
    let args = CommandLineArgs::parse();

    let context = read_file(args.path);
}

fn to_json(string: String) -> Value {
    serde_json::from_str(&string).unwrap()
}

fn read_file(path: String) -> String {
    std::fs::read_to_string(&path).unwrap()
}

#[derive(Debug, Parser)]
struct CommandLineArgs {
    path: String,
}
